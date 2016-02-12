;=============================================================================
;+
; NAME:
;	dsk_set_lib_lan
;
;
; PURPOSE:
;	Sets lib_lan in each given disk descriptor.  This value is determined 
;	by the orientation of the BODY axes.
;
;
; CATEGORY:
;	NV/LIB/DSK
;
;
; CALLING SEQUENCE:
;	dsk_set_lib_lan, bx, lib_lan, frame_bd
;
;
; ARGUMENTS:
;  INPUT: 
;	dkx:	 Array (nt) of any subclass of DISK.
;
;	lib_lan:	 New lib_lan value.
;
;	frame_bd:	Subclass of BODY giving the frame against which to 
;			measure inclinations and nodes, e.g., a planet 
;			descriptor.  One for each dkx.
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
; 	Written by:	Spitale, 1/1998
;	
;-
;=============================================================================
pro dsk_set_lib_lan, dkx, lib_lan, frame_bd
@nv_lib.include
 dkd = class_extract(dkx, 'DISK')

 if(NOT keyword_set(frame_bd)) then $
             nv_message, name='dsk_set_lib_lan', 'frame_bd required.'

 orb_set_lib_lan, dkd, frame_bd, lib_lan

end
;===========================================================================
