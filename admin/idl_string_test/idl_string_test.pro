;===========================================================================
; idl_string_test
;
;
;===========================================================================
pro idl_string_test


 names = ['name1', 'name2', 'name3']

 status = call_external('./idl_string_test.so', 'idl_string_test', $
                         value=[0,0], names, n_elements(names))


end
;===========================================================================
