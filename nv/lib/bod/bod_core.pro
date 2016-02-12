;=============================================================================
;+
; NAME:
;	bod_core
;
;
; PURPOSE:
;	Returns the core descriptor for each given body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	crd = bod_core(bx)
;
;
; ARGUMENTS:
;  INPUT: 
;	bx:	 Any subclass of BODY.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Core descriptor associated with each given body descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
function bod_core, bxp
@nv_lib.include
 bdp = class_extract(bxp, 'BODY')
 nv_notify, bdp, type = 1
 bd = nv_dereference(bdp)
 return, bd.crd
end
;===========================================================================
