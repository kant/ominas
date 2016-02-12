;=============================================================================
;+
; NAME:
;	nv_dereference
;
;
; PURPOSE:
;	Turns an array of pointers to descriptors into an array of descriptors.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	result = nv_dereference(dp)
;
;
; ARGUMENTS:
;  INPUT:
;	dp:	Array of pointers to an arbitrary type of descriptor.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS: NONE
;
;
; RETURN:
;	Array of descriptors (structures).
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	nv_rereference
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/2002
;	
;-
;=============================================================================
function nv_dereference, dp
@nv.include

 if(size(dp, /type) NE 10) then return, dp

 s = size(dp)
 n1 = (n2 = 1)
 if(s[0] GT 0) then n1 = s[1]
 if(s[0] GT 1) then n2 = s[2]

 d = replicate(*dp[0], n1, n2)
 for j=0, n2-1 do $
  for i=0, n1-1 do $
   begin
    ii = j*n1 + i
    d[ii] = *dp[ii]
   end


 return, d
end
;=============================================================================
