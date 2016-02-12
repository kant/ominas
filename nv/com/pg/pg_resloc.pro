;=============================================================================
;+
; NAME:
;	pg_resloc
;
;
; PURPOSE:
;	Scans an image for candidate reseau marks.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	result = pg_resloc(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor containing the image to scan.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;        edge:  Distance from edge within which points are ignored.
;
;       ccmin:  Minimum correlation coefficient to accept.  Default is 0.8 . 
;
;       gdmax:  Maximum gradiant of correlation coefficient to accept. 
;		Default is 0.25
;
;       model:  2-D array giving a model of the reseau image.  Default model
;		is an inverted Gaussian.
;
;	nom_ps:	If given, reseau marks are searched for only within the
;		given radius about each nominal point.
;
;	radius:	Radius about no_ps to search.  Default is ten pixels.
;
;  OUTPUT:
;	NONE
;
;
; RETURN:
;	Points structure containing the image coordinates of each candidiate
;	reseau mark and the corresponding correlation coefficients.  If not 
;	marks are found, zero is returned.
;
;
; PROCEDURE:
;	A correlation map is computed across image.  Candidates reseau marks 
;	are identified as local maxima in the correlation map by accepting
;	points where the correlation is above the specified threshold and 
;	where the gradient of the correlation map is below the specified 
;	threshold.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_resfit, modloc
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1998
;	
;-
;=============================================================================
function pg_resloc, dd, edge=edge, model=model, $
                       ccmin=ccmin, gdmax=gdmax, nom_ps=nom_ps,radius=radius


 image = nv_data(dd)
 s = size(image)
 if(NOT keyword_set(edge)) then edge = s[1]/50

 if(NOT keyword_set(ccmin)) then ccmin=0.8
 if(NOT keyword_set(gdmax)) then gdmax=0.25

 if(NOT keyword_set(radius)) then radius = 10

 ;----------------------------------
 ; use default model if none given
 ;----------------------------------
 if(NOT keyword_set(model)) then model = 1.-gauss_2d(0, 0, 1, 9, 9)

 ;----------------------------------
 ; locate candidate reseaus
 ;----------------------------------
 if(NOT keyword_set(nom_ps)) then $
  begin
   points = locmod(image, model, edge=edge, ccmin=ccmin, gdmax=gdmax, coeff=cc)
   if(NOT keyword_set(points)) then return, 0
  end $
 else $
  begin
   p = pg_points(nom_ps)
   n = n_elements(p)/2
   nom__ps = ptrarr(n)
   for i=0, n-1 do ps_set_points, nom__ps[i], p[*,i]

   scan_ps = pg_ptscan(dd, nom__ps, model=model, $
                          width=radius, ccmin=ccmin, gdmax=gdmax, cc_out=cc)

   points = pg_points(scan_ps)
   if(NOT keyword_set(points)) then return, 0
  end

 ;--------------------
 ; save the scan data
 ;--------------------
 scan_data = transpose(cc)
 tags = ['scan_cc']

 points_ps = ps_init(points = points, $
                     desc = 'reseau_location', $
                     data = scan_data, $
                     tags = tags)


 return, points_ps
end
;=============================================================================
