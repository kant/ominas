;=============================================================================
;+
; NAME:
; 	pgs_read_ps
;
;
; PURPOSE:
; 	Reads a point structure file.
;
;
; CATEGORY:
; 	NV/PGS
;
;
; CALLING SEQUENCE:
; 	ps = pgs_read_ps(filename)
;
;
; ARGUMENTS:
;  INPUT:
; 	filename: Name of the point structure file to read.
;
;  OUTPUT: NONE
;
;
; KEYWORDS:
;  INPUT:
; 	bin:	If set, a binary point structure file is read;
; 		not currently implemented.
;
; 	visible:	If set, only visible points are returned.
;
; 	no_ps:	If set, point structures are not created.
;
;  OUTPUT:
; 	name:  Array names.
;
; 	desc:  Array descriptions.
;
; 	flags:  Array flags
;
; 	points:  Point arrays.
;
; 	vectors: Vector arrays.
;
;
; RETURN:
; 	Normally, this routine returns a pg_points_struct containing
; 	the points from the file.  If no_ps is set, then 0 is returned 
; 	instead.
;
;
; SEE ALSO:
;	pgs_write_ps
;
;
; MODIFICATION HISTORY:
;  Written by: Spitale, 1/2004
; 
;-
;=============================================================================



;=============================================================================
; pgs_read_ps_0
;
;=============================================================================
function pgs_read_ps_0, filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment

 lines = read_txt_file(filename, /raw)

 ;- - - - - - - - - - - - - - - - - - -
 ; get array names
 ;- - - - - - - - - - - - - - - - - - -
 w = where(strmid(lines, 0, 5)  EQ 'NAME:')
 if(w[0] NE -1) then name = lines[w+1]

 if(keyword_set(name)) then $
  begin
   nps = n_elements(name)

   ;- - - - - - - - - - - - - - - - - - -
   ; get comments
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines,0,1) EQ '#')
   if(w[0] NE -1) then $ 
    begin
     comment = lines[w]
     if(NOT keyword_set(silent)) then $
      begin
       print, filename + ':'
       print, tr(comment)
      end
    end

   ;- - - - - - - - - - - - - - - - - - -
   ; get array descriptions
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 5)  EQ 'DESC:')
   if(w[0] NE -1) then desc = lines[w+1]

   ;- - - - - - - - - - - - - - - - - - -
   ; get point flags
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 6)  EQ 'FLAGS:')
   if(w[0] NE -1) then $
    begin
     flags = bytarr(nps)
     for i=0, nps-1 do flags[i] = byte(lines[w[i]+1])
    end

   ;- - - - - - - - - - - - - - - - - - -
   ; get points
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 7)  EQ 'POINTS:')
   if(w[0] NE -1) then $
    begin
     ww = [w+1, w+2]
     ss = sort(ww)
     ww = ww[ss]
     points = reform(double(lines[ww]), 2, nps, /over)
    end

   ;- - - - - - - - - - - - - - - - - - -
   ; get vectors
   ;- - - - - - - - - - - - - - - - - - -
   w = where(strmid(lines, 0, 8)  EQ 'VECTORS:')
   if(w[0] NE -1) then $
    begin
     ww = [w+1, w+2, w+3]
     vectors = reform(double(lines[ww]), nps, 3, /over)
    end

  end


 ;- - - - - - - - - - - - - - - - - - - - -
 ; construct points structures
 ;- - - - - - - - - - - - - - - - - - - - -
 ps = replicate({pg_points_struct}, nps)
 for i=0, nps-1 do $
  begin
   if(keyword__set(flags)) then _flags = flags[i]
   if(keyword__set(desc)) then _desc = desc[i]
   if(keyword__set(points)) then _points = points[*,i]
   if(keyword__set(vectors)) then _vectors = vectors[i,*]
   ps[i] = pgs_set_points(ps[i], $
              name=name[i], desc=_desc, flags=_flags, $
              points=_points, vectors=_vectors)
  end


 return, ps
end
;===========================================================================



