;=============================================================================
;+
; NAME:
;	pg_hide_limb
;
;
; PURPOSE:
;	Hides the given points with respect to the limb of each given globe and
;	observer.  This routine is only relevant for points that lie on the 
;	surface of a body.  pg_hide_globe should be used for non-surface
;	points.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_hide_limb, object_ps, cd=cd, od=od, gbx=gbx
;	pg_hide_limb, object_ps, gd=gd, od=od
;
;
; ARGUMENTS:
;  INPUT:
;	object_ps:	Array of points_struct containing inertial vectors.
;
;	hide_ps:	Array (n_disks, n_timesteps) of points_struct 
;			containing the hidden points.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	gbx:	Array (n_globes, n_timesteps) of descriptors of objects 
;		which must be a subclass of GLOBE.  n_globes must be the
;		same as the number of object_ps arrays.
;
;	od:	Array (n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.  These objects are used
;		as the observer from which points are hidden.  If no observer
;		descriptor is given, the camera descriptor is used.
;
;	gd:	Generic descriptor.  If given, the cd and gbx inputs 
;		are taken from the cd and gbx fields of this structure
;		instead of from those keywords.
;
;	reveal:	 Normally, objects whose opaque flag is set are ignored.  
;		 /reveal suppresses this behavior.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	The flags arrays in object_ps are modified.
;
;
; RESTRICTIONS:
;	The result is meaningless if the given inertial vectors do not lie
;	on the surface of the globe.
;
;
; PROCEDURE:
;	For each object in object_ps, hidden points are computed and
;	PS_MASK_INVISIBLE in the points_struct is set.  No points are
;	removed from the array.
;
;
; EXAMPLE:
;	The following command hides all points which lie on the surface of the
;	planet behind the limb as seen by the camera:
;
;	pg_hide_limb, object_ps, cd=cd, gbx=pd
;
;	In this call, pd is a planet descriptor, and cd is a camera descriptor.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_hide, pg_hide_globe, pg_hide_disk
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro pg_hide_limb, cd=cd, od=od, gbx=gbx, gd=gd, point_ps, hide_ps, $
              reveal=reveal
@ps_include.pro

 hide = keyword_set(hide_ps)
 if(NOT keyword_set(point_ps)) then return

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, gbx=gbx, od=od
 if(NOT keyword_set(cd)) then cd = 0 

 ;-----------------------------
 ; default observer is camera
 ;-----------------------------
 if(NOT keyword_set(od)) then od=cd

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(od)
 n_objects = n_elements(point_ps)
 pgs_count_descriptors, gbx, nd=n_globes, nt=nt1
 if(nt NE nt1) then nv_message, name='pg_hide_limb', 'Inconsistent timesteps.'
 if(n_globes NE n_objects) then nv_message, name='pg_hide_limb', $
                                                        'Inconsistent inputs.'

 if(hide) then hide_ps = ptrarr(n_objects)

 ;------------------------------------
 ; hide object points for each planet
 ;------------------------------------
 obs_pos = bod_pos(od)
 for i=0, n_globes-1 do $
  if((bod_opaque(gbx[i,0])) OR (keyword_set(reveal))) then $
   begin
    xd = reform(gbx[i,*], nt)
    gbds = class_extract(xd, 'GLOBE')

    Rs = bod_inertial_to_body_pos(gbds, obs_pos)

    ps_get, point_ps[i], p=p, vectors=vectors, flags=flags
    object_pts = bod_inertial_to_body_pos(gbds, vectors)

    w = glb_hide_points_limb(gbds, Rs, object_pts)

    if(hide) then $
     begin
      ps_get, point_ps[i], desc=desc, inp=inp
      hide_ps[i] = $
         ps_init(desc=desc+'-hide_limb', $
                 input=inp+pgs_desc_suffix(gbx=gbx[i,0], od=od[0], cd=cd[0]))
     end

    if(w[0] NE -1) then $
     begin
      if(hide) then $
           ps_set, hide_ps[i], p=p[*,w], flags=flags[w], vectors=vectors[w,*]
      flags[w] = flags[w] OR PS_MASK_INVISIBLE
      ps_set_flags, point_ps[i], flags
     end
   end



end
;=============================================================================
