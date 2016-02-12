;=============================================================================
;+
; NAME:
;	nv_set_header
;
;
; PURPOSE:
;	Replaces the header array associated with a data descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_set_header, dd, header
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	header:	New header array.
;
;  OUTPUT:
;	dd:	Modified data descriptor.
;
;
; KEYWORDS:
;  INPUT: 
;	update:	Update mode flag.  If not given, in will be taken from dd.
;
;	silent:	If set, messages are suppressed.
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
; SEE ALSO:
;	nv_header
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro nv_set_header, ddp, header, silent=silent, update=update
@nv.include
 dd = nv_dereference(ddp)

 if(NOT defined(update)) then update = dd.update
 if(update EQ -1) then return


 if((NOT keyword_set(silent)) and (dd.maintain GT 0)) then $
  nv_message, /con, name='nv_set_header', $
   'WARNING: Changes to header array may be lost due to the maintainance level.'


 ;-----------------------------
 ; modify header array 
 ;-----------------------------
 if(keyword_set(dd.header_dap)) then dap = dd.header_dap
 data_archive_set, dap, header, index=dd.dap_index
 dd.header_dap = dap
 dd.dap_index = 0


 ;--------------------------------------------
 ; generate write event
 ;--------------------------------------------
 nv_rereference, ddp, dd
 nv_notify, ddp, type = 0
 nv_notify, /flush

end
;===========================================================================



