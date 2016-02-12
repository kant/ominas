;================================================================================
; subimage
;
;================================================================================
function subimage, im, x0, y0, dx, dy

 if(NOT keyword_set(dy)) then dy = dx

 dx2 = dx/2
 dy2 = dy/2

 return, im[x0-dx2:x0+dx2, y0-dy2:y0+dy2]
end
;================================================================================
