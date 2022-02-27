; Martian Attack - JagCode2007 entry
;

DEBUGBG		.equ	0						; set to 1 to enable BG timing

; hacky noise settings
SHOTPITCH		.equ	179
HITSHOTPITCH	.equ	149
HITSHIPPITCH	.equ	129
HITEARTHPITCH	.equ	79
GETHITPITCH		.equ	99

NEWENTIME	.equ	180						; time in frames between new enemies (accelerates)
NEWSHOTTIME	.equ	180						; time in frames between new shots (accelerates)
PLAYERLIFE	.equ	100						; player life
EARTHLIFE	.equ	254						; Earth life (254 max)
EARTHSPEED	.equ	1						; how quickly the earth approaches (max 8)

; these guys are 8 bit
PPP8		.equ	8						; Pixels per Phrase (8-bit CRY)

STAR_WIDTH	.equ	320						; Width in Pixels 
STAR_DWIDTH	.equ	(STAR_WIDTH/PPP8)		; Width in Phrases for data
STAR_IWIDTH .equ    (STAR_WIDTH/PPP8)		; Width in Phrases to draw
STAR_HEIGHT	.equ	40						; Height in Pixels

EARTH_WIDTH	.equ	128						; Width in Pixels 
EARTH_DWIDTH .equ	(EARTH_WIDTH/PPP8)		; Width in Phrases for data
EARTH_IWIDTH .equ   (EARTH_WIDTH/PPP8)		; Width in Phrases to draw
EARTH_HEIGHT .equ	120						; Height in Pixels

; these guys are 16-bit
PPP16		.equ	4						; pixels per phrase (16-bit cry)

SHIP_WIDTH	.equ	80						; Width in Pixels 
SHIP_DWIDTH .equ	(SHIP_WIDTH/PPP16)		; Width in Phrases for data
SHIP_IWIDTH .equ	(SHIP_WIDTH/PPP16)		; Width in Phrases to draw
SHIP_HEIGHT .equ	19						; Height in Pixels

SHOT_WIDTH	.equ	64						; Width in Pixels 
SHOT_DWIDTH .equ	(SHOT_WIDTH/PPP16)		; Width in Phrases for data
SHOT_IWIDTH .equ	(SHOT_WIDTH/PPP16)		; Width in Phrases to draw
SHOT_HEIGHT .equ	60						; Height in Pixels

; For clock frequency 41548.4375 Hz and samples 128 words long
; The '_' indicates a sharp (#) note
A01 :   .dc.l 22209         ; 110 Hz
A_1 :   .dc.l 23529         ; 116.54 Hz
B01 :   .dc.l 24929         ; 123.47 Hz
C11 :   .dc.l 26410         ; 130.81 Hz
C_11:   .dc.l 27981         ; 138.59 Hz
D11 :   .dc.l 29645         ; 146.83 Hz
D_11:   .dc.l 31407         ; 155.56 Hz
E11 :   .dc.l 33275         ; 164.81 Hz
F11 :   .dc.l 35254         ; 174.61 Hz
F_11:   .dc.l 37351         ; 185 Hz
G11 :   .dc.l 39572         ; 196 Hz
G_11:   .dc.l 41924         ; 207.65 Hz
A11 :   .dc.l 44418         ; 220 Hz
A_11:   .dc.l 47059         ; 233.08 Hz
B11 :   .dc.l 49857         ; 246.94 Hz
C21 :   .dc.l 52823         ; 261.63 Hz
C_21:   .dc.l 55962         ; 277.18 Hz
D21 :   .dc.l 59290         ; 293.66 Hz
D_21:   .dc.l 62817         ; 311.13 Hz
E21 :   .dc.l 66552         ; 329.63 Hz
F21 :   .dc.l 70509         ; 349.23 Hz
F_21:   .dc.l 74701         ; 369.99 Hz
G21 :   .dc.l 79145         ; 392 Hz
G_21:   .dc.l 83849         ; 415.3 Hz
A21 :   .dc.l 88836         ; 440 Hz
A_21:   .dc.l 94117         ; 466.16 Hz
B21 :   .dc.l 99714         ; 493.88 Hz
C31 :   .dc.l 105644        ; 523.25 Hz
C_31:   .dc.l 111927        ; 554.37 Hz
D31 :   .dc.l 118582        ; 587.33 Hz
D_31:   .dc.l 125632        ; 622.25 Hz
E31 :   .dc.l 133104        ; 659.26 Hz
F31 :   .dc.l 141019        ; 698.46 Hz
F_31:   .dc.l 149404        ; 739.99 Hz
G31 :   .dc.l 158287        ; 783.99 Hz
G_31:   .dc.l 167700        ; 830.61 Hz
A31 :   .dc.l 177672        ; 880 Hz
A_31:   .dc.l 188237        ; 932.33 Hz
B31 :   .dc.l 199430        ; 987.77 Hz
C41 :   .dc.l 211288        ; 1046.5 Hz
C_41:   .dc.l 223852        ; 1108.73 Hz
D41 :   .dc.l 237163        ; 1174.66 Hz
D_41:   .dc.l 251266        ; 1244.51 Hz
E41 :   .dc.l 266206        ; 1318.51 Hz
F41 :   .dc.l 282035        ; 1396.91 Hz
F_41:   .dc.l 298807        ; 1479.98 Hz
G41 :   .dc.l 316376        ; 1567 Hz

		.extern		earthpal
		.extern		starpal
		.extern		base
		.extern		earth
		.extern		ship
		.extern		shots
		.extern		onestar

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
