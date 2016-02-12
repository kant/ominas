;===========================================================================
; pgs_cat_ps
;
;===========================================================================
function pgs_cat_ps, ps
nv_message, /con, name='pgs_cat_ps', 'This routine is obsolete.'

 n = n_elements(ps)

 result = {pg_points_struct}

 for i=0, n-1 do $
  begin
   if(ptr_valid(ps[i].points_p)) then p = *ps[i].points_p
   if(ptr_valid(ps[i].vectors_p)) then v = *ps[i].vectors_p
   if(ptr_valid(ps[i].flags_p)) then f = *ps[i].flags_p
   if(ptr_valid(ps[i].tags_p)) then t = *ps[i].tags_p

; need to add the other fields...


   flags = append_array(flags, f)
   tags = append_array(tags, t)
   vectors = append_array(vectors, v)

   if(keyword_set(p)) then $
    begin
     s = size(p, /dim)
     ndim = n_elements(s)
     if(ndim EQ 1) then pp = reform(p, s[0], 1, 1) $
     else if(ndim EQ 2) then pp = reform(p, s[0], s[1], 1) $
     else pp = p

     points = append_array(points, transpose(pp, [1,2,0]))   
    end  
  end

 if(keyword_set(points)) then points = transpose(points, [2,0,1])

 pgs_points, ps[0], name=name, desc=desc, input=input

 result = pgs_set_points(result, name=name, desc=desc, input=input, $
                    points=points, vectors=vectors, flags=flags, tags=tags)

 return, result
end
;===========================================================================
