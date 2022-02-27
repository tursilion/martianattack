; Martian Attack - JagCode2007 entry
; 
   	.globl	onestar
	.globl	starinit
	.globl	starini2
  
	.include "palette.inc"

	.include "d_star/base.cry"
	.include "earth/earth.cry"
	.include "ships/ship.cry"
	.include "ships/shots.cry"  
	.include "font12.cry"
  
   	.data 
	.phrase
onestar:
; 8 x 1 (and 16 intensities)
	dc.w	$88FF, 0, 0, 0, 0, 0, 0, 0
	dc.w	$88eF, 0, 0, 0, 0, 0, 0, 0
	dc.w	$88dF, 0, 0, 0, 0, 0, 0, 0
	dc.w	$88cF, 0, 0, 0, 0, 0, 0, 0
	dc.w	$88bF, 0, 0, 0, 0, 0, 0, 0
	dc.w	$88aF, 0, 0, 0, 0, 0, 0, 0
	dc.w	$889F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$888F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$887F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$886F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$885F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$884F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$883F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$882F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$881F, 0, 0, 0, 0, 0, 0, 0
	dc.w	$880F, 0, 0, 0, 0, 0, 0, 0
  
; init data for the starfield - nothing special, it's just randomly pregenerated
starinit:
	; sx, sy, z, x, y 
	; sx=(x-2500)/(z+1)+160
	; sy=(y-2500)/(z+1)+120
 
	; most invalid values should end up off the visible screen, so that's okay
	dc.l 1833, -2205, 0, 4173, 175
	dc.l 164, 167, 16, 2584, 3314
	dc.l 148, 60, 32, 2131, 523
	dc.l 205, 162, 48, 4746, 4606
	dc.l 163, 108, 64, 2747, 1729
	dc.l 158, 112, 80, 2358, 1874
	dc.l 177, 110, 96, 4234, 1584
	dc.l 158, 109, 112, 2280, 1359
	dc.l 178, 112, 128, 4914, 1488
	dc.l 168, 122, 144, 3695, 2836
	dc.l 150, 128, 160, 979, 3806
	dc.l 169, 117, 176, 4197, 1988
	dc.l 160, 130, 192, 2504, 4450
	dc.l 148, 131, 208, 137, 4972
	dc.l 161, 110, 224, 2862, 252
	dc.l 160, 113, 240, 2656, 970


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
