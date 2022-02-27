; Martian Attack - JagCode2007 entry
;
; TODO note: Can't put score at the top of the screen because 68k fighting OP fighting GPU is
; resulting in too much bus traffic, score ends up tilted down. Could we move 68k processing 
; after the big scaled earth?
; Need to check how much time the 68k needs for game logic (apparently it's more than the
; vblank already)... then we can probably put score back at the top of the screen.

.if 0
; Fragment code to generate a 32-bit randomish number in d1
		move.l	rndseed,d1
		lsr.l	#1,d1
		bcc		.rndclr
		eori.l	#$a3000000,d1
.rndclr:
		move.l	d1,rndseed
;
.endif

		.include	"jaguar.inc"
		.include	"mou.inc"
 
; Globals
		.globl		a_vdb
		.globl		a_vde
		.globl		a_hdb
		.globl		a_hde
		.globl		width
		.globl		height
		.globl		earth_frame
		.globl		earthleft
		.globl		base_frame
		.globl		earth_scale
		.globl		base_y
		.globl		base_bright
		.globl		earth_bright
		.globl		enemy_table
		.globl		enemy_shot
		.globl		paused
		.globl		cross_x
		.globl		cross_y
		.globl		screenbuf

; Externals
		.extern		main_obj_list1
		.extern		main_obj_list2
		.extern		initlister
		.extern		UpdateList
		.extern		FirstGPU
		.extern		StartGPU
		.extern		LastGPU
		.extern		RAMGPUAddress
		.extern		starinit
		.extern		DSPSTART
		.extern		DSPEND
		.extern		DSP_START
		.extern		DCTRLTAB


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Program Entry Point Follows...

; NOCLEAR throws warnings when you use clr.l (memory) - this doesn't work
; real well on the Jag (sort of like the GPU main memory bugs, kind of
; hard to pin down exactly why it fails sometimes). machine works a lot
; better when you don't do that. ;)
		.NOCLEAR

		.text

.Entry:
		move.l	#$00070007,G_END	; big-endian mode
		move.w	#$FFFF,VI			; disable video interrupts

		move.l	#INITSTACK,a7		; Setup a stack
			
; Copy over the GPU program
		move.l	#RAMGPUAddress,a0	; Get the address of the GPU code in main memory
		move.l	#FirstGPU,a1		; Get destination address
		move.l	#LastGPU,d0			; and calculate length of GPU code
		sub.l	#FirstGPU,d0
		asr.l	#2,d0				; divide by 4 since we're copying longs
.loop:
		move.l	(a0)+,(a1)+	; actually copy the code...
		dbra	d0,.loop
 
; Now copy over the DSP program (pretty much the same deal)
		move.l	#DSPSTART,a0
		move.l	#D_RAM,a1
		move.l	#DSPEND,d0
		sub.l	#DSPSTART,d0
		asr.l	#2,d0
.translop:
		move.l	(a0)+,(a1)+
		dbra	d0,.translop

; Make sure the DACs are silent!
		moveq	#0,d0 
		move.l	d0,DAC1
		move.l	d0,DAC2

; And clear our tone controls
		move.l	#A01,DCTRLTAB		; voice 1
		move.l	#0,DCTRLTAB+4		; voice 1 volume

; Set up the I2S mode and clock (the serial registers tweak sound? well, the JOYSTICK has the mute bit, why not?)
;		move.l	#19,SCLK		; CLK = SystemClock / (2 * (SCLK+1)) 
		; We just make a simple noise generator for this pass, low freq needed
		move.l	#149,SCLK		; CLK = SystemClock / (2 * (SCLK+1)) 
		move.l	#$15,SMODE		; enable clock, enable word strobes, enable falling edge interrupt 

; (TODO: Jag docs says to smoothly decrement from 0x8000 to 0 to avoid click, AFTER setting the clock)
; Might need to change the initial write value, too.

; Joystick read will turn on the sound bit if it's off

Startup:
; Init system
		jsr	.preparegame			; set up game variables

		jsr	.InitVideo				; Setup our video registers.
		
		lea	main_obj_list1,a0
		jsr	initlister				; Initialize Object Display List1
;		lea	main_obj_list2,a0
;		jsr	initlister				; Initialize Object Display List2

		jsr	.InitVBint				; Initialize our VBLANK routine

; Finish the system init
; Now get a swapped list pointer in d0 (skipping initial stop)
		move.l	#main_obj_list1+16,d0  
		swap    d0
		move.l	d0,OLP				; Load into OP list pointer
		move.w	#$8C1,VMODE			; Configure Video (Enable, 16b CRY, CSync, BGen, 5 clks/pix) 320 pix 

; clear the BG register
		moveq #0,d0
		move.w d0,BG

; set up music list
		move.l	#twinkle,twinklepos
		move.l	#1,musiccnt

		bsr	.preparegame

		move.l	#0,cheat

		lea gameovertxt,a0
		; copy text into center line
		lea screenbuf,a1
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+	

; start the DSP program
		moveq	#0,d0
		move.l  d0,D_FLAGS			; Disable all DSP interrupts 
		move.l	#DSP_START,D_PC	
		moveq	#1,d0
		move.l	d0,D_CTRL

