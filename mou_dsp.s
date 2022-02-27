; Martian Attack - JagCode2007 entry
;
; Based on Atari 'simple' sample (met a pample?)
; This code does not work properly yet. It's not a very good reference. :)
; Only one voice, fixed sample, fixed frequency. I just ran out of time
; for this version. Will fix it later. :) For now, it's just a simple
; noise generator.
;
	include "jaguar.inc"
	include	"mou.inc"

	.globl	DSPSTART
	.globl	DSPEND
	.globl	DSP_START
	.globl	DCTRLTAB

DSPSTART::
	.dsp
	.ORG	D_RAM

	movei	#DSP_START,r0		; (interrupt 0	- DSP Control)
	jump	T,(r0)			
	nop
	nop
	nop
	nop

; We put the stack here so that we do not waste
; the first 16 bytes

STACKPOS:
	movei	#i2s_isr,r29			; (interrupt 1 - I2S)
	jump	T,(r29)
	nop
	nop

; Semaphore -- set when the interrupt fires to load the next sample
SEMAPHORE:
	nop
	nop

; Table to control the settings of each tone generator externally
; sort of inspired by the TI's sound generator ;)
DCTRLTAB:
	nop
	nop

	nop
	nop
	
	nop
	nop
	
	nop
	nop
	
	nop
	nop
	
	nop
	nop
	
	nop
	nop
	
	nop
	nop

DSP_START::
; Set up the modulo adders to handle tables that are 128 longs in length
; This is the size of the internal ROM_TABLES

	movei	#D_MOD,r25		; MODPARM
	movei	#$FFFFFE00,r0
	store	r0,(r25)

;	movei	#ROM_TRI,r4		; Let's play back this wave (voice 1)
	movei	#ROM_NOISE,r4	; Let's play back this wave (voice 4)
	movei	#ROM_TRI,r5		; Let's play back this wave (voice 2)
	movei	#ROM_TRI,r6		; Let's play back this wave (voice 3)
	movei	#ROM_NOISE,r7	; Let's play back this wave (voice 4)
	
	movei	#ROM_SINE+511,r17	; Wave end address 1
	movei	#ROM_SINE+511,r18	; Wave end address 2
	movei	#ROM_SINE+511,r19	; Wave end address 3
	movei	#ROM_NOISE+511,r20	; Wave end address 4

	moveq	#0,r8			; clear increment counter 1
	moveq	#0,r9			; clear increment counter 2
	moveq	#0,r10			; clear increment counter 3
	moveq	#0,r11			; clear increment counter 4

	movei	#DAC1,r12		; Get the DAC location
	movei	#DAC2,r13		; Get the DAC location

	movei	#$ffff,r14		; set up a mask
	movei	#512,r15		; set up sample size in bytes

	movei	#tlop,r16		; address of top of loop

	movei	#STACKPOS,r31	; Set up a stack

	movei	#D_FLAGS,r1		; load dsp flags to go to bank 1

	load	(r1),r0
	bset	#5,r0			; enable I2S interrupt
	store	r0,(r1) 		; save dsp flags

	moveq	#0,r0
	movei	#SEMAPHORE,r1
	store	r0,(r1)			; Clear the SEMAPHORE

	movei	#0,r21			; init volume
	movei	#DCTRLTAB,r22
	store	r21,(r22)		; noise volume

; We have the following registers in use
; r0 = 0
; r1 = ADDRESS of SEMAPHORE
; r2  SCRATCH
; r3  SCRATCH
; r4 = ADDRESS of current sample voice 1
; r5 = ADDRESS of current sample voice 2
; r6 = ADDRESS of current sample voice 3
; r7 = ADDRESS of current sample voice 4
; r8 = current step voice 1
; r9 = current step voice 1
; r10 = current step voice 1
; r11 = current step voice 1
; r12 = ADDRESS of right DAC
; r13 = ADDRESS of left DAC
; r14 = mask value for counter
; r15 = sample size (512)
; r16 = address of top of loop
; r17 = end address of sample 1
; r18 = end address of sample 2
; r19 = end address of sample 3
; r20 = end address of sample 4
;
; Temp stuff
; r21 = current volume (0-0x7ff0, auto decrement)
; r22 = address of DCTRLTAB

tlop:
	load	(r1),r2			; Get SEMAPHORE
lop:
	btst	#1,r2
	jr	EQ,lop
	load	(r1),r2			; Get SEMAPHORE

	load	(r22),r21		; get volume
	load	(r4),r3			; 16-bit sample
	mult	r21,r3			; 32-bit multiply
	shrq	#16,r3			; 16-bit significant result
	
	store	r3,(r12)		; Store the data in the right DAC
	store	r3,(r13)		; Store the data in the left DAC

	or		r21,r21
	jr	EQ,.nodec
	nop
	subq	#16,r21
.nodec:
	store	r21,(r22)		; store volume

.if 0
; update counters
	movei	#DCTRLTAB,r2
	load	(r2),r3			; voice 1 frequency counter
	add		r3,r8
	move	r8,r3
	and		r14,r8			; mask to just the lower 16 bits
	shrq	#16,r3			; just the integer portion
	jr	EQ,.lpout1
	nop
.lpv1:
	addqmod	#4,r4			; This will wrap around the table
;	subq	#1,r3
;	jr	NE,.lpv1
;	nop
.lpout1:

.else
	; quick and simple, use the SCLK reg to change frequency
	addqmod	#4,r4			; This will wrap around the table
.endif

	jump	T,(r16)			; DO IT AGAIN
	store	r0,(r1)			; clear the SEMAPHORE (delay slot)

;____________________start of I2S interrupt service routine__________________
;______________________________________________________________________________

; Sample Rate interrupt
; Registers used in this ISR
;	.	.	.	.
;	.	.	.	.
;	.	.	.	26
;	.	.	.	27
;	.	.	.	28
;	.	.	.	29
;	.	.	.	30
;	.	.	.	31

i2s_isr:

	movei	#D_FLAGS,r30	; get flags ptr
	load	(r30),r27
	bclr	#3,r27			; clear IMASK
	load	(r31),r28		; get last instruction address
	bset	#10,r27			; clear I2S interrupt
	addq	#2,r28			; point at next to be executed
	addq	#4,r31			; update the stack pointer

	moveq	#1,r26
	neg	r26					; turn 1 into ffffffff (probably not really needed here)
	store	r26,(r1)		; set the semaphore so the main code will load the next sample

	jump	T,(r28)			; and return
	store	r27,(r30)		; restore flags
	
	.68000

DSPEND::

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
