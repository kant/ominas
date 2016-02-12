;=============================================================================
;+
; NAME:
;	pg_blemish
;
;
; PURPOSE:
;	Removes blemishes from an image using interpolation.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_blemish(dd, blem_ps)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor containing the image to be corrected.
;
;	blem_ps:	points_struct containing the known image
;			coordinates of the blemishes.  If an array of
;			points_struct is given, then the operation is
;			performed repeatedly using each set of blemish
;			coordinates. 
;
;			This argument can also be specified directly as an
;			array of image points.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;        a:		Semimajor axis of elliptical blemish model.  Default is
;			5 pixels.
;
;        b:		Semiminor axis of elliptical blemish model.  Default is
;			5 pixels.
;
;        h:		Angle of rotation (in radians) of smimajor axis from
;			horizontal.  Default is 0.
;
;	 show:		If set, the outlines of the blemishes are plotted on 
;			the current graphics window.
;
;  OUTPUT:
;	image:		The corrected image.
;
;
; RETURN:
;	Data descriptor containing the corrected image.
;
;
; PROCEDURE:
;	Blemishes are modeled as ellipses.  Pixels interior to the ellipse
;	are interpolated from those on the boundary.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_resloc, pg_linearize_image, pg_resfit
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 5/2002
;	
;-
;=============================================================================
function pg_blemish, dd, blem_ps, nom_ps, a=a, b=b, h=h, image=image, show=show

 if(NOT keyword_set(a)) then a = 5d
 if(NOT keyword_set(b)) then b = a
 if(NOT keyword_set(h)) then h = 0d

 ;------------------------------------------------------------
 ; count number of input arrays
 ;  if blem_ps is not a structure, then assume it's 
 ;  an array of image points.
 ;------------------------------------------------------------
 direct = 0
 s = size(blem_ps)
 type = s[s[0]+1]
 if(type EQ 8) then n = n_elements(blem_ps) $
 else $
  begin
   n = 1
   direct = 1
  end

 ;---------------------------------------
 ; dereference the data descriptor
 ;---------------------------------------
 image = nv_data(dd)

 for i=0, n-1 do $
  begin
   if(direct) then blem_pts = blem_ps $
   else blem_pts = ps_points(blem_ps[i])

   nblem = n_elements(blem_pts)/2


   ;------------------------------------------------------
   ; interpolate 
   ;------------------------------------------------------
   image = perim_interp(image, blem_pts, a, b, h, show=show)

  end


 new_dd = nv_clone(dd)
 nv_set_data, new_dd, image

 return, new_dd
end
;=============================================================================
