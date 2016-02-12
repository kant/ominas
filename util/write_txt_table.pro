;===========================================================================
; write_txt_table
;
;===========================================================================
pro write_txt_table, fname, data, header=header

 nhead = n_elements(header)

 s = size(data)
 n = s[1]

 openw, unit, fname, /get_lun

 for i=0, nhead-1 do printf, unit, header[i]
 printf, unit, '%'
; for i=0, n-1 do printf, unit, string(tr(data[i,*]))
 for i=0, n-1 do printf, unit, str_comma_list(tr(data[i,*]), delim='	')


 close, unit
 free_lun, unit


end
;===========================================================================
