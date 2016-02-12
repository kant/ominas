;=============================================================================
;+
; NAME:
;	dsk_evolve
;
;
; PURPOSE:
;	Computes new disk descriptors at the given time offsets from the 
;	given disk descriptors using the taylor series expansion 
;	corresponding to the derivatives contained in the given disk 
;	descriptor.
;
;
; CATEGORY:
;	NV/LIB/BOD
;
;
; CALLING SEQUENCE:
;	dkdt = dsk_evolve(dkx, dt)
;
;
; ARGUMENTS:
;  INPUT: 
;	dkx:	 Any subclass of DISK.
;
;	dt:	 Time offset.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nodv:	 If set, derivatives will not be evolved.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (ndkd,ndt) of newly allocated descriptors, of class DISK,
;	evolved by time dt, where ndkd is the number of dkx, and ndt
;	is the number of dt.
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
function dsk_evolve, dkxp, dt, nodv=nodv
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')
 dkds = nv_dereference(dkdp)

 ndt = n_elements(dt)
 ndkd = n_elements(dkds)


 tdkds = _dsk_evolve(dkds, dt, nodv=nodv)


 tdkdps = ptrarr(ndkd, ndt)
 nv_rereference, tdkdps, tdkds

 return, tdkdps
end
;===========================================================================

