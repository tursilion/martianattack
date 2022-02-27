; Martian Attack - JagCode2007 entry
;

		.include    "jaguar.inc"
		.include    "mou.inc"

		.globl		main_obj_list1
;		.globl		main_obj_list2
		.globl      initlister
		.globl		UpdateList

		.extern		earth_frame
		.extern		earthleft
		.extern		base_frame
		.extern		earth_scale
		.extern		base_y
		.extern		base_bright
		.extern		earth_bright
		.extern		enemy_table
		.extern		enemy_shot
		.extern		paused
		.extern		cross_x
		.extern		cross_y
		.extern		screenbuf

		.extern     a_vde
		.extern     a_vdb
		.extern     a_hdb
		.extern     a_hde
		.extern		width
		.extern		height
		.extern		StartGPU
		.extern		starinit
		.extern		starini2
		.extern		font12x16

		.NOCLEAR
		.text

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InitLister: Build Object List Processor List
;
; Similar to InitLister, but called each frame. Skips the 'header' objects
;
; This is probably common sense, but don't change the structure of the
; OP list while the OP is active. And the OP is always active. If
; you are doing dynamic lists like I originally tried, double buffer
; the darn things!! Otherwise you'll experience random crashes.
; There is still the possibility of corruption doing it the way I am here.
;
;	INPUT: a0 must be set to the address of the list to fill
;
updatelister:
		movem.l d0-d6/a1-a2,-(sp)		; Save registers

		; build list
		jmp		updatepoint

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; InitLister: Build Object List Processor List
;
;	INPUT: a0 must be set to the address of the list to fill
;
initlister:
		movem.l d0-d6/a1-a2,-(sp)		; Save registers

		; build list
		move.l	a0,d2			; Copy for address of STOP object

; Write some fixed STOP objects for initial branches
; (note you must start the list at main_obj_list+16)
; This is to keep alignment
		moveq	#0, d1
		moveq   #(STOPOBJ),d0

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

; Write first BRANCH object (branch if YPOS > a_vde )
		moveq	#0, d1
		move.l  #(BRANCHOBJ|O_BRLT),d0	; $4000 = VC < YPOS
		lea	.ret1,a2
		bra     format_link             ; Stuff in our LINK address
.ret1:
						
		move.w  a_vde,d3                ; for YPOS
		lsl.w   #3,d3                   ; Make it bits 13-3
		or.w    d3,d0

		move.l  d1,(a0)+                                
		move.l  d0,(a0)+                ; First OBJ is done.

; Write second branch object (branch if YPOS < a_vdb)   
; Note: LINK address is the same so preserve it
		andi.l  #$FF000007,d0           ; Mask off CC and YPOS
		ori.l   #O_BRGT,d0				; $8000 = VC > YPOS
		move.w  a_vdb,d3                ; for YPOS
		lsl.w   #3,d3                   ; Make it bits 13-3
		or.w    d3,d0

		move.l  d1,(a0)+                ; Second OBJ is done
		move.l  d0,(a0)+  

updatepoint:
.if 1

.if DEBUGBG
	move.w	#$40ff,BG
.endif

; ********** begin stars (16) *********
		lea		starinit,a1
		moveq	#15,d6

.nextstar:
; Write a normal BITMAP for a star block (must be dphrase aligned)
		moveq	#0, d1
		moveq	#0, d0                  ; Type = BITOBJ

		move.l  a0,d2					; jump address is next object
		addq.l	#8,d2          
		addq.l	#8,d2          
		lea	.ret2,a2
		bra     format_link
.ret2:

		move.l	#$4000,d5				; Height of image = 1
		or.l    d5,d0

		move.l	(4,a1),d3
		add.w	d3,d3					; y*2
		add.w   a_vdb,d3
		and.w	#$7ff,d3				; just 11 bits
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	(8,a1),d3				; Z axis	(0-255, top nibble is index)
		and.l	#$f0,d3
		add.l	#onestar,d3				; address (higher Z is dimmer)
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS|O_RELEASE,d1   ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH16|O_NOGAP,d0	; Bit Depth = 16-bit, Contiguous data

		move.l	(a1),d3
		and.l	#$fff,d3				; just 12 bits
		or.l    d3,d0

