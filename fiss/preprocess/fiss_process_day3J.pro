pro fiss_process_day3J, directories, get_flat_pattern=get_flat_pattern, $
                       data_process=data_process, data_compress=data_compress, $
                       tilt_from_raw=tilt_from_raw

if ~n_elements(get_flat_pattern) then get_flat_pattern=1
if ~n_elements(data_process) then data_process=1
if ~n_elements(data_compress) then data_compress=1
if ~n_elements(tilt_from_raw) then tilt_from_raw=1  ;; added 180503 khcho / fiss_process_day3

useref=1
compress=1
detector='both'
;detector='A'
case detector of
  'A': begin
    idet1=0 & idet2=0
  end
  'B': begin
    idet1=1 & idet2=1
  end
  'both': begin
    idet1=0 & idet2=1
  end
endcase

for dir_loop=0, n_elements(directories)-1 do begin
  data_dir=directories[dir_loop]
  
  t1=systime(/second)
  if !version.os_family eq 'Windows' then delim='\' else delim='/'
  ;delim=''
  if strmid(data_dir, strlen(data_dir)-1,1) ne delim  then data_dir=data_dir+delim
 
  ; Check data directory
  if not file_test(data_dir) then begin
    print, 'Directory: '+data_dir+' does not exist! ...returning from FISS_PROCESS_DAY'
    stop
  endif
  
  cal_dir=data_dir+'cal'+delim
  if not file_test(cal_dir) then begin
    print, 'Directory: '+cal_dir+' does not exist! ...returning from FISS_PROCESS_DAY'
    stop
  endif
  
  proc_dir=data_dir+'proc'+delim
  file_mkdir, proc_dir
  proc_cal_dir=proc_dir+'cal'+delim
  file_mkdir, proc_cal_dir

  ;  Flat /slit pattern determination
  if get_flat_pattern then begin
    for idet=idet1, idet2 do begin
      detector=(['A', 'B'])[idet]
      fflats=file_search(cal_dir+'FISS_*_'+detector+'_Flat.fts', count=nflat)
      fdarks=file_search(cal_dir+'FISS_*_'+detector+'_BiasDark.fts', count=ndark)
      if nflat eq 0 then begin
        print, 'no flat data for detector '+detector+' in directory: '+cal_dir+$
                ' . returning from FISS_PROCESS_DAY'
        stop
      endif
      if nflat ne ndark then begin
        print, 'not matched with ndark'
      ;stop
      endif
      
      for k=0, nflat-1 do begin
        if tilt_from_raw then begin
          n_raw_for_tilt = 10
          raw_dir=data_dir+'raw'+delim
          if not file_test(raw_dir) then begin
            print, 'Directory: '+raw_dir+$
                   ' does not exist! ...returning from FISS_PROCESS_DAY'
            stop
          endif
          regs_dir=file_search(raw_dir+'*', count=nreg)
          if nreg eq 0 then begin
            print, 'Directory: '+ raw_dir+$
                   ' does not contain any region! ...returning from FISS_PROCESS_DAY'
            stop
          endif
          print, 'Extract the tilt angle of '+detector+$
            ' camera from '+string(n_raw_for_tilt, f='(i0)')+' RAW data.'
          dummy = file_search(raw_dir, 'FISS_*_'+detector+'.fts', count=nraw)
          check_gratwvln, dummy, grat
          check_gratwvln, fflats[k], grat_ref
          whgrat = where(fix(grat) eq fix(grat_ref[0]))
          dummy = dummy[whgrat]
;          t_raw = fiss_jultime(dummy)
;          t_ref = fiss_jultime(fflats[k])
;          t_diff = abs(t_raw-t_ref[0])
;          raw_for_tilt = dummy[sort(t_diff)]
          raw_for_tilt = dummy[n_elements(dummy)*randomu(seed, n_raw_for_tilt)]
          tilt_ang = fltarr(n_raw_for_tilt)
          for ii = 0, n_raw_for_tilt-1 do begin
            raw0 = float(readfits(raw_for_tilt[ii], h0, /sil))
            rawsz = size(raw0)
;            rflat = rebin(median(readfits(fflats[k]),dim = 3),rawsz[1:3])
;            fiss_get_flat_v2, fflats[k],fdarks[k<(ndark-1)], 'tt', 0, tmp=rflat
;            rflat = rebin(rflat,rawsz[1:3])
;            rdark = rebin(readfits(fdarks[k<(ndark-1)]),rawsz[1:3])
;            raw = (raw - rdark) / float(rflat)
            raw = raw0[*,*,rawsz[3]/2]
