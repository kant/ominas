;=============================================================================
;+
; NAME:
;	dsk_disk_to_body
;
;
; PURPOSE:
;	Transforms vectors from the disk coordinate system to the body
;	coordinate system.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	v_body = dsk_disk_to_body(dkx, v_dsk, frame_bd=frame_bd)
;
;
; ARGUMENTS:
;  INPUT:
;	dkx:	 Array (nt) of any subclass of DISK.
;
;	v_disk:	 Array (nv x 3 x nt) of column vectors in the disk
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
;	Array (nv x 3 x nt) of column vectors in the body coordinate system.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function dsk_disk_to_body, dkxp, v, frame_bd=frame_bd
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')
 _ref = orb_get_ascending_node(dkdp, frame_bd)

 sv = size(v)
 nv = sv[1]
 nt = n_elements(dkdp)

 rad = v[*,0,*]
 lon = v[*,1,*]

 bd = class_extract(dkdp, 'BODY')

 ref_inertial = _ref[linegen3x(nv,3,nt)]			; nv x 3 x nt

 ;------------------------------------------------------------------------
 ; subtract lon. of ascending node before rotating
 ;------------------------------------------------------------------------
 lan = make_array(nv,val=1d)#dsk_get_lan(dkdp, frame_bd)
 lon = lon - lan

 ;------------------------------------------
 ; rotate reference vector along disk plane
 ;------------------------------------------
 ref = bod_inertial_to_body(bd, ref_inertial)
 zz = (tr([0,0,1])##make_array(nv,val=1d))[linegen3z(nv,3,nt)]				; nv x 3 x nt
 pp = v_rotate_11(ref, zz, sin(lon), cos(lon))

 ;------------------------------------------
 ; apply radius
 ;------------------------------------------
 rrad = rad[linegen3y(nv,3,nt)]
 vv = pp*rrad

 ;------------------------------------------
 ; package result
 ;------------------------------------------
 result = dblarr(nv,3,nt, /nozero)
 result[*,0,*] = vv[*,0,*]
 result[*,1,*] = vv[*,1,*]
 result[*,2,*] = v[*,2,*]

 ;------------------------------------------
 ; apply radial scale
 ;------------------------------------------
 result[*,0,*] = dsk_apply_scale(dkdp, result[*,0,*], /inverse)

 return, result
end
;===========================================================================



;===========================================================================
; dsk_disk_to_body
;
; v is array (nv,3,nt) of 3-element column vectors. result is array 
; (nv,3,nt) of 3-element column vectors.
;
;===========================================================================
function _dsk_disk_to_body, dkxp, v, frame_bd=frame_bd
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')
 node = dsk_get_node(dkdp, frame_bd)
 return, disk_to_body(dkdp, v, node)
end
;===========================================================================



