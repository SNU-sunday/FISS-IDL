pro fiss_process_day2, directories, get_flat_pattern=get_flat_pattern, $
                       data_process=data_process, data_compress=data_compress

if ~n_elements(get_flat_pattern) then get_flat_pattern=1
if ~n_elements(data_process) then data_process=1
if ~n_elements(data_compress) then data_compress=1

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
  ;      stop
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
      file_mkdir, proc_dir+region
      
      for idet=idet1,  idet2 do begin
        detector=(['A', 'B'])[idet]
        datafiles=file_search(reg_dir+delim+'*'+detector+'.fts', count=nf)
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
  
        proc_files= proc_dir+region+delim+strmid(filebases, 0, strlen(filebases[0])-4)+'1.fts'
        calfile=''
        kref=0
        for k=0, (nf-1) do  begin
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
    regs_dir=file_search(proc_dir+'*', count=nreg)
    if nreg eq 0 then begin
      print, 'Directory: '+ raw_dir+' does not contain any region! ...returning from FISS_PROCESS_DAY'
      stop
    endif
    
    
    for reg=0,  ( nreg-1)  do begin
      reg_dir=regs_dir[reg]
      
      print, 'compressing files in directory: '+reg_dir
      
      region=file_basename(reg_dir)
      file_mkdir, comp_dir+region
      if region ne 'cal' then for idet=idet1,  idet2 do begin
      
        detector=(['A', 'B'])[idet]
        proc_files=file_search(reg_dir+delim+'*'+detector+'1.fts', count=nf)
        filebases=file_basename(proc_files)
        comp_files=comp_dir+region+delim+strmid(filebases, 0, strpos(filebases[0], '1.fts'))+'1_c.fts'
        
        calfile=''
        kref=0
        for k=0, nf-1 do  begin
          dt = abs(fiss_dt(strmid(filebases[kref], 5, 15), strmid(filebases[k],5,15)))*24.*60. ; min
          if (dt gt 20. or k eq 0 ) and compress  and fxpar(headfits(proc_files[k]),'NAXIS') eq 3 then begin
            kref=k
            pfile=comp_dir+region+delim+strmid(filebases[kref], 0,  strpos(filebases[0], '1.fts'))+'1_p.fts'
            fiss_pca_conv, proc_files[kref], comp_files[kref],  init=1, pfile=pfile
          endif
          if compress  then fiss_pca_conv, proc_files[k], comp_files[k],  init=0, pfile=pfile
          print, 'prepared '+detector+' detector '+string(k, format='(i3)')+'th data'
          wait, 0.1
        endfor  ; k
        
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

directories=['/data/home/chokh/temp/24']
fiss_process_day2, directories
end