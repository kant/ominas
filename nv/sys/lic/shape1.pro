;==============================================================================
; lic_validate; disguised as "shape1.pro"
;
;==============================================================================
pro shape1, gg=gg

 on_error, 2

;lic_validate_pwd...
 tvhash, 0b, gg=gg
 gg = 0


 ;----------------------------------------
 ; read binary license file
 ;----------------------------------------
           ;lic_filename...
 filename = get_tokens(gg=438309913l)
          ;lic_read...
 _id = maxz(filename, settings=settings, gg=438309913l)
 if(size(_id, /type) NE 7) then $
  begin
   case _id of
    ; "There is no license file for this OMINAS installation."
    -1 : nv_message, /cont, $
 	    string(byte([117,137,134,147,134,65,138,148,65,$
                  143,144,65,141,138,132,134,143,148,134,65,135,$
                  138,141,134,65,135,144,147,65,149,137,138,148,$
                  65,110,106,111,98,116,65,138,143,148,149,130,$
                  141,141,130,149,138,144,143,79]) - 33b)
    ; "Invalid OMINAS license file."
    -2 : nv_message, /cont, $
	    string(byte([146,183,191,170,181,178,173,105,150,146,$
                  151,138,156,105,181,178,172,174,183,188,174, $
                  105,175,178,181,174,119]) - 73b)
    ; "I/O error, code = "
    -3 : nv_message, /cont, $
	    string(byte([90,64,96,49,118,131,131,128,131]) - 17b)
   endcase
   exit
  end

 ;----------------------------------------
 ; get hostid from local host
 ;----------------------------------------
         ;lic_gethost...
 id = optimize_2d(gg=438309913l)

 ;--------------------------------------------------------------
 ; encrypt hostid and compare with encrypted license info
 ;--------------------------------------------------------------
 __id = enigma(settings, id)
 settings = 0

 if(_id NE __id) then $
  begin
   ; "Invalid OMINAS license file"
   nv_message, /cont, $
        string(byte([146,183,191,170,181,178,173,105,150,146,$
                  151,138,156,105,181,178,172,174,183,188,174, $
                  105,175,178,181,174]) - 73b) + ': ' + filename
   exit
  end

 ;--------------------------------------------------------------
 ; print some info about OMINAS
 ;--------------------------------------------------------------
 dir = getenv('OMINAS_DIR')
 version = read_txt_file(dir + 'version')
 cdate = read_txt_file(dir + 'cdate')

 print, 'This is OMINAS version ' + version + '; compiled ' + cdate + '.'
; print, 'spitale@lpl.arizona.edu ' ...

end
;==============================================================================
