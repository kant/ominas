;=============================================================================
; write_ext
;
;=============================================================================
pro write_ext, filename, data, label

 extname = ext_get_name(filename, /write)
 call_procedure, extname, filename, data
end
;=============================================================================