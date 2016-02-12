;===========================================================================
; pgs_size.pro
;
;===========================================================================
pro pgs_size, pp, nn=nn, nt=nt, nd=nd
nv_message, /con, name='pgs_size', 'This routine is obsolete.'

 nv_notify, pp, type = 1

 ;---------------------------------------------------------------
 ; if there are points, then get nn and nt from there
 ;---------------------------------------------------------------
 if(ptr_valid(pp.points_p)) then $
  begin
   s = size(*pp.points_p)
   if(s[0] EQ 1) then nn=1 else nn = s[2]
   nt = 1
   if(s[0] EQ 3) then nt = s[3]
  end $
 ;---------------------------------------------------------------
 ; otherwise, get nn and nt from the vectors array
 ;---------------------------------------------------------------
 else if(ptr_valid(pp.vectors_p)) then $
  begin
   s = size(*pp.vectors_p)
   nn = s[1]
   nt = 1
   if(s[0] EQ 3) then nt = s[3]
  end $
; else nv_message, name='pgs_size', 'Empty points structure.'
 else $
  begin
   nn = 0
   nt = 0
   nd = 0
  end

 ;---------------------------------------------------------------
 ; determine nd
 ;---------------------------------------------------------------
 if(ptr_valid(pp.data_p)) then nd = (size(*pp.data_p))[2]

end
;===========================================================================
