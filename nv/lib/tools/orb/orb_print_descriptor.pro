;==============================================================================
; orb_get_elements
;
;==============================================================================
pro orb_get_elements, rd, gbx, t=t

 if(NOT keyword__set(t)) then t = bod_time(gbx)

 ;-----------------------------------------
 ; precess to epoch
 ;-----------------------------------------
 gbxt = glb_evolve(gbx, bod_time(gbx) - t)
 rdt = orb_evolve(rd, gbx, bod_time(rd) - t)

 ;-----------------------------------------
 ; compute precessing elements
 ;-----------------------------------------



end
;==============================================================================
