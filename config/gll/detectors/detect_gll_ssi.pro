;===========================================================================
; detect_gll_ssi.pro
;
;===========================================================================
function detect_gll_ssi, dd

 label = (dat_header(dd));[0]
 if ~isa(label,/string) then return,0
 if( (strpos(label, 'SSI') NE -1) AND $
          (strpos(label, 'GALILEO') NE -1) ) then return, 'GLL_SSI'

 return, ''
end
;===========================================================================
