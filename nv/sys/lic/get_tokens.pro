;==============================================================================
; lic_filename; disguised as get_tokens
;
;
;==============================================================================
function get_tokens, gg=gg, proto=proto

 on_error, 2

;lic_validate_pwd...
 tvhash, 3b, gg=gg
 gg = 0

 ;---------------------------------------------------------------
 ; License file is $OMINAS_LICENSE
 ;  strings encoded using bcode, so that they don't appear in
 ;  the .sav file
 ;---------------------------------------------------------------
 ; "OMINAS_LICENSE"
 env =  string(byte([114,110,115,102,120,132,113,110,104,106, $
                                                         115,120,106]) - 37b)
 filename = getenv(env)

 ;---------------------------------------------------------------
 ; Default license file is $OMINAS_DIR/ominas_license.dat
 ;  strings encoded using bcode, so that they don't appear in
 ;  the .sav file
 ;---------------------------------------------------------------
 ; "OMINAS_DIR"
 env =  string(byte([146,142,147,134,152,164,137,142,151]) - 69b)

 top_path = getenv(env) + '/'


  ; "ominas_license.dat"
  fname = string(byte([166,162,167,154,172,152,165,162, $
                       156,158,167,172,158,103,157,154,173]) - 57b)

  ; "ominas_prototype.dat"
  pfname = string(byte([174,170,175,162,180,160,177,179,176, $
                       181,176,181,186,177,166,111,165,162,181]) - 65b)

 if(NOT keyword__set(filename)) then filename = top_path + fname


 proto = './' + pfname
; proto = top_path + pfname


 return, filename
end
;==============================================================================