;            raw = raw0[*,*,20]
            dker = [[-1.,-2.,-1.],[0.,0.,0.],[1.,2.,1.]]
            raw = convol(convol(raw, dker),dker)
            SGimg = fltarr(rawsz[1],rawsz[2])
            SGFilter = savgol(8,8,0,4)
            for i=0,rawsz[1]-1 do SGimg[i,*] = convol(reform(raw[i,*]),SGFilter,/edge_truncate)
            pick = 0
            corcrit=0.92
            corarr =0.
            toffarr = [0.,0.]
            repeat begin
              pick += 10
;              img1 = reform(raw[pick-7:pick+8, *])
              img1 = reform(SGimg[pick-7:pick+8, *])
              rpick = rawsz[1]-pick
;              img2 = reform(raw[rpick-7:rpick+8, *])
              img2 = reform(SGimg[rpick-7:rpick+8, *])
              tilt_off = alignoffset(img1, img2, cor)
              toffarr = [[toffarr], [tilt_off]]
              corarr = [corarr, cor] 
              if cor lt corcrit and pick ge 240 then begin
                corcrit =0.
                whcor = where(corarr eq max(corarr))
                pick = 10. * whcor
                cor = corarr[whcor]
                tilt_off = toffarr[*,whcor] 
              endif
            endrep until cor gt corcrit
            tilt_ang[ii] = -atan(tilt_off[1], (rawsz[1]-2.*pick))*180d0/!dpi
          endfor
          tilt = median(tilt_ang)
          if abs(tilt) ge 1.5 then begin
            print,'An absolute value of the tilt angle is greater than 1.5 degree!!, check please'
            stop
          endif
        endif

        fiss_mkcalfile, fflats[k],  cal_dir
        flatname=file_basename(fflats[k])
        id = strmid(flatname, 5, strpos(flatname, '_Flat.fts')-5)
        flat_file=proc_cal_dir+'FISS_FLAT_'+id+'.fts'
        fiss_get_flat_v2,  fflats[k], fdarks[k<(ndark-1)], flat_file, tilt, slit_pattern=slit_pattern
        mkhdr, slit_h, slit_pattern, /extend
        fxaddpar, slit_h, 'GRATWVLN', float(fxpar(headfits(fflats[k]), 'GRATWVLN'))
        writefits, proc_cal_dir+'FISS_SLIT_'+id+'.fts', slit_pattern, slit_h
        flat= readfits(flat_file)
        window, xs=512, ys=512
        tv, bytscl(flat, 0.9, 1.1) , 0
        tv, bytscl(slit_pattern, 0.9, 1.1)
        ok=1B
;        stop
        ;        read, 'If OK, type 1 else 0: ', ok  ;; removed
        if not ok then stop
      endfor  ; k
    endfor ; idet
  endif   ; get_flat_pattern
  
  if data_process then begin
    raw_dir=data_dir+'raw'+delim
    if not file_test(raw_dir) then begin
      print, 'Directory: '+raw_dir+' does not exist! ...returning from FISS_PROCESS_DAY'
      stop
    endif
    
    regs_dir=file_search(raw_dir+'*', count=nreg)
    if nreg eq 0 then begin
      print, 'Directory: '+ raw_dir+' does not contain any region! ...returning from FISS_PROCESS_DAY'
      stop
    endif
    
    ; Data reduction
    for reg=0, ( nreg-1) do begin
      reg_dir=regs_dir[reg]
      
      print, 'processing files in directory: '+reg_dir
      
      region=file_basename(reg_dir)
      prdir =  proc_dir + region
      file_mkdir, prdir
      
      for idet=idet1,  idet2 do begin
        detector=(['A', 'B'])[idet]
        datafiles=file_search(reg_dir+delim+'*'+detector+'.fts', count=nf)
        dark_files = file_search(reg_dir+delim+'*'+detector+'_BiasDark.fts', count = ndark)
        dark = file_basename(dark_files)

       
        if nf lt 1 then goto, next
        if useref then begin
          calfiles=fiss_calfile_v2(datafiles,  cal_dir, type='cal', det=detector)
          if calfiles[0]  eq '' then useref=0
        endif
        
        if not useref then  calfiles=datafiles
        
        darkfiles=fiss_darkfile(datafiles)
        flatfiles=fiss_calfile_v2(datafiles, proc_cal_dir, type='flat', det=detector)
        slitfiles=fiss_calfile_v2(datafiles, proc_cal_dir, type='slit', det=detector)
        filebases=file_basename(datafiles)
        
        proc_files = strarr(nf)
        for target=0, ndark-1 do begin
          target_dir = prdir + delim + 'target' + string(target, format='(i02)')
          file_mkdir, target_dir
          wh = where(file_basename(darkfiles) eq dark[target])
          proc_files[wh]= target_dir +delim+strmid(filebases[wh], 0, strlen(filebases[0])-4)+'1.fts'
        endfor
        
        calfile=''
        kref=0
        for k=0, nf-1 do  begin
          tilt=float(fxpar(headfits(flatfiles[k]), 'TILT'))
          slit_pattern=readfits(slitfiles[k], /sil)    
          if calfiles[k] ne calfile then begin
            calfile=calfiles[k]
            fiss_cal_par_v2, calfile, (fiss_calfile_v2(calfile, proc_cal_dir, typ='flat', det=detector))[0], $
                          '', slit_pattern,  tilt, dw
          endif
          fiss_prep_v2, datafiles[k], proc_files[k], flatfiles[k], darkfiles[k], slit_pattern, $
                     tilt,  wvpar,  dw, slit_adjust=useref, detector=detector
          print, 'prepared '+detector+' detector '+string(k, format='(i4)')+'th data'
          wait, 0.1