; start the GPU program
		moveq	#0,d0
		move.l  d0,G_FLAGS			; Disable all GPU interrupts (GPU will enable them)
		move.l	#StartGPU,G_PC		; GPU Program counter to first address
		moveq	#1,d0
		move.l	d0,G_CTRL			; Set the GPU going

.forevr:	stop #$2000			; go to sleep, allow ints to wake us

.if DEBUGBG
	move.w	#$80ff,BG
.endif

		; we woke up - rendered a frame, now let's calculate the next one (main game code)
		; First, check if we are paused, and if we are, just past everything to the joystick code
		;move.l	paused,d0
		tst.l	paused
		bne		.skipforpause

		; update stars
		lea		starinit,a0
		moveq	#15,d6

.starupd:
		; update z
		move.l	(8,a0),d0
		subq	#4,d0
		bcc.s	.starok

		; we don't worry about manually wrapping z, we just use the AND below to mask
		; but we need to update X and Y here - we just flip to the other quadrant to
		; reduce the repetition factor slightly
		move.l	(12,a0),d1
		move.l	#5000,d2
		sub.l	d1,d2
		move.l	d2,(12,a0)

		move.l	(16,a0),d1
		move.l	#5000,d2
		sub.l	d1,d2
		move.l	d2,(16,a0)

.starok:
		and.l	#$ff,d0
		move.l	d0,(8,a0)
		; now project and update sx and sy
		move.l	#2500,d2
		addq	#1,d0

		; sx=(x-2500)/(z+1)+160
		move.l	(12,a0),d1		; x
		sub.l	d2,d1
		divs	d0,d1
		add.l	#160,d1
		move.l	d1,(a0)			; sx

		; sy=(y-2500)/(z+1)+120
		move.l	(16,a0),d1		; y
		sub.l	d2,d1
		divs	d0,d1
		add.l	#120,d1
		move.l	d1,(4,a0)		;sy

		; now do the next star
		lea		(20,a0),a0
		dbra	d6,.starupd

		; handle the animation frames
		; update earth rotation
		move.l	earth_frame,d0
		addq.l	#1,	d0
		move.l	earthleft,d1
		moveq	#127,d2
		add.l	d2,d2
		sub.l	d1,d2
		lsr.l	#5,d2
		add.l	d2,d0
		cmpi.l	#36*4,d0
		blt.s .noreset
		sub		#36*4,d0
.noreset:
		move.l	d0,earth_frame

		; decrement base_bright
		move.l	base_bright,d0
		beq.s	.base0
		subq	#1,d0
		move.l	d0,base_bright
.base0:

		; decrement earth_bright
		move.l	earth_bright,d0
		beq.s	.earth0
		subq	#1,d0
		move.l	d0,earth_bright
.earth0:

		; decrement gameover count if needed
		move.l	gameover,d0
		beq.s	.go1
		subq	#1,d0
		move.l	d0,gameover
.go1:

		; animate enemy shots (we animate separate from movement so
		; that they will keep animating on the GAME OVER screen, if visible)

		; update shots
		lea		enemy_shot+12,a0
		moveq	#5,d6
		moveq	#63,d7
.shotlp1:
		move.l	(a0),d0
		addq	#1,d0
		cmp.l	d7,d0
		ble.s	.shrotok
		moveq #0,d0
.shrotok:
		move.l	d0,(a0)
		lea		(24,a0),a0
		dbra	d6,.shotlp1

		; update base rotation
		move.l	base_frame,d0
		addq.l	#1,	d0
		cmpi.l	#21,d0
		bne.s .noreset2
		moveq	#0, d0
.noreset2:
		move.l	d0,base_frame

; *** check if the game is not on yet
		tst.l	gameon
		bne.s	.gameison

		; Game is not on, before we skip, see if we need to push the base downwards
		tst.l	earthleft
		beq.s	.baseok2		; if we blew up earth, don't move the base
		move.l	base_y,d0
		cmp.l	#240,d0
		bhi.s	.baseok2
		addq	#1,d0
		move.l	d0,base_y
.baseok2:
		bra	.skipforpause

; *** Game is on!
.gameison:
	
		; Now see if we should move the base upwards
		move.l	base_y,d0
		cmp.l	#200,d0
		ble.s	.baseok
		subq	#1,d0
		move.l	d0,base_y
.baseok:

		; update earth distance (and scale relative)
		move.l	earthrange, d0		; from 16384 (not 16383!) to 0
		beq.s	.earthclr
		subq.l	#EARTHSPEED,d0
		move.l	d0,earthrange
		bne.s .earthnotyet

		; we just reached earth, put up a status notify to the user
		lea	inrangetxt,a0
		lea screenbuf,a1
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	#4*60,clearctr		; countdown time

.earthnotyet:
		; update earth scale
		move.l	#16384,d1
		sub.l	d0,d1				; flip value
		lsr.l	#7,d1				; scale down to 0-128
		move.l	d1,earth_scale
.earthclr:

		; countdown the clearctr for the center line status text
		move.l	clearctr,d0
		beq.s	.clearclr
		subq.l	#1,d0
		move.l	d0,clearctr
		bne.s	.clearclr

		; clear text in center line
		lea cleartxt,a0
		lea screenbuf,a1
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
.clearclr:

		; countdown the enemy out counter
		move.l	newenemycnt,d0
		beq.s	.nodec1
		subq	#1,d0
		move.l	d0,newenemycnt
