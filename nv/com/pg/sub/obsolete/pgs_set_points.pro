;=============================================================================
;+
; NAME:
;	pgs_set_points
;
;
; PURPOSE:
;	Set fields of a points structure.
;
;
; CATEGORY:
;	NV/PGS
;
;
; CALLING SEQUENCE:
;	new_ps = pgs_set_points(ps, name=name, points=points, vectors=vectors, $
;	                        flags=flags, ...)
;
;
; ARGUMENTS:
;  INPUT:
;	ps:		Point structure whose fields are to be set.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
;	name:		Point structure name.
;
;	desc:		Point structure description.
;
;	input:		Description of input data.
;
;	assoc_idp:	ID pointer of associated descriptor.
;
;	points:		Array of image points; [2,np,nt].
;
;	vectors:	Array of column vectors; [np,3,nt].
;
;	flags:		Array of flags; [np,nt].
;
;	tags:		Tags for point data; [nd].  These strings may be used
;			by other programs to identify point-by-point data
;			given by the 'data' keyword.
;
;	data:		Data for each point; [nd,np,nt].
;
;	uname:		Name of a user data array.
;
;	udata:		User data to associate with uname.
;
;	
;
;  OUTPUT: NONE
;
;
; RETURN:
;	The returned point structure is identical to the input point structure
;	excet that the specified fields are modified.
;
;
; SEE ALSO:
;	pgs_points
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale, 1/1997
;	
;-
;=============================================================================
function pgs_set_points, pp, points=_points, $
                             vectors=_vectors, $
                             flags=flags, $
                             data=data, tags=tags, name=name, desc=desc, input=input, $
                             uname=uname, udata=udata, assoc_idp=assoc_idp, $
                             noevent=noevent, clear=clear

nv_message, /con, name='pgs_set_points', 'This routine is obsolete.'

 if(keyword_set(_points)) then points = _points
 if(keyword_set(_vectors)) then vectors = _vectors

 if(NOT ptr_valid(pp.idp)) then pp.idp = nv_ptr_new(0)

 pgs_size, pp, nn=nn, nt=nt, nd=nd

 ;-------------------------------
 ; set points
 ;-------------------------------
 if(keyword_set(points)) then $
  begin
   s = size(points, /dim)
   if(s[0] GT 1) then $
    begin
     ndim = n_elements(s)
     pnn = 1 & if(ndim GT 1) then pnn = s[1]
     pnt = 1 & if(ndim GT 2) then pnt = s[2]

     if(NOT ptr_valid(pp.points_p)) then pp.points_p = nv_ptr_new(points) $
     else *pp.points_p=points
    end
  end

 ;-------------------------------
 ; set vectors
 ;-------------------------------
 if(keyword_set(vectors)) then $
  begin
   s = size(vectors, /dim)
   ndim = n_elements(s)
   if(ndim GT 1) then $
    begin
     vnn = s[0]
     vnt = 1 & if(ndim GT 2) then vnt = s[2]

     if(NOT ptr_valid(pp.vectors_p)) then pp.vectors_p = nv_ptr_new(vectors) $
     else *pp.vectors_p=vectors
    end
  end


 ;------------------------------------------------
 ; check for point/vector array consistency
 ;------------------------------------------------
 if(keyword_set(pnn) AND keyword_set(vnn)) then $
  if(pnn NE vnn) then stop;nv_message, name='pgs_set_points', $
;                           'Inconsistent point and vector arrays.'
 if(keyword_set(pnt) AND keyword_set(vnt)) then $
  if(pnt NE vnt) then stop;nv_message, name='pgs_set_points', $
;                           'Inconsistent point and vector arrays.'

 if(keyword_set(vnn)) then pnn = vnn
 if(keyword_set(vnt)) then pnt = vnt
 if(NOT keyword_set(pnn)) then pnn = nn
 if(NOT keyword_set(pnt)) then pnt = nt


 ;-------------------------------
 ; set user data
 ;-------------------------------
 if(defined(udata)) then $
  begin
   if(keyword_set(uname)) then $ 
    begin
     tlp = pp.udata_tlp
     tag_list_set, tlp, uname, udata
     pp.udata_tlp = tlp
    end $
   else pp.udata_tlp = udata
  end

 ;-------------------------------
 ; set point-by-point data
 ;-------------------------------
 if(keyword_set(data)) then $
  begin
   if(NOT ptr_valid(pp.data_p)) then pp.data_p = nv_ptr_new(data) $
   else *pp.data_p=data
  end

 ;-------------------------------
 ; set tags
 ;-------------------------------
 if(keyword_set(tags)) then $
  begin
   if(NOT ptr_valid(pp.tags_p)) then pp.tags_p = nv_ptr_new(tags) $
   else *pp.tags_p=tags
  end

 ;-------------------------------
 ; set assoc_idp
 ;-------------------------------
 if(keyword_set(assoc_idp)) then pp.assoc_idp = assoc_idp

 ;-------------------------------
 ; set names
 ;-------------------------------
 if(keyword_set(name)) then pp.name = name

 ;-------------------------------
 ; set descriptions
 ;-------------------------------
 if(keyword_set(desc)) then pp.desc = desc

 ;-------------------------------
 ; set inputs
 ;-------------------------------
 if(keyword_set(input)) then pp.input = input


 ;-------------------------------
 ; set flags
 ;-------------------------------
 if(keyword_set(pnn)) then $
  begin 
   if(keyword__set(flags)) then $	; need keyword__set here -- thanks RSI.
    begin

     if(n_elements(flags) NE pnn*pnt) then $
         nv_message, name='pgs_set_points', 'Invalid flags array.'
 
     if(NOT ptr_valid(pp.flags_p)) then pp.flags_p = nv_ptr_new(byte(flags)) $
     else *pp.flags_p=byte(flags)
    end $
   else if(NOT ptr_valid(pp.flags_p)) then $
        if(nn + nt GT 0) then pp.flags_p = nv_ptr_new(bytarr(nn,nt))
  end 



 ;--------------------------------------------
 ; cleanse
 ;--------------------------------------------
 pgs_size, pp, nn=nn, nt=nt, nd=nd

 if((NOT ptr_valid(pp.points_p)) AND $
    (NOT ptr_valid(pp.vectors_p))) then nv_free, pp.flags_p
 if(ptr_valid(pp.points_p)) then $
    if(NOT keyword_set(*pp.points_p)) then nv_free, pp.points_p
 if(ptr_valid(pp.vectors_p)) then $
    if(NOT keyword_set(*pp.vectors_p)) then nv_free, pp.vectors_p

 if(NOT ptr_valid(pp.flags_p)) then $
  begin
    if(nn + nt GT 0) then pp.flags_p = nv_ptr_new(bytarr(nn,nt))
  end $
 else if(nn NE n_elements(*pp.flags_p)) then  $
         nv_message, name='pgs_set_points', 'Invalid flags array.'
 
 pp.npoints = nn

 if(keyword_set(clear)) then $
  begin
   nv_free, pp.points_p & pp.points_p = nv_ptr_new()
   nv_free, pp.vectors_p & pp.vectors_p = nv_ptr_new()
   nv_free, pp.flags_p & pp.flags_p = nv_ptr_new()
   pp.npoints = 0
  end




 if(NOT keyword_set(noevent)) then nv_notify, pp, type = 0
 return, pp
end
;===========================================================================
