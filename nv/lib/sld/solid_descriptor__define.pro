;=============================================================================
;+
; NAME:
;	solid_descriptor__define
;
;
; PURPOSE:
;	Class structure fo the SOLID class.
;
;
; CATEGORY:
;	NV/LIB/SLD
;
;
; CALLING SEQUENCE:
;	N/A 
;
;
; FIELDS:
;	bd:	BODY class descriptor.  
;
;		Methods: sld_body, sld_set_body
;
;
;	opacity: Normalized opacity for ray tracing.
;
;		Methods: sld_opacity, sld_set_opacity
;
;
;	GM:	Mass x gravitational constant.
;
;		Methods: sld_gm, sld_set_gm
;
;
;	mass:	Body mass.  This field and GM are kept in sync unless
;		/nosync is used in sld_set_mass or sld_set_gm.
;
;		Methods: sld_mass, sld_set_mass
;
;
;	phase_fn: String giving the name of a phase function to be defined as 
;		  follows:
;
;		  function <name>, mu, mu0, parm
;
;		  The function should return a value corresponding to the 
;		  phase function with emission cosine mu and incidence 
;		  cosine mu0.
;
;		  Methods: sld_phase_fn, sld_set_phase_fn
;
;
;	phase_parm:	Array (npht) of parameters to pass to the phase
;			function.
;
;		  Methods: sld_phase_parm, sld_set_phase_parm
;
;
;	refl_fn:  String giving the name of a reflection function to be defined as 
;		  follows:
;
;		  function <name>, mu, mu0, parm
;
;		  The function should return a value corresponding to the 
;		  reflection function with emission cosine mu and incidence 
;		  cosine mu0.
;
;		  Methods: sld_refl_fn, sld_set_refl_fn
;
;
;	refl_parm:	Array (npht) of parameters to pass to the reflection
;			function.
;
;		  Methods: sld_refl_parm, sld_set_refl_parm
;
;
;	albedo:	Bond albedo.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2015
;	
;-
;=============================================================================
pro solid_descriptor__define

 npht = sld_npht()

 struct = $
    { solid_descriptor, $
	bd:		 nv_ptr_new(), $	; ptr to body descriptor
	class:		 '', $			; Name of descriptor class
	abbrev:		 '', $			; Abbreviation of descriptor class
						; ellipsoid radius.  
	;----------------------------------------
	; photometric parameters
	;----------------------------------------
	refl_fn:	 '', $			; Photometric functions
	refl_parm:	 dblarr(npht), $
	phase_fn:	 '', $	
	phase_parm:	 dblarr(npht), $

	albedo:		 0d, $			; Bond albedo
	opacity:	 0d, $			; Opacity 

	;----------------------------------------
	; dynamical parameters
	;----------------------------------------
	GM:		0d, $			; better for dynamics
	mass:		0d $			; mass

    }

end
;===========================================================================
