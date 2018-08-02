pro fiss_tell_model_v2,  wv,  par, f
common cloud_model_v2_com, i_in
dwv = par[0]
amp=par[1]
disp=1.; par[2]
wldif=i_in
;print, 'wldif :', wldif
f=convol(-amp*fiss_tell_lines_v2((wv-median(wv))*disp+median(wv)+dwv,wldif), [-1,1])
end

function fiss_tell_rm_v2, wv, sp, par, wldif, nofit=nofit
common cloud_model_v2_com, i_in
i_in=wldif
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
if not keyword_set(nofit) then begin
par=[0., 1.0]
y=convol(alog(total(sp,2)/n_elements(sp[0,*])), [-1, 1])
res=curvefit(wv,  y,  fiss_tell_lines_v2(wv,wldif) ge 0.02, par,  /noderivative, funct='fiss_tell_model_v2')
endif
model=sp*(exp(par[1]*fiss_tell_lines_v2((wv-median(wv))+median(wv)+par[0],wldif))#replicate(1., n_elements(sp[0,*])))
;stop
return, model
end