.nodec1:

		; update enemy movement
		lea		enemy_table,a0
		moveq	#2,d6
.lpenemymv:
		; First check if this enemy is active
		move.l	(a0),d2
		bne .readshipdat

		; enemy dead! Should we activate a new one?
		;move.l	newenemycnt,d0
		tst.l	newenemycnt
		bne	.nextenemy		; not ready yet

		; Yes! Let's create a new enemy here
		; first, count down the timer and reset it
		move.l	maxnewencnt,d0
		beq.s	.nodec3
		subq.l	#1,d0
		move.l	d0,maxnewencnt
.nodec3:
		move.l	d0,newenemycnt

		; random X from 0-127, then add 64 to sorta center it
		; we used to use 256, but we can't safely start larger than 232 ;)
		; Fragment code to generate a 32-bit randomish number in d2
		move.l	rndseed,d2
		lsr.l	#1,d2
		bcc.s	.rndclr1
		eori.l	#$a3000000,d2
.rndclr1:
		move.l	d2,rndseed
		and.l	#$7f,d2
		add.l	#64,d2
		; we'll set this last to reduce odds of race with OP code

		; set Y to 8
		moveq	#8,d3
		move.l	d3,(4,a0)
		
		; frame is set to 0 (we don't need to keep frame)
		moveq #0,d0
		move.l	d0,(8,a0)
		
		; xd is randomly 0-15 minus 8
		; Fragment code to generate a 32-bit randomish number in d4
		move.l	rndseed,d4
		lsr.l	#1,d4
		bcc.s	.rndclr2
		eori.l	#$a3000000,d4
.rndclr2:
		move.l	d4,rndseed
		and.l	#$f,d4
		sub.l	#8,d4
		move.l	d4,(12,a0)
		
		; yd is set to 8 for rapid entry (and to skip past the top Y check)
		moveq.l	#8,d5
		move.l	d5,(16,a0)

		; now write X last
		move.l	d2,(a0)
		bra.s	.shipok
 
.readshipdat:	; read in the ship data (d2=x,d3=y,d4=xd,d5=yd)
		move.l	(4,a0),d3
		; skip frame
		move.l	(12,a0),d4
		move.l	(16,a0),d5

.shipok:		; here we have the data in registers
		; update x
		add.l	d4,d2
		move.l	d2,(a0)
		; check boundaries - we bounce at 8 pixels from edges
		moveq	#8,d7
		cmp.l	d7,d2
		bgt.s	.xok1
		; too low! change X dir to a positive one
		; Fragment code to generate a 32-bit randomish number in d4
		move.l	rndseed,d4
		lsr.l	#1,d4
		bcc.s	.rndclr3
		eori.l	#$a3000000,d4
.rndclr3:
		move.l	d4,rndseed
		and.l	#7,d4
		addq.l	#1,d4
		move.l	d4,(12,a0)
		bra.s	.chky
.xok1:
		cmp.l	#232,d2
		blt.s	.chky
		; too high! Change X dir to a negative one
		; Fragment code to generate a 32-bit randomish number in d4
		move.l	rndseed,d4
		lsr.l	#1,d4
		bcc.s	.rndclr4
		eori.l	#$a3000000,d4
.rndclr4:
		move.l	d4,rndseed
		and.l	#7,d4
		addq.l	#1,d4
		neg.l	d4
		move.l	d4,(12,a0)

.chky:
		; update y
		add.l	d5,d3
		move.l	d3,(4,a0)
		; check boundaries - we bounce at 8 pixels from edges
		moveq	#8,d7
		cmp.l	d7,d3
		bgt.s	.yok1
		; too low! change Y dir to a positive one
		; Fragment code to generate a 32-bit randomish number in d5
		move.l	rndseed,d5
		lsr.l	#1,d5
		bcc.s	.rndclr5
		eori.l	#$a3000000,d5
.rndclr5:
		move.l	d5,rndseed
		and.l	#7,d5
		addq.l	#1,d5
		move.l	d5,(16,a0)
		bra.s	.chkdone
.yok1:
		cmp.l	#213,d3
		blt.s	.chkdone
		; too high! Change Y dir to a negative one
		; Fragment code to generate a 32-bit randomish number in d5
		move.l	rndseed,d5
		lsr.l	#1,d5
		bcc.s	.rndclr6
		eori.l	#$a3000000,d5
.rndclr6:
		move.l	d5,rndseed
		and.l	#7,d5
		addq.l	#1,d5
		neg.l	d5
		move.l	d5,(16,a0)

.chkdone:
.nextenemy:
		lea		(20,a0),a0
		dbra	d6,.lpenemymv

;*****
		; now countdown the enemy shot counter
		move.l	newshotcnt,d0
		beq.s	.nodec2
		subq	#1,d0
		move.l	d0,newshotcnt
.nodec2:

		; update enemy shots
		lea		enemy_shot,a0
		moveq	#5,d6
.lpshotmv:
		; First check if this shot is active
		tst.l	(a0)
		bne .readshotdat
		; shot not in use! Should we activate a new one?
		tst.l	newshotcnt
		bne	.nextshot		; not ready yet

		; Yes! Let's create a new shot here
		; first, count down the timer and reset it
		move.l	maxnewshotcnt,d0
		beq.s	.nodec4
		subq.l	#1,d0
		move.l	d0,maxnewshotcnt
.nodec4:
		move.l	d0,newshotcnt

		; random val from 0-4 for ship to launch from (that will give us the data we need)
		; Fragment code to generate a 32-bit randomish number in d2
		move.l	rndseed,d2
		lsr.l	#1,d2
		bcc.s	.rndclr7
		eori.l	#$a3000000,d2
.rndclr7:
		move.l	d2,rndseed
		and.l	#$3,d2
		; if out of range, we don't fire
		moveq	#2,d7
		cmp.l	d7,d2
		bhi	.nextshot

		; otherwise, get the position. Fire from right gun first
		lea	enemy_table,a1
		tst.l	d2
		beq.s	.skipadd
		subq	#1,d2
.addlp:
		lea		(20,a1),a1
		dbra	d2, .addlp
.skipadd:

		move.l	(a1),d2
		beq	.nextshot		; don't use if ship not out ;)
		add.l	#75,d2
		move.l	(4,a1),d3
		add.l	#15,d3
		moveq	#1,d4

		; set up xd and yd - 0 if less than center, -1 if greater, both are the same
		moveq	#0,d1		; xd
		moveq	#0,d7		; yd
		cmp.l	#160,d2
		blt.s	.xdok
		moveq	#-1,d1
.xdok:
		cmp.l	#120,d3
		blt.s	.ydok
		moveq	#-1,d7
.ydok:

		move.l	d3,(4,a0)
		move.l	d4,(8,a0)	; z
		move.l	d4,(12,a0)	; frame
		move.l	d1,(16,a0)	; xd
		move.l	d7,(20,a0)	; yd
		move.l	d2,(a0)		; write x last to reduce races

		; check if we are going to create a second one
		; only if distance < 7200 (about 2 mins left) and frame < 3 and next slot clear
		move.l	(16,a1),d5		; check frame
		move.l	#2,d0
		cmp.l	d0,d5
		bcc.s	.nosecondshot

		move.l	earthrange,d5	; check distance
		cmp.l	#7200,d5
		bhi.s	.nosecondshot

		tst.l	d6
		beq.s .nosecondshot

		lea		(24,a0),a0
		tst.l	(a0)
		beq.s	.yessecondshot

		; no, fix the address then jump ahead (we could just loop back, but this is cleaner and not much pricier)
		lea		(-24,a0),a0
		bra.s	.nosecondshot

.yessecondshot:
		; We're good! Just offset the X address and fill it in
		sub.l	#70,d2
		move.l	d3,(4,a0)
		move.l	d4,(8,a0)	; z
		move.l	d4,(12,a0)	; frame
		move.l	d1,(16,a0)	; xd (same as above!)
		move.l	d7,(20,a0)	; yd
		move.l	d2,(a0)		; write x last
		subq	#1,d6		; already processed the next one

.nosecondshot:
		; we will not process/move the new shot(s) till next frame
		bra	.nextshot

		; although it's not strictly realistic, we will drift the shots
		; towards the center of the screen. This keeps them off the non-visible
		; areas of the screen, and offsets the apparent movement caused by
		; the scaling (see the earth draw code in the list function for
		; how we keep IT looking centered!)
.readshotdat:	 ; (d4=z)
		move.l	(8,a0),d4	; z
		addq.l	#1,d4

		; did we hit the screen?
		cmp.l	#32<<1,d4
		bhi.s	.hitplayer

		; no, not yet, write it back and update x/y
		move.l	d4,(8,a0)
		move.l	(16,a0),d4			; xd
		add.l	d4,(a0)
		move.l	(20,a0),d4			; yd
		add.l	d4,(4,a0)
				
		bra	.nextshot

.hitplayer:
		; yes, player took a hit
		
		; flash base
		moveq	#6,d5
		move.l	d5,base_bright		; how long we want it lit
		
		; decrement player health
		move.l	lifeleft,d0
		subq	#1,d0
		move.l	d0,lifeleft
		beq.s	.deadnow

		; remove shot from table
		moveq	#0,d1
		move.l	d1,(a0)

		; check for warnings
		cmp.l	#30,d0
		bhi.s	.nextshot

		cmp.l	#15,d0
		bhi.s	.onlylow

		; critical text in center line
		lea shieldcrittxt,a2
		lea screenbuf,a3
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+
		move.l	#2*60,clearctr		; countdown time

		bra.s	.nextshot

.onlylow:
		; shield low text in center line
		lea shieldlowtxt,a2
		lea screenbuf,a3
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+
		move.l	#2*60,clearctr		; countdown time

		bra.s	.nextshot

.deadnow:
		; player finished!
		moveq	#0,d0
		move.l	d0,gameon
		move.l	#300,gameover		; about 5 seconds
		lea gameovertxt,a2
		lea screenbuf,a3
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+

		; just abort now
		bra.s	.skipforpause

.nextshot:
		lea		(24,a0),a0
		dbra	d6,.lpshotmv

;***

.skipforpause:
		; scramble random number
; Fragment code to generate a 32-bit randomish number in d1
		move.l	rndseed,d1
		lsr.l	d1
		bcc.s	.rndclr8
		eori.l	#$a3000000,d1
.rndclr8:
		move.l	d1,rndseed

		; let's just read the joystick real quick and update registers accordingly
		; bits end up a bit screwy. It looks like these. The first set is joystick 1 if enabled,
		; notice how it's selects are the opposite to joystick 0. Value to write is $81YZ, where Y
		; is the row for JOY1 and Z is the row for JOY0. The 8 enables read, and the 1 enables
		; audio (why that's in the joystick register... oi.). I can't test the Numpad or option
		; because my Genesis pad doesn't have those. ;)
		;           JOY1JOY0                       J1J0
		; row0 (e): 369#RLDU xxxxxxxx xxxxxxxx xxxxOxAP
		; row1 (d): 2580*741 xxxxxxxx xxxxxxxx xxxxCxBx		; note: numpad may be backwards here
		; row2 (b): *7412580 xxxxxxxx xxxxxxxx xxxxBxCx
		; row3 (7): RLDU369# xxxxxxxx xxxxxxxx xxxxAPOx		; also, option may be bitshifted by one :)

		move.w #$81fe,JOYSTICK	; enable read, audio, nothing on joystick 1, col 0 on joystick 0
		move.l JOYSTICK,d0		; by doing a long read, we get JOYSTICK and JOYBUTS

		tst.l	gameon
		beq.s	.skippause

		; check buttons - we have Pause and A on this row
		btst #0,d0
		bne.s .joy5

		; Pause pressed, check that state changed
		tst.l	pausepres
		bne.s	.joy5c			; still pressed from last time, ignore

		; note that pause is now pressed
		moveq	#1,d1
		move.l	d1,pausepres

		;move.l	paused,d1
		tst.l	paused
		bne.s	.joy5b

		; pause pressed, state was zero
		moveq	#1,d1
		move.l	d1,paused	; set to pause pressed
		lea	pausedtxt,a0
		; copy text into center line
		lea screenbuf,a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		

		bra.s	.joy5c

.joy5:
		; Pause not pressed, clear flag
		moveq	#0,d1
		move.l	d1,pausepres
		bra.s	.joy5c

.joy5b:
		; pause pressed, state not zero
		moveq	#0,d1
		move.l	d1,paused	; set to not paused
		lea cleartxt,a0
		; copy text into center line
		lea screenbuf,a1
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		

.joy5c:	; almost done pause handling
		;move.l	paused,d1
		tst.l	paused
		bne	.skiprestofpause

.skippause:
		move.l	cross_x,d2
		move.l	cross_y,d3

		btst	#24,d0
		bne.s	.joy1
		subq	#4,d3			; up
		bhi.s	.joy1
		addq	#4,d3			; cancel
.joy1:
		btst #25,d0
		bne.s .joy2
		addq	#4,d3			; down
		cmp		#234,d3
		blt.s	.joy2
		subq	#4,d3
.joy2:	
		btst #26,d0
		bne.s .joy3
		subq	#4,d2			; left
		bcc.s	.joy3
		addq	#4,d2			; cancel
.joy3:	
		btst #27,d0
		bne.s .joy4
		addq	#4,d2			; right
		cmp		#308,d2
		blt.s	.joy4
		subq	#4,d2			; cancel
.joy4:
		; write coordinates back
		move.l	d2,cross_x
		move.l	d3,cross_y

		btst #1,d0
		bne .joy6nopress
		; button pressed, check if held
		tst.l	firepres
		bne	.joy6done			; fire already pressed

		; valid press
		moveq	#1,d1
		move.l	d1,firepres

		; check game state
		tst.l	gameon
		bne.s	.joy6game
		tst.l	gameover	; ignore if gameover count not done
		bne	.joy6done

		; start game
		lea cleartxt,a0
		; copy text into center line
		lea screenbuf,a1
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		
		bsr .preparegame
		; display the score if it wasn't
		moveq	#0,d1
		bsr		.addscore

		moveq	#1,d1
		move.l	d1,gameon

		; clear cheat flag
		moveq	#0,d1
		move.l	d1,cheat

		; check if Pause is also held!
		btst #0,d0
		bne .joy6done

		; pause was held! enable cheat
		moveq	#1,d1
		move.l	d1,cheat

		bra	.joy6done

.joy6game:
		; game already on, player fires! Check collisions
		move.l	#SHOTPITCH,SCLK
		move.l	#$3000,DCTRLTAB	; make noise

		; get crosshairs
		move.l	cross_x,d2		; x
		addq	#8,d2
		addq	#4,d2			; add 12
		move.l	cross_y,d3		; y
		addq	#8,d3
		addq	#8,d3			; add 16

		; first check shots (72x76 range)
		lea	enemy_shot,a0
		moveq	#5,d6
.tstshot:
		move.l	(a0),d4			; x
		beq.s	.nexttstshot
		move.l	(4,a0),d5		; y

		cmp.l	d2,d4
		bgt.s	.nexttstshot
		cmp.l	d3,d5
		bgt.s	.nexttstshot
		add.l	#72,d4
		add.l	#76,d5
		cmp.l	d2,d4
		blt.s	.nexttstshot
		cmp.l	d3,d5
		blt.s	.nexttstshot
		
		; We hit this one! add score and clear it
		move.l	#HITSHOTPITCH,SCLK
		move.l	#$4000,DCTRLTAB	; make noise

		moveq	#10,d1
		bsr		.addscore
		
		moveq	#0,d0
		move.l	d0,(a0)
		
		; don't check anything else
		bra	.tstshotdone

.nexttstshot:
		lea		(24,a0),a0
		dbra	d6,.tstshot

		; now check ships	(92x35)
		lea	enemy_table,a0
		moveq	#2,d6
.tstship:
		move.l	(a0),d4			; x
		move.l	(4,a0),d5		; y

		cmp.l	d2,d4
		bgt.s	.nexttstship
		cmp.l	d3,d5
		bgt.s	.nexttstship
		add.l	#92,d4
		add.l	#35,d5
		cmp.l	d2,d4
		blt.s	.nexttstship
		cmp.l	d3,d5
		blt.s	.nexttstship
		
		; We hit this one! increase damage, add score, clear if dead
		move.l	#HITSHIPPITCH,SCLK
		move.l	#$3000,DCTRLTAB	; make noise

		moveq	#20,d1
		bsr		.addscore

		move.l	(8,a0),d0
		addq	#1,d0
		cmp.l	#4,d0
		blt.s	.shipsurvives

		; else, ship dead, add extra points and remove it
		move.l	#HITSHIPPITCH,SCLK
		move.l	#$4500,DCTRLTAB	; make noise

		move.l	#1000,d1
		bsr		.addscore

		moveq	#0,d0
		move.l	d0,(a0)

		moveq	#100,d1
		bsr		.addscore

		; don't check anything else
		bra	.tstshotdone

.shipsurvives:
		; write the frame data back
		move.l	d0,(8,a0)

		; don't check anything else
		bra	.tstshotdone

.nexttstship:
		lea		(20,a0),a0
		dbra	d6,.tstship

; Test Earth (132x136)
		tst.l	earthrange			; is earth in range?
		bne	.tstshotdone		; nothing else to check

		move.l	#200,d4		; x
		moveq	#20,d5		; y

		cmp.l	d2,d4
		bgt	.tstshotdone
		cmp.l	d3,d5
		bgt.s	.tstshotdone
		add.l	#132,d4
		add.l	#136,d5
		cmp.l	d2,d4
		blt.s	.tstshotdone
		cmp.l	d3,d5
		blt.s	.tstshotdone
		
		; earth hit!
		move.l	#HITEARTHPITCH,SCLK
		move.l	#$2500,DCTRLTAB	; make noise

		move.l	#6,earth_bright

		move.l	earthleft,d0
		subq	#1,d0
		move.l	d0,earthleft
		bne.s	.tstshotdone

		; Earth is FINISHED... flashy BOOM goes here later ;)
		; My humble apologies for this part being unfinished >:)
		; I will come back to this part after the contest :)
		move.l	#HITEARTHPITCH,SCLK
		move.l	#$7ff0,DCTRLTAB	; make noise
		
		lea splodetxt,a2
		; copy text into center line
		lea screenbuf,a3
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		
		move.l	(a2)+,(a3)+		

		; mark the game finished
		move.l	#0,gameon
		move.l	#300,gameover	; about 5 seconds

