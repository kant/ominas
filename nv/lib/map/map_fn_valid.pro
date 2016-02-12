;=============================================================================
;+
; NAME:
;	map_fn_valid
;
;
; PURPOSE:
;	Returns the name of the map->image validation function for each given 
;	map descriptor.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	fn_valid = map_fn_image_to_map(md)
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
;	Array (nt) of map->image validation function names associated with each given 
;	map descriptor.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 8/2012
;	
;-
;=============================================================================
function map_fn_valid, mdp
@nv_lib.include
 nv_notify, mdp, type = 1
 md = nv_dereference(mdp)
 return, 'map_valid_points_' + md.type
end
;===========================================================================
