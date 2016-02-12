;===========================================================================
; pgs_trim_invisible_points.pro
;
;===========================================================================
function pgs_trim_invisible_points, points, flags, sub=sub, $
                                                    x0=x0, y0=y0, x1=x1, y1=y1
@pgs_include.pro
nv_message, /con, name='pgs_trim_invisible_points', 'This routine is obsolete.'

 sp = size(points)
 nel = sp[1]
 nn = sp[2]
 nt = 1
 if(sp[0] EQ 3) then nt = sp[3]

 ;-----------------------------------------------------------------
 ; if there are more than one timestep, then need to rearrange
 ;-----------------------------------------------------------------
 sf = size(flags)
 if(sf[0] EQ 2) then cpoints = reform(points, nel,nn*nt) $
 else cpoints = points

 ;-----------------------------
 ; find visible points
 ;-----------------------------
 xpoints=cpoints[0,*]
 ypoints=cpoints[1,*]

 if(n_elements(x0) NE 0) then $
   sub = where( (flags AND PGS_INVISIBLE_MASK) EQ 0 AND $
                          xpoints GE x0 AND xpoints LE x1 AND $
                                            ypoints GE y0 AND ypoints LE y1) $
 else sub = where((flags AND PGS_INVISIBLE_MASK) EQ 0)

 if(sub[0] EQ -1) then return, 0

 ;-----------------------------
 ; extract the visible points
 ;-----------------------------
 vpoints = cpoints[*,sub]


 return, vpoints
end
;===========================================================================