.tstshotdone:
		bra.s	.joy6done

.joy6nopress:
		; not pressed, reset flag
		moveq	#0,d1
		move.l	d1,firepres

.joy6done:
		
		; check for autofire on cheat mode (just toggling firepres)
		tst.l	cheat
		beq.s	.doneauto
		tst.l	firepres
		beq.s	.doneauto
		moveq	#0,d1
		move.l	d1,firepres
.doneauto:

.skiprestofpause:
		; done one game cycle

.if DEBUGBG
	move.w	#$10ff,BG
.endif

.if 0
		; play some music (does not work yet)
		sub.l	#1,musiccnt
		bne		.nomusic
		move.l	twinklepos,a0
		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.l	a0,twinklepos
		bne	.processmusic
		move.l	#twinkle,twinklepos
		move.l	#1,musiccnt
		; get it next time
		bra	.nomusic
.processmusic:
		move.l	d1,musiccnt
		move.l	d0,score
		swap	d0
		move.l	d0,DCTRLTAB
		moveq	#0,d1
		bsr	.addscore
.nomusic:
.endif

.if DEBUGBG
	move.w	#$0000,BG
.endif
  
		jmp .forevr			; and continue forever


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: preparegame
; Setup the important game-level variables
;
.preparegame:
		movem.l	d0-d1/a0,-(sp)

