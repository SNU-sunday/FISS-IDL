
;pro fiss_process_day, data_dir, out_dir
data_dir='/data/home/chokh/KASI_fiss_process/16jul03_fiss'
get_flat_pattern=1
data_process=1
data_compress=1
useref=1
compress=1
detector='both'

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

t1=systime(/second)
;if !version.os_family eq 'Windows' then delim='\' else delim='/'
delim=get_delim()
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
if nflat eq 0 then begin
print, 'no flat data for detector '+detector+' in directory: '+cal_dir+' . returning from FISS_PROCESS_DAY'
stop
end
for k=0, nflat-1 do begin
fiss_mkcalfile, fflats[k],  cal_dir
flatname=file_basename(fflats[k])
id = strmid(flatname, 5, strpos(flatname, '_Flat.fts')-5)
flat_file=proc_cal_dir+'FISS_FLAT_'+id+'.fts'
fiss_get_flat,  fflats[k], '',  flat_file, slit_pattern=slit_pattern
writefits, proc_cal_dir+'FISS_SLIT_'+id+'.fts', slit_pattern
flat= readfits(flat_file)
tv, bytscl(flat, 0.9, 1.1) , 0
tv, bytscl(slit_pattern, 0.9, 1.1)
ok=1B

read, 'If OK, type 1 else 0: ', ok
if not ok then stop

;a=readfits(fflats[k])
;slit_pattern=a
;for kk=0, n_elements(a[0,0,*])-1 do slit_pattern[*,*,kk]=fiss_slit_pattern(a[*,*,kk])
;slit_pattern=total(slit_pattern, 3) & slit_pattern=slit_pattern/median(slit_pattern)

endfor  ; k

endfor ; idet

endif

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

for reg=0,  ( nreg-1)  do begin
reg_dir=regs_dir[reg]


print, 'processing files in directory: '+reg_dir

region=file_basename(reg_dir)
file_mkdir, proc_dir+region


;if region eq 'qr' or region eq 'dc' then useref=0 else
; useref=1
; compress=1
;if region eq 'prom' or region eq 'limb' then  compress=0 else compress=1

for idet=idet1,  idet2 do begin

detector=(['A', 'B'])[idet]
datafiles=file_search(reg_dir+delim+'*'+detector+'.fts', count=nf)
if nf lt 1 then goto, next

if useref then begin
calfiles=fiss_calfile(datafiles,  cal_dir, type='cal', det=detector)
if calfiles[0]  eq '' then useref=0
endif

if not useref then  calfiles=datafiles

darkfiles=fiss_darkfile(datafiles)
flatfiles=fiss_calfile(datafiles, proc_cal_dir, type='flat', det=detector)
filebases=file_basename(datafiles)

proc_files= proc_dir+region+delim+strmid(filebases, 0, strlen(filebases[0])-4)+'1.fts'
;comp_files=comp_dir+region+delim+strmid(filebases, 0, strlen(filebases[0])-4)+'1_c.fts'

calfile=''
kref=0
for k=0, ( nf-1) do  begin

if calfiles[k] ne calfile then begin
calfile=calfiles[k]
fiss_cal_par, calfile,  fiss_calfile(calfile, proc_cal_dir, typ='flat', det=detector), '', slit_pattern,  tilt,  wvpar,  dw
endif
fiss_prep, datafiles[k], proc_files[k], flatfiles[k], darkfiles[k], slit_pattern,  tilt,  wvpar,  dw, slit_adjust=useref
print, 'prepared '+detector+' detector '+string(k, format='(i3)')+'th data'
  tvscl, fiss_read_frame(proc_files[k], fxpar(headfits(proc_files[k]), 'NAXIS3')/2 , pca=0)
wait, 0.1

endfor  ; k

next:

endfor ; idet

endfor ; reg
endif  ; data processing


if data_compress then begin

comp_dir=data_dir+'comp'+delim
file_mkdir, comp_dir

proc_dir=data_dir+'proc'+delim
regs_dir=file_search(proc_dir+'*', count=nreg)
if nreg eq 0 then begin
 print, 'Directory: '+ raw_dir+' does not contain any region! ...returning from FISS_PROCESS_DAY'
 stop
endif


for reg=0,  nreg-1 do  begin
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
if (dt gt 20. or k eq 0 ) and compress   then begin
kref=k
pfile=comp_dir+region+delim+strmid(filebases[kref], 0,  strpos(filebases[0], '1.fts'))+'1_p.fts'
  fiss_pca_conv, proc_files[kref], comp_files[kref],  init=1, pfile=pfile
endif
if compress  then fiss_pca_conv, proc_files[k], comp_files[k],  init=0, pfile=pfile
print, 'prepared '+detector+' detector '+string(k, format='(i3)')+'th data'
;if compress then
tvscl, fiss_read_frame(comp_files[k], fxpar(headfits(comp_files[k]), 'NAXIS3')/2)  ;$
; else  tvscl, fiss_read_frame(proc_files[k], fxpar(headfits(proc_files[k]), 'NAXIS3')/2 , pca=0)
wait, 0.1
endfor  ; k

next1:
endfor ; idet

endfor ; reg
endif  ; data processing







t2=systime(/second)
print, 'total processing time=', (t2-t1)/60., ' minutes'

end