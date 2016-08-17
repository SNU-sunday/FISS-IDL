pro fiss_mkcalfile, datafile, cal_dir,  from_flat=from_flat
if n_elements(from_flat) eq 0 then from_flat=1
h=headfits(datafile)
if keyword_set(from_flat) then begin
a=fiss_read_frame(datafile, fxpar(h, 'NAXIS3')/2)
filename=file_basename(datafile)
newfile=cal_dir+strmid(filename, 0, strpos(filename, '_Flat.fts'))+'_Cal.fts'
endif else begin
 a=fiss_sp_av(datafile)-fiss_sp_av(fiss_darkfile(datafile))
 filename=file_basename(datafile)
newfile=cal_dir+strmid(filename, 0, strlen(filename)-4)+'_Cal.fts'
endelse
fxaddpar, h, 'HISTORY', 'prepared from '+filename
writefits, newfile, a, h
end