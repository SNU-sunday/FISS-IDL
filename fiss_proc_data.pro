pro  fiss_proc_data,  file,  file1, pinit=pinit, pfile=pfile, wvcal=wvcal, wvpar=wvpar
h=headfits(file)
compressed=strmid(file, strlen(file)-5, 5) eq 'c.fts'
if compressed then h1=fxpar(h, 'COMMENT') else h1=h
band=strmid(fxpar(h1, 'WAVELEN'), 0, 4)
nw=fxpar(h1, 'NAXIS1')
ny=fxpar(h1, 'NAXIS2')
nx=fxpar(h1,'NAXIS3')
fxaddpar, h1, 'BSCALE', 1./5000.

data=intarr(nw,  ny, nx)

sp=fiss_sp_av(file)
sp0= total(sp,2)/ny
if keyword_set(wvcal) then wv=fiss_wv_calib1(band,sp0, wvpar) $
else wv=(findgen(nw)-wvpar[0])*wvpar[1]

sp=fiss_correct_stray1(wv, sp, sp0)
response=fiss_get_response (sp, wv, caii=band eq '8542')
sp=sp*response
sp=total(sp,2)/n_elements(sp[0,*])
 res=1./fiss_get_tell(wv, sp, band=band)#replicate(1.,ny)

for x=0, nx-1 do begin
da=fiss_read_frame(file, x)
da=(fiss_correct_stray1(wv, da, sp0) *(response*res))>(2./5000.)<(32767./5000.)
data[*,*,x]=round(da*5000)

endfor
if compressed then file1=strmid(file, 0, strlen(file)-5)+'d.fts' else  file1=strmid(file, 0, strlen(file)-4)+'_d.fts
fxaddpar, h1,  'CRPIX1',  wvpar[0]
fxaddpar, h1, 'CDELT1', wvpar[1]
fxaddpar, h1, 'HISTORY', 'processed by  FISS_PROC_DATA'
fxhmake, h1, data
writefits, 'tmp.fts', data, h1
if keyword_set(pinit) then if compressed then pfile=strmid(file, 0, strlen(file)-5)+'q.fts' else $
 pfile=strmid(file, 0, strlen(file)-4)+'_q.fts'
if band eq '6562' then ncoeff=31 else ncoeff=21
fiss_pca_conv, 'tmp.fts', file1, ncoeff=ncoeff, pfile=pfile , init=pinit
end
