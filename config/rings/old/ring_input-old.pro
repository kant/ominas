;=============================================================================
;+
; NAME:
;	ring_input
;
;
; PURPOSE:
;	Input translator for planetary rings.
;
;
; CATEGORY:
;	NV/CONFIG
;
;
; CALLING SEQUENCE(only to be called by nv_get_value):
;	result = ring_input(dd, keyword)
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;	keyword:	String giving the name of the translator quantity.
;
;  OUTPUT:
;	NONE
;
;
; KEYWORDS:
;  INPUT:
;	key1:		Planet descriptor -- required
;
;	key2:		Camera descriptor
;
;  OUTPUT:
;	status:		Zero if valid data is returned
;
;	n_obj:		Number of objects returned.
;
;	dim:		Dimensions of return objects.
;
;
;  TRANSLATOR KEYWORDS:
;	system:		Asks translator to return a single ring descriptor
;			encompassing the entire ring system.  If not specified,
;			the translator may return a more detailed set of
;			individual rings.
;
;
; RETURN:
;	Data associated with the requested keyword.
;
;
; STATUS:
;	Complete
;
;
; MODIFICATION HISTORY:
; 	Written by:	Spitale; 8/2004
;	
;-
;=============================================================================



;=============================================================================
; ri_clone
;
;=============================================================================
function ri_clone, _rd

 n = n_elements(_rd)
 rd = ptrarr(n)

 for i=0, n-1 do if(ptr_valid(_rd[i])) then $
                           rd[i] = rng_clone_descriptor(_rd[i])

 return, rd
end
;=============================================================================



;=============================================================================
; ri_load
;
;=============================================================================
pro ri_load, catfile, pd, dkd_inner, dkd_outer, $
        default=default, fiducial=fiducial, opaque=opaque, $
        reload=reload
common ri_load_block, _catfile, _dkd_inner, _dkd_outer, _default, _fiducial, _opaque

 ;--------------------------------------------------------------------
 ; if appropriate catalog is loaded, then just return descriptors
 ;--------------------------------------------------------------------
 if(keyword_set(_catfile) AND (NOT keyword_set(reload))) then $
  begin
   dkd_inner = _dkd_inner
   dkd_outer = _dkd_outer
   default = _default
   fiducial = _fiducial
   opaque = _opaque

   return
  end $
 ;--------------------------------------------------------------------
 ; otherwise read and parse the catalog
 ;--------------------------------------------------------------------
 else $
  begin
   ;- - - - - - - - - - - - - - - - - - - -
   ; read the catalog
   ;- - - - - - - - - - - - - - - - - - - -
   ringcat_read, catfile, $
        names=names, default=default, $
        fiducial=fiducial, opaque=opaque, sma=sma, ecc=ecc, lp=lp, dlpdt=dlpdt, $
        inc=inc, lan=lan, dlandt=dlandt, m=m, epoch=epoch

   ;- - - - - - - - - - - - - - - - - -
   ; build descriptors
   ;- - - - - - - - - - - - - - - - - -

   ;...........................................
   ; separate inner/outer ring edges
   ;...........................................
   rings = str_nnsplit(names, '/', rem=types)
   w = where(rings EQ '')
   if(w[0] NE -1) then $
    begin
     rings[w] = types[w]
     types[w] = 'OUTER'
    end

   types = strupcase(types)
   w = where((types NE 'INNER') AND (types NE 'OUTER'))
   if(w[0] NE -1) then nv_message, name='ring_input', $
                                   'Parse error in ring catalog file.'

   ;.............................................
   ; get unique ring names + all unnamed rings
   ;.............................................
   ss = sort(rings)
   uu = uniq(rings[ss])
   xx = ss[uu]


   ;...........................................................
   ; create descriptors
   ;  rings with no name are created using their feature name
   ;  with inner and outer edges indentical
   ;...........................................................
   n_rings = n_elements(xx)

   opaque = strupcase(opaque[xx]) EQ 'YES'
   fiducial = fiducial[xx]
   default = default[xx]

   dkd_inner = ptrarr(n_rings)
   dkd_outer = ptrarr(n_rings)
   kk = 0
   for j=0, n_rings-1 do $
    begin
     ring = rings[xx[j]]
     w = where(rings EQ ring)
     name = ring

     nw = n_elements(w)
     if(nw GT 2) then nv_message, name='ringcat_read', $
                    'Too many features with ring name ' + rings[xx[j]] + '.'
     w0 = where(types[w] EQ 'INNER') 
     w1 = where(types[w] EQ 'OUTER') 

     dkd_inner[j] = (dkd_outer[j] = nv_ptr_new())

     ;................................ 
     ; inner edge
     ;................................ 
     if(w0[0] NE -1) then $
      begin
       ii = w[w0]
       dkd_inner[j] = orb_construct_descriptor(pd, /ring, /noevolve, $
			name = strupcase(name), $
			time = epoch[ii], $ 
			sma = sma[ii], $
			ecc = ecc[ii,0] , $
			lp =  lp[ii,0] , $
			dlpdt = dlpdt[ii,0] , $
			inc =  inc[ii], $
			lan =  lan[ii], $
			dlandt = dlandt[ii])
       dm = size(ecc, /dim)
       if(n_elements(dm) GT 1) then $
        for k=1, dm[1]-1 do $
         begin
          dsk_set_m, dkd_inner[j], m[ii,k]
          dsk_set_em, dkd_inner[j], ecc[ii,k]
          dsk_set_lpm, dkd_inner[j], lp[ii,k]
          dsk_set_dlpmdt, dkd_inner[j], dlpdt[ii,k]
         end
      end

     ;................................ 
     ; outer edge
     ;................................ 
     if(w1[0] NE -1) then $
      begin
       ii = w[w1]
       dkd_outer[j] = orb_construct_descriptor(pd, /ring, /noevolve, $
			name = strupcase(name), $
			time = epoch[ii], $ 
			sma = sma[ii], $
			ecc = ecc[ii,0] , $
			lp =  lp[ii,0] , $
			dlpdt = dlpdt[ii,0] , $
			inc =  inc[ii], $
			lan =  lan[ii], $
			dlandt = dlandt[ii])
       dm = size(ecc, /dim)
       if(n_elements(dm) GT 1) then $
        for k=1, dm[1]-1 do $
         begin
          dsk_set_m, dkd_outer[j], m[ii,k]
          dsk_set_em, dkd_outer[j], ecc[ii,k]
          dsk_set_lpm, dkd_outer[j], lp[ii,k]
          dsk_set_dlpmdt, dkd_outer[j], dlpdt[ii,k]
         end
      end

    end

   ;-------------------------------------------
   ; save catalog data
   ;-------------------------------------------
   _catfile = catfile
   _dkd_inner = dkd_inner
   _dkd_outer = dkd_outer
   _default = default
   _fiducial = fiducial
   _opaque = opaque
  end


