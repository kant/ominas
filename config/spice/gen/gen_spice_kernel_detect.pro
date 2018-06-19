;=============================================================================
;+
; NAME:
;       gen_spice_kernel_detect
;
;
; PURPOSE:
;       Return filenames of kernels approprate to given time, in correct order.
;
;
; CATEGORY:
;       UTIL/SPICE
;
;
; CALLING SEQUENCE:
;       files = gen_spice_kernel_detect(dd, kpath, type, sc=sc, time=time ) 
;
;
; ARGUMENTS:
;  INPUT:
;	dd:		Data descriptor.
;
;       kpath:         Path of the CK files
;
;	type:		Type of kernel: 'c' or 'sp' or 'pc'.
;
;	sc:		NAIF spacecraft ID 
;
;       time:           Time for CK coverage (optional if using /all)
;
;	djd:		Window around time to include coverage for (days, default=1)
;
;  OUTPUT: 
;	files:		Array of CK filenames for use with cspice_furnsh
;
;
; KEYWORDS:
;  INPUT:
;	sc:		NAIF spacecraft ID 
;
;       time:           Time for CK coverage (optional if using /all)
;
;	djd:		Window around time to include coverage for (days, default=1)
;
;	all:		Return all kernels (time not needed in this case)
;	
;	strict:		No function.  Included for consistent interface.
;
;	filters:	List of names of filter algorithms to use, in order.
;			Default is ['SEGLEN', 'LBLTIME', 'ITIME', 'MTIME'].
;			Algorithms behave as follows:
;
;			  SEGLEN:  Selects results residing within the shortest
;			           kernel segments. 
;			  LBLTIME: Selects results with the latest label time,
;			           if a kernel label exists.
;			  ITIME:   Selects results with the latest OMINAS
;			           install timestamp.
;			  MTIME:   Selects results with the latest file system
;			           date.
;
;  OUTPUT: NONE
;
;
; RESTRICTIONS:
;			Leapseconds kernels need to be loaded, SCLK kernels
;			also need to be loaded if type=='c'.
;
;
; STATUS:
;       Complete.
;
;
; MODIFICATION HISTORY:
;       Written by:     V. Haemmerle,  Feb. 2017
;	Addapted by:	J.Spitale      Feb. 2017
;       Modified by:    V. Haemmerle,  Jun. 2018
;-
;=============================================================================



;=============================================================================
; gskd_filter_seglen
;
;=============================================================================
function gskd_filter_seglen, dat
 if(NOT keyword_set(dat)) then return, ''

 intervals = dat.last - dat.first
 w = where(intervals EQ min(intervals))
 if(w[0] EQ -1) then return, ''

 return, dat[w]
end
;=============================================================================



;=============================================================================
; gskd_filter_lbltime
;
;=============================================================================
function gskd_filter_lbltime, dat
 if(NOT keyword_set(dat)) then return, ''

 times = dat.lbltime 
 w = where(times NE -1)
 if(w[0] EQ -1) then return, dat
 tmax = max(times, w)
 if(w[0] EQ -1) then return, ''

 return, dat[w]
end
;=============================================================================



;=============================================================================
; gskd_filter_itime
;
;=============================================================================
function gskd_filter_itime, dat
 if(NOT keyword_set(dat)) then return, ''

 times = dat.installtime 
 w = where(times NE -1)
 if(w[0] EQ -1) then return, dat
 tmax = max(times, w)
 if(w[0] EQ -1) then return, ''

 return, dat[w]
end
;=============================================================================



;=============================================================================
; gskd_filter_mtime
;
;=============================================================================
function gskd_filter_mtime, dat
 if(NOT keyword_set(dat)) then return, ''

 times = dat.mtime 
 w = where(times NE -1)
 if(w[0] EQ -1) then return, dat
 tmax = max(times, w)
 if(w[0] EQ -1) then return, ''

 return, dat[w]
end
;=============================================================================