;		move.l  #$40000,d4				; DWIDTH is 1 phrase
		moveq	#4,d4
		swap	d4						; end up with $40000
		or.l    d4,d0

		move.l	#$10000000,d4			; IWIDTH is 1 phrase
		or.l    d4,d0

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

;		add.l	#20,a1
		lea		(20,a1),a1
; *
		dbra	d6,.nextstar			; branches at -1, not 0! Set initial count to size-1
; ********** end stars ***********
.endif

.if DEBUGBG
	move.w	#$50ff,BG
.endif

; Write a scaled BITMAP for the Earth (must be qphrase aligned!) object ; Note: pure black (000) is transparent!
; There is a dummy stop object after this that we skip over in order to display a second scaled earth
; for the flashing effect, same as the base above.
		moveq	#0, d1
		moveq	#SCBITOBJ,d0			; type = scaled bitobj!
		move.l	earth_scale,d6

		move.l  a0,d2					; jump address is next object, skipping a dummy stop obj
		add.l   #32,d2          
		lea .ret3,a2
		bra     format_link
.ret3:

		move.l  #EARTH_HEIGHT-1,d5		; Height of image
		lsl.l   #8,d5					; HEIGHT
		lsl.l   #6,d5
		or.l    d5,d0

		; if earthleft is 0, then we just load a very large Y value
		tst.l	earthleft
		bne.s	.earthonscreen
		; earth is gone, draw this one off screen
		move.l	#(800<<3),d3
		bra.s	.earthyset2
.earthonscreen:
		move.w	#128,d3
		move.w	d6,d4
		and.w	#$fffc,d4
		sub.w	d4,d3
		lsr.w	d3
		move.w	d3,d2					; save for X work below
		add.w	#20,d3					; y=10 + scale factor
		add.w   a_vdb,d3
		lsl.w   #3,d3
.earthyset2:
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	earth_frame,d4
		lsr.l	#2,d4
		move.l	#(EARTH_WIDTH*EARTH_HEIGHT),d5
		moveq	#0,d3
		tst.l	d4
		beq.s	.nomulearth
		subq	#1,d4
.mulearthlp:
		add.l	d5,d3
		dbra	d4,.mulearthlp
.nomulearth:
		add.l	#earth,d3

		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS|O_RELEASE,d1   ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH8|O_NOGAP,d0	; Bit Depth = 8-bit, Contiguous data

		add.w	#200,d2					; x=200
		or.w    d2,d0

		move.l  #(EARTH_DWIDTH<<18),d4 
		or.l    d4,d0

		move.l	#(EARTH_IWIDTH<<28),d4
		or.l    d4,d0
		move.l	#(EARTH_IWIDTH>>4),d3
		or.l    d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

		; third phrase of scaled bitmap
		lsr.l	#2,d6			; low byte
		move.l	d6,d1
		lsl.l	#8,d1			; high byte
		or.l	d1,d6		
		bset	#21,d6			; set remainder count to 1.0 so first line is drawn
		
		moveq	#0,d0
		move.l	d0,(a0)+
		move.l	d6,(a0)+		; v/h scale

; Write a dummy STOP object (skipped by previous object)
		moveq	#0, d1
		moveq   #(STOPOBJ),d0

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

.if DEBUGBG
	move.w	#$60ff,BG
.endif

; Write a scaled RMW BITMAP for the Earth (must be qphrase aligned!) object ; Note: pure black (000) is transparent!
; This one, like the base, is overlaid in order to brighten the earth
.if 1
		moveq	#0, d1
		moveq	#SCBITOBJ,d0			; type = scaled bitobj!
		move.l	earth_scale,d6

		move.l  a0,d2					; jump address is next object, skipping a dummy stop obj for alignment's sake
		add.l   #32,d2          
		lea	.ret4,a2
		bra     format_link
.ret4:

		move.l  #EARTH_HEIGHT-1,d5		; Height of image
		lsl.l   #8,d5					; HEIGHT
		lsl.l   #6,d5
		or.l    d5,d0

		; if earth_bright is 0, then we just load a very large Y value
		;move.l	earth_bright,d3
		tst.l	earth_bright
		bne.s	.earthlit
		; earth is dark, draw this one off screen
		move.l	#(800<<3),d3
		bra.s	.earthyset
