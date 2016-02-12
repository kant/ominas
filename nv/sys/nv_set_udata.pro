;=============================================================================
;+
; NAME:
;	nv_set_udata
;
;
; PURPOSE:
;	Creates or replaces a user data array associated with a data
;	descriptor.
;
;
; CATEGORY:
;	NV/SYS
;
;
; CALLING SEQUENCE:
;	nv_set_data, dd, data, name
;
;
; ARGUMENTS:
;  INPUT:
;	dd:	Data descriptor.
;
;	name:	String giving the name of the user data array.  If the name 
;		exists, then the corresponding data array is replaced.  
;		Otherwise, a new array is created with this name. 
;
;	data:	New data array.
;
;  OUTPUT: NONE
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
;	nv_udata
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro nv_set_udata, ddp, udata, name, silent=silent, update=update
@nv.include
 dd = nv_dereference(ddp)

 if(NOT defined(update)) then update = dd.update
 if(update EQ -1) then return


 if((NOT keyword_set(silent)) and (dd.maintain GT 0)) then $
  nv_message, /con, name='nv_set_udata', $
   'WARNING: Changes to user data array may be lost due to the maintainance level.'


 ;-----------------------------
 ; modify udata array 
 ;-----------------------------
 if(NOT keyword_set(name)) then dd.udata_tlp = udata $
 else $
  begin
   tlp = dd.udata_tlp
   tag_list_set, tlp, name, udata
   dd.udata_tlp = tlp
  end

 ;--------------------------------------------
 ; generate write event
 ;--------------------------------------------
 nv_rereference, ddp, dd
 nv_notify, ddp, type = 0
 nv_notify, /flush
end
;===========================================================================



