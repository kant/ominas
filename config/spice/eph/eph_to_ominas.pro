;=============================================================================
; eph_to_ominas
;
;=============================================================================
function eph_to_ominas, _od

 if(NOT keyword__set(_od)) then return, 0

 od = nv_clone(_od)

 gbd = class_extract(od, 'GLOBE')

 bd = sld_body(gbd)
 bod_set_pos, bd, bod_pos(bd)*1000d           ; km --> m
 bod_set_vel, bd, bod_vel(bd)*1000d           ; km/s --> m/s
 glb_set_radii, gbd, glb_radii(gbd)*1000d     ; km --> m
 sld_set_gm, gbd, sld_gm(gbd)*1d9, /nosynch   ; km3/s2kg --> m3/s2kg
 glb_set_rref, gbd, glb_rref(gbd)*1000d       ; km --> m
 sld_set_body, gbd, bd
 return, od


 return, od
end
;=============================================================================