.earthlit:
		; earth is lit, draw it after all
		move.w	#128,d3
		move.w	d6,d4
		and.w	#$fffc,d4
		sub.w	d4,d3
		lsr.w	d3
		move.w	d3,d2					; save for X work below
		add.w	#20,d3					; y=10 + scale factor
		add.w   a_vdb,d3
		lsl.w   #3,d3
.earthyset:
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	earth_frame,d4
		lsr.l	#2,d4
		move.l	#(EARTH_WIDTH*EARTH_HEIGHT),d5
		moveq	#0,d3
		tst.l	d4
		beq.s	.nomulearth2
		subq	#1,d4
.mulearthlp2:
		add.l	d5,d3
		dbra	d4,.mulearthlp2
.nomulearth2:
		add.l	#earth,d3

		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS|O_RMW|O_RELEASE,d1       ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH8|O_NOGAP,d0	; Bit Depth = 8-bit, Contiguous data

		add.w	#200,d2					; x=200
		or.w    d2,d0

		move.l  #(EARTH_DWIDTH<<18),d4 
		or.l    d4,d0

		move.l	#(EARTH_IWIDTH<<28),d4
		or.l    d4,d0
		move.l	#(EARTH_IWIDTH>>4),d3
		or.l    d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

		; third phrase of scaled bitmap
		lsr.l	#2,d6			; low byte
		move.l	d6,d1
		lsl.l	#8,d1			; high byte
		or.l	d1,d6		
		bset	#21,d6			; set remainder count to 1.0 so first line is drawn
		
		moveq	#0,d0
		move.l	d0,(a0)+
		move.l	d6,(a0)+		; v/h scale

; Write a dummy STOP object (skipped by previous object)
		moveq	#0, d1
		moveq   #(STOPOBJ),d0

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

.if DEBUGBG
	move.w	#$70ff,BG
.endif
 
; Write a normal BITMAP for the death star (must be dphrase aligned) (000 is transparent)
		moveq	#0, d1
		moveq	#0, d0                  ; Type = BITOBJ

		move.l  a0,d2					; jump address is next object
		addq.l	#8,d2          
		addq.l	#8,d2          
		lea	.ret5,a2
		bra     format_link
.ret5:

		move.l  #(STAR_HEIGHT<<14),d5	; Height of image
		or.l    d5,d0

		move.l  base_y,d3         		; read Y value
		add.l	d3,d3					; *2
		add.w   a_vdb,d3
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	base_frame,d4
		move.l	#(STAR_WIDTH*STAR_HEIGHT),d5
		moveq	#0,d3
		tst.l	d4
		beq.s	.nomulbase
		subq	#1,d4
.mulbaselp:
		add.l	d5,d3
		dbra	d4,.mulbaselp
.nomulbase:

		add.l	#base,d3				; this one counts backwards in memory 

		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		; do second word
		move.l  #O_TRANS|O_RELEASE,d1             ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH8|O_NOGAP,d0	; Bit Depth = 8-bit, Contiguous data

		moveq	#-2,d3					; x
		and.l	#$fff,d3				; just 12 bits
		or.l    d3,d0

		move.l  #(STAR_DWIDTH<<18),d4 
		or.l    d4,d0

		move.l	#(STAR_IWIDTH<<28),d4
		or.l	d4,d0
		move.l	#(STAR_IWIDTH>>4),d3
		or.l	d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

.if DEBUGBG
	move.w	#$90ff,BG
.endif

; Write a second RMW BITMAP for the death star for flashing (must be dphrase aligned) (000 is transparent)
; Using the original data screws up the color too, but I'm not worried about it enough to provide
; a brightness only version of the data.
		moveq	#0, d1
		moveq	#0, d0                  ; Type = BITOBJ

		move.l  a0,d2					; jump address is next object
		addq.l	#8,d2          
		addq.l	#8,d2          
		lea .ret6,a2
		bra     format_link
.ret6:

		move.l  #(STAR_HEIGHT<<14),d5	; Height of image
		or.l    d5,d0

		; if base_bright is 0, then we just load a very large Y value
		;move.l	base_bright,d3
		tst.l	base_bright
		bne.s	.baselit
		; base is dark, draw this one off screen
		move.l	#(800<<3),d3
		bra.s	.baseyset
.baselit:
		; base is lit, draw it after all
		move.l  base_y,d3         		; read Y value
		add.l	d3,d3					; *2
		add.w   a_vdb,d3
		lsl.w   #3,d3
