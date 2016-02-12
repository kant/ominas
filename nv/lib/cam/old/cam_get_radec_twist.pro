;===========================================================================
; cam_get_radec_twist
;
;===========================================================================
pro cam_get_radec_twist, cd, ra=ra, dec=dec, twist=twist

 orient = bod_orient(cd)
 radec = bod_body_to_radec(bod_inertial(), orient[1,*,*])
 ra = radec[*,0,*]
 dec = radec[*,1,*]

 cel_north = -image_celestial_northangle(cd)
 twist = reduce_angle(!dpi - cel_north)

end
;===========================================================================