; init animation
		moveq	#0,d0
		move.l	d0,earth_frame
		move.l	d0,base_frame
		move.l	d0,earth_scale
		move.l	#255,base_y
		move.l	d0,base_bright
		move.l	d0,earth_bright

; set up some game variables
		moveq	#0,d0
		move.l	d0,score
		move.l	d0,paused
		move.l	d0,pausepres
		move.l	d0,gameon
		move.l	d0,gameover
		move.l	d0,firepres
		move.l	#16384,earthrange	; just under 5 minutes, but shifts nicely for the scale range
		move.l	d0, clearctr
		move.l	#180,newenemycnt			; time in frames till we can add first new enemy
		move.l	#NEWENTIME,maxnewencnt		; time in frames (resets newenemycnt)


		move.l	#480,newshotcnt				; time in frames till we can add first new shot (intentionally high for first shot)
		move.l	#NEWSHOTTIME,maxnewshotcnt	; time in frames (resets newshotcnt)

		move.l	#PLAYERLIFE,lifeleft		; player life left
		move.l	#EARTHLIFE,earthleft		; earth life left

; clear the enemy tables
		lea	enemy_table,a0
		moveq	#0,d0
		moveq	#14,d1
.clrlp1:
		move.l	d0,(a0)+
		dbra	d1,.clrlp1

		lea	enemy_shot,a0
		moveq	#0,d0
		moveq	#35,d1
