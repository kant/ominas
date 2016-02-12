;==============================================================================
; ringplane_radial_bounds
;
;  Finds ringplane radial bounds by projection fov on ringplane.  
;
;==============================================================================
function ringplane_radial_bounds, cd, dkx, frame_bd=frame_bd

 v = (bod_orient(cd))[1,*] 			; optic axis vector
 n = (bod_orient(dkx))[2,*]			; ringplane normal
 p = bod_pos(cd)

 cam_size = cam_size(cd)

 theta = 0.5 * sqrt(0.5*(((cam_scale(cd))[0]*cam_size[0])^2 + $
                                      ((cam_scale(cd))[1]*cam_size[1])^2))

 axis = v_cross(n, v)

 sin_theta = sin(theta)
 cos_theta = cos(theta)
 v1 = v_rotate(v, axis, sin_theta, cos_theta)
 v2 = v_rotate(v, axis, -sin_theta, cos_theta)

 vv1 = dsk_intersect_inertial(dkx, p, v1)
 vv2 = dsk_intersect_inertial(dkx, p, v2)

 vv1_disk = inerrtial_to_disk(cd, dkx, vv1, frame_bd=frame_bd)
 vv2_disk = inerrtial_to_disk(cd, dkx, vv2, frame_bd=frame_bd)

 rad1 = vv1_disk[0]
 rad2 = vv1_disk[1]

 rads = [rad1, rad2]
 rads = rads[sort(rads)]

 return, rads
end
;==============================================================================