.baseyset:
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	base_frame,d4
		move.l	#(STAR_WIDTH*STAR_HEIGHT),d5
		moveq	#0,d3
		tst.l	d4
		beq.s	.nomulbase2
		subq	#1,d4
.mulbaselp2:
		add.l	d5,d3
		dbra	d4,.mulbaselp2
.nomulbase2:

		add.l	#base,d3				; this one counts backwards in memory 

		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		; do second word
		move.l  #O_TRANS|O_RMW|O_RELEASE,d1       ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH8|O_NOGAP,d0	; Bit Depth = 8-bit, Contiguous data

		moveq	#-2,d3					; x
		and.l	#$fff,d3				; just 12 bits
		or.l    d3,d0

		move.l  #(STAR_DWIDTH<<18),d4 
		or.l    d4,d0

		move.l	#(STAR_IWIDTH<<28),d4
		or.l	d4,d0
		move.l	#(STAR_IWIDTH>>4),d3
		or.l	d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

; Now we write the ships and shots. x of 0 means offscreen (so don't move to 0!)
; To guarantee qphrase alignment, we insert 2 dummy stop objects after each one.
; They are skipped by each object

.if DEBUGBG
	move.w	#$a0ff,BG
.endif

; ********** begin ships (up to 3) *********
		lea		enemy_table,a1
		moveq	#2,d6

.nextship:
; Write a normal BITMAP for an enemy ship (must be dphrase aligned)
		move.l	(a1),d4
		bne.s	.goodship
		; set a high x value
		move.l	#400,d4
.goodship:

		moveq	#0, d1
		moveq	#0, d0                  ; Type = BITOBJ

		move.l  a0,d2					; jump address is next object
		add.l	#32,d2					; plus skip 2 dummy stops
		lea .ret7,a2
		bra     format_link
.ret7:

		move.l  #(SHIP_HEIGHT<<14),d5	; Height of image
		or.l    d5,d0

		move.l	(4,a1),d3
		add.w	d3,d3					; y*2
		add.w   a_vdb,d3
		and.w	#$7ff,d3				; just 11 bits
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	(8,a1),d7				; damage (0-3)
		and.l	#$3,d7
		move.l	#(SHIP_WIDTH*SHIP_HEIGHT*2),d5
		moveq	#0,d3
		tst.l	d7
		beq.s	.nomulship
		subq	#1,d7
.mulshiplp:
		add.l	d5,d3
		dbra	d7,.mulshiplp
.nomulship:

		add.l	#ship,d3				; address 
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS,d1             ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH16|O_NOGAP,d0	; Bit Depth = 16-bit, Contiguous data

		; d4 still contains saved value of (a1) - x - from top of block
		and.l	#$fff,d4				; just 12 bits
		or.l    d4,d0

		move.l  #(SHIP_DWIDTH<<18),d4 
		or.l    d4,d0

		move.l	#(SHIP_IWIDTH<<28),d4
		or.l	d4,d0
		move.l	#(SHIP_IWIDTH>>4),d3
		or.l	d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

; Write two dummy STOP objects (skipped by previous object)
		moveq	#0, d1
		moveq	#(STOPOBJ),d0

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

;		add.l	#20,a1
		lea		(20,a1),a1
; *
		dbra	d6,.nextship

; ********** end ships ***********

.if DEBUGBG
	move.w	#$b0ff,BG
.endif

; ********** begin shots (up to 6) *********
		lea		enemy_shot,a1
		moveq	#5,d6

.nextshot:
; Write a scaled BITMAP for an enemy shot (must be qphrase aligned, followed by dummy stop)
		move.l	(a1),d4
		bne.s	.goodshot
		; set a high x value
		move.l	#400,d4
.goodshot:

		moveq	#0, d1
		moveq	#SCBITOBJ, d0           ; Type = Scaled bitmap

		move.l  a0,d2					; jump address is after the dummy stop for alignment's sake
		add.l	#32,d2
		lea .ret8,a2
		bra     format_link
.ret8:

		move.l  #(SHOT_HEIGHT<<14),d5	; Height of image
		or.l    d5,d0

		move.l	(4,a1),d3
		add.w	d3,d3					; y*2
		add.w   a_vdb,d3
		and.w	#$7ff,d3				; just 11 bits
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	(12,a1),d7				; frame (0-63)
		and.l	#$3f,d7
		lsr.l	#2,d7
		move.l	#(SHOT_WIDTH*SHOT_HEIGHT*2),d5
		moveq	#0,d3
		tst.l	d7
		beq.s	.nomulshot
		subq	#1,d7
.mulshotlp:
		add.l	d5,d3
		dbra	d7,.mulshotlp
.nomulshot:

		add.l	#shots,d3				; address 
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS,d1             ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH16|O_NOGAP,d0	; Bit Depth = 16-bit, Contiguous data

		; d4 still contains saved value of (a1) - x - from top of block
		and.l	#$fff,d4				; just 12 bits
		or.l    d4,d0

		move.l  #(SHOT_DWIDTH<<18),d4 
		or.l    d4,d0

		move.l	#(SHOT_IWIDTH<<28),d4
		or.l	d4,d0
		move.l	#(SHOT_IWIDTH>>4),d3
		or.l	d3,d1

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

		; third phrase of scaled bitmap
		move.l	(8,a1),d3		; Z (0-255, shifted 3 bit int + 5 bit fraction, so 2-64, 64=1.0)
		and.l	#$ff,d3
		lsr.l	#1,d3
		move	d3,d1
		lsl.l	#8,d3
		or.l	d3,d1
		bset	#21,d1			; set remainder count to 1.0 so first line is drawn
		
		moveq	#0,d0
		move.l	d0,(a0)+
		move.l	d1,(a0)+		; v/h scale

; Write a dummy STOP object (skipped by previous object)
		moveq	#0, d1
		moveq	#(STOPOBJ),d0

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

.skipshot:
;		add.l	#24,a1
		lea		(24,a1),a1
; *
		dbra	d6,.nextshot

; ********** end shots ***********

.if DEBUGBG
	move.w	#$c0ff,BG
.endif

; Draw the player's crosshairs (we use the '*' character in the font, it's handy)
; Write a normal BITMAP for crosshairs (must be dphrase aligned)
		moveq	#0, d1
		moveq	#0, d0                  ; Type = BITOBJ

		move.l  a0,d2					; jump address is next object
		add.l	#16,d2
		lea .ret9,a2
		bra     format_link
