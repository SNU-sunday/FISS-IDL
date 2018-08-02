;+ fiss_wv_calib_atlas
  ; :Description:
  ;    wavelength calibration for FISS data using Solar atlas irradiance
  ;
  ; :Params:
  ;    data : 2d(spectrogram) or 3d cube FISS data  / or FISS filename
  ;    header : FISS header
  ;
  ; :Keywords:
  ;    atlas : Solar atlase
  ;    detector : FISS camera (A or B)
  ;    cent_wv : central wavelength (input value)
  ;     
  ; :Author: chokh first coded (2016. june)
  ;-
function fiss_wv_calib_atlas, data, header, intensity=intensity, wave=wave, $
                              detector=detector, cent_wv=cent_wv
  if ~keyword_set(intensity) or ~keyword_set(wave) then begin
    cd, current=c
    dir=file_which('wall2011.pro')
    cd, strmid(dir, 0, strlen(dir)-12)
    restore, 'solar_atlas.sav'
    cd, c
  endif
  
  if n_elements(header) eq 0 then begin
    file=data
    data=readfits(file, header, /sil)
  endif
  if ~keyword_set(detector) then begin
    detector=(fxpar(header, 'NAXIS1') eq 512) ? 'A' : 'B'
  endif
  if (size(data))[0] eq 3 then data1=median(data, dim=3) else data1=data
  
  if ~keyword_set(cent_wv) then wv0=fxpar(header, 'GRATWVLN') else wv0=cent_wv
  crval1=wv0
  if detector eq 'A' then begin
    nw=512
    ny=256
    if abs(wv0-6562.817) lt 5. then crval1=6562.817
    if abs(wv0-5889.95) lt 5. then crval1=5889.95
    if abs(wv0-5875.618) lt 5. then crval1=5875.618
    get_echelle_grating, 79, 62., 0.93, crval1, order, alpha, br
  endif
  if detector eq 'B' then begin
    nw=502
    ny=250
    if abs(wv0-6562.817) lt 5. then crval1=8542.09
    if abs(wv0-5889.95) lt 5. then crval1=5434.5235
    get_echelle_grating, 79, 62., 1.92, crval1, order, alpha, br
  endif
  wr=fiss_sp_range(alpha, order, detector)
  dw=(wr[1]-wr[0])/nw
  ww=findgen(nw)*dw+wr[0]
  int=interpol(intensity, wave, ww)
  
  cen_pix=fltarr(ny)
  for loop_y=0, ny-1 do begin
;  med=fltarr(nw)
;  for dum=0, nw-1 do med[dum]=median(data1[dum, *])
  med=data1[*, loop_y]
  leg=findgen(nw)-nw*0.5
  cor=c_correlate(med, int, leg)
  shift1=(where(cor eq max(cor)))[0]
  if shift1 eq -1 then shift1=nw*0.5
  xra=3
  xdum=findgen(xra*2+1)+shift1-xra
  pfit=poly_fit(xdum, cor[xdum], 2)
  ww_cor=ww+interpol(leg, findgen(nw), pfit[1]/(-2.*pfit[2]))*dw
  cen_pix[loop_y]=interpol(findgen(nw), ww_cor, crval1)
  endfor
  cen_pix1=median(cen_pix)
  wvpar=[cen_pix1, dw, crval1]
;  stop
return, wvpar
end