;          stop
        endfor  ; k
          
          next:
        
      endfor ; idet
      
    endfor ; reg
  endif  ; data processing
  
  
  ;stop
  
  if data_compress then begin
  
    comp_dir=data_dir+'comp'+delim
    file_mkdir, comp_dir
    
    proc_dir=data_dir+'proc'+delim
    regs_dir=file_search(proc_dir+'*/target*', count=nreg)
    if nreg eq 0 then begin
      print, 'Directory: '+ raw_dir+' does not contain any region! ...returning from FISS_PROCESS_DAY'
      stop
    endif
    
    
    for reg=0,  nreg-1  do begin
      reg_dir=regs_dir[reg]
      npfile = 0
      print, 'compressing files in directory: '+reg_dir
      
      target=file_basename(reg_dir)
      region = file_basename(file_dirname(reg_dir))
      target_dir = comp_dir + region + delim + target
      file_mkdir, target_dir
      if region ne 'cal' then for idet=idet1,  idet2 do begin
      
        detector=(['A', 'B'])[idet]
        proc_files=file_search(reg_dir+delim+'*'+detector+'1.fts', count=nf)
        filebases=file_basename(proc_files)
        comp_files=target_dir+delim+strmid(filebases, 0, strpos(filebases[0], '1.fts'))+'1_c.fts'
        
        if nf ne 0 then h0 = headfits(proc_files[0])
        
        calfile=''
        kref=0
        for k=0, nf-1 do  begin
          h = headfits(proc_files[k])
          dt = abs(fiss_dt(strmid(filebases[kref], 5, 15), strmid(filebases[k],5,15)))*24.*60. ; min
          if (dt gt 20. or k eq 0 ) and compress  and $
                fxpar(h,'NAXIS') eq 3 or $
                fxpar(h, 'gratwvln') ne fxpar(h0, 'gratwvln') or $
                fxpar(h, 'tel_xpos') * 1000 + fxpar(h, 'tel_ypos') ne fxpar(h0, 'tel_xpos') * 1000 + fxpar(h0, 'tel_ypos') or $
                fxpar(h, 'exptime') ne fxpar(h0, 'exptime') or $
                fxpar(h, 'emgain') ne fxpar(h0, 'emgain') then begin ; added by Kang, make _p file when the information is changed from the previous one.
            kref=k
            pfile=target_dir+delim+strmid(filebases[kref], 0,  strpos(filebases[0], '1.fts'))+'1_p.fts'
            fiss_pca_conv, proc_files[kref], comp_files[kref],  init=1, pfile=pfile
            npfile +=1
          endif
          if compress  then fiss_pca_conv, proc_files[k], comp_files[k],  init=0, pfile=pfile
          print, 'prepared '+detector+' detector '+string(k, format='(i3)')+'th data'
          h0 = h
          wait, 0.1
          
        endfor  ; k
        print, 'The number of _p.fits file is  ' + string(npfile)
        next1:
      endfor ; idet
      
    endfor ; reg
  endif  ; data processing
endfor ; dir_loop

t2=systime(/second)
print, 'total processing time=', (t2-t1)/60., ' minutes'
;endfor

end

;; example!

;directories=['/data/home/chokh/170615/process']
directories=['F:\fiss\20181005']
fiss_process_day3j, directories, get_flat_pattern=1, data_process=1, data_compress=1, tilt_from_raw=1


;mother='F:\fiss\20190624\comp\dc'
;
;dir_all = file_search(mother, '*', /test_dir)
;n = intarr(n_elements(dir_all))
;for ii=0, n_elements(dir_all)-1 do begin
;  dum = file_search(dir_all[ii], '*', count=dum1)
;  n[ii] = dum1
;endfor
;
;real = where(n gt 0)
;
;for i = 0, n_elements(real)-1 do begin
;
;  in_dir = dir_all[real[i]]+path_sep()
;  dum = strsplit(in_dir, 'comp', /extract, /reg)
;  out_dir = strjoin([dum[0], 'png', dum[1]])
;  ;stop
;  print, out_dir
;  ;file_mkdir, out_dir
;
;  f = file_search(in_dir, '*_c.fts', /fully)
;  fiss2png, f, /pca, subdir=out_dir
;
;endfor
end
