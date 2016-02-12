;=============================================================================
; best_radial_scale_feat
;
;=============================================================================
function best_radial_scale_feat, cd, rd, pd, $
         radmin=radmin, radmax=radmax, lonmin=lonmin, lonmax=lonmax, $ 
         pp_min=pp_min, pp_max=pp_max, pp0=pp0, resperp=resperp


 if(NOT keyword_set(radmax)) then $
   dsk_image_bounds, cd, rd, pd, $
          radmin=radmin, radmax=radmax, lonmin=lonmin, lonmax=lonmax


 rdtest = nv_clone(rd)
 sma = dsk_sma(rdtest) & sma[0] = max(sma) & dsk_set_sma, rdtest, sma


 ring_ps = pg_disk(cd=cd, dkx=rdtest, gbx=pd, fov=1)

 image_pts = pg_points(ring_ps[0])
 w = in_image(cd, image_pts)
 if(w[0] EQ -1) then return, 0
 image_pts = image_pts[*,w]

 inertial_pts = pg_vectors(ring_ps[0])

 dsk_projected_resolution, rd, cd, inertial_pts, (cam_scale(cd))[0], $
                perp=resperp


 w = where(resperp EQ min(resperp))
 disk_pt = inertial_to_disk(rd, inertial_pts[w,*], frame=pd)


 pp0 = image_pts[*,w]

 p = bod_body_to_inertial_pos(rd, $
       dsk_disk_to_body(rd, frame=pd, $
         image_to_disk(cd, rd, pp0, frame=pd)))
 vv = dsk_get_perp(cd, rd, p, frame=pd, uu=uu)


 diag = sqrt(total(cam_size(cd)^2))
 pp_min = pp0 - uu*diag
 pp_max = pp0 + uu*diag

 nv_free, rdtest

 return, resperp[w]
end
;=============================================================================



