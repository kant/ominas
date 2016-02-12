;=============================================================================
;+
; NAME:
;	map_map_to_image
;
;
; PURPOSE:
;	Transforms the given map points to map image points.
;
;
; CATEGORY:
;	NV/LIB/MAP
;
;
; CALLING SEQUENCE:
;	image_pts = map_map_to_image(md, map_pts)
;
;
; ARGUMENTS:
;  INPUT: 
;	md	 	Array (nt) of MAP descriptors.
;
;	map_pts:	Array (2,nv,nt) of map points.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: 
;	nowrap:	If set, then points that lie outide the map will not be
;		around to the other side.
;
;  OUTPUT: 
;	valid:	Indices of all input points that correspond to valid
;		output image points.  If not se then all points are
;		valid.
;
;
; RETURN:
;	Array (2,nv,nt) of map image points.
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
function map_map_to_image, mdp, _map_pts, valid=valid, nowrap=nowrap, all=all
 md = nv_dereference(mdp)

 nt = n_elements(md)
 nv = n_elements(_map_pts)/2/nt

 pi2 = !dpi/2d
 
 map_pts = _map_pts

 ii = transpose(linegen3z(2,nt,nv), [0,2,1])
 jj = transpose(gen3y(nt,nv,1))

 offset = (md.offset)[ii]
 size = double((md.size)[ii])
 rotate = (md.rotate)[jj]

 map_pts = map_pts - offset

 fn = map_fn_map_to_image(mdp[0])

 image_pts = call_function(fn, mdp, map_pts)
 image_pts = rotate_coord(image_pts, rotate, size=size)

 if(NOT keyword_set(nowrap)) then image_pts = map_wrap_points(md, image_pts, map_pts)

 if(NOT keyword_set(all)) then valid = map_valid_points(md, map_pts, image_pts) $
 else valid = lindgen(nv*nt)

 return, image_pts
end
;===========================================================================