.ret9:

		move.l  #(16<<14),d5			; Height of image
		or.l    d5,d0

		move.l	cross_y,d3
		add.w	d3,d3					; y*2
		add.w   a_vdb,d3
		and.w	#$7ff,d3				; just 11 bits
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		move.l	#font12x16+(512*10),d3	; address of '*' char 42
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS,d1             ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH16|O_NOGAP,d0	; Bit Depth = 16-bit, Contiguous data

		move.l	cross_x,d4
		and.l	#$fff,d4				; just 12 bits
		or.l    d4,d0

		move.l  #(4<<18),d4 
		or.l    d4,d0

		move.l	#(4<<28),d4
		or.l	d4,d0

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

		lea		screenbuf,a1
.if 1

.if DEBUGBG
	move.w	#$e0ff,BG
.endif

; Now render the text layer - 16x1 cells per line, each cell 12x16 (but we can draw 16x16)
; one line at middle, one at bottom

; middle line
		move.l	#15,d6		; count
		move.l	#64,d5		; x

.nexttext2:
; Write a normal BITMAP for a text character (must be dphrase aligned)
		moveq	#0, d1
		moveq	#0, d0                  ; Type = BITOBJ

		move.l  a0,d2					; jump address is next object
		addq	#8,d2
		addq	#8,d2
		lea .ret10,a2
		bra     format_link
.ret10:

		move.l  #(16<<14),d3			; Height of image
		or.l    d3,d0

		move.l	#224,d3					; y*2
		add.w   a_vdb,d3
		and.w	#$7ff,d3				; just 11 bits
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		moveq	#0,d3
		move.b	(a1)+,d3				; character
		sub.l	#32,d3					; 32 = space
		and.l	#$7f,d3
		lsl		#8,d3					; *512 for each character
		add.l	d3,d3
		add.l	#font12x16,d3			; address 
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS,d1             ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH16|O_NOGAP,d0	; Bit Depth = 16-bit, Contiguous data

		move.l	d5,d3					; x
		and.l	#$fff,d3				; just 12 bits
		or.l    d3,d0

		move.l  #(4<<18),d3 
		or.l    d3,d0

		move.l	#(4<<28),d3
		or.l	d3,d0

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

		; update position
		addq	#8,d5					; add 12 to x
		addq	#4,d5
