; Martian Attack - JagCode2007 entry
;
	.globl	earthpal
	.globl	starpal
	.data
 
earthpal:
;earth palette data: 256 x 16-bit palette entries
	dc.w	$0000,$0008,$2418,$2320,$0010,$2430,$4510,$2338,$1328,$3428,$4520,$7808,$5618,$7810,$7818
	dc.w	$2340,$4530,$4628,$6620,$3438,$7820,$6728,$5630,$9828,$7828,$9830,$6730,$A920,$8838,$4638,$0018
	dc.w	$7830,$7738,$5638,$8840,$4010,$3440,$A918,$7838,$8848,$7740,$7840,$6640,$1230,$4640,$7920,$4540
	dc.w	$3228,$7928,$7930,$7848,$7748,$6648,$8850,$7850,$7A18,$7838,$BA10,$7750,$7858,$5648,$7860,$6750
	dc.w	$7840,$4220,$0020,$7758,$7868,$8858,$3338,$7760,$2230,$6758,$7870,$7848,$7B10,$8860,$5650,$3240
	dc.w	$7878,$A838,$4330,$7768,$9740,$9848,$2018,$6760,$8940,$7770,$1528,$4548,$9938,$8868,$A830,$7880
	dc.w	$0710,$9850,$7850,$7778,$2140,$7858,$6768,$2258,$8930,$7888,$7780,$8758,$8948,$9620,$6658,$9728
	dc.w	$A940,$7008,$2348,$2368,$1238,$A728,$9848,$A618,$2348,$6828,$5920,$2360,$5318,$7788,$9730,$5918
	dc.w	$2250,$7860,$7890,$A938,$4340,$4A10,$8870,$9850,$7770,$7898,$6830,$1350,$9860,$7838,$2138,$8738
	dc.w	$33A0,$7790,$7868,$2538,$A850,$4720,$4438,$2378,$4650,$A848,$2620,$2818,$5328,$2270,$44B0,$5728
	dc.w	$9A28,$33A8,$A930,$A858,$7840,$8950,$2020,$8740,$0F08,$5830,$2380,$2630,$45A8,$7940,$78A0,$7778
	dc.w	$1430,$3728,$2440,$6660,$8878,$2260,$5838,$3350,$4730,$7870,$FF08,$8748,$7798,$54A0,$4458,$3390
	dc.w	$5430,$5598,$7A38,$3548,$3398,$2148,$5440,$6740,$77A0,$9858,$9868,$6420,$7848,$0518,$B720,$7A30
	dc.w	$4448,$A840,$3638,$4738,$5548,$3358,$3280,$7948,$3348,$78A8,$3398,$5560,$1028,$B510,$7780,$7878
	dc.w	$44A8,$1030,$5538,$8750,$0028,$9860,$8880,$6648,$6848,$5568,$5490,$6630,$7850,$34B0,$5558,$7860
	dc.w	$3468,$5588,$4588,$4598,$3388,$6540,$5740,$6850,$8758,$77A8,$6528,$33B0,$3270,$6650,$3378,$5570
	dc.w	$6668
	
starpal:
;dstar palette data: 256 x 16-bit palette entries
;palette data: number of colors, then the palette entries
	dc.w	$0000,$A748,$A750,$A740,$A838,$9740,$B738,$9758,$9640,$A760,$A830,$A758,$A750,$A638,$A768
	dc.w	$A858,$B848,$9648,$A838,$A848,$A650,$9848,$A840,$8878,$9658,$A650,$9750,$9660,$9868,$8888,$88A0
	dc.w	$FF08,$A670,$9970,$8870,$9858,$9960,$9980,$A918,$8780,$B510,$9850,$8740,$A670,$B628,$B740,$8848
	dc.w	$A920,$8840,$9890,$A668,$78A0,$B720,$BA10,$9728,$A860,$9730,$B730,$7850,$B850,$B940,$9760,$8838
	dc.w	$8968,$98A0,$A728,$A618,$8890,$C728,$7808,$7840,$8990,$B520,$8758,$A630,$8768,$B760,$F008,$A868
	dc.w	$9888,$9970,$7838,$7820,$A788,$A878,$7810,$7828,$8770,$7630,$9668,$9790,$8748,$9758,$7860,$C748
	dc.w	$C848,$9828,$B680,$9978,$9830,$8738,$A668,$9958,$6850,$B750,$8640,$C838,$7878,$B758,$A648,$A880
	dc.w	$7878,$88A8,$A768,$B830,$A938,$A930,$A940,$B760,$B748,$9938,$A948,$A660,$C758,$9B20,$B970,$B640
	dc.w	$9990,$A850,$B768,$A940,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000

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
