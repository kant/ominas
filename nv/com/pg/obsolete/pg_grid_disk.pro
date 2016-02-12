;=============================================================================
;+
; NAME:
;	pg_grid_disk
;
;
; PURPOSE:
;	Computes image points on a radius/longitude grid for objects that 
;	are a subclass of DISK.
;
;
;	***This routine is obsolete.  Use pg_grid instead.
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	grid_ps = pg_grid_disk(cd=cd, dkx=dkx, gbx=gbx)
;	grid_ps = pg_grid_disk(gd=gd)
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
;	dkx:	Array (n_objects, n_timesteps) of descriptors of objects 
;		which must be a subclass of DISK.
;
;	gbx:	Array  of descriptors of objects which must be a subclass 
;		of GLOBE, describing the primary body.  For each
;		timestep, only the first descriptor is used.
;
;	gd:	Generic descriptor.  If given, the cd and dkx inputs 
;		are taken from the cd and dkx fields of this structure
;		instead of from those keywords.
;
;	reveal:	Normally, points computed for objects whose opaque flag
;		is set are made invisible.  /reveal suppresses this behavior.
;
;	fov:	If set points are computed only within this many camera
;		fields of view.
;
;	cull:	If set, points structures excluded by the fov keyword
;		are not returned.  Normally, empty points structures
;		are returned as placeholders.
;
;	nrad:	Number of radial grid lines.  Default is 4.
;
;	nlon:	Number of longitudinal grid lines. Default is 36.
;
;	nrpoints:	Number of points per radial grid line. Defauly is 500.
;
;	nlpoints:	Number of points per longitudinal grid line. Defauly 
;			is 720.
;
;	rad:	If given, radii at which to put grid lines.
;
;	lon:	If given, longitudes at which to put grid lines.
;	
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (n_objects) of pg_points_struct containing image points and
;	the corresponding inertial vectors.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
function pg_grid_disk, cd=cd, dkx=dkx, gbx=_gbx, gd=gd, rad=rad, lon=lon, $
	nrad=nrad, nlon=nlon, nlpoints=nlpoints, nrpoints=nrpoints, fov=fov, $
        reveal=reveal, cull=cull
@pgs_include.pro

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, dkx=dkx, gbx=_gbx
 if(NOT keyword_set(cd)) then cd = 0 

 if(NOT keyword_set(_gbx)) then $
            nv_message, name='pg_grid_disk', 'Globe descriptor required.'
 __gbx = get_primary(cd, _gbx, rx=dkx)
 if(keyword_set(__gbx)) then gbx = __gbx $
 else gbx = _gbx[0,*]

  if(keyword_set(fov)) then slop = (cam_size(cd[0]))[0]*(fov-1) > 1

;-----------------------------------
 ; generate longitudes
 ;-----------------------------------
 if(n_elements(nrad) EQ 0) then nrad=4
 if(NOT keyword__set(nlpoints)) then nlpoints=720
 if(NOT keyword__set(nrpoints)) then nrpoints=500
 if(n_elements(lon) EQ 0) then $
  begin
   if(n_elements(nlon) EQ 0) then nlon=36
   lon=dindgen(nlon)/nlon*2*!dpi
  end

 ;-----------------------------------
 ; validate descriptors
 ;-----------------------------------
 nt = n_elements(cd)
 pgs_count_descriptors, dkx, nd=n_objects, nt=nt1
 if(nt NE nt1) then nv_message, name='pg_grid', $
                                   'Inconsistent camera and object timesteps.'


 ;-----------------------------------
 ; get grid for each disk
 ;-----------------------------------
 grid_ps = replicate({pg_points_struct}, n_objects)

 for i=0, n_objects-1 do $
  begin
   ii = dsk_valid_edges(dkx[i,*], /all)
   if(ii[0] NE -1) then $
    begin
     xd = reform(dkx[i,ii], nt)
     dkd = class_extract(xd, 'DISK')			; Object i for all t.

     ;-----------------------------------
     ; generate radii
     ;-----------------------------------
     if(n_elements(rad) EQ 0) then $
      begin
       drad = dsk_sma(dkd[0])
       radii = (dindgen(nrad)+1)/(nrad+1)*(drad[0,1]-drad[0,0]) + drad[0,0]
       radii = [drad[0,0], radii, drad[0,1]]
      end $
     else radii=rad


     ;-----------------------------------
     ; fov 
     ;-----------------------------------
     dlon = 0
     continue = 1
     if(keyword_set(fov)) then $
      begin
       dsk_image_bounds, cd, dkd, gbx, slop=slop, /plane, $
               lonmin=lonmin, lonmax=lonmax, radmin=radmin, radmax=radmax, $
                                         border_pts_im=border_pts_im
       if(NOT keyword_set(lonmin)) then continue = 0 
      end

     if(continue) then $
      begin
       grid_pts = dsk_get_grid_points(dkd, nlpoints, nrpoints, $
                           rad=radii, lon=lon, frame_bd=gbx, $
                    minlon=lonmin, maxlon=lonmax, minrad=radmin,maxrad=radmax)

       if(keyword__set(grid_pts)) then $
        begin 
         flags = bytarr(n_elements(grid_pts[*,0]))
         points = body_to_image_pos(cd, xd, grid_pts, $
                          frame_bd=gbx, inertial=inertial_pts, valid=valid)
         if(keyword__set(valid)) then $
          begin
           invalid = complement(grid_pts[*,0], valid)
           if(invalid[0] NE -1) then flags[invalid] = PGS_INVISIBLE_MASK
          end
         grid_ps[i] = $
            pgs_set_points( grid_ps[i], $
		name = get_core_name(dkd), $
		desc = 'disk_grid', $
		input = pgs_desc_suffix(dkx=dkx[i,0], gbx=gbx[0], cd=cd[0]), $
		assoc_idp = nv_extract_idp(xd), $
		points = points, $
		flags = flags, $
		vectors = inertial_pts )

         if(NOT bod_opaque(dkd)) then $
            grid_ps[i] = pgs_set_points(grid_ps[i], $
                   flags=make_array(n_elements(points)/2, val=PGS_INVISIBLE_MASK))
        end 
      end
    end
  end


 ;------------------------------------------------------
 ; crop to fov, if desired
 ;  Note, that one image size is applied to all points
 ;------------------------------------------------------
 if(keyword_set(fov)) then $
  begin
   pg_crop_points, grid_ps, cd=cd[0], slop=slop
   if(keyword_set(cull)) then grid_ps = pgs_cull(grid_ps)
  end



 return, grid_ps
end
;=============================================================================
