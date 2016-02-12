;=============================================================================
;+
; NAME:
;       findfile1
;
;
; PURPOSE:
;       A more flexible version of the IDL routine findfile.
;
;
; CATEGORY:
;       UTIL
;
;
; CALLING SEQUENCE:
;       result = findfile1(filespec)
;
;
; ARGUMENTS:
;  INPUT:
;       filespec:       A filename that may contain the ~ symbol.
;
;  OUTPUT:
;       NONE
;
; RETURN:
;       Array of found filenames.
;
; PROCEDURE:
;       Under unix, the IDL findfile routine does not expand the ~ symbol,
;       but openr does.  In order to salvage some functionality, findfile1
;       allows filespecs to pass even if they don't expand to anything using
;       findfile.  In this way, a filespec containing ~ can be properly
;       expanded usng openr, but only if it expands to one filename.  If it
;       expands to multiple filenames, then openr will choke on it.
;
;	UPDATE 8/22/2012: Under idl 7.0, the '~' symbol is expanded by 
;	findfile.
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
function findfile1, filespec

 filenames=''
 for i=0, n_elements(filespec)-1 do $
  begin
   ff  = findfile(filespec[i])
   if(ff[0] NE '') then filenames = [filenames, ff] $
   else filenames = [filenames, filespec[i]]
  end

 if(n_elements(filenames) EQ 1) then return, ''

 return, filenames[1:*]
end
;=============================================================================
