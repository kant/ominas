;==============================================================================
; corot_to_disk_lon
;
;==============================================================================
function corot_to_disk_lon, corot_lons, cd=cd, dkx=dkx, frame_bd=frame_bd, t0=t0, $
           dmldt=dmldt, times=times

 if(NOT keyword_set(t0)) then t0 = 0d
 nv = n_elements(corot_lons)

 if(NOT keyword_set(dmldt)) then dmldt = orb_compute_dmldt(dkx, frame_bd)
 if(NOT keyword_set(times)) then times = bod_time(cd)

 lon0 = dmldt * (times - t0[0])

 disk_lons = reduce_angle(corot_lons + lon0##make_array(nv,val=1d))

 return, disk_lons
end
;==============================================================================
