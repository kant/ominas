;=============================================================================
;+
; NAME:
;	pg_to_disk
;
;
; PURPOSE:
;       Converts image coordinates to disk plane coordinates.  Input
;       array can be array of image points or a points_struct.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;       result = pg_to_disk(image_points, cd=cd, dkx=dkx) 
;       result = pg_to_disk(image_points, gd=gd)
;
;
; ARGUMENTS:
;  INPUT:
;        image_points:     Array (n_points) of image points (x,y) or
;                          array of type points_struct.
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;  INPUT:
;                  cd:     Array (n_timesteps) of camera descriptors.
;
;                 dkx:     Array (n_objects, n_timesteps) of descriptors of
;                          objects that must be a subclass of DISK.
;
;                  gd:     Generic descriptor.  If given, the cd and dkx
;                          inputs are taken from the cd and dkx fields of 
;                          this structure instead of from those keywords.
;
;                  ps:     If set, image_points is treated as a structure
;                          of type points_struct.
;
;  OUTPUT:
;        NONE
;
; RETURN:
;	Array (n_points) of disk points (radius and longitude).
;
; STATUS:
;	Completed.
;
;
; SEE ALSO:
;	pg_to_surface
;
;
; MODIFICATION HISTORY:
; 	Written by:	Haemmerle,  5/1998
;	
;-
;=============================================================================
function pg_to_disk, image_points, cd=cd, dkx=dkx, gbx=_gbx, gd=gd, $
                       ps=ps


 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, dkx=dkx

 if(NOT keyword__set(_gbx)) then $
            nv_message, name='pg_to_disk', 'Globe descriptor required.'
 __gbx = get_primary(cd, _gbx, rx=dkx)
 if(keyword__set(__gbx)) then gbx = __gbx $
 else gbx = _gbx[0,*]

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(cd)
 pgs_count_descriptors, dkx, nd=n_objects, nt=nt1
 if(nt NE nt1) then nv_message, name='pg_get_plane', 'Inconsistent timesteps.'


 ;------------------------------------------------------------
 ; compute ring plane points for all image points at all times
 ;------------------------------------------------------------
 if(keyword__set(ps)) then image_pts = ps_points(image_points, /visible) $
 else image_pts = image_points


 disk_pts = image_to_disk(cd, dkx, image_pts, frame_bd=gbx)


 return, disk_pts
end
;=============================================================================
