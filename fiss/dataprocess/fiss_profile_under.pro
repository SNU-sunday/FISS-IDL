;pro get_mean_std, f, prof0, prof1,  del
;
;nf=n_elements(f)
;count=0
;for k=0, nf-1 do begin
;h=fxpar(headfits(f[k]), 'COMMENT')
;nw=fxpar(h, 'NAXIS1')
;ny=fxpar(h, 'NAXIS2')
;nx=fxpar(h,'NAXIS3')
;band=strmid(fxpar(h,'WAVELEN'),0,4)
;if n_elements(data) eq 0 then begin
; nprof=100*nf
; data=fltarr(nw, nprof)
; del=fltarr(nprof)
; endif
;
;x=round(nx*randomu(seed,100))>0<(nx-1)
;y=round(ny*randomu(seed,100))>0<(ny-1)
;for j=0, 99 do begin
;   a=fiss_read_profile(f[k], x[j],y[j])
;   if median(a) ge 1000 then begin
;   data[*,count]=a
;   if n_elements(wl) eq 0 then wl=fiss_wv_calib(band, a)
;   del[count]=fiss_wv_line(wl, a)
;   count=count+1
;  endif
;endfor
;;print, count
;
;endfor
;
;
;
;prof0=fltarr(nw)
;prof1=fltarr(nw)
;for w=0, nw-1 do begin
;prof1[w]=stdev(data[w,0:count-1],m)
;prof0[w]=m
;endfor
;end

;function q_model, wl, prof_av, band
;if band eq '6562' then begin
;tau0=0.55
;dwl= 0.45; sqrt(0.45^2-1.*(4./3.e5*6563.)^2)
;a=0.
;s0=1.1
;wl0=-0.012
;end
;if band eq '8542' then begin
;tau0=0.35
;dwl=0.11; sqrt(0.16^2-1.*(4./3.e5*8542.)^2)
;a=1.5
;s0=0.62
;wl0= -0.004
;endif
; asym=0.
;
;u=(wl-wl0)/dwl
;ch_voigt, a, u, vgt, dis, vgtda, vgtdu
;ch_voigt, a, 0, vgt0
;phi=vgt/vgt0
;dlnphidu = vgtdu/vgt
;source=s0*0.5*total(prof_av*vgt)/total(vgt)
;tau=tau0*phi
;f=(1-source/prof_av)*  (exp(tau)-1.)
;return, f
;end

;pro std_model, wl, par, f , pder
;common  profil_under_com,  wv,  prof_av, par0, band
;npar=n_elements(par)
;tau0=1.
;dwl=abs(par[0])
;coeff1=(par[1])^2
;coeff2=(par[2])^2
;wl0= 0.;par[3]
;u=(wl-wl0)/dwl
;if npar ge 6 then a=par[npar-1] else a=0.
;ch_voigt, a, u, vgt, dis, vgtda, vgtdu
;ch_voigt, a, 0, vgt0
;phi=vgt/vgt0
;dlnphidu = vgtdu/vgt
;ch_voigt, a,  (wv-wl0)/dwl,  vgt1
;prof_av1=interpol(prof_av, wv, wl)
;;if n_elements(par) ge 5 then s0=0.9 else s0=1.2
;s0=abs(par[3])
;source=s0*0.5*total(prof_av*vgt1)/total(vgt1)
;tau=tau0*phi
;f=sqrt((1-source/prof_av1)^2*tau^2*(coeff1+dlnphidu^2*coeff2)+par[4]^2)
;
;end

;pro  get_std_model,  files, par, display=display
;common  profil_under_com, wl,  prof_av, par0, band
;k=0
;f=files[k]
;h=fxpar(headfits(f), 'COMMENT')
;nw=fxpar(h, 'NAXIS1')
;ny=fxpar(h, 'NAXIS2')
;band=strmid(fxpar(h,'WAVELEN'),0,4)
;
;nf=n_elements(files)
;get_mean_std, files, prof_av, prof_std, del
; wl=fiss_wv_calib(band, prof_av)
; ress=prof_std/prof_av
;if band eq '6562' then begin
; sfit=where(wl ge  -2. and wl le 1.3)
; sbg=where( (wl+2.2)*(wl+1.5) le 0. or (wl-1.8)*(wl-2.2) le 0.)
; sweight=where(abs(wl) ge  0.5 and abs(wl) le 1.)
;bg=median(ress[sbg])
; par0=[ 0.45, 0.20,0.20, 1.,   bg]
;endif
;if band eq '8542' then begin
; sfit=where(abs(wl) le 2.)
; sbg=where(abs(wl) ge 2.5 )
; sweight=where(abs(wl) ge  0.2 and abs(wl) le 1.0)
; bg=median(ress[sbg])
; par0=[0.17, 0.3, 0.30,   1.,  bg,  0.5]
;
;endif




