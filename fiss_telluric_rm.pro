pro fiss_telluric_model,  wv,  par, f
dwv = par[0]
amp=par[1]
disp=par[2]
f=convol(-amp*fiss_telluric_tau((wv-median(wv))*disp+median(wv)+dwv), [-1,1])
end
function fiss_telluric_rm, wv, sp, par, nofit=nofit
if not keyword_set(nofit) then begin
par=[0., 1.0, 1.0]
y=convol(alog(total(sp,2)/n_elements(sp[0,*])), [-1, 1])
res=curvefit(wv,  y,  fiss_telluric_tau(wv) ge 0.01, par,  /noderivative, funct='fiss_tell_model')
endif
model=sp*(exp(par[1]*fiss_telluric_tau((wv-median(wv))*par[2]+median(wv)+par[0]))#replicate(1., n_elements(sp[0,*])))
return, model
end

ha=1
if ha then f=(file_search('E:\BBSO Data\20100723\comp\qr\*A1_c.fts'))[50] else $
f=(file_search('E:\BBSO Data\20100723\comp\qr\*B1_c.fts'))[50]

d=fiss_sp_av(f, /pca)
wv=fiss_wv(f)
;d=fiss_read_frame(f, 50)
if  ha  then wc=6562.817d0  else wc=8542.089d0

;a1=fiss_rm_telluric(wv+wc, a, par)
;d1=d*exp(fiss_telluric_tau(wv+wc)#replicate(1., 250));
d1=fiss_rm_telluric(wv+wc, d, par)
print, par
window, 2, xs=512, ys=256*4
;tvscl, rotate(a,5), 0
;tvscl, rotate(a1,5), 1
if ha then begin
tvscl, d, 2
tvscl, d1, 3
endif else begin
tvscl, rotate(d,5),2
tvscl, rotate(d1,5), 3
endelse
end