.clrlp2:
		move.l	d0,(a0)+
		dbra	d1,.clrlp2

		movem.l	(sp)+,d0-d1/a0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: addscore 
; Add value in d1 to score and re-display score line at bottom
.addscore:
		movem.l	d0-d1/a0-a1,-(sp)

		move.l	score,d0
		add.l	d1,d0
		move.l	d0,score

		lea scoretxt,a0
		; copy text into bottom line (copy it all to clear the unused positions in case of old strings)
		lea screenbuf2,a1
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		

		; now calc and draw 5 digits into the buffer
		lea	screenbuf2+7,a1	

		move.l	#10000,d1
		divu	d1,d0
		add.b	#48,d0
		move.b	d0,(a1)+
		clr.w	d0
		swap	d0

		move.l	#1000,d1
		divu	d1,d0
		add.b	#48,d0
		move.b	d0,(a1)+
		clr.w	d0
		swap	d0

		moveq	#100,d1
		divu	d1,d0
		add.b	#48,d0
		move.b	d0,(a1)+
		clr.w	d0
		swap	d0

		moveq	#10,d1
		divu	d1,d0
		add.b	#48,d0
		move.b	d0,(a1)+
		clr.w	d0
		swap	d0

		add.b	#48,d0
		move.b	d0,(a1)+

		movem.l	(sp)+,d0-d1/a0-a1
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: InitVBint 
; Install our vertical blank handler and enable interrupts
;

