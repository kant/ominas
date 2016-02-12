function photometric_angles, cd, sund, coords, gbx=gbx, dkx=dkx

;     cd = Camera descriptor
;     sund = Sun descriptor (star descriptor of class GLOBE)
;     gbx = Planet descriptor (of class GLOBE)
;     dkx = Ring descriptor (of class DISK)
; coords = If ring descriptor is given, radius (meters) and lon (radians)
;          of surface point.  If planet descriptor, lat and lon (radians).

if keyword__set(gbx) then begin

  gbd = class_extract(gbx, 'GLOBE')
  bd = class_extract(gbx, 'BODY')

  vertical = bod_body_to_inertial(bd, $
               local_vertical(gbd, coords))

  surface_coord = bod_body_to_inertial_pos(bd, $
                    glb_globe_to_body(gbd, coords))

endif else if keyword__set(dkx) then begin

  dkd = class_extract(dkx, 'DISK')
  bd = class_extract(dkx, 'BODY')

  vertical = bod_body_to_inertial(bd, [[0],[0],[1]])

  surface_coord = bod_body_to_inertial_pos(bd, $
                    dsk_disk_to_body(dkd, coords))

endif else begin

  message, 'Must specify either planet or ring.'

endelse

cam_bd = cam_body(cd)
camera_coord = bod_pos(cam_bd)

sgbd = class_extract(sund, 'GLOBE')
sun_bd = sld_body(sgbd)
sun_coord = bod_pos(sun_bd)

incidence = incidence_angle( surface_coord, sun_coord, vertical )
emission = emission_angle( surface_coord, camera_coord, vertical )
phase = phase_angle( surface_coord, camera_coord, sun_coord )

return, [ incidence, emission, phase ]

end


