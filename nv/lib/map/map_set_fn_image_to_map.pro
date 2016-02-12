;=============================================================================
;+
; NAME:
;	map_set_fn_image_to_map
;
;
; PURPOSE:
;	Replaces the name of the image->map function for each given map 
;	descriptor.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	map_set_fn_image_to_map, md, fn
;
;
; ARGUMENTS:
;  INPUT: NONE
;	md:	Array (nt) of map descriptors.
;
;	fn:	Array (nt) of function names.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
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
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
pro map_set_fn_image_to_map, mdp, fn
@nv_lib.include
 md = nv_dereference(mdp)

 md.fn_image_to_map=fn

 nv_rereference, mdp, md
 nv_notify, mdp, type = 0
end
;===========================================================================
