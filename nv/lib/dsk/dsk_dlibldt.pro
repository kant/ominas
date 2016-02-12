;=============================================================================
;+
; NAME:
;	dsk_dlibldt
;
;
; PURPOSE:
;	Returns dlibldt for each given disk descriptor.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dlibldt = dsk_dlibldt(dkx)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	dkx:	 Any subclass of DISK.
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
;	dlibldt value associated with each given disk descriptor.
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
function dsk_dlibldt, dkxp
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')
 nv_notify, dkdp, type = 1
 dkd = nv_dereference(dkdp)
 return, dkd.dlibldt
end
;===========================================================================



