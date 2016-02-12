;=============================================================================
;+
; NAME:
;	dsk_body_to_disk
;
;
; PURPOSE:
;	Transforms vectors from the body coordinate system to the disk
;	coordinate system.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	v_disk = dsk_body_to_disk(dkx, v_body, frame_bd=frame_bd)
;
;
; ARGUMENTS:
;  INPUT:
;	dkx:	 Array (nt) of any subclass of DISK.
;
;	v_body:	 Array (nv x 3 x nt) of column vectors in the body 
;		 coordinate system.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  
;	frame_bd:	Subclass of BODY giving the frame against which to 
;			measure inclinations and nodes, e.g., a planet 
;			descriptor.
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array (nv x 3 x nt) of column vectors in the disk coordinate system.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function dsk_body_to_disk, dkxp, v, frame_bd=frame_bd
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')
 _ref = orb_get_ascending_node(dkdp, frame_bd)

 sv = size(v)
 nv = sv[1]
 nt = n_elements(dkdp)

 bd = class_extract(dkdp, 'BODY')

 ;----------------------------------
 ; radius
 ;----------------------------------
 rad = sqrt(v[*,0,*]^2 + v[*,1,*]^2)


 ;----------------------------------
 ; longitude
 ;----------------------------------

 ;- - - - - - - - - - - - - - - - - - - - - - -
 ; lon. w.r.t. asc. node of dkx on frame_bd
 ;- - - - - - - - - - - - - - - - - - - - - - -
 ref = _ref[linegen3x(nv,3,nt)]
 ref_body = bod_inertial_to_body(bd, ref)			; nv x 3 x nt
 pp = v & pp[*,2,*] = 0 					; nv x 3 x nt
 lon = v_angle(ref_body, pp)					; nv x nt
 zz = ((bod_orient(bd))[2,*,*])[linegen3x(nv,3,nt)]		; nv x 3 x nt
 ss = bod_inertial_to_body(bd, v_cross(zz, ref))		; nv x 3 x nt
 w = where(v_inner(ss, pp) LT 0)
 if(w[0] NE -1) then lon[w] = reduce_angle(2d*!dpi - lon[w])

 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
 ; add offset to asc. node of frame_bd on inertial frame to get true lon.
 ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 lan = make_array(nv,val=1d)#dsk_get_lan(dkdp, frame_bd)
 lon = lon + lan

 ;------------------------------------------
 ; package result
 ;------------------------------------------
 result = dblarr(nv,3,nt, /nozero)
 result[*,0,*] = rad				; radius
 result[*,1,*] = reduce_angle(lon)		; disk longitude
 result[*,2,*] = v[*,2,*]			; altitude

 ;------------------------------------------
 ; apply radial scale
 ;------------------------------------------
 result[*,0,*] = dsk_apply_scale(dkdp, result[*,0,*])

 return, result
end
;===========================================================================



;===========================================================================
; dsk_body_to_disk
;
; v is array (nv,3,nt) of 3-element column vectors. result is array 
; (nv,3,nt) of 3-element column vectors.
;
;===========================================================================
function _dsk_body_to_disk, dkxp, v, frame_bd=frame_bd
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')
 node = dsk_get_node(dkdp, frame_bd)
 return, body_to_disk(dkdp, v, node)
end
;===========================================================================