.InitVBint:
		move.l	d0,-(sp)

		move.l	#UpdateList,LEVEL0	; Install 68K LEVEL0 handler

		move.w	a_vde,d0		; Must be ODD
		ori.w	#1,d0
		move.w	d0,VI

		move.w	INT1,d0			; Enable video interrupts
		ori.w	#1,d0
		move.w	d0,INT1

		move.w	sr,d0
		and.w	#$F8FF,d0		; Lower 68k IPL to allow
		move.w	d0,sr			; interrupts

		move.l	(sp)+,d0
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Procedure: InitVideo (same as in vidinit.s)
;            Build values for hdb, hde, vdb, and vde and store them.
;
 						
.InitVideo:
		movem.l	d0-d6,-(sp)		
			
		move.w	CONFIG,d0		; Also is joystick register
		andi.w	#VIDTYPE,d0		; 0 = PAL, 1 = NTSC
		beq.s	.palvals

		move.w	#NTSC_HMID,d2
		move.w	#NTSC_WIDTH,d0

		move.w	#NTSC_VMID,d6
		move.w	#NTSC_HEIGHT,d4

		bra.s	.calc_vals
.palvals:
		move.w	#PAL_HMID,d2
		move.w	#PAL_WIDTH,d0

		move.w	#PAL_VMID,d6
		move.w	#PAL_HEIGHT,d4

.calc_vals:
		move.w	d0,width
		move.w	d4,height

		move.w	d0,d1
		asr	#1,d1				; Width/2

		sub.w	d1,d2			; Mid - Width/2
		add.w	#4,d2			; (Mid - Width/2)+4

		sub.w	#1,d1			; Width/2 - 1
		ori.w	#$400,d1		; (Width/2 - 1)|$400
		
		move.w	d1,a_hde
		move.w	d1,HDE

		move.w	d2,a_hdb
		move.w	d2,HDB1
		move.w	d2,HDB2
	
		move.w	d6,d5
		sub.w	d4,d5
		move.w	d5,a_vdb

		add.w	d4,d6
		move.w	d6,a_vde

		move.w	a_vdb,VDB
		move.w	#$FFFF,VDE

		moveq	#0,d0			
		move.l	d0,BORD1		; Black border
		move.w	d0,BG			; Init line buffer to black
			
		movem.l	(sp)+,d0-d6
		rts

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Uninitialized Data!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;

	.bss
	.phrase

; Display settings
a_hdb:			.ds.w	1
a_hde:			.ds.w	1
a_vdb:			.ds.w	1
a_vde:			.ds.w	1
width:			.ds.w	1
height:			.ds.w	1

lifeleft:		.ds.l	1		; player life remaining
earthleft:		.ds.l	1		; Earth hitpoints

