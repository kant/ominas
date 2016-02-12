;=============================================================================
;+
; NAME:
;	class_get_abbrev
;
;
; PURPOSE:
;	Returns the abbrieviation for the given object class.
;	This routine is obsolete.  Use cor_abbrev instead.
;
;
; CATEGORY:
;	NV/LIB/COR
;
;
; CALLING SEQUENCE:
;	abbrev = class_get_abbrev(xd)
;
;
; ARGUMENTS:
;  INPUT:
;	xd:	 Descriptor.
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
;	String giving the standard abbreviation for the given class, 
;	e.g., 'BOD'.
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
function class_get_abbrev, xd
 return, (*xd[0]).abbrev
end
;===========================================================================


