;=============================================================================
; strcap
;
;
;=============================================================================
function strcap, s

 return, strupcase(strmid(s,0,1)) + strlowcase(strmid(s,1,strlen(s)-1))

end
;=============================================================================
