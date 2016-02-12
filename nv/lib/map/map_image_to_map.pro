;=============================================================================
;+
; NAME:
;	map_image_to_map
;
;
; PURPOSE:
;	Transforms the given image points to map coordinate points.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	map_pts = map_image_to_map(md, image_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	md	 	Array (nt) of MAP descriptors.
;
;	image_pts:	Array (2,nv,nt) of map image points.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: 
;	valid:	Indices of all input points that correspond to valid
;		output map points.  If not set then all points are
;		valid.
;
;
; RETURN:
;	Array (2,nv,nt) of map coordinate points.
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
function map_image_to_map, mdp, _image_pts, valid=valid
@nv_lib.include
 md = nv_dereference(mdp)

 nt = n_elements(md)
 nv = n_elements(_image_pts)/2/nt

 ii = transpose(linegen3z(2,nt,nv), [0,2,1])
 jj = transpose(gen3y(nt,nv,1))

 offset = (md.offset)[ii]
 size = (md.size)[ii]
 rotate = (md.rotate)[jj]

 image_pts = rotate_coord(_image_pts, rotate, /inverse, size=size)

 fn = map_fn_image_to_map(mdp)

 map_pts = call_function(fn, mdp, image_pts, valid=valid)
 if(NOT keyword_set(map_pts)) then $
  begin
   valid = [-1]
   return, 0
  end

 map_pts = map_pts + offset

 return, map_pts
end
;===========================================================================
