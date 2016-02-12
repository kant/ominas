;=============================================================================
;+
; NAME:
;	nv_get_sn
;
;
; PURPOSE:
;	Returns unique and available descriptor serial numbers.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	result = nv_get_sn(n)
;
;
; ARGUMENTS:
;  INPUT:
;	n:	Number of serial numbers to return.  Default is one.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	NONE
;
;  OUTPUT:
;	NONE
;
;
; RETURN:
;	An array of n unused unique serial numbers.  Note serial numbers 
;	start at 1.
;
;
; COMMON BLOCKS:
;	nv_sn_block:	Keeps track of current serial number.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	nv_extract_sn
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2002
;	
;-
;=============================================================================
function nv_get_sn, n
common nv_sn_block, sn
@nv.include

 if(NOT keyword__set(n)) then n=1

 ;--------------------------------------
 ; set initial serial number
 ;--------------------------------------
 if(NOT keyword__set(sn)) then sn = 1l

 ;--------------------------------------
 ; release n new serial numbers
 ;--------------------------------------
 result = sn + lindgen(n)
 sn = sn + n


 return, result
end
;=============================================================================
