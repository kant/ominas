;=============================================================================
;+
; NAME:
;       str_sp
;
;
; PURPOSE:
;       Returns a spectral type for each given star descriptor.
;
;
; CATEGORY:
;       NV/LIB/STR
;
;
; CALLING SEQUENCE:
;       result = str_sp(sd)
;
;
; ARGUMENTS:
;  INPUT:
;       sd:    Array (t) of star descriptors
;
;  OUTPUT:
;       NONE
;
;
; KEYWORDS:
;         NONE
;
; RETURN:
;       An array (nt) of spectral types which is a three character string.
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Haemmerle, 5/1998
; 	Adapted by:	Spitale, 5/2016
;
;-
;=============================================================================
function str_sp, sd, noevent=noevent
@core.include

 nv_notify, sd, type = 1, noevent=noevent
 _sd = cor_dereference(sd)
 return, _sd.sp
end
;===========================================================================



