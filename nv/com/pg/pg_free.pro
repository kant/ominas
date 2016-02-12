;=============================================================================
;+
; NAME:
;	pg_free
;
;
; PURPOSE:
;	Frees all pointers in the given structure.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_free, s
;
;
; ARGUMENTS:
;  INPUT:
;	s:	Array of structures containing pointers to be freed.
;
;  OUTPUT: NONE
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
; PROCEDURE:
;	All fields of the structure are searched for pointers to free.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro pg_free, object_ps

 n_objects=n_elements(object_ps)

 ;----------------------------
 ; scan objects
 ;----------------------------
 for i=0, n_objects-1 do $
  begin
   tags=tag_names(object_ps[i])

   ;------------------------------------------
   ; free any fields that are of pointer type
   ;------------------------------------------
   for j=0, n_elements(tags)-1 do $
    begin
     s=size(object_ps[i].(j))
     if(s[s[0]+1] EQ 10) then nv_ptr_free, object_ps[i].(j)
    end
  end

end
;===========================================================================



