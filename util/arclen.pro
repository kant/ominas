;===================================================================================
; arclen
;
;===================================================================================
function arclen, p, closed=closed

 pp = poly_rectify(p)
 dx = shift(pp[0,*], 1) - pp[0,*]
 dy = shift(pp[1,*], 1) - pp[1,*]

 if(NOT keyword_set(closed)) then $
  begin
   dx = dx[1:*]
   dy = dy[1:*]
  end

 d = sqrt(dx^2 + dy^2)

 return, total(d)
end
;===================================================================================
