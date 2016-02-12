;===========================================================================
; _bod_evolve
;
;  Input  : array (nbd) of body descriptor (structures)
;  Output : array (nbd, ndt) of body descriptor (structures)
;
;===========================================================================
function _bod_evolve, bds, dt, nodv=nodv
@nv_lib.include

 nbd = n_elements(bds)
 ndv = n_elements(bds[0].vel[*,0])
 ndt = n_elements(dt)

 tbds = bds[gen3x(nbd, ndt, 1)]	
 tbds.crd = cor_replicate((_xd=nv_clone(bds.crd)), [nbd, ndt])
 nv_free, _xd

 ;======================
 ; time
 ;======================
 tbds.time = tbds.time + dt##make_array(nbd,val=1d)

 ;======================
 ; position, velocity
 ;======================
 pos = reform(bds.pos, 1, 3*nbd)
 vel = reform(bds.vel, ndv, 3*nbd)

 ;-----------------------
 ; compute new position
 ;-----------------------
 tpos = vtaylor([pos,vel], dt)				; ndt x 3*nbd
 tpos = reform(tpos, ndt, 3, nbd, /over)		; ndt x 3 x nbd
 tbds.pos = degen(reform(transpose(tpos, [1,2,0]), $	; 1 x 3 x nbd x ndt
                                   1,3,nbd,ndt, /over))

 ;------------------------
 ; compute new velocities
 ;------------------------
 if(NOT keyword_set(nodv)) then $
  begin
   for i=0, ndv-1 do $
    begin
     tvel = vtaylor(vel[i:*,*], dt)			; ndt x 3*nbd
     tvel = reform(tvel, ndt, 3, nbd, /over)		; ndt x 3 x nbd
     tbds.vel[i,*,*,*] = $				; 1 x 3 x nbd x ndt
           degen(reform(transpose(tvel, [1,2,0]), $
                                   1,3,nbd,ndt, /over))
    end
  end


 ;=================================
 ; angular velocity
 ;=================================
 avel = reform(bds.avel, ndv, 3*nbd)

 ;------------------------------------------------------------------------
 ; rotate axes about original avel vector
 ;------------------------------------------------------------------------
 tavel = tbds.avel					; ndv x 3 x nbd x ndt

 tav = reform(tavel[0,*,*,*], 3,nbd,ndt)		; 3 x nbd x ndt
 tav = transpose(tav, [1,0,2])				; nbd x 3 x ndt
 dtheta = v_mag(tbds.avel[0,*,*,*]) # dt

 if(nbd NE 1) then v = (bds.orient)[vecgen(3,3,nbd)] $
 else v = bds.orient

 vt = v[linegen3z(3*nbd,3,ndt)]				; 3*nbd x 3 x ndt

 sin_dtheta = [sin(dtheta)]
 cos_dtheta = [cos(dtheta)]

 ii0 = indgen(nbd)*3
 ii1 = ii0+1
 ii2 = ii0+2

 w = where(v_mag(tav) NE 0)
 if(w[0] NE -1) then $
  begin
   w = where(v_mag(tav) EQ 0)
   if(w[0] NE -1) then $
    begin
     sub = colgen(nbd,3,ndt, w)
     tav[sub] = 1d
    end

   nn = v_unit(tav)					; nbd x 3 x ndt

   vt[ii0,*,*] = v_rotate_11(vt[ii0,*,*], nn, sin_dtheta, cos_dtheta)
   vt[ii1,*,*] = v_rotate_11(vt[ii1,*,*], nn, sin_dtheta, cos_dtheta)
   vt[ii2,*,*] = v_rotate_11(vt[ii2,*,*], nn, sin_dtheta, cos_dtheta)
  end 

 ;------------------------------------------------------------------------
 ; rearrange resultant vectors to fit into output structure
 ;------------------------------------------------------------------------
 xx = dblarr(3,3,nbd,ndt)
 xx[0,*,*,*] = transpose(reform(vt[ii0,*,*],nbd,3,ndt, /over), [1,0,2])
 xx[1,*,*,*] = transpose(reform(vt[ii1,*,*],nbd,3,ndt, /over), [1,0,2])
 xx[2,*,*,*] = transpose(reform(vt[ii2,*,*],nbd,3,ndt, /over), [1,0,2])

 tbds.orient = xx
 tbds.orientT = transpose(reform(xx, 3,3,nbd,ndt, /over), [1,0,2,3])



 ;--------------------------------------------------------------------
 ; compute new angular velocities and precess --
 ;  In a body descriptor, each vector avel[i,*] is used to rotate
 ;  the orientation matrix.  In addition, avel[i,*] is the angular 
 ;  velocity for  vector avel[i-1,*].  In other words, the vector 
 ;  avel[i,*] precesses about the vector avel[i+1,*].
 ;--------------------------------------------------------------------
 w = where(bds.avel[1:*,*,*] NE 0)
 if(w[0] NE -1) then $
  begin
   if(NOT keyword__set(nodv)) then $
    begin
     for i=1, ndv-1 do $
      begin
       tav = reform(tavel[i,*,*,*], 1,3,nbd,ndt, /over)
       tav1 = reform(tavel[i-1,*,*,*], 1,3,nbd,ndt, /over)

       vv = reform(degen(transpose(tav, [2,1,3,0])), nbd,3,ndt, /ov)
								; nbd x 3 x ndt
       w = where(v_mag(vv) EQ 0)
       if(w[0] NE -1) then sub = colgen(nbd,3,ndt, w)
       if((n_elements(w) NE ndt*nbd) OR (w[0] EQ -1)) then $
        begin
         axis = vv						; nbd x 3 x ndt
         if(keyword__set(sub)) then axis[sub] = 1d
         axis = v_unit(axis)					; nbd x 3 x ndt
         if(keyword__set(sub)) then axis[sub] = 0d
         phi = reform(v_mag(vv), nbd, ndt, /over) * $
                  dt##make_array(nbd,val=1d)			; nbd x ndt
         sin_phi = sin(phi) & cos_phi = cos(phi)
         vvv = reform(degen(transpose(tav1, [2,1,3,0])), nbd,3,ndt, /ov)	
								; nbd x 3 x ndt
         xxx = $
            reform(v_rotate_11(vvv, axis, sin_phi, cos_phi), nbd,3,ndt, /ov)	
								; nbd x 3 x ndt

        ;-------------------------------
        ; precess orientation
        ;-------------------------------
        if(i EQ 1) then $
          begin
           orient = reform(tbds.orient, 3,3,nbd,ndt)	; 3 x 3 x nbd x ndt
           orient = reform(orient, 3*nbd,3,ndt)		; 3*nbd x 3 x ndt
           ii0 = indgen(nbd)*3
           ii1 = ii0+1
           ii2 = ii0+2

           orient[ii0,*,*] = $
                     v_rotate_11(orient[ii0,*,*], axis, sin_phi, cos_phi)
           orient[ii1,*,*] = $
                     v_rotate_11(orient[ii1,*,*], axis, sin_phi, cos_phi)
           orient[ii2,*,*] = $
                     v_rotate_11(orient[ii2,*,*], axis, sin_phi, cos_phi)

           xx = dblarr(3,3,nbd,ndt)
           xx[0,*,*,*] = $
                 transpose(reform(orient[ii0,*,*],nbd,3,ndt, /over), [1,0,2])
           xx[1,*,*,*] = $
                 transpose(reform(orient[ii1,*,*],nbd,3,ndt, /over), [1,0,2])
           xx[2,*,*,*] = $
                 transpose(reform(orient[ii2,*,*],nbd,3,ndt, /over), [1,0,2])

           tbds.orient = xx
           tbds.orientT = transpose(reform(xx, 3,3,nbd,ndt, /over), [1,0,2,3])
          end


         tbds.avel[i-1,*,*,*] = reform(transpose(xxx, [1,0,2]),1,3,nbd,ndt)
        end
      end
    end

  end



return, tbds
; The following code is circumvented because it resets the body orientation 
; after already having been precessed above.  That will need to be fixed before
; using this code again.




 ;=================================
 ; libration
 ;=================================
 libv = reform(bds.libv, ndv, 3*nbd)

 ;------------------------------------------------------------------------
 ; librate axes about original libv vector
 ;------------------------------------------------------------------------
 tlibv = tbds.libv					; ndv x 3 x nbd x ndt

 tlbv = reform(tlibv[0,*,*,*], 3,nbd,ndt)		; 3 x nbd x ndt
 tlbv = transpose(tlbv, [1,0,2])			; nbd x 3 x ndt
 dtheta = v_mag(tbds.libv[0,*,*,*]) # dt

 if(nbd NE 1) then v = (bds.orient)[vecgen(3,3,nbd)] $
 else v = bds.orient

 vt = v[linegen3z(3*nbd,3,ndt)]				; 3*nbd x 3 x ndt

 sin_dtheta = [sin(dtheta)]
 cos_dtheta = [cos(dtheta)]

 ii0 = indgen(nbd)*3
 ii1 = ii0+1
 ii2 = ii0+2

 w = where(v_mag(tlbv) NE 0)
 if(w[0] NE -1) then $
  begin
   w = where(v_mag(tlbv) EQ 0)
   if(w[0] NE -1) then $
    begin
     sub = colgen(nbd,3,ndt, w)
     tlbv[sub] = 1d
    end

   nn = v_unit(tlbv)					; nbd x 3 x ndt

   vt[ii0,*,*] = v_rotate_11(vt[ii0,*,*], nn, sin_dtheta, cos_dtheta)
   vt[ii1,*,*] = v_rotate_11(vt[ii1,*,*], nn, sin_dtheta, cos_dtheta)
   vt[ii2,*,*] = v_rotate_11(vt[ii2,*,*], nn, sin_dtheta, cos_dtheta)
  end 

 ;------------------------------------------------------------------------
 ; rearrange resultant vectors to fit into output structure
 ;------------------------------------------------------------------------
 xx = dblarr(3,3,nbd,ndt)
 xx[0,*,*,*] = transpose(reform(vt[ii0,*,*],nbd,3,ndt, /over), [1,0,2])
 xx[1,*,*,*] = transpose(reform(vt[ii1,*,*],nbd,3,ndt, /over), [1,0,2])
 xx[2,*,*,*] = transpose(reform(vt[ii2,*,*],nbd,3,ndt, /over), [1,0,2])

 tbds.orient = xx
 tbds.orientT = transpose(reform(xx, 3,3,nbd,ndt, /over), [1,0,2,3])



 ;--------------------------------------------------------------------
 ; compute new libration vectors and precess --
 ;  In a body descriptor, each vector libv[i,*] is used to librate
 ;  the orientation matrix with an ampitude given by v_mag(libv[i]) and 
 ;  a phase given by lib[i].  In addition,  libv[i,*] is the libration 
 ;  vector for libv[i-1,*].  In other words,  the vector libv[i,*] 
 ;  librates about the vector libv[i+1,*].
 ;--------------------------------------------------------------------
 w = where(bds.libv[1:*,*,*] NE 0)
 if(w[0] NE -1) then $
  begin
   if(NOT keyword__set(nodv)) then $
    begin
     for i=1, ndv-1 do $
      begin
       tlbv = reform(tlibv[i,*,*,*], 1,3,nbd,ndt, /over)
       tlbv1 = reform(tlibv[i-1,*,*,*], 1,3,nbd,ndt, /over)

       vv = reform(degen(transpose(tlbv, [2,1,3,0])), nbd,3,ndt, /ov)
								; nbd x 3 x ndt
       w = where(v_mag(vv) EQ 0)
       if(w[0] NE -1) then sub = colgen(nbd,3,ndt, w)
       if((n_elements(w) NE ndt*nbd) OR (w[0] EQ -1)) then $
        begin
         axis = vv						; nbd x 3 x ndt
         if(keyword__set(sub)) then axis[sub] = 1d
         axis = v_unit(axis)					; nbd x 3 x ndt
         if(keyword__set(sub)) then axis[sub] = 0d
         phi = reform(v_mag(vv), nbd, ndt, /over) * $
                  dt##make_array(nbd,val=1d)			; nbd x ndt
         sin_phi = sin(phi) & cos_phi = cos(phi)
         vvv = reform(degen(transpose(tlbv1, [2,1,3,0])), nbd,3,ndt, /ov)	
								; nbd x 3 x ndt
         xxx = $
            reform(v_rotate_11(vvv, axis, sin_phi, cos_phi), nbd,3,ndt, /ov)	
								; nbd x 3 x ndt

        ;-------------------------------
        ; precess orientation
        ;-------------------------------
        if(i EQ 1) then $
          begin
           orient = reform(tbds.orient, 3,3,nbd,ndt)	; 3 x 3 x nbd x ndt
           orient = reform(orient, 3*nbd,3,ndt)		; 3*nbd x 3 x ndt
           ii0 = indgen(nbd)*3
           ii1 = ii0+1
           ii2 = ii0+2

           orient[ii0,*,*] = $
                     v_rotate_11(orient[ii0,*,*], axis, sin_phi, cos_phi)
           orient[ii1,*,*] = $
                     v_rotate_11(orient[ii1,*,*], axis, sin_phi, cos_phi)
           orient[ii2,*,*] = $
                     v_rotate_11(orient[ii2,*,*], axis, sin_phi, cos_phi)

           xx = dblarr(3,3,nbd,ndt)
           xx[0,*,*,*] = $
                 transpose(reform(orient[ii0,*,*],nbd,3,ndt, /over), [1,0,2])
           xx[1,*,*,*] = $
                 transpose(reform(orient[ii1,*,*],nbd,3,ndt, /over), [1,0,2])
           xx[2,*,*,*] = $
                 transpose(reform(orient[ii2,*,*],nbd,3,ndt, /over), [1,0,2])

           tbds.orient = xx
           tbds.orientT = transpose(reform(xx, 3,3,nbd,ndt, /over), [1,0,2,3])
          end


         tbds.libv[i-1,*,*,*] = reform(transpose(xxx, [1,0,2]),1,3,nbd,ndt)
        end
      end
    end

  end



 return, tbds
end
;===========================================================================



