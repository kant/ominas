;=============================================================================
;+
; NAME:
;	nv_undo
;
;
; PURPOSE:
;	Increments the data archive index in the data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_undo, dd
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
; RETURN: NONE
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
pro nv_undo, ddp
@nv.include
 nv_notify, ddp, type = 1
 dd = nv_dereference(ddp)

 nhist = n_elements(*dd.data_dap)
 ii = dd.dap_index
 if(ii EQ nhist-1) then return

 data = data_archive_get(dd.data_dap, ii+1)
 if(NOT keyword_set(data)) then return

 dd.dap_index = dd.dap_index + 1
 *dd.dim_p = size(data, /dim)

 nv_rereference, ddp, dd
 nv_notify, ddp, type = 0
 nv_notify, /flush
end
;===========================================================================
