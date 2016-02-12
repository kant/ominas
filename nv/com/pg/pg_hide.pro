;=============================================================================
;+
; NAME:
;	pg_hide
;
;
; PURPOSE:
;	Hides the given points with respect to each given object and observer
;	using pg_hide/rm_disk, pg_hide/rm_globe, or pg_hide_limb.
;
;
; CATEGORY:
;	NV/PG
;
;
; CALLING SEQUENCE:
;	pg_hide, object_ps, cd=cd, od=od, gbx=gbx, dkx=dkx, /[disk|globe|limb]
;	pg_hide, object_ps, gd=gd, od=od, /[disk|globe|limb]
;
;
; ARGUMENTS:
;  INPUT: 
;	object_ps:	Array of points_struct containing inertial vectors.
;
;	hide_ps:	Array (n_disks, n_timesteps) of points_struct 
;			containing the hidden points.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	globe:	If set, use pg_hide_globe or pg_rm_globe.
;
;	disk:	If set, use pg_hide_disk or pg_rm_disk.
;
;	limb:	If set, use pg_hide_limb .
;
;	rm:	If set use the *rm* programs instead of *hide* programs.
;
;	  All other keywords are passed directly to pg_rm/hide_globe,
;	  pg_hide/rm_disk or pg_hide_limb and are documented with those
;	  programs.
;
;  OUTPUT: NONE
;
;
; RETURN: NONE
;
;
; SIDE EFFECTS:
;	The flags arrays in object_ps are modified.
;
;
; PROCEDURE:
;	For each object in object_ps, hidden points are computed and
;	PS_MASK_INVISIBLE in the points_struct is set.  No points are
;	removed from the array.
;
;
; EXAMPLE:
;	(1) The following command hides all points on the planet which lie
;	    behind the terminator:
;
;	    pg_hide, object_ps, /limb, gbx=pd, od=sd
;
;	    In this call, pd is a planet descriptor, and sd is a star descriptor
;	    (i.e., the sun).
;
;
;
;	(2) This command hides all points on the planet which are shadowed by
;	    the rings:
;
;	    pg_hide, object_ps, /disk, dkx=rd, od=sd
;
;	    In this call, rd is a ring descriptor, and sd is as above.
;
;
;
;	(3) This command hides all points which lie behind the planet or the
;	    rings:
;
;	    pg_hide, object_ps, /disk, /globe, dkx=rd, gbx=pd, cd=cd
;
;	    In this call, rd is a ring descriptor, pd is a planet descriptor, 
;	    cd is a camera descriptor, and sd is as above.
;
;
; STATUS:
;	Complete
;
;
; SEE ALSO:
;	pg_hide_disk, pg_hide_globe, pg_hide_limb
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 2/1998
;	
;-
;=============================================================================
pro pg_hide, object_ps, hide_ps, cd=cd, $
             od=od, gbx=gbx, dkx=dkx, gd=gd, one2one=one2one, $
	     globe=globe, limb=limb, disk=disk, rm=rm, reveal=reveal, cat=cat


 if(arg_present(hide_ps)) then hide_ps = 1	; need this to allow called routines
						; to detect presence of hide_ps argument.

 ;--------------------------
 ; remove instead of hide
 ;--------------------------
 if(keyword_set(rm)) then $
  begin
   if(keyword_set(disk)) then $
      pg_rm_disk, object_ps, hide_ps, cd=cd, dkx=dkx, gbx=gbx, gd=gd, reveal=reveal, cat=cat
   if(keyword_set(globe)) then $
      pg_rm_globe, object_ps, hide_ps, cd=cd, gbx=gbx, gd=gd, reveal=reveal, cat=cat
  end $
 ;--------------------------
 ; hide
 ;--------------------------
 else $
  begin
   ps = object_ps
;   if(keyword_set(one2one)) then ps = ps_compress(object_ps)
;if(keyword_set(one2one)) then stop

   if(keyword_set(disk)) then $
     pg_hide_disk, ps, hide_ps, cd=cd, od=od, dkx=dkx, gbx=gbx, gd=gd, reveal=reveal, cat=cat
   if(keyword_set(globe)) then $
     pg_hide_globe, ps, hide_ps, cd=cd, od=od, gbx=gbx, gd=gd, reveal=reveal, cat=cat

;if(keyword_set(one2one)) then stop
;   if(keyword_set(one2one)) then ps_uncompress, object_ps, ps

   if(keyword_set(limb)) then $
     pg_hide_limb, ps, hide_ps, cd=cd, od=od, gbx=gbx, gd=gd, reveal=reveal
  end



end
;=============================================================================
