;==============================================================================
; band_intersection_area
;
;==============================================================================
function band_intersection_area, v1, n1, w1, v2, n2, w2
 return, abs(w1*w2 / p_inner(v1,n2)/p_inner(v2,n1) * p_mag(p_cross(v1,v2)))
end
;==============================================================================


