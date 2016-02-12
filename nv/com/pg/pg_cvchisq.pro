;=============================================================================
;+
; NAME:
;	pg_cvchisq
;
;
; PURPOSE:
;	Computes chi-squared value for given curve fit parameters.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	chisq = pg_cvchisq(dxy, dtheta, scan_ps, axis_ps=axis_ps)
;
;
; ARGUMENTS:
;  INPUT:
;	dxy:		2-element vector giving the translation as [dx,dy].
;
;	dtheta:		Rotation in radians.
;
;	scan_ps:	Array (n_curves) of points_struct output from
;			pg_cvscan containing scanned image points as well as
;			other necessary scan data.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	axis_ps:	points_struct containing a single image  point
;			to be used as the axis of rotation.
;
;	fix:		Array specifying which parameters to fix as
;			[dx,dy,dtheta].
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Chi-square value.
;
;
; RESTRICTIONS:
;	The caller is responsible for ensuring that the input parameters are
;	consistent with those used with other programs like pg_fit.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_cvscan, pg_cvscan_coeff, pg_cvchisq, pg_ptscan, pg_ptscan_coeff,
;	pg_ptchisq, pg_fit, pg_threshold
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 6/1998
;	
;-
;=============================================================================
function pg_cvchisq, dxy, dtheta, scan_ps, axis_ps=axis_ps, fix=fix
                 

 n_objects = n_elements(scan_ps)
 chisq = 0d


 ;===============================================
 ; compute chi-squared for each object
 ;===============================================
 for i=0, n_objects-1 do $
  begin
   ;-------------------
   ; get scan data
   ;-------------------
   ps_get, scan_ps[i], data=scan_data, points=scan_pts, /visible

   if(keyword__set(scan_data)) then $
    begin

     cos_alpha = scan_data[0,*]
     sin_alpha = scan_data[1,*]
     scan_offsets = scan_data[2,*]

     axis = dblarr(2)
     if(keyword__set(axis_ps)) then axis = ps_points(axis_ps)

     ;----------------------
     ; compute chi-squared
     ;----------------------
     chisq = chisq + icv_chisq(dxy, dtheta, fix, $
                        cos_alpha, sin_alpha, scan_offsets, scan_pts, axis)
    end
  end



 return, chisq
end
;===========================================================================
