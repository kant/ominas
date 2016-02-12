;=============================================================================
;+
; NAME:
;	sld_refl
;
;
; PURPOSE:
;	Computes a reflection function.
;
;
; CATEGORY:
;	NV/LIB/SLD
;
;
; CALLING SEQUENCE:
;	refl = sld_refl(sld, mu, mu0)
;
;
; ARGUMENTS:
;  INPUT:
;	sld:	 Globe descriptor.
;
;	mu:	 Cosine of the emission angle.
;
;	mu0:	 Cosine of the incidence angle.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:  NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	Refletion function value for the given mu and mu0 parameters.
;
;
; PROCEDURE:
;	The function indicated by the refl_fn field of the solid descriptor
;	is called and its return value is passed through to the caller of
;	sld_phase.  
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale
;	
;-
;=============================================================================
function sld_refl, sldp, mu, mu0

 sld = nv_dereference(sldp)
 return, call_function(sld.refl_fn, mu, mu0, sld.refl_parm)

end
;==================================================================================
