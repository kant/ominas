;=============================================================================
;+
; NAME:
;	nv_id_string
;
;
; PURPOSE:
;	Returns the identification string associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	data = nv_id_string(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
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
;	The identification string associated with the data descriptor.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 11/2001
;	
;-
;=============================================================================
function nv_id_string, ddp
@nv.include
 nv_notify, ddp, type = 1
 dd = nv_dereference(ddp)
 return, dd.id_string
end
;===========================================================================



