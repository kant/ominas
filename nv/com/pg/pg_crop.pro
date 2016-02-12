;=============================================================================
;++
; NAME:
;       pg_crop
;
;
; PURPOSE:
;       Crops an image and modifies that camera descriptor accordingly.
;
;
; CATEGORY:
;       NV/PG
;
;
; CALLING SEQUENCE:
;       pg_crop, dd, corner_ps, cd=cd, image=image
;
;
; ARGUMENTS:
;  INPUT:
;       dd:        Data descriptor containing the image to be cropped.
;
;	corner_ps: points_struct containing 2 points, giving the corners
;		   for cropping.  May also be an array of 2 image points.
;
;  OUTPUT:
;       dd:	The image contained in the input data descriptor is cropped.
;
;
; KEYWORDS:
;  INPUT:
;       cd:     Camera descriptor.
;
;       gd:     Generic descriptor to use instead of cd.
;
;  OUTPUT:
;	cd:	The optic axis of the camera descriptor is modified to 
;		correspond to the corrected image.
;
;       image:	The cropped image
;
;
; RETURN:
;       NONE
;
;
; EXAMPLE:
;	pg_crop, dd, cd=cd, [[100,200], [800,900]], im=im
;
;
; STATUS:
;       Complete.
;
;
; NOTES:
;	This routine should be modified to work with map descriptors as well.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale; 6/2005
;
;-
;=============================================================================
pro pg_crop, dd, corner_ps, cd=cd, gd=gd, image=image, crop=crop

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, dd=dd

 if(NOT keyword_set(crop)) then crop = 0

 cam_size = double(cam_size(cd))
 nx = cam_size[0] & ny = double(cam_size[1])

 if(NOT keyword_set(corner_ps)) then $
   corner_ps = tr([tr([0d,0]), tr([nx-1,0]), tr([nx-1,ny-1]), tr([0,ny-1])]) + 0.5

 if(size(corner_ps, /type) EQ 10) then corners = pg_points(corner_ps) $
 else corners = corner_ps


 ;-----------------------------------------------
 ; crop image
 ;-----------------------------------------------
 image = nv_data(dd)
 xmin = min(corners[0,*]) + crop
 xmax = max(corners[0,*]) - crop
 ymin = min(corners[1,*]) + crop
 ymax = max(corners[1,*]) - crop

 image = image[xmin:xmax, ymin:ymax]
 nv_set_data, dd, image


 ;-----------------------------------------------
 ; modify camera descriptor
 ;-----------------------------------------------
 cam_set_size, cd, [xmax - xmin + 1, ymax - ymin + 1]
; cam_set_nx, cd, xmax - xmin + 1
; cam_set_ny, cd, ymax - ymin + 1

 cam_set_oaxis, cd, cam_oaxis(cd) - [xmin, ymin]
 add_core_task, cd, 'pg_crop'

end
;=============================================================================
