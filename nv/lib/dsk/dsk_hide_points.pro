;=============================================================================
;+
; NAME:
;	dsk_hide_points
;
;
; PURPOSE:
;	Hides points wrt a DISK object.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	sub = dsk_hide_points(dkx, r, points)
;
;
; ARGUMENTS:
;  INPUT:
;	dkx:	 Array (nt) of any subclass of DISK.
;
;	r:	 Column vector giving the position of the viewer in the disk
;		 body frame.
;
;	points:	 Array (nv x 3 x nt) of points to test, given in the disk
;		 body frame
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
;	epsilon:	Distance in front of the disk for a point to be
;			considered "in front of" the disk.  Default is 1.
;
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Array Subscripts of all input vectors (points argument) that are hidden 
;	from the viewer at r by the given disk.
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function dsk_hide_points, dkxp, r, points, epsilon=epsilon, frame_bd=frame_bd;, invert=invert
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')

 if(NOT keyword_set(epsilon)) then epsilon = 1d

 nt = n_elements(dkdp)
 nv = (size(points))[1]

 rr = r[gen3y(nv,3,nt)]
 v = points-rr

 p = dsk_intersect(dkdp, rr, v, frame_bd=frame_bd, hit=hit)
 if(hit[0] EQ -1) then return, -1

 ii = colgen(nv,3,nt,hit)

 p = p[ii]
 rr = rr[ii]
 v = v[ii]
 
 pmag = v_mag(p-rr)
 vmag = v_mag(v)

; if(keyword_set(invert)) then w = where(pmag - vmag LT -epsilon) $
; else w = where(pmag - vmag LT -epsilon)
 w = where(pmag - vmag LT -epsilon)

 if(w[0] EQ -1) then return, -1
 sub = ii[w,0]

 return, sub
end
;===========================================================================



;===========================================================================
; dsk_hide_points.pro
;
; Inputs are in disk body coordinates.
;
; Returns subscripts of points that are hidden from the viewer at r by the disk.
;
;===========================================================================
function _dsk_hide_points, dkxp, r, points, epsilon=epsilon, frame_bd=frame_bd, $
              invert=invert
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')


 nt = n_elements(dkdp)
 nv = (size(points))[1]

 rr = r[gen3y(nv,3,nt)]
 v = points-rr
 vmag = v_mag(v)

 p = dsk_intersect(dkdp, rr, v, frame_bd=frame_bd)
 pmag = v_mag(p-rr)


 p_rp = dsk_body_to_disk(dkdp, p, frame_bd=frame_bd)
 rad = dsk_get_radius(dkdp, p_rp[*,1,*], frame_bd)

 if(NOT keyword_set(epsilon)) then epsilon = 1d-8 * rad[0,1,0]

 if(NOT keyword_set(invert)) then $
   sub = where( $
         (p_rp[*,0,*] GT rad[*,0,*] AND p_rp[*,0,*] LT rad[*,1,*]) AND $
                                                    (vmag - pmag GT epsilon) ) $
 else $
   sub = where( $
         (p_rp[*,0,*] GT rad[*,0,*] AND p_rp[*,0,*] LT rad[*,1,*]) AND $
                                                    (vmag - pmag LT epsilon) )
 return, sub
end
;===========================================================================

