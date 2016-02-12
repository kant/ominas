;=============================================================================
;+
; NAME:
;	nv_ndd
;
;
; PURPOSE:
;	Returns the global maintenance ndd value.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	data = nv_ndd(dd)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT: NONE
;
;  OUTPUT: NONE
;
;
; RETURN:
;	The global maintenance ndd value.
;
;
; STATUS:
;	Complete
;
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 7/2008
;	
;-
;=============================================================================
function nv_ndd, ddp
@nv_block.common
 return, nv_state.ndd
end
;===========================================================================