;if keyword_set(display) then begin
;!p.multi=[0,2,2]
;std_model, wl, par0, f
;plot, wl, f , yr=[-0.1, 0.20], xr=[-2,2]
;oplot, wl, ress, thick=2
;endif
;
;
;noise=wl*0+stdev((ress-shift(ress,1))[10:n_elements(ress)-10])/1.414
;; noise[sweight]=noise[sweight]/5.
;
;par=par0
;res=curvefit(wl[sfit],  [ress[sfit]], 1./(noise[sfit])^2, par, sigma, function_name='std_model' , chisq=chisq, noderiv=1)
;
;print,  'par in get_std_model=', par, ' chisq=', chisq
;
;
;std_model, wl, par, tmp
;q=q_model(wl,prof_av, band)
;
;if keyword_set(display) then begin
;plot, wl, tmp, xr=[-2,2]
;oplot, wl, ress, thick=2
;plot, wl, prof_av, xr=[-3,3]
;oplot, wl, prof_av*(1+q), thick=2
;endif
;
;
;end


function fiss_profile_under, file, x, y,  wl, profile,  refwv=refwv, alpha=alpha, $
   ress=ress,  neg_range=nr, manual=manual, display=display, npoint=npoint, mask=mask
common  profil_under_com, wv,  prof_av, par0

if n_elements(refwv) eq 0 then refwv=[-3., 1.5]
nwv=n_elements(refwv)
image = fiss_raster(file, refwv, 0.01)
for k=0, nwv-1 do image[*,*,k]=image[*,*,k]/median(image[*,*,k])
nx=n_elements(image[*,0,0])
;profile=0.  & dx=[0,0,0,-1,1] & dy=[0,-1,1, 0,0]
;for jj=0, 4 do profile=profile+fiss_read_profile(file, x+dx[jj], y+dy[jj])
;profile=profile/5.

xyindex, image[*,*,0], xa, ya
if n_elements(mask) eq 0 then mask=byte(xa*0+1)
distance= 100*(sqrt((xa-x)^2+(ya-y)^2) le 10 or not mask)
for k=0, nwv-1 do begin

s=where(abs(image[*,*,k]-1.) le 0.5)
std=stdev((image[*,*,k])[s])
 distance=distance+((median(image[*,*,k]-image[x,y,k],5))/std)^2
 if keyword_set(display) then tv,  bytscl((image[*,*,k]-1.)/std, -3, 3.), nx*k,0
end
if n_elements(npoint) eq 0 then npoint=100
s=(sort(distance))[0:npoint-1]
xsel=s mod nx
ysel=s/ nx
cont=''
if keyword_set(display) then begin
for k=0, nwv-1 do begin
plots, /dev, xsel+nx*k, ysel, psym=3
plots, /dev, x+nx*k, y, psym=1
endfor
read, cont, prompt='continue=? (y if yes)'
if cont ne 'y' then stop
endif
prof_av=0.
for  k=0, npoint-1 do prof_av=prof_av+fiss_read_profile(file, xsel[k], ysel[k])
prof_av=prof_av/npoint

k=0

h=fxpar(headfits(file), 'COMMENT')
nw=fxpar(h, 'NAXIS1')
ny=fxpar(h, 'NAXIS2')
band=strmid(fxpar(h,'WAVELEN'),0,4)

wl=fiss_wv_calib(band,prof_av)
q=q_model(wl, prof_av, band)
ress=q
if not keyword_set(manual) then begin
if n_elements(nr) eq 0 then begin
if band eq '6562' then nr=where(   q ge max(q)*0.1 and abs(wl) ge 0.)
if band eq '8542' then nr=where(  q ge max(q)*0.1 and abs(wl) ge 0.0)
endif

tmp=(profile/prof_av-1.)/q
alpha = max(tmp[nr])>0.0

if keyword_set(display) then begin
plot, wl, tmp, xr=[-1.,1.]
oplot, wl[nr], tmp[nr], psym=1
print, 'alpha=', alpha
read, cont, prompt= 'continue=? (hit any key if yes)'
if cont ne 'y' then stop
endif
endif

result=prof_av*(1+alpha*q)

return, result
end
f=file_search('E:\BBSO Data\20100723\comp\qr\*A1_c.fts')
g=file_search('E:\BBSO Data\20100723\comp\qr\*B1_c.fts')
f=f[n_elements(f)-n_elements(g):*]
;get_std_model,  g[indgen(100)*2], par, display=1
; kk=19 & k1=(kk-40)>0 & k2=(kk+40)<(n_elements(f)-1) & x=61 & yca=112
kk=30
n=100
alphas=fltarr(n)
x=90*randomu(seed, n)+5
y=200*randomu(seed,n)+10
for i=0,n-1 do begin
prof1=fiss_profile_under( g[kk], x[i], y[i], profile, alpha=alpha, display=0)
alphas[i]=alpha
endfor
print, 'median alpha=', median(alphas)
end