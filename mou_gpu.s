; Martian Attack - JagCode2007 entry
;
 
		.include    "jaguar.inc"
		.include    "mou.inc"

		.extern		earth_bright
		.extern		base_bright

		.gpu

RAMGPUAddress::
		.org     G_RAM
FirstGPU::
	; CPU must have cleared the G_FLAGS register - at a minimum
	; we must be in reg bank 0 and it'd be nice if interrupts
	; were disabled ;)
StartGPU::
; Init some registers in bank 0 for interrupt usage
	moveq	#0,r0			; just have 0 handy

; Just copied from my other code - we probably don't need all this but we only set it once
	movei	#A1_STEP,r6		; Step register - though not active, it's used when FSTEP overflows
	movei	#A1_FSTEP,r8	; Fractional step register
	movei	#$00010100,r9	; Blitter count (256 copies, inner loop)
	movei	#A2_PIXEL,r11	; A2 pixel address
	movei	#A1_FPIXEL,r12	; A1 fractional pixel address
	movei	#A1_PIXEL,r13	; A1 pixel address
	movei	#CLUT,r14		; output address for blit
	movei	#(SRCEN|LFU_S|BUSHI),r18	; Blitter command value - src read enable, write src data, bus high (will interrupt OP! Be very very quick!)
	movei	#B_COUNT,r19	; Blitter counters
	movei	#B_CMD,r20		; Blitter command/Status
	movei	#OBF,r22		; Object processor flags
	movei	#G_FLAGS,r23	; GPU flags
	movei	#A1_BASE,r26	; A1 base address register for blitter
	movei	#A2_BASE,r27	; A2 base address register for blitter

	; set up the blitter as well 
	
	; A1 (Dest)
	movei #A1_FLAGS,r3
	movei #(PITCH1|PIXEL16|ZOFFS0|WID256|XADDPHR|YADD0|XSIGNADD|YSIGNADD),r4	; we say 16 bit, 16 bit colors
	store r4,(r3)			; flags
	movei #A1_CLIP,r3
	movei #$00f00100,r4		; 256x240
	store r4,(r3)			; set clip size (not used)
	store r0,(r6)			; step (not needed for x because this is automatic in phrase mode)
	store r0,(r8)			; fractional step
	movei #A1_INC,r3
	store r0,(r3)			; increment (in increment mode, we aren't using)
	movei #A1_FINC,r3
	store r0,(r3)			; fractional increment
	
	; A2 (Src)
	movei #A2_FLAGS,r3
	movei #(PITCH1|PIXEL16|ZOFFS0|WID256|XADDPHR|YADD0|XSIGNADD|YSIGNADD),r4
	store r4,(r3)			; flags
	movei #A2_MASK,r3
	movei #-1,r4
	store r4,(r3)			; no mask
	movei #A2_STEP,r3
	store r0,(r3)			; step
	
	; Blitter general
	movei #B_STOP,r3
	store r0,(r3)			; collision control
	movei #B_IINC,r3
	store r0,(r3)			; intensity increment (none)
	
; Main loop - watch the scanline - for the top, load the Earth palette.
; at the halfway point, load the starbase palette.
; Enemy ships are truecolor so they's unaffected

maingpu:
; WAIT FOR BOTTOM OF SCREEN
	movei	#VC, r1
	movei	#$1f8, r2
	movei	#$1FF, r3

.waitvid1:
	; delays to read bus less often
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
	loadw	(r1),r4
	and		r3, r4
	cmp		r2, r4			; Wait for line Display Start.
	jr		NE, .waitvid1
	nop						; Delay

; LOAD EARTH PALETTE
	movei #earthpal,r1		; earth address

	store r1,(r27)			; source address
	store r14,(r26)			; dest address (CLUT)
	store r9,(r19)			; load count
	store r0,(r11)			; src pixel window pos
	store r0,(r13)			; dest pixel window pos
	store r18,(r20)			; fire the blitter off!

; WAIT FOR MIDDLE OF SCREEN
	movei	#VC, r1
	movei	#240+$2e, r2
	movei	#$1FF, r3
.waitvid2:
	; delays to read bus less often
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
	loadw	(r1),r4
	and		r3, r4
	cmp		r2, r4			; Wait for line Display Start.
	jr		NE, .waitvid2
	nop						; Delay
 
; LOAD DSTAR PALETTE
	movei #starpal,r1

	store r1,(r27)			; source address
	store r14,(r26)			; dest address (CLUT)
	store r9,(r19)			; load count
	store r0,(r11)			; src pixel window pos
	store r0,(r13)			; dest pixel window pos
	store r18,(r20)			; fire the blitter off!

	movei #maingpu,r1
	jump T,(r1)
	nop

LastGPU::
	nop
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
