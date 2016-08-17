
pro fiss_flat, qsfile, flat, dark, qsfile1, continuum=continuum, tilt=tilt
nc=n_elements(continuum)
h=headfits(qsfile) & nx=fxpar(h, 'NAXIS3') & ny=fxpar(h,'NAXIS2') & nw=fxpar(h, 'NAXIS1')
assowritefits, unit, file=qsfile1, header=h, /open
for x=0, nx-1 do begin
a=readfits_frame(qsfile,x) -dark ; rebin(dark, 256,512)
a1=a/flat
if nc gt 0 then begin
flats=total(a1[continuum, *],1)
flats=replicate(1., nw)#(flats/median(flats))
a1=a1/flats
if keyword_set(tilt) then a1=rot(a1, tilt, cubic=-0.5)
endif
assowritefits, unit, data=fix(round(a1))
endfor
assowritefits, unit, header=h, /close

end

;;qsfile='D:\WORK\FISS\data\BBSO\FISS_20100514_174002_SNU.fts'
;;darkfile='D:\WORK\FISS\data\BBSO\FISS_20100512_222510_SNU.fts'
;
;
;
;;qsfile='D:\work\fiss\data\bbso\fiss_20100519_193245_SNU.fts'
;;darkfile='D:\work\fiss\data\bbso\fiss_20100512_222510_SNU.fts'
;;qsfile1='D:\work\fiss\data\bbso\fiss_20100519_193245_SNU1.fts'
;
;qsfile='D:\work\fiss\data\bbso\fiss_20100519_175432_KAS.fts'
;darkfile='D:\work\fiss\data\bbso\fiss_20100512_193956_KAS.fts'
;qsfile1='D:\work\fiss\data\bbso\fiss_20100519_175432_KAS1.fts'
;
;if 1 then begin
;flat= fiss_get_flat(qsfile, darkfile)
;dark=readfits(darkfile)
;print, qsfile1
;a=total(readfits_frame(qsfile, 350),2)
;continuum=where(a ge (max(a)*0.9))
;help, continuum
;
;fiss_flat, qsfile, flat, dark, qsfile1, continuum=continuum
;print, qsfile1
;pca_conv, qsfile1
;;stop
;endif
;h=headfits(qsfile) & nx=fxpar(h, 'NAXIS3') & ny=fxpar(h,'NAXIS2')
;images=fltarr(nx,ny, 5)
;wv=[450, 213,243, 273,  350 ]
;
;;wv=[50, 239, 254, 269]
;wv1=wv-[20,5,5,5]
;wv2=wv+[20,5,5,5]
;for x=0, 749 do begin
;;a1=readfits_frame(qsfile1,x)  ; rebin(dark, 256,512)
;a1=pca_read(qsfile1, x)
;;a1=a/flat  ;/rebin(flat, 256, 512)
;for w=0,3 do begin
;w1=wv1[w] & w2=wv2[w]
;images[x, *, w]=total(a1[w1:w2,*], 1)
;endfor
;endfor
;window, 3, xs=750*2, ys=512*2
;flat_im=images[*,*,0]/median(images[*,*,0])
;tvscl, flat_im, 0
;for w=1, 3 do tv, bytscl(images[*,*,w]/median(images[*,*,w])/flat_im, 0.7, 1.5),w
;end