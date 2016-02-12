;===========================================================================
; pgs_cat_vectors.pro
;
; concatenates arrays of column vectors
;
; returns 0 if no visible vectors
;
;===========================================================================
function pgs_cat_vectors, ps, flags_ps=flags_ps
@pgs_include.pro
nv_message, /con, name='pgs_cat_vectors', 'This routine is obsolete.'
 nv_notify, ps, type = 1

 n_ps=n_elements(ps)

 ;-----------------------------------
 ; set up concatenated vectors array
 ;-----------------------------------
 nn=intarr(n_ps)
 nnt=intarr(n_ps)
 ntot=intarr(n_ps)
 for i=0, n_ps-1 do if(ptr_valid(ps[i])) then $
  begin
   s=size(*ps[i])
   nn[i]=s[1]
   if(s[0] EQ 3) then nnt[i]=s[3] $
   else nnt[i]=1

   w = where((*flags_ps[i] AND PGS_INVISIBLE_MASK) EQ 0)
   if(w[0] NE -1) then ntot[i] = n_elements(w)
  end
 n_vectors=total(ntot)

 if(n_vectors EQ 0) then return, 0

 vectors=dblarr(n_vectors,3)


 ;----------------------------------
 ; populate the vectors array
 ;----------------------------------
 n=0
 for i=0, n_ps-1 do if(ptr_valid(ps[i])) then $
  begin
   w = where((*flags_ps[i] AND PGS_INVISIBLE_MASK) EQ 0)

   if(w[0] NE -1) then $
    begin
     p = reform(*ps[i], nn[i]*nnt[i],3)
     vectors[n:n+ntot[i]-1,*] = p[w,*]
     n = n+ntot[i]
    end
  end


 return, vectors
end
;===========================================================================
