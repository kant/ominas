;=============================================================================
;+
; NAME:
;	map_fn_image_to_map
;
;
; PURPOSE:
;	Returns the name of the image->map function for each given map 
;	descriptor.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	fn_image_to_map = map_fn_image_to_map(md)
;
;
; ARGUMENTS:
;  INPUT: NONE
;	md:	 Array (nt) of map descriptors.
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
; RETURN:
;	Array (nt) of image->map function names associated with each given 
;	map descriptor.
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
function map_fn_image_to_map, mdp
@nv_lib.include
 nv_notify, mdp, type = 1
 md = nv_dereference(mdp)
 return, 'map_image_to_map_' + md.type
end
;===========================================================================