paused:			.ds.l	1		; are we currently paused
pausepres:		.ds.l	1		; is pause currently pressed
gameon:			.ds.l	1		; is game currently on
gameover:		.ds.l	1		; gameover countdown (ignores buttons)
firepres:		.ds.l	1		; is fire currently pressed (can't just hold it down ;) )
earthrange:		.ds.l	1		; distance to earth, essentially this is a game timer! 3600 ticks per second
score:			.ds.l	1		; player score
clearctr:		.ds.l	1		; time in frames till we clear the center line (used for status displays)
newenemycnt:	.ds.l	1		; time in frames till we can add a new enemy
maxnewencnt:	.ds.l	1		; time in frames (resets newenemycnt)
newshotcnt:		.ds.l	1		; time in frames till we can add a new enemy
maxnewshotcnt:	.ds.l	1		; time in frames (resets newenemycnt)

base_frame:		.ds.l	1		; 0-20 (21 frames)
earth_frame:	.ds.l	1		; 0-35 (36 frames), shifted 2 bits for speed
earth_scale:	.ds.l	1		; 0-128 (128=1.0. The *actual* range is 0-32, we shift when we read)

base_y:			.ds.l	1		; y for the base (scrolls up when > 200)

base_bright:	.ds.l	1		; brightness of base (0-255, 0=normal)
earth_bright:	.ds.l	1		; brightness of earth (0-255, 0=normal)

twinklepos:		.ds.l	1
musiccnt:		.ds.l	1

cheat:			.ds.l	1		; set to enable cheating (hold pause while pressing A)

;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initialized Data!!!
;;;;;;;;;;;;;;;;;;;;;;;;;;
	.data
	.phrase

rndseed:		.dc.l	1		; random seed

; these texts need to be 16 characters long exactly
pausedtxt:		.dc.b	'     PAUSED     '
cleartxt:		.dc.b	'                '
gameovertxt:	.dc.b	'   GAME  OVER   '
inrangetxt:		.dc.b	'PLANET IN RANGE!'
shieldlowtxt:	.dc.b	'  SHIELDS LOW!  '
shieldcrittxt:	.dc.b	'SHIELD CRITICAL!'
splodetxt:		.dc.b	'SPLODE! YOU WIN!'

; this text totals 12 characters including digits
scoretxt:		.dc.b	'SCORE:      '

	.phrase
; Done as tables this way so I don't need to initialize them (waste of space, though, the
; code is small), but also easier for testing before all the dev is done, since I can
; pre-build enemies into the table ;)

; player crosshairs
cross_x:		.dc.l		154
cross_y:		.dc.l		112

; three enemies: x, y, damage (0-4), xd, yd
enemy_table:
		.dc.l		0,0,0,0,0
		.dc.l		0,0,0,0,0
		.dc.l		0,0,0,0,0
		.dc.l		0,0,0,0,0	

; up to six shots: x,y,z (0-64),frame (0-63 (shifted 2 bits to get 0-15)), xd, yd (static)
enemy_shot:
		.dc.l		0,0,0,0,0,0
		.dc.l		0,0,0,0,0,0
		.dc.l		0,0,0,0,0,0
		.dc.l		0,0,0,0,0,0
		.dc.l		0,0,0,0,0,0
		.dc.l		0,0,0,0,0,0
		.dc.l		0,0,0,0,0,0

; text overlay buffers 16 chars (middle) and 12 chars (bottom)
screenbuf:
		.dc.b		32,32,32,32,32,32,32,32,32,32,32,32,32,32,32,32
screenbuf2:
		.dc.b		32,32,32,32,32,32,32,32,32,32,32,32

twinkle:
		.dc.l	C21,10,C21,10,G21,10,G21,10,A21,10,A21,10,G21,20
		.dc.l	F21,10,F21,10,E21,10,E21,10,D21,10,D21,10,C21,20
		.dc.l	G21,10,G21,10,F21,10,F21,10,E21,10,E21,10,D21,20
		.dc.l	G21,10,G21,10,F21,10,F21,10,E21,10,E21,10,D21,20
		.dc.l	C21,10,C21,10,G21,10,G21,10,A21,10,A21,10,G21,20
		.dc.l	F21,10,F21,10,E21,10,E21,10,D21,10,D21,10,C21,20
		.dc.l	0,0

		.end

;
; (C) 2007 Mike Brent aka Tursi aka HarmlessLion.com
; This software is provided AS-IS. No warranty
; express or implied is provided.
;
; This notice defines the entire license for this software.
; All rights not explicity granted here are reserved by the
; author.
;
; You may redistribute this software provided the original
; archive is UNCHANGED and a link back to my web page,
; http:;harmlesslion.com, is provided as the author's site.
; It is acceptable to link directly to a subpage at harmlesslion.com
; provided that page offers a URL for that purpose
;
; Source code, if available, is provided for educational purposes
; only. You are welcome to read it, learn from it, mock
; it, and hack it up - for your own use only.
;
; Please contact me before distributing derived works or
; ports so that we may work out terms. I don't mind people
; using my code but it's been outright stolen before. In all
; cases the code must maintain credit to the original author(s).
;
; Unless you have explicit written permission from me in advance,
; this code may never be used in any situation that changes these
; license terms. For instance, you may never include GPL code in
; this project because that will change all the code to be GPL.
; You may not remove these terms or any part of this comment
; block or text file from any derived work.
;
; -COMMERCIAL USE- Contact me first. I didn't make
; any money off it - why should you? ;) If you just learned
; something from this, then go ahead. If you just pinched
; a routine or two, let me know, I'll probably just ask
; for credit. If you want to derive a commercial tool
; or use large portions, we need to talk. ;)
;
; Commercial use means ANY distribution for payment, whether or
; not for profit.
;
; If this, itself, is a derived work from someone else's code,
; then their original copyrights and licenses are left intact
; and in full force.
;
; http://harmlesslion.com - visit the web page for contact info
;
