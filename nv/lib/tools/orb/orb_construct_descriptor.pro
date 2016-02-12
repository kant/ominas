;==============================================================================
; orb_construct_descriptor
;
;  Epoch of returned descriptor is the same as that of gbx.  
; 
;==============================================================================
function orb_construct_descriptor, gbx, $
		name=name, $
		sma=_sma, $		; Semimajor axis
		ecc=_ecc, $		; Eccentricity
		inc=_inc, $		; Inclination
		lan=_lan, $		; Lon. asc. node
		ap=_ap, $		; Arg. Periapse
		lp=_lp, $
		ma=_ma, $		; Mean anom. at epoch
		ml=_ml, $		; Mean lon.; instead of ma
		ta=_ta, $		; True anom.; instead of ma
		tl=_tl, $		; True lon.; instead of ma
		dmldt=_dmldt, $		; Sidereal mean motion
		dmadt=_dmadt, $		; Kepler mean motion
		dlandt=_dlandt, $
		liba_lan=_liba_lan, $
		dlibdt_lan=_dlibdt_lan, $
		lib_lan=_lib_lan, $
		dapdt=_dapdt, $
		liba_ap=_liba_ap, $
		dlibdt_ap=_dlibdt_ap, $
		lib_ap=_lib_ap, $
		dlpdt=_dlpdt, $
		mm=mm, $
		em=em, $
		_lpm=lpm, $
		dlpmdt=dlpmdt, $
		libam=libam, $
		libm=libm, $
		dlibmdt=dlibmdt, $
		ll=ll, $
		il=il, $
		_lanl=lanl, $
		dlanldt=dlanldt, $
		libal=libal, $
		libl=libl, $
		dlibldt=dlibldt, $
		time=time, $		; Epoch at which given elements apply,
					;  if different than gbx
		ppt=ppt, $		; Time of last pericenter passage
		rd0=rd0, $		; Orbit descriptor at epoch t.
		ring=ring, $		; If set, ma and dmadt are not included
		GG=GG, $
		noevolve=noevolve, nocompute=nocompute, $
                rdout=rd			; input descriptor, instead of creating a new one


; Note: ta and tl not yet implemented.
if(defined(ta)) then message, /con, 'WARNING: ta not implemented.'
if(defined(tl)) then message, /con, 'WARNING: tl not implemented.'

 if(defined(time)) then t = time
 if(NOT defined(t)) then t = bod_time(gbx)

 dt = bod_time(gbx) - t
 gbxt = glb_evolve(gbx, -dt)
 bd = class_extract(gbxt, 'BODY')

 sma = (ecc = tr([0d,0d]))
 if(defined(_sma)) then sma = tr([_sma,0])
 if(defined(_ecc)) then ecc = tr([_ecc,0])
 
 if(defined(_inc)) then inc = _inc
 if(defined(_lan)) then lan = _lan
 if(defined(_ap)) then ap = _ap
 if(defined(_lp)) then lp = _lp
 if(defined(_ma)) then ma = _ma
 if(defined(_ml)) then ml = _ml
 if(defined(_dmldt)) then dmldt = _dmldt
 if(defined(_dmadt)) then dmadt = _dmadt
 if(defined(_dlandt)) then dlandt = _dlandt
 if(defined(_dapdt)) then dapdt = _dapdt
 if(defined(_liba_ap)) then liba_ap = _liba_ap
 if(defined(_dlibdt_ap)) then dlibdt_ap = _dlibdt_ap
 if(defined(_lib_ap)) then lib_ap = _lib_ap
 if(defined(_dlpdt)) then dlpdt = _dlpdt

 if(NOT keyword_set(rd)) then $
  rd = rng_init_descriptors(1, $
		name=name, $
		primary = get_core_name(gbxt), $
		orient = bod_orient((_xd=orb_inertialize(gbxt))), $
		pos = bod_pos(gbxt), $
                time = t, $
                sma=sma, $
                ecc=ecc ) $
 else $
  begin
   dsk_set_sma, rd, sma
   dsk_set_ecc, rd, ecc
  end
 nv_free, _xd

 if(defined(inc)) then orb_set_inc, rd, bd, inc


 if(NOT defined(dlandt)) then $
  begin
   dlandt = 0d
   if(NOT keyword_set(nocompute)) then $
                     dlandt = orb_compute_dlandt(rd, gbxt, GG=GG)
  end

 if(defined(dlpdt)) then dapdt = dlpdt - dlandt
 if(NOT defined(dapdt)) then $
  begin
   dapdt = 0d
   if(NOT defined(dapdt)) then dapdt = orb_compute_dapdt(rd, gbxt, GG=GG)
  end


