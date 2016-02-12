;===========================================================================
;+
; NAME:
;	cam_image_to_focal_linear
;
;
; PURPOSE:
;       Transforms the given array of points in the image coordinate
;       system to an array of points in the camera focal plane
;       coordinate system using a linear model that assumes that
;       distances in the image are proportional to angles in the focal
;       plane.
;
;
; CATEGORY:
;	NV/LIB/CAM
;
;
; CALLING SEQUENCE:
;	focal_pts = cam_image_to_focal_linear(cd, image_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	cd:	        Array (nt) of CAMERA descriptors.
;
;	image_pts:	Array (2,nv,nt) of points in the image coordinate system.
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
;       Array (2,nv,nt) of points in the camera focal frame.
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
function cam_image_to_focal_linear, cxp, v
@nv_lib.include
 cdp = class_extract(cxp, 'CAMERA')
 cd = nv_dereference(cdp)

 sv = size(v)
 nv = 1
 if(sv[0] GT 1) then nv = sv[2]
 nt = n_elements(cd)

 vv = reform(v, 2,nv*nt)

 MM = make_array(nv, val=1)

 scale = dblarr(2,nv,nt,/nozero)
 scale[0,*,*] = [cd.scale[0,*,*]]##MM
 scale[1,*,*] = [cd.scale[1,*,*]]##MM

 oaxis = dblarr(2,nv,nt,/nozero)
 oaxis[0,*,*] = [cd.oaxis[0,*,*]]##MM
 oaxis[1,*,*] = [cd.oaxis[1,*,*]]##MM

 return, reform((vv - oaxis)*scale, 2,nv,nt, /over)
end
;===========================================================================



