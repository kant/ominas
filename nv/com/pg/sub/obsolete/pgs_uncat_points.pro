;==============================================================================
; pgs_uncat_points
;
;
;==============================================================================
function pgs_uncat_points, p
 nv_message, /con, name='pgs_uncat_points', 'This routine is obsolete.'

 np = n_elements(p)/2

 ps = replicate({pg_points_struct}, np)

 for i=0, np-1 do $
  begin
   ps[i] = pgs_set_points(ps[i], p=p[*,i])
  end

 return, ps
end
;==============================================================================