end
;=============================================================================


;=============================================================================
; ring_input
;
;=============================================================================
function ring_input, dd, keyword, prefix, $
                      n_obj=n_obj, dim=dim, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords

 ;--------------------------
 ; verify keyword
 ;--------------------------
 if(keyword NE 'RNG_DESCRIPTORS') then $
  begin
   status = -1
   return, 0
  end


 ;----------------------------------------------
 ; if no ring catalog, then use old translator
 ;----------------------------------------------
 nocat = tr_keyword_value(dd, 'nocat')
 catpath = getenv('NV_RING_DATA')
 if(NOT keyword_set(catpath)) then $
   nv_message, /con, name='ring_input', $
     'Warning: Not using using catalog because NV_RING_DATA environment variable is undefined.'

 if((NOT keyword_set(catpath)) OR (keyword_set(nocat))) then $
   return, ring_input_nocat(dd, keyword, prefix, $
                      n_obj=n_obj, dim=dim, status=status, $
@nv_trs_keywords_include.pro
@nv_trs_keywords1_include.pro
	end_keywords)




 status = 0
 n_obj = 0
 dim = [1]

 deg2rad = !dpi/180d
 degday2radsec = !dpi/180d / 86400d

 ;-----------------------------------------------
 ; translator arguments
 ;-----------------------------------------------
 system = tr_keyword_value(dd, 'system')
 select_all = tr_keyword_value(dd, 'all')
 select_fiducial = tr_keyword_value(dd, 'fiducial')
 reload = tr_keyword_value(dd, 'reload')

 ;-----------------------------------------------
 ; planet descriptor passed as key1
 ;-----------------------------------------------
 if(keyword__set(key1)) then pds = key1 $
 else nv_message, name='ring_input', 'Planet descriptor required.'

 ;-----------------------------------------------
 ; object names passed as key8
 ;-----------------------------------------------
 if(keyword__set(key8)) then sel_names = key8



 ;-----------------------------------------------
 ; set up ring descriptors
 ;-----------------------------------------------
 npds = n_elements(pds)
 for i=0, npds-1 do $
  begin
   planet = cor_name(pds[i])

   dkd_inner = (dkd_outer = '')

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; read relevant ring catalog
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   catfile = catpath + '/ringcat_' + strlowcase(planet) + '.txt'
   ff = findfile(catfile)   
   if(keyword_set(ff)) then $
    begin
     ri_load, catfile, pds[i], dkd_inner, dkd_outer, $
        default=default, fiducial=fiducial, opaque=opaque, reload=reload
