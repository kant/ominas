;===========================================================================
; dh_get_array
;
;
;===========================================================================
function dh_get_array, dh, keyword, history_index=history_index, $
                       n_obj=n_obj, dim=dim, status=status, section=section

 status=-1

 ;------------------------------------------
 ; get all values matching the prefix
 ;------------------------------------------
 val = dh_get_value(dh, keyword, history_index=history_index, $
                   /all_match, /all_obj, match_obj=match_obj, section=section)
 if(NOT keyword_set(val)) then return, nv_ptr_new()
 status=0

 ;------------------------------------------
 ; determine number of objects
 ;------------------------------------------
 dim=[1]
 n_obj=1
 if(NOT keyword_set(match_obj)) then return, [nv_ptr_new()]

 n_obj = max(match_obj)+1

 ;------------------------------------------
 ; create array of pointers
 ;------------------------------------------
 result = ptrarr(n_obj)

 for i=0, n_obj-1 do $
  begin
   w = where(match_obj EQ i)
   if(w[0] NE -1) then result[i] = nv_ptr_new(val[w])
  end


 return, reform(result, n_obj, /overwrite)
end
;===========================================================================
