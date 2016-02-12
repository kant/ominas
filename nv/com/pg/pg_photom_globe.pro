;=============================================================================
;+
; NAME:
;	pg_photom_globe
;
;
; PURPOSE:
;	Photometric image correction for globe objects.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_photom_globe(dd, cd=cd, gbx=gbx)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor containing image to correct.
;
;
;  OUTPUT:
;	NONE
;
; KEYWORDS:
;  INPUT:
;	cd:	Camera descriptor
;
;	gbx:	Globe descriptor
;
;	sund:	Sun descriptor
;
;	gd:	Generic descriptor.  If present, cd and gbx are taken from 
;		here if contained.
;
; 	outline_ps:	points_struct with image points outlining the 
;			region of the image to correct.  To correct the entire
;			planet, this input could be generated using pg_limb(). 
;			If this keyword is not given, the entire image is used.
;
;	refl_fn:	String naming reflectance function to use.  Default is
;			'pht_refl_minneart'.
;
;	refl_parms:	Array of parameters for the photometric function named
;			by the 'refl_fn' keyword.
;
;	phase_fn:	String naming phase function to use.  Default is none.
;
;	phase_parms:	Array of parameters for the photometric function named
;			by the 'phase_fn' keyword.
;
;  OUTPUT:
;	emm_out:	Image emission angles.
;
;	inc_out:	Image incidence angles.
;
;	phase_out:	Image phase angles.
;
;
; RETURN:
;	Data descriptor containing the corrected image.  The photometric angles
;	emm, inc, and phase are placed in the user data arrays with the tags
;	'EMM', 'INC', and 'PHASE' respectively.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/2002 (pg_photom)
;	 Spitale, 6/2004:	changed to pg_photom_globe
;	
;-
;=============================================================================
function pg_photom_globe, dd, outline_ps=outline_ps, $
                  cd=cd, gbx=gbx, sund=sund, gd=gd, $
                  refl_fn=refl_fn, phase_fn=phase_fn, $
                  refl_parm=refl_parm, phase_parm=phase_parm, $
                  emm_out=emm_out, inc_out=inc_out, phase_out=phase_out

 ;-----------------------------------------------
 ; dereference the generic descriptor if given
 ;-----------------------------------------------
 pgs_gd, gd, cd=cd, gbx=gbx, sund=sund, dd=dd


 ;----------------------------------------------
 ; get phot functions; default is Lunar-Lambert
 ;----------------------------------------------
 if(NOT keyword_set(refl_fn)) then $
  begin
   refl_fn = sld_refl_fn(gbx)
   refl_parm = sld_refl_parm(gbx)
  end

 if(NOT keyword_set(phase_fn)) then $
  begin
   phase_fn = sld_phase_fn(gbx)
   phase_parm = sld_phase_parm(gbx)
  end

 if(NOT keyword_set(refl_fn)) then refl_fn = 'pht_refl_lunar_lambert'


 ;-----------------------------------------------
 ; validate descriptors
 ;-----------------------------------------------
 if(n_elements(cd) GT 1) then $
         nv_message, name='pg_photom_globe', 'Only one camera descriptor allowed.'
 if(n_elements(gbx) GT 1) then $
         nv_message, name='pg_photom_globe', 'Only one globe descriptor allowed.'
 if(n_elements(sund) GT 1) then $
         nv_message, name='pg_photom_globe', 'Only one sun descriptor allowed.'


 ;---------------------------------------
 ; dereference the data descriptor 
 ;---------------------------------------
 image = nv_data(dd)
; s = size(image)
; xsize = s[1] & ysize = s[2]
 xsize = (cam_nx(cd))[0] & ysize = (cam_ny(cd))[0]

 xysize = xsize*ysize


 ;---------------------------------------
 ; find relevant image points 
 ;---------------------------------------
 if(keyword_set(outline_ps)) then $
  begin
   p = ps_points(outline_ps)
   p = poly_rectify(p)
   indices = polyfillv(p[0,*], p[1,*], xsize, ysize)
  end $
 else indices = lindgen(xysize)

 xarray = indices mod ysize
 yarray = fix(indices / ysize) + 1

 nn = n_elements(xarray)

 image_pts = dblarr(2, nn)
 image_pts[0,*] = xarray
 image_pts[1,*] = yarray


 ;---------------------------------------
 ; compute photometric angles
 ;---------------------------------------
 pht_angles, image_pts, cd, gbx, sund, emm=mu, inc=mu0, g=g
 valid = where(mu0 NE 0)
 if(valid[0] EQ -1) then $
       nv_message, name='pg_photom_globe', 'No valid points in image region.'

 mu0 = mu0[valid] 
 mu = mu[valid] 
 g = g[valid] 
 indices = indices[valid]


 ;---------------------------------------
 ; correct the image
 ;---------------------------------------
 phase_corr = 1d
 if(keyword_set(phase_fn)) then $
                   phase_corr = call_function(phase_fn, g, phase_parm)
 refl_corr = call_function(refl_fn, mu, mu0, refl_parm)

 new_image = float(image)
 new_image[indices] = new_image[indices] / phase_corr / refl_corr
 new_image = new_image < max(image)

 ;---------------------------------------
 ; modify the data descriptor
 ;---------------------------------------
 dd_pht = nv_clone(dd)
 nv_set_data, dd_pht, new_image

 ;---------------------------------------
 ; fill output arrays
 ;---------------------------------------
 emm = fltarr(xsize,ysize)
 emm[indices] = mu
 nv_set_udata, dd_pht, emm, 'EMM'

 inc = fltarr(xsize,ysize)
 inc[indices] = mu0
 nv_set_udata, dd_pht, inc, 'INC'

 phase = fltarr(xsize,ysize)
 phase[indices] = g
 nv_set_udata, dd_pht, phase, 'PHASE'

 emm_out = emm
 inc_out = inc
 phase_out = phase_out

 return, dd_pht 
end
;=============================================================================