; if(NOT defined(dmldt)) then dmldt = orb_compute_dmldt(rd, gbxt, GG=GG)
 if(defined(dmldt)) then dmadt = dmldt - dlandt - dapdt
 if(NOT defined(dmadt)) then $
  begin
   dmadt = 0d
   if(NOT defined(dmadt)) then dmadt = orb_compute_dmadt(rd, gbxt, GG=GG)
  end

 orb_set_dlandt, rd, bd, dlandt
 orb_set_dapdt, rd, bd, dapdt 
 if(NOT keyword_set(ring)) then orb_set_dmadt, rd, dmadt

 if(defined(lan)) then orb_set_lan, rd, bd, lan
 if(defined(lp)) then ap = orb_lon_to_arg(rd, lp, bd)
 if(defined(ap)) then orb_set_ap, rd, bd, ap
 if(defined(lan)) then orb_set_lan, rd, bd, lan		; this is not redundant!!

 if(defined(liba_ap)) then orb_set_liba_ap, rd, bd, liba_ap
 if(defined(dlibdt_ap)) then orb_set_dlibdt_ap, rd, bd, dlibdt_ap
 if(defined(lib_ap)) then orb_set_lib_ap, rd, bd, lib_ap 

 if(defined(liba_lan)) then orb_set_liba_lan, rd, bd, liba_lan
 if(defined(dlibdt_lan)) then orb_set_dlibdt_lan, rd, bd, dlibdt_lan
 if(defined(lib_lan)) then orb_set_lib_lan, rd, bd, lib_lan 

; if(defined(ppt)) then ma = ma + dmadt*(t - ppt)
 if(defined(ppt)) then ma = dmadt*(t - ppt)
 if(defined(ml)) then ma = orb_lon_to_anom(rd, ml, bd)
 if(NOT keyword_set(ring)) then if(defined(ma)) then orb_set_ma, rd, ma

 if(keyword__set(mm)) then $		; keyword__set intended
  begin
   nmm = n_elements(mm)

   if(defined(mm)) then $
    begin
     __mm = dsk_m(rd) & __mm[0:nmm-1] = mm & dsk_set_m, rd, __mm
    end
   if(defined(em)) then $
    begin
     __em = dsk_em(rd) & __em[0:nmm-1] = em & dsk_set_em, rd, __em
    end
   if(defined(lpm)) then $
    begin
     __lpm = dsk_lpm(rd) & __lpm[0:nmm-1] = lpm & dsk_set_lpm, rd, __lpm
    end
   if(defined(dlpmdt)) then $
    begin
     __dlpmdt = dsk_dlpmdt(rd) & __dlpmdt[0:nmm-1] = dlpmdt & dsk_set_dlpmdt, rd, __dlpmdt
    end

   if(defined(libam)) then $
    begin
     __libam = dsk_libam(rd) & __libam[0:nmm-1] = libam & dsk_set_libam, rd, __libam
    end
   if(defined(libm)) then $
    begin
     __libm = dsk_libm(rd) & __libm[0:nmm-1] = libm & dsk_set_libm, rd, __libm
    end
   if(defined(dlibmdt)) then $
    begin
     __dlibmdt = dsk_dlibmdt(rd) & __dlibmdt[0:nmm-1] = dlibmdt & dsk_set_dlibmdt, rd, __dlibmdt
    end
  end  


 if(keyword__set(ll)) then $		; keyword__set intended
  begin
   nll = n_elements(ll)

   if(defined(ll)) then $
    begin
     __ll = dsk_l(rd) & __ll[0:nll-1] = ll & dsk_set_l, rd, __ll
    end
   if(defined(il)) then $
    begin
     __il = dsk_il(rd) & __il[0:nll-1] = il & dsk_set_il, rd, __il
    end
   if(defined(lanl)) then $
    begin
     __lanl = dsk_lanl(rd) & __lanl[0:nll-1] = lanl & dsk_set_lanl, rd, __lanl
    end
   if(defined(dlanldt)) then $
    begin
     __dlanldt = dsk_dlanldt(rd) & __dlanldt[0:nll-1] = dlanldt & dsk_set_dlanldt, rd, __dlanldt
    end

   if(defined(libal)) then $
    begin
     __libal = dsk_libal(rd) & __libal[0:nll-1] = libal & dsk_set_libal, rd, __libal
    end
   if(defined(libl)) then $
    begin
     __libl = dsk_libl(rd) & __libl[0:nll-1] = libl & dsk_set_libl, rd, __libl
    end
   if(defined(dlibldt)) then $
    begin
     __dlibldt = dsk_dlibldt(rd) & __dlibldt[0:nll-1] = dlibldt & dsk_set_dlibldt, rd, __dlibldt
    end
  end  


 ;------------------------------
 ; evolve elements to gbx epoch
 ;-------------------------------
 if(NOT keyword_set(noevolve)) then $
  begin
   if(NOT keyword_set(ring)) then rdt = orb_evolve(rd, dt) $
   else rdt = rng_evolve(rd, dt)

   if(NOT arg_present(rd0)) then nv_free, rd
  end $
 else rdt = rd

 rd0 = rd

 nv_free, gbxt

 bod_set_pos, rdt, bod_pos(gbx)

 return, rdt
end
;==============================================================================