;=============================================================================
; gen_spice_kernel_detect
;
;=============================================================================
function gen_spice_kernel_detect, dd, kpath, type, $
               djd=_djd, sc=sc, time=_time, all=all, strict=strict, $
               filters=filters

 ticks = 0
 if(type EQ 'c') then ticks = 1
 if(NOT defined(filters)) then $
                    filters = ['SEGLEN', 'LBLTIME', 'ITIME', 'MTIME']
;                    filters = ['LBLTIME', 'SEGLEN', 'ITIME', 'MTIME']

 if(ticks) then $
    if(NOT keyword_set(sc)) then nv_message, 'Spacecraft must be specified.'

 if(keyword_set(_time)) then time = _time
 
 djd = 0d
 if(keyword_set(_djd)) then djd = _djd
 dsec = djd * 86400d 

 if(~keyword_set(all) && ~keyword_set(time)) then begin
    nv_message, name='gen_spice_kernel_detect', 'Must specify /all or time.'
 endif

 ;--------------------------------
 ; Get kernel database 
 ;--------------------------------
 data = gen_spice_build_db(kpath, type)
 if(NOT keyword_set(data)) then return,''

 ;------------------------
 ; Get appropriate kernels
 ;------------------------
 if(keyword_set(all)) then $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; get all files with valid ranges
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   valid = where(data.first NE -1, count)

   nv_message, verb=0.9, 'Number of valid kernels = ' + strtrim(count,2)
  end $
 else $
  begin
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; convert ET to sclk ticks
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   before_time = time-dsec
   after_time = time+dsec

   if(keyword_set(ticks)) then $
    begin
     cspice_sce2t, sc, time-dsec, before_time
     cspice_sce2t, sc, time+dsec, after_time
    end

   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   ; get all files with valid ranges that include input time
   ;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
   valid = where((data.first LT after_time) AND (data.last GT before_time), nvalid)

   nv_message, verb=0.9, 'Number of valid kernels including given time = ' + strtrim(nvalid,2)
 end

 if(nvalid EQ 0) then return, ''


 ;--------------------------------------------------------------
 ; select files(s)
 ;--------------------------------------------------------------
 data = data[valid] 


 ;---------------------------------------------------
 ; choose among all files with coverage 
 ;---------------------------------------------------
 all_ids = data.id
 ids = unique(all_ids)
 nids = n_elements(ids)
 for i=0, nids-1 do $
  begin
   w = where(all_ids EQ ids[i])
   dat = data[w]

   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; apply filters
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   if(keyword_set(filters)) then $
    for j=0, n_elements(filters)-1 do $
      dat = call_function('gskd_filter_' + strlowcase(filters[j]), dat)
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   ; add selected kernels
   ;- - - - - - - - - - - - - - - - - - - - - - - - -
   files = append_array(files, dat.filename)
  end

 files_to_use = unique(files, /desort)

 ;---------------------------------------------------
 ; order result by time, by filter
 ;---------------------------------------------------
 nfiles = n_elements(files_to_use)
 w = where(data.filename EQ files_to_use[0])
 ind = w[0]
 for j=1, nfiles-1 do $
  begin
   w = where(data.filename EQ files_to_use[j])
   ind = [ind, w[0]] 
  end
 dat = data[ind]

 if(keyword_set(filters)) then $
  begin
   for j=0, n_elements(filters)-1 do $
    begin
     if (filters[j] EQ 'SEGLEN') then continue
     if (filters[j] EQ 'LBLTIME') then $
      begin
       w = where(dat.lbltime NE -1, count)
       if (count EQ nfiles) then $
        begin
         times = dat.lbltime
         break
        end 
      end
     if (filters[j] EQ 'ITIME') then $
      begin
       w = where(dat.installtime NE -1, count)
       if (count EQ nfiles) then $
        begin
         times = dat.installtime
         break
        end
      end
     if (filters[j] EQ 'MTIME') then $
      begin
       w = where(dat.mtime NE -1, count)
       if (count EQ nfiles) then $
        begin
         times = dat.mtime
         break
        end
      end
    end
  end
 if (keyword_set(times)) then $
  begin
   ind = sort(times)
   files_to_use = files_to_use[ind]
 end

 return, files_to_use
end
;=============================================================================

