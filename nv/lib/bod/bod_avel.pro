;===========================================================================
;+
; NAME:
;	bod_avel
;
;
; PURPOSE:
;	Returns the angular velocity for each given body descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	avel = bod_avel(bx)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	bx:	 Array (nt) of any subclass of BODY descriptors.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Angular velocity value associated with each given body descriptor.
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
;===========================================================================
function bod_avel, bxp
@nv_lib.include
 bdp = class_extract(bxp, 'BODY')
 nv_notify, bdp, type = 1
 bd = nv_dereference(bdp)
 return, bd.avel
end
;===========================================================================
