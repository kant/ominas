;=============================================================================
;+
; NAME:
;	pg_footprint
;
;
; PURPOSE:
;	Computes the footprint of a camera on a given body.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;       footprint_ps = footprint(cd=cd, bx=bx)
;
;
; ARGUMENTS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	cd:	Array (n_timesteps) of camera descriptors.
;
;	bx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		which must be a subclass of BODY.
;
;	gd:	Generic descriptor.  If given, the cd and bx inputs 
;		are taken from the cd and bx fields of this structure
;		instead of from those keywords.
;
;	frame_bd:	Subclass of BODY giving the frame against which to 
;			measure inclinations and nodes, e.g., a planet 
;			descriptor.  One per bx.
;
;	fov:	 If set points are computed only within this many camera
;		 fields of view.
;
;	sample:	 Sampling rate; default is 1 pixel.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n_objects) of points_struct containing image points and
;	the corresponding inertial vectors.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2014
;	
;-
;=============================================================================
function pg_footprint, cd=cd, od=od, bx=bx, gd=gd, frame_bd=frame_bd, fov=fov, $
    sample=sample
@ps_include.pro

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, bx=bx, od=od
 if(NOT keyword_set(cd)) then cd = 0 

 if(NOT keyword_set(bx)) then return, ptr_new()

 ;-----------------------------
 ; default observer is camera
 ;-----------------------------
 if(NOT keyword_set(od)) then od=cd

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(cd)
 nt1 = n_elements(od)
 pgs_count_descriptors, bx, nd=n_objects, nt=nt2
 if(nt NE nt1 OR nt1 NE nt2) then nv_message, $
                          name='pg_footprint', 'Inconsistent timesteps.'

 ;-----------------------------------------------
 ; determine points description
 ;-----------------------------------------------
 desc = class_get(bx) + '_footprint'


 ;-----------------------------------
 ; get footprint for each object
 ;-----------------------------------
 footprint_ps = ptrarr(n_objects)

 for i=0, n_objects-1 do $
  begin
   surface_pts = footprint(od, bx, frame_bd=frame_bd, sample=sample, $
                                               valid=valid, body_pts=body_pts)
   if(keyword_set(surface_pts)) then $
    begin 
     flags = bytarr(n_elements(body_pts[*,0]))
     points = body_to_image_pos(cd, bx, body_pts, inertial=inertial_pts, valid=valid)

     if(keyword__set(valid)) then $
      begin
       invalid = complement(body_pts[*,0], valid)
       if(invalid[0] NE -1) then flags[invalid] = PS_MASK_INVISIBLE
      end

     footprint_ps[i] = $
        ps_init(name = get_core_name(bx), $
		desc = desc[i], $
		input = pgs_desc_suffix(bx=bx[i,0], cd=cd[0]), $
		assoc_idp = nv_extract_idp(bx), $
		vectors = inertial_pts, $
                flags = flags, $
		points = points)

     ps_set_udata, footprint_ps[i], name='SURFACE_PTS', surface_pts
     ps_set_udata, footprint_ps[i], name='BODY_PTS', body_pts

     if(NOT bod_opaque(bx[i,0])) then 
              ps_set_flags, footprint_ps[i], $
                           make_array(n_elements(flags), val=PS_MASK_INVISIBLE)
    end 
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(fov)) then $
  begin
   pg_crop_points, footprint_ps, cd=cd[0], slop=slop
   if(keyword_set(cull)) then footprint_ps = ps_cull(footprint_ps)
  end


 return, footprint_ps
end
;=============================================================================