;stop
;n = n_elements(dkd_outer)
;for k=0, n-1 do if(ptr_valid(dkd_outer[k])) then print, dsk_sma(dkd_outer[k])

     ;- - - - - - - - - - - - - - - - - - - - - - - -
     ; select desired rings by classification
     ;- - - - - - - - - - - - - - - - - - - - - - - -
     if(NOT keyword_set(select_all)) then $
      begin
       if(keyword_set(select_fiducial)) then w = where(fiducial EQ 'yes') $
       else w = where(default EQ 'yes')

       default = default[w]
       dkd_inner = dkd_inner[w]
       dkd_outer = dkd_outer[w]
       fiducial = fiducial[w]
       opaque = opaque[w]
      end

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; record which rings had only one edge, and fix them up so
     ; that the following calculations are valid
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     xx_inner = where(ptr_valid(dkd_inner) EQ 0)
     xx_outer = where(ptr_valid(dkd_outer) EQ 0)

     if(xx_inner[0] NE -1) then dkd_inner[xx_inner] = dkd_outer[xx_inner]
     if(xx_outer[0] NE -1) then dkd_outer[xx_outer] = dkd_inner[xx_outer]

     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     ; if /system, make one descriptor encompassing entire ring system
     ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
     if(keyword__set(system)) then $
      begin
       sma = (dsk_sma(dkd_inner))[0,0,*]
       ecc = (dsk_ecc(dkd_inner))[0,0,*]
       q = sma*(1d - ecc)
       w = where(q EQ min(q))
       dkd_inner = dkd_inner[w]
       cor_set_name, dkd_inner, 'MAIN_RING_SYSTEM'

       sma = (dsk_sma(dkd_outer))[0,0,*]
       ecc = (dsk_ecc(dkd_outer))[0,0,*]
       q = sma*(1d + ecc)
       w = where(q EQ max(q))
       dkd_outer = dkd_outer[w]
       cor_set_name, dkd_outer, 'MAIN_RING_SYSTEM'
      end

     ;- - - - - - - - - - - - - - - - - - - - -
     ; merge inner/outer descriptors
     ;- - - - - - - - - - - - - - - - - - - - -
     if(keyword__set(dkd_inner)) then $
      begin
       dkd = dkd_inner
       ndkd = n_elements(dkd)
       for j=0, ndkd-1 do $
        begin
         sma = tr( [tr((dsk_sma(dkd[j]))[*,0]), tr((dsk_sma(dkd_outer[j]))[*,0])] )
         dsk_set_sma, dkd[j], sma
         ecc = tr( [tr((dsk_ecc(dkd[j]))[*,0]), tr((dsk_ecc(dkd_outer[j]))[*,0])] )
         dsk_set_ecc, dkd[j], ecc
         bod_set_pos, dkd[j], bod_pos(pds[i])
         bod_set_opaque, dkd[j], opaque[j]
        end

       dkds = append_array(dkds, dkd)
       primaries = append_array(primaries, make_array(ndkd, val=cor_name(pds[i])))
       ppds = append_array(ppds, make_array(n_elements(dkd), val=pds[i]))
      end

    end
  end


 if(NOT keyword_set(dkds)) then $
  begin
   status = -1
   return, 0
  end


 ;------------------------------------------------------------------
 ; handle rings with only one edge
 ;------------------------------------------------------------------
 if(xx_inner[0] NE -1) then $
  begin
   sma = dsk_sma(dkds[xx_inner])
   sma[0,0,*] = -1
   dsk_set_sma, dkds[xx_inner], sma
  end

 if(xx_outer[0] NE -1) then $
  begin
   sma = dsk_sma(dkds[xx_outer])
   sma[0,1,*] = -1
   dsk_set_sma, dkds[xx_outer], sma
  end

 ;------------------------------------------------------------------
 ; select any requested names
 ;------------------------------------------------------------------
 if(keyword_set(sel_names)) then $
  begin
   all_names = cor_name(dkds)
   w = nwhere(all_names, sel_names)
   if(w[0] EQ -1) then $
    begin
     status = -1
     return, 0
    end
   dkds = dkds[w]
   primaries = primaries[w]
  end


 ;----------------------------------------------
 ; evolve rings to primary epochs
 ;----------------------------------------------
 n_obj = n_elements(dkds)

 dkdts = ptrarr(n_obj)
 for i=0, n_obj-1 do $
  dkdts[i] = rng_evolve(dkds[i], bod_time(ppds[i]) - bod_time(dkds[i]))
;dkdts = dkds


 ;------------------------------------------------------------------
 ; make ring descriptors
 ;------------------------------------------------------------------
 rds = rng_init_descriptors(n_obj, $
		primary=primaries, $
		name=cor_name(dkdts), $
		opaque=bod_opaque(dkdts), $
		orient=bod_orient(dkdts), $
		avel=bod_avel(dkdts), $
		pos=bod_pos(dkdts), $
		vel=bod_vel(dkdts), $
		time=bod_time(dkdts), $
		sma=dsk_sma(dkdts), $
		ecc=dsk_ecc(dkdts))

 return, rds
end
;===========================================================================



