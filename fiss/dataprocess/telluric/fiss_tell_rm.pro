
pro fiss_tell_model,  wv,  par, f
dwv = par[0]
amp=par[1]^2
f=convol(-amp*fiss_tell_lines(wv+dwv), [-1,1])
end

function fiss_tell_rm, wv, sp, par, nofit=nofit

;+
;  Name: FISS_TELL_RM
;  Purpose:
;              Remove telluric lines from spectrogram
;  Calling sequence:
;              sp_new = fiss_tell_rm(wv, sp,  par, nofit=nofit)
;  Inputs
;           wv      array of wavelengths in angstrom
;           sp      spectrogram to be corrected
;  Optional input:
;           par      adjustment parameters for the model of optical depth
;                       recognized as an input when keyword NOFIT is set
;  Output:
;          sp_new    corrected spectrogram
;  Optional output
;          par    recognized as an output unless keyword NOFIT is set
;  Keyword
;         nofit    if set,  given adjustment parameters are used
;                     if not, parameters are internally determined. (default)
; History:
;      2010 Septmeber: J. Chae first coded
;-
if n_elements(par) ne 2 then par=[0., 1.0]
if not keyword_set(nofit) then begin
y=convol(alog(total(sp,2)/n_elements(sp[0,*])), [-1, 1])
res=curvefit(wv,  y,  fiss_tell_lines(wv) ge 0.03, par,  /noderivative, funct='fiss_tell_model', itmax=20)
endif


model=sp*(exp(par[1]^2*fiss_tell_lines(wv+par[0]))#replicate(1., n_elements(sp[0,*])))
;halpha_flux, wl1,  flux1, tr=tr,  fwhm=0.05
;tr1=interpol(tr, wl1, wv-6562.8)
;stop
;model=sp*(1./(1-0.35*(1-tr1))#replicate(1., n_elements(sp[0,*])))
;stop
return, model
end


;
ha=0
if ha then f=(file_search('E:\FISS\20100723\comp\qr\*A1_c.fts'))[50] else $
f=(file_search('E:\FISS\20100723\comp\qr\*B1_c.fts'))[50]
wv=fiss_wv(f)
d=fiss_read_frame(f, 50)
if  ha  then wc=6562.817d0  else wc=8542.089d0
par=[0,1,1.]
d1=fiss_tell_rm(wv+wc, d, par)
print, par
window, 2, xs=512, ys=256*2
if ha then begin
tvscl, d, 0
tvscl, d1, 1
endif else begin
tvscl, rotate(d,5),0
tvscl, rotate(d1,5), 1
endelse
end