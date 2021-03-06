;===========================================================================
;+
; NAME:
;	cam_evolve
;
;
; PURPOSE:
;       Computes new camera descriptors at the given time offsets from
;       the given camera descriptors using the taylor series expansion
;       corresponding to the derivatives contained in the given camera
;       descriptor.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	cdt = cam_evolve(cd, dt)
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	 Array (ncd) of CAMERA descriptors.
;
;	dt:	 Array (ndt) of time offsets.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nodv:	 If set, velocities will not be evolved.
;
;	copy:	If set, the evolved descriptor is copied into the input
;		descriptor and it is freed.  The input descriptor is returned.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;       Array (ncd,ndt) of newly allocated camera descriptors evolved
;       by time dt, where ncd is the number of cd, and ndt is the
;       number of dt.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1998
; 	Adapted by:	Spitale, 5/2016
;	
;-
;===========================================================================
function cam_evolve, cd, dt, nodv=nodv, copy=copy
@core.include
 return, bod_evolve(cd, dt, nodv=nodv, copy=copy)
end
;===========================================================================



