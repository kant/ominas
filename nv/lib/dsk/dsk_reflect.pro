;=============================================================================
;+
; NAME:
;	dsk_reflect
;
;
; PURPOSE:
;	Computes ray reflections with a DISK object. 
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	v_int = dsk_reflect(dkx, v, r)
;
;
; ARGUMENTS:
;  INPUT:
;	dkx:	 Array (nt) of any subclass of DISK.
;
;	v:	 Array (nv x 3 x nt) of column vectors giving the observer
;		 position in the body frame.
;
;	r:	 Array (nv x 3 x nt) of column vectors giving the target
;		 position in the body frame.
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
;  OUTPUT: 
;	t:	Array(nv x 3 x nt) giving the distances to each reflection.
;		Values down each column are identical, i.e., this array
;		is a stack of three identical (nv x 1 x nt) arrays.
;
;	hit: 	Array giving the subscripts of the input rays that actually
;	 	reflect on the disk. 
;
;
; RETURN:
;	Array (nv x 3 x nt) of column vectors giving the ray/disk
;	reflections in the body frame. 
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function dsk_reflect, dkxp, v, r, t=t, hit=hit, frame_bd=frame_bd
@nv_lib.include
 dkdp = class_extract(dkxp, 'DISK')

 nt = n_elements(dkdp)
 nv = (size(v))[1]

 ;-----------------------------------------
 ; compute v, r projections in disk plane
 ;-----------------------------------------
 n = (bod_orient(dkdp))[2,*,*]				; nv x 3 x nt

 vn = (v_inner(v,n))[linegen3y(nv,3,nt)]		; nv x 3 x nt
 rn = (v_inner(r,n))[linegen3y(nv,3,nt)]		; nv x 3 x nt

 vp = v + n*vn 						; nv x 3 x n
 rp = r + n*rn 						; nv x 3 x n



 ;--------------------------------------
 ; compute reflection points
 ;--------------------------------------
 vv = (v_mag(vn))[linegen3y(nv,3,nt)]			; nv x 3 x nt
 rr = (v_mag(rn))[linegen3y(nv,3,nt)]			; nv x 3 x nt
 p = vp + (rp-vp) * vv/(vv+rr)


 ;---------------------------------------------------------------
 ; determine where reflection lies within radial limits
 ;---------------------------------------------------------------
 if(arg_present(hit)) then $
  begin
   p_disk = dsk_body_to_disk(dkdp, p, frame_bd=frame_bd)
   rad = dsk_get_radius(dkdp, p_disk[*,1,*], frame_bd)
   hit = where((p_disk[*,0,*] GT rad[*,0,*]) AND (p_disk[*,0,*] LT rad[*,1,*]))

   ;-------------------------------------------
   ; disks with only one edge cannot be 'hit'
   ;-------------------------------------------
   mark = bytarr(nv, nt)
   if(hit[0] NE -1) then mark[hit] = 1

   sma = (dsk_sma(dkdp))[0,*,*]
   w = where((sma[0,0,*] EQ -1) OR (sma[0,1,*] EQ -1))
   if(w[0] NE -1) then mark[w] = 0

   hit = where(mark NE 0)
  end



 return, p
end
;===========================================================================


