;=============================================================================
;+
; NAME:
;       remchar
;
;
; PURPOSE:
;       Removes a character from a string
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       remchar, s, c
;
;
; ARGUMENTS:
;  INPUT:
;       s:      An input string
;
;       c:      Character to remove
;
;  OUTPUT:
;       NONE
;
; KEYWORDS:
;       NONE
;
;
; STATUS:
;       Completed.
;
;
; MODIFICATION HISTORY:
;       Written by:     Spitale
;
;-
;=============================================================================
pro remchar, s, c
 p=strpos(s, c)
 if(p NE -1) then s = strmid(s, 0, p) + strmid(s, p+1, strlen(s)-p-1)
end
;===========================================================================