; *
		dbra	d6,.nexttext2
.endif

.if 1

.if DEBUGBG
	move.w	#$20ff,BG
.endif

; bottom line
		move.l	#11,d6		; count
		move.l	#88,d5		; x

.nexttext3:
; Write a normal BITMAP for a text character (must be dphrase aligned)
		moveq	#0, d1
		moveq	#0, d0                  ; Type = BITOBJ

		move.l  a0,d2					; jump address is next object
		addq	#8,d2
		addq	#8,d2
		lea .ret11,a2
		bra     format_link
.ret11:

		move.l  #(16<<14),d3			; Height of image
		or.l    d3,d0

		move.l	#432,d3					; y*2
		add.w   a_vdb,d3
		and.w	#$7ff,d3				; just 11 bits
		lsl.w   #3,d3
		or.w    d3,d0                   ; Stuff YPOS in low phrase

		moveq	#0,d3
		move.b	(a1)+,d3				; character
		sub.l	#32,d3					; 32 = space
		lsl		#8,d3					; *512 for each character
		add.l	d3,d3
		add.l	#font12x16,d3			; address 
		andi.l  #$FFFFF0,d3
		lsl.l   #8,d3                   ; Shift bitmap_addr into position
		or.l    d3,d1
     
		move.l  d1,(a0)+
		move.l  d0,(a0)+

		move.l  #O_TRANS,d1             ; Now for PHRASE 2 of BITOBJ
		move.l  #O_DEPTH16|O_NOGAP,d0	; Bit Depth = 16-bit, Contiguous data

		move.l	d5,d3					; x
		and.l	#$fff,d3				; just 12 bits
		or.l    d3,d0

		move.l  #(4<<18),d3				; data phrases
		or.l    d3,d0

		move.l	#(4<<28),d3				; data phrases
		or.l	d3,d0

		move.l  d1,(a0)+                ; Write second PHRASE of BITOBJ
		move.l  d0,(a0)+

		; update position
		addq	#8,d5					; add 12 to x
		addq	#4,d5
; *
		dbra	d6,.nexttext3
.endif


; Write a STOP object at end of list
		moveq	#0, d1
		moveq	#(STOPOBJ),d0

		move.l  d1,(a0)+                
		move.l  d0,(a0)+

		movem.l (sp)+,d0-d6/a1-a2
		rts 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: format_link
;
;    Inputs: d1.l/d0.l is a 64-bit phrase
;            d2.l contains the LINK address to put into bits 42-24 of phrase
;			 a2 contains the return address
;
;   Returns: Updated phrase in d1.l/d0.l
; 
;  Corrupts d2,d3, assumes valid link address
;
format_link:
		move.l  d2,d3                   ; Make a copy

		swap	d2                   	; Put bits 10-3 in bits 31-24
		clr.w	d2
		lsl.l   #5,d2
		or.l    d2,d0

		lsr.l   #8,d3                   ; Put bits 21-11 in bits 42-32
		lsr.l   #3,d3
		or.l    d3,d1

;		rts
		jmp	(a2)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; UpdateList: Update list fields destroyed by the object processor.
;			  and do other vblank stuff (int handler)
;
UpdateList:
		; Update OP list - must be done before the first Bitmap is processed
		movem.l a0,-(sp)

.if DEBUGBG
	move.w	#$30ff,BG
.endif

		lea main_obj_list1+32, a0
		jsr updatelister

; We'll work out the double buffer later
;		subq.l	#8,a0
;		subq.l	#8,a0
;		move.l	a0,OLP

.if DEBUGBG
	move.w	#0,BG
.endif

		; Signal we're done
		move.w	#$101,INT1
		move.w	#$0,INT2

		movem.l (sp)+,a0
		rte

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Storage space for our object lists

		.bss

; The list must start 4-phrase aligned
		.qphrase
main_obj_list1:
		.ds.l       150*2		; number of 64 bit phrases * 2 for 32 bit words plus a bit of padding

;main_obj_list2:
;		.ds.l       150*2		; number of 64 bit phrases * 2 for 32 bit words plus a bit of padding

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