;=============================================================================
; pgsrps_get_next
;
;=============================================================================
function pgsrps_get_next, unit, token, stop=stop, status=status, n=n, $
                           bin=bin, buf=buf

 if(NOT keyword_set(n)) then n = 1
 status = 0

 if(keyword_set(bin)) then $
  begin
   readu, unit, buf
   return, buf
  end

 line = make_array(n, val='')
 done = 0
 while not eof(unit) do $
  begin
   fs = fstat(unit)
   save_ptr = fs.cur_ptr
   readf, unit, line
   if(NOT keyword_set(token)) then done = 1 $
   else $
    begin
     p = strpos(line, token) 
     if(p[0] NE -1) then done = 1
     if(keyword_set(stop) AND (NOT done)) then $
      begin
       p = strpos(line, stop) 
       if(p[0] NE -1) then $
        begin
         done = 1
         status = -1
         point_lun, unit, save_ptr
        end
      end
    end

   if(done) then return, strtrim(line,2)
  end

 status = -1
 return, ''
end
;=============================================================================



;=============================================================================
; pgs_read_ps_1
;
;=============================================================================
function pgs_read_ps_1, filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=p, vectors=v, $
         comment=comment, input=input, version=version, data=data, tags=tags

 
 openr, unit, filename, /get_lun

 ;- - - - - - - - - - - - - - - - - - -
 ; read the file
 ;- - - - - - - - - - - - - - - - - - -
 name_token = 'name ='

 line = pgsrps_get_next(unit)

 bin = 0
 fs = fstat(unit)
 save_ptr = fs.cur_ptr
 line = pgsrps_get_next(unit)
 p = strpos(line, 'binary')
 if(p[0] NE -1) then bin = 1 $
 else point_lun, unit, save_ptr


 done = 0
 repeat $
  begin
   ;- - - - - - - - - - - - - - - - - - -
   ; name, desc, n
   ;- - - - - - - - - - - - - - - - - - -
   line = pgsrps_get_next(unit, name_token, stat=stat)
   if(stat EQ -1) then done = 1 $
   else $
    begin
     name = strtrim(strep_s(line, name_token, ''), 2)
     desc = strtrim(strep_s(pgsrps_get_next(unit), 'desc =', ''), 2)
     if(version GT 0) then input = strtrim(strep_s(pgsrps_get_next(unit), 'input =', ''), 2)
     n = fix(strtrim((str_sep(pgsrps_get_next(unit), ' '))[2], 2))

     ;- - - - - - - - - - - - - - - - - - -
     ; points
     ;- - - - - - - - - - - - - - - - - - -
     line = pgsrps_get_next(unit, 'points:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = pgsrps_get_next(unit, n=n, bin=bin, buf=dblarr(2,n))
       if(bin) then p = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=ys)
         p = [tr(double(xs)), tr(double(ys))]
        end
      end

     ;- - - - - - - - - - - - - - - - - - -
     ; vectors
     ;- - - - - - - - - - - - - - - - - - -
     line = pgsrps_get_next(unit, 'vectors:', stop=':', stat=stat)
     v = 0
     if(stat EQ 0) then $
      begin
       buf = pgsrps_get_next(unit, n=n, bin=bin, buf=dblarr(3,n))
       if(bin) then v = buf $
       else $
        begin
         xs = str_nnsplit(buf, ' ', rem=rem)
         ys = str_nnsplit(rem, ' ', rem=zs)
         v = tr([tr(double(xs)), tr(double(ys)), tr(double(zs))])
        end
      end
 
     ;- - - - - - - - - - - - - - - - -
     ; point data
     ;- - - - - - - - - - - - - - - - -
     line = pgsrps_get_next(unit, 'point data:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       ss = str_nsplit(strcompress(line[0]), ' ')

       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; This is a crap protocol.  Shouldn't exist, but somehow does.
       ;  It looks like a protocol 1 file, but the point data are stored
       ;  like a protocol 0 file.
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if(n_elements(ss) EQ 2) then $
        begin
         done = 0
         repeat $
          begin
           readf, unit, line
           pp = strpos(line, ':')
           if(pp[0] EQ -1) then data = append_array(data, double(line)) $
           else done = 1
          endrep until(done)

         data = reform(data)
        end $
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       ; this is the real protocol...
       ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       else $
        begin
         nn = fix(ss[n_elements(ss)-1])

         buf = pgsrps_get_next(unit, n=n, bin=bin, buf=dblarr(nn,n))
         if(bin) then data = buf $
         else $
          begin
           lines = strcompress(buf)
           test = str_nsplit(lines[0], ' ')
           nn = n_elements(test)
           data = dblarr(n, nn)

           rem = lines

;           for i=0, nn-1 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           for i=0, nn-2 do data[*,i] = str_nnsplit(rem, ' ', rem=rem)
           data[*,i] = rem
          end

         if(n GT 1) then data = reform(data) 
        end

       data = transpose(data)
      end     


     ;- - - - - - - - - - - - - - - - -
     ; generic user data
     ;- - - - - - - - - - - - - - - - -
     line = pgsrps_get_next(unit, 'udata:', stop=':', stat=stat)
     if(stat EQ 0) then udata_tlp = tag_list_read(unit=unit, bin=bin)


     ;- - - - - - - - - - - - - - - - - - -
     ; tags
     ;- - - - - - - - - - - - - - - - - - -
     line = pgsrps_get_next(unit, 'tags:', stop=':', stat=stat)
     if(stat EQ 0) then $
          tags = pgsrps_get_next(unit, n=nn, buf=bytarr(nn))


     ;- - - - - - - - - - - - - - - - - - -
     ; flags
     ;- - - - - - - - - - - - - - - - - - -
     line = pgsrps_get_next(unit, 'flags:', stop=':', stat=stat)
     if(stat EQ 0) then $
      begin
       buf = pgsrps_get_next(unit, n=n, bin=bin, buf=bytarr(n))
       if(bin) then f = buf $
       else f = byte(fix(buf))
      end
   

     ;- - - - - - - - - - - - - - - - - - -
     ; make ps
     ;- - - - - - - - - - - - - - - - - - -
     ps = append_array(ps, $
             pgs_set_points({pg_points_struct}, $
                name=name, desc=desc, flags=f, $
                points=p, vectors=v, data=data, tag=tags, udata=udata_tlp) )
    end
  endrep until(done)


 close, unit
 free_lun, unit

 return, ps
end
;===========================================================================



;=============================================================================
; pgs_read_ps
;
;=============================================================================
function pgs_read_ps, filename, bin=bin, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment, data=data, tags=tags
@pgs_include.pro
nv_message, /con, name='pgs_read_ps', 'This routine is obsolete.'

 openr, unit, filename, /get_lun

 ;- - - - - - - - - - - - - - - - - - -
 ; read the file
 ;- - - - - - - - - - - - - - - - - - -
 line = ''
 readf, unit, line
 close, unit
 free_lun, unit


 ;---------------------------------------------------------------------
 ; Check protocol on line 0.  If none specified, then it's protocol 0
 ;---------------------------------------------------------------------
 protocol = 0
 s = str_sep(line, ' ')
 if(keyword_set(s[0])) then $
  begin
   if(s[0] NE 'protocol') then nv_message, name='pgs_read_ps', $
                                 'Syntax error in file ' + filename+ '.'
   w = str_isalpha(s[1])
   if(w[0] NE -1) then nv_message, name='pgs_read_ps', $
                                 'Syntax error in file ' + filename+ '.'
   protocol = fix(s[1])
   version = fix((float(s[1]) - protocol) * 10)
  end


 ;---------------------------------------------------------------------
 ; parse file according to protocol
 ;---------------------------------------------------------------------
 case protocol of
  0: begin
      ps = pgs_read_ps_0(filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment)
     end
  1: ps = pgs_read_ps_1(filename, visible=visible, $
         name=name, desc=desc, flags=flags, points=points, vectors=vectors, $
         comment=comment, version=version, input=input, data=data, tags=tags)
  else: nv_message, name='pgs_read_ps', 'Invalid protocol.'
 endcase


 ;-----------------------------------------
 ; filter out invisible points if desired
 ;-----------------------------------------
 if(keyword_set(visible)) then $
  begin
   nps = n_elements(ps)
   for i=0, nps-1 do $
    begin
     pgs_points, ps[i], $
        name=name, desc=desc, $
        flags=flags, points=points, vectors=vectors

     ww = where((flags AND PGS_INVISIBLE_MASK) EQ 0)
     if(ww[0] EQ -1) then ps[i] = pgs_null() $
     else $
      begin
       if(keyword_set(flags)) then flags = flags[ww]
       if(keyword_set(points)) then points = points[*,ww]
       if(keyword_set(vectors)) then vectors = vectors[ww,*]
       if(keyword_set(name)) then name = name[ww]
       if(keyword_set(desc)) then desc = desc[ww]

       ps = pgs_set_points(ps, $
          name=name, desc=desc, $
          flags=flags, points=points, vectors=vectors)
      end
    end
  end



 return, ps
end
;=============================================================================





