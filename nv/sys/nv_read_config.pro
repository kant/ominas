;=============================================================================
;+
; NAME:
;	nv_read_config
;
;
; PURPOSE:
;	Reads an NV configuration table.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_read_config, env, table_p, filenames_p
;
;
; ARGUMENTS:
;  INPUT:
;	env:	Name of an environment variable giving the names of the
;		configuration files to read, delimited by ':'.
;
;  OUTPUT:
;	table_p:	Pointer to the configuration table contructed by
;			concatenating the contents of each file.
;
;	filenames_p:	List of configuration filenames that were read.
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
pro nv_read_config, env, table_p, filenames_p, continue=continue
@nv.include

 ;----------------------------------
 ; separate files list
 ;----------------------------------
 filenames = str_nsplit(getenv(env), ':')

 w = where(filenames NE '')
 if(w[0] EQ -1) then return
 filenames = filenames[w]

 if(NOT keyword_set(filenames[0])) then $
  begin
;   nv_message, 'Unable to obtain ' + env +' from the environment.', $
;                                      name='nv_read_config', continue=continue
   return
  end


 ;----------------------------------
 ; concatenate all files
 ;----------------------------------
 n = n_elements(filenames)
 for i=0, n-1 do lines = append_array(lines, read_txt_file(filenames[i]))

 w = where(lines NE '')
 if(w[0] EQ -1) then return
 lines = lines[w]


 ;----------------------------------
 ; parse table
 ;----------------------------------
 table = read_txt_table(lines=lines)




 *filenames_p = filenames
 *table_p = table
end
;===========================================================================
