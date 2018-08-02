;**********************************************************
pro draw_profs, band,wl,  I_out,  I_out_av,    I_mod, I_in,  id=id,  type=type,  $
                     yplot=yplot, model=model, chisq=chisq, title=title
classical=0
if n_elements(type) eq 0 then type=4
case type of
              0: begin & yplot=2 & model=0 & classical=0 & end
              1: begin & yplot=1 & model=0 & classical=1 & end
              2: begin & yplot=1 & model=1 & classical=0 & end
              3: begin & model=1 & yplot=1 & classical=0 & end
              4: begin & model=1 & yplot=1 & classical=0 & end
              5: begin & yplot=1 & model=0 & classical=1 & end
endcase

  if n_elements(model) eq 0 then model=0

if yplot eq 1 then xcharsize=0.9
if yplot eq 2 then xcharsize=1.1
if yplot eq 3 then xcharsize=1.2

if yplot eq 1 then pos=[0.2, 0.2, 0.9, 0.9]
set_plot, 'ps'

filename='fg_plot'+band+'_'+id  +'_'+strtrim(string(type),2)
;if  keyword_set(classical) then filename=filename+'c'
device, xs=8., ys=yplot*5+1., color=1, file=filename+'.eps', encap=1, bits=8, /bold

@color
!P.multi=[0,1, yplot]
wlpm=wl*100. ; wavelength in pm
if band eq '6562' then xr=[-1.,1]*1.5*100 else xr=[-1,1]*100
if band eq '6562' then syms=1.2 else syms=2
usersym, syms*0.2*cos(findgen(21)/10.*!pi), syms*0.2*sin(findgen(21)/10.*!pi), thick=2, color=green
if type  eq 0  then begin
plot, wlpm,  I_out, xr=xr, yr=[0, 0.8],  xst=1,font=0, xthick=4, ythick=4, psym=8,  $
  xtitle='!6!Ml-l!d0!X!n (pm)', ytitle='Intensity', xcharsize=xcharsize, ycharsize=xcharsize, pos=pos, /norm
;oplot, wl, I_in, thick=2, color=green
oplot, wlpm,  I_out_av, thick=4, color=blue, psym=0, syms=syms*0.15
if model then oplot, wlpm,  I_mod, thick=2, color=red
endif

if type  eq 4  then begin
plot, wlpm,  I_out, xr=xr, yr=[0, 0.8],  xst=1,font=0, xthick=4, ythick=4, psym=8, $
  xtitle='!6!Ml-l!d0!X!n (pm)', ytitle='Intensity', xcharsize=xcharsize, ycharsize=xcharsize, pos=pos
oplot, wlpm,  I_mod, thick=2, color=red
oplot, wlpm, I_in, thick=4, color=red, linest=2
oplot, wlpm,  I_out_av, thick=4, color=blue, psym=0, syms=syms*0.15
endif

if type eq 0 or type eq 1 or type eq 2 or type eq 5   then begin
plot, wlpm, (I_out-I_out_av)/I_out_av, xr=xr, yr=[-0.5, 0.5], yst=1, xst=1,  font=0, xthick=4, ythick=4, title=title,   $
  psym=8, xtitle='!6!Ml-l!d0!X !n (pm)', ytitle='Contrast', xcharsize=xcharsize, ycharsize=xcharsize, pos=pos, /norm
  if model then oplot, wlpm, (I_mod-I_out_av)/I_out_av,  color=red, thick=2
 ; if model then xyouts,  total(xr*[0.3, 0.7]), 0.35, '!Mc!X!u2!n='+string(chisq, format='(f5.2)'), font=0
;if classical then oplot, wlpm, I_mod0, color=blue, thick=4
endif
if type eq 3 then begin
 plot, wlpm,  G_data, xr=xr, yr=[0, 0.2],  font=0, xst=1,xthick=4, ythick=4, psym=8, $
     xtitle='!6!Ml-l!d0!X !n (pm)', ytitle='G', xcharsize=xcharsize, ycharsize=xcharsize, pos=pos, /normal
if model then oplot, wlpm, G_mod, color=red, thick=2
endif


device, /close
!p.multi=[0,1,1]
set_plot, 'win'
end

function get_tickname,  x1, x2, del
del=5
repeat begin
n=(x2-x1)/del
del=del*2
endrep until n lt 7
del=del/2
x11=(x1/del +(x1 mod del ne 0) )*del
x22=(x2/del)*del
n1=(x22-x11)/del+1
tickname=strtrim(string(indgen(n1)*del+x11),2)
return, tickname
end
pro draw_image_marks, band, file, x1, y1, x2, y2, name=name, slength=slength

if band eq  '6562' then begin
sel=[0, 1, 3, 5, 7,9]
wvs=     ([-4., -0.8,  -0.60, -0.40,  -0.20,        0,     0.20,   0.4,   0.60,    0.8,   4.0])[sel]
minv=([-0.1, -0.075,  -0.15,  -0.20,  -0.30,   -0.15 ,  -0.30,  -0.2,  -0.15,  -0.075,  -0.1])[sel]
maxv=([0.04, 0.04, 0.08,   0.15,   0.15,     0.15,   0.15, 0.15,   0.08,    0.04,   0.04])[sel]
bandwidth=0.05
color=3
dy=0
endif    else begin
sel=[0, 3, 4,5,6,7]
  wvs = ([-4.,  0.8, -0.6, -0.4, -0.2, 0,     0.2, 0.4, 0.6,  0.8,   4.0])[sel]
minv=([-0.07, -0.07,  -0.10,  -0.15,  -0.25,    -0.30,          -0.25,   -0.15,  -0.10,    -0.07,  -0.07])[sel]
maxv=([0.04,  0.05,  0.075, 0.10,   0.15,       0.25,             0.15,    0.10, 0.075,  0.05,   0.04])[sel]
bandwidth=0.02
color=8
dy=-8
endelse
if n_elements(slength) eq 0 then slength=1
data=fiss_raster(file, wvs,bandwidth, x1, x2,y1, y2)
if slength eq 3 then  for k=0, n_elements(data[0,0,*])-1 do data[*,*,k]=smooth(data[*,*,k], 3)
del= 1  ; Mm
if n_elements(name) eq 0 then name='fg_'+band

s=size(data)
nx=x2-x1+1
ny=y2-y1+1
nwv = n_elements(wvs)
set_plot, 'ps'
yimg=6. & ximg=yimg/ny*nx & gap=0.01
device, xs=ximg*nwv+(nwv-1)*gap+1.5, ys=1*yimg+1., color=1, file=name+'.eps', encap=1, bits=8, /bold

for k=0, nwv-1 do begin
 loadct, color, /sil
image=data[*,*,k] ; total(data1[w1:w2,*,*], 1)/(w2-w1+1)
s=where(image le 0.03,count)
if count ge 1 then image[s]=median(image)
tv, bytscl(alog10(image/median(image)), minv[k], maxv[k]),  $
              k*(gap+ximg)+1., 0.6, /cen, xs=ximg,  ys=yimg
xtickname=get_tickname(x1, x2, xtickinterval)
xtickv=float(xtickname)
nxticks=n_elements(xtickv)
ytickname=get_tickname(y1-dy, y2-dy, ytickinterval)
ytickv=float(ytickname)
nyticks=n_elements(ytickv)

 if k ne 0 then   ytickname=replicate( ' ', nyticks+1)
if k eq  2 or 1  then xtitle='H!Ma!X Pixel' else xtitle=' '
if k eq 0   then ytitle='H!Ma!X Pixel' else ytitle=' '
loadct, 0, /sil
 plot, /noerase, /nodata, xr=[x1, x2], yr=[y1, y2]-dy,  xst=1, yst=1,  [0,1], [0,1], $
   xtitle=xtitle, ytitle=ytitle,     ynozero=1, xminor=5, yminor=5,  $
     ytickname=ytickname, ytickv=ytickv,  xtickname=xtickname, xtickv=xtickv, $
     ; xticks=nxticks, yticks=nyticks,  $
      xticks=nxticks-1, yticks=nyticks-1,  $
  pos=[1+k*(gap+ximg), 0.6, 1+k*(gap+ximg)+ximg, 0.6+yimg]*1000, /dev ,$
          xthick=2, ythick=2, xticklen=0.05, yticklen=0.06, $
          font=0, xcharsize=0.5, ycharsize=0.5
     xyouts, font=0, 0.5*(x1+x2), y2-dy+(y2-y1)*0.02, color=0,  size=0.5,  align=0.5, $
 string(wvs[k]*0.1*1000, format='(i4)')+ ' pm'
endfor

device, /close  & set_plot, 'win'
end

pro draw_parameter,  band, apar, x1, y1, name=name

if n_elements(name) eq 0 then name='map_par'+band
if n_elements(name1) eq 0 then name1='dis_par'+band

s=size(apar)
npar=s[1]
nx=s[2]
ny=s[3]
x2= x1+nx-1
y2=y1+ny-1
wy=round(ny*0.05)>1
images=bytarr(nx, ny, 6)

 image1=  bindgen(256)#replicate(1B, wy)
caption=[  '!9t!d0!n!4', $
   'v', 'W',  'S/I!dc!n', ' t!d0!n',  ' log !Mc!u2!n!X']
if band eq '6562' then begin
s1=['0',  '-15', '.2', '0', '0', '-1'] & m1=float(s1)
s2=['2',      '15', '.8', '0.4', '2', '1'] & m2=float(s2)
col=[3, 33,  4, 4,3, 4]
wl0=6562.8
dy=0
endif else begin

s1=['0',  '-10', '.1',    '0', '0', '-1'] & m1=float(s1)
s2=['1',      '10', '.4',    '0.3', '1', '1'] & m2=float(s2)
col=[3, 33,  4, 4,3, 4]
dy=-8
wl0=8542.
endelse
images[*,0:ny-1,0]=bytscl(apar[0,*,*]-0.*apar[4,*,*], m1[0], m2[0])  ; dtau
images[*,0:ny-1,1]=bytscl((apar[1,*,*]-0.*median(apar[1,*,*]))/wl0*3.e5, m1[1],m2[1])  ; vel
for k=2, 4 do images[*,0:ny-1,k]= bytscl(apar[k,*,*],  m1[k], m2[k]) ; Doppler width
images[*,0:ny-1,3]= bytscl((apar[3,*,*]),  m1[3], m2[3])
images[*,0:ny-1,5]= bytscl(alog10(apar[8,*,*]),  m1[5], m2[5])
nimage=n_elements(images[0,0,*])

images[*,*,0]=255-images[*,*,0]
images[*,*,4]=255-images[*,*,4]
n=255/255 ; (255/15)

for k=0, 5 do images[*,*,k]=n*((images[*,*,k]/n)+1)<255
!p.multi=[0,1,1]

set_plot, 'ps'
yimg=6. &  ximg=yimg/ny*nx & & gap=0.01
device, xs=ximg*nimage+(nimage-1)*gap+1.5, ys=1*yimg+2., color=1, file=name+'.eps', encap=1, bits=8, /bold

for k=0, nimage-1 do begin
loadct, col[k], /sil
;h_eq_ct,  images[*,*,k]
tv, images[*,*,k],   k*(gap+ximg)+1.0, 1., /cen, xs=ximg,  ys=yimg ;*(1.+float(wy)/ny)
if k eq 0 or k eq 4 then image2=255-image1 else image2=image1
tv,  image2,  k*(gap+ximg)+1.0,  1.+yimg , /cen, xs=ximg, ys=yimg*float(wy)/ny
xtickname=get_tickname(x1, x2, xtickinterval)
xtickv=float(xtickname)
nxticks=n_elements(xtickv)
ytickname=get_tickname(y1, y2, ytickinterval)
ytickv=float(ytickname)
nyticks=n_elements(ytickv)

 if k ne 0 then   ytickname=replicate( ' ', nyticks+1)
if k eq  2 or 1  then xtitle='H!Ma!X Pixel' else xtitle=' '
if k eq 0   then ytitle='H!Ma!X Pixel' else ytitle=' '
loadct, 0, /sil
 plot, /noerase, /nodata, xr=[x1, x2], yr=[y1, y2],  xst=1, yst=1,  [0,1], [0,1], $
   xtitle=xtitle, ytitle=ytitle,     ynozero=1, xminor=5, yminor=5,  $
     ytickname=ytickname, ytickv=ytickv,  xtickname=xtickname, xtickv=xtickv, $
     ; xticks=nxticks, yticks=nyticks,  $
      xticks=nxticks-1, yticks=nyticks-1,  $
  pos=[1+k*(gap+ximg), 1, 1+k*(gap+ximg)+ximg, 1+yimg]*1000, /dev ,$
          xthick=2, ythick=2, xticklen=0.05, yticklen=0.06, $
          font=0, xcharsize=0.5, ycharsize=0.5
w=[0.88, 0.5, 0.12]
xyouts, [x1*w+x2*(1-w)],  (y2+wy*1.3),  font=0, [s1[k], caption[k], s2[k]], align=0.5, size=0.7
endfor
device, /close  & set_plot, 'win'

end

pro select_reference,  wvp, profile,  wv, refdata, sigdata,wvs,  ref, sig
;p1=interpol(profile, wvp, wv1)
;p2=interpol(profile, wvp, wv2)
nwv=n_elements(wv)
i=interpol(findgen(nwv), wv,wvp  )
 ref=refdata[i, *]
 sig=sigdata[i,*]
 nr=n_elements(ref[0,*])
 ;& r1=refdata[round(i1),*]*(1-i1+round(i1))+refdata[round(i1)+1,*]*(i1-round(i1))
;i2=interpol(findgen(nwv), wv, wv2) & r2=refdata[round(i2),*]*(1-i2+round(i2))+refdata[round(i2)+1,*]*(i2-round(i2))
ss=interpol(findgen(n_elements(wvp)), wvp, wvs)
tmp=fltarr(nr)
for k=0, nr-1 do tmp[k]= $
 (profile[ss[0]]/profile[ss[1]]-ref[ss[0],k]/ref[ss[1],k])^2+(profile[ss[2]]/profile[ss[3]]-ref[ss[2],k]/ref[ss[3],k])^2  ;$
 ;+ (profile[ss[0]]-ref[ss[0],k])^2+ (profile[ss[3]]-ref[ss[3],k])^2
sel=(where(tmp eq min(tmp(where(finite(tmp)))) ))[0]
factor=median(profile[ss]/ref[ss, sel])
ref=ref[*, sel]*factor
sig=sig[*, sel]

end


pro f_emb_model_pca,  wl, par, av_Iout,  y, band=band
common  c_emb_model,  fixvalue
pars=fltarr(8)
pars[0:4]=par
 pars[5:7]=fixvalue

tau0 =      pars[0]     &  lam_c =       pars[1]  &      dlam = pars[2]    &      src = pars[3]
av_tau0 = pars[4]    &  av_lam_c =  pars[5]  & av_dlam= pars[6]     &  av_src = pars[7]

av_u =(wl-av_lam_c)/av_dlam
phi_lam_av = exp(-av_u^2)
av_tau = av_tau0*phi_lam_av
u=(wl-lam_c)/dlam

phi_lam=exp(-u^2)
tau = tau0*phi_lam
c_lam_out = (av_src/av_Iout-1.)*(1-exp(-(tau-av_tau)))+ (1-exp(-tau))*(src-av_src)/av_Iout

Iin= av_Iout*exp(av_tau)+av_src*(1.-exp(av_tau) )
y=c_lam_out

end

function emb_fea_pca_par, index,  nd, band=band
if band eq '6562' then wl0=6562.8 else wl0=8542.
if band eq '6562' then dwl1=0.40 else dwl1=0.20
ntau0=5L & nlam_c=11L & ndlam=5L & nsrc=5L & nav_tau0=5L
Nd = ntau0*nlam_c*ndlam*nsrc*nav_tau0

tau0_array=10^(0.+0.3*findgen(ntau0)/(ntau0-1.))
lam_c_array= (findgen(nlam_c)-nlam_c/2)/(nlam_c/2)*dwl1
if band  eq '6562' then dlam_array = 0.20+0.4*findgen(ndlam)/(ndlam-1.) $
                               else dlam_array = 0.10+0.30*findgen(ndlam)/(ndlam-1.)
src_array        =  0.05+0.25*findgen(nsrc)/(nsrc-1.)
if band  eq '6562' then av_tau0_array= 10^(-0.5+0.8*findgen(nav_tau0)/(nav_tau0-1)) $
  else av_tau0_array= 10^(-0.5+0.3*findgen(nav_tau0)/(nav_tau0-1))

tau0_index = index mod ntau0  & tau0=tau0_array[tau0_index]
 lam_c_index = (index / ntau0) mod nlam_c   & lam_c=lam_c_array[lam_c_index]
 dlam_index = (index/(ntau0*nlam_c)) mod ndlam  & dlam=dlam_array[dlam_index]
 src_index = (index/(ntau0*nlam_c*ndlam)) mod nsrc  & src=src_array[src_index]
 av_tau0_index = (index/(ntau0*nlam_c*ndlam*nsrc)) mod nav_tau0  & av_tau0=av_tau0_array[av_tau0_index]

par=[tau0, lam_c, dlam, src,  av_tau0]
return, par

end
pro   emb_fea_pca_archive, wl,  I_out_av, simdata, par_data, fixvalue1,  band=band
;+
;/  Inputs
;            wl           wavelengths
;              I_out        observed intensity profile at the point of interest
;              I_out_av   average of intensity profiles over  the ensemble
;             std_I_out   standard deviation of intensity profiles in the ensemble
;
;  Outputs
;             I_in         profile of incident intensity
;             I_mod    model of the observed profile
;             par      parameters of the feature
;            par_av   parameters of the average slab
;-
common  c_emb_model,  fixvalue
fixvalue=fixvalue1
null=emb_fea_pca_par( 0, nd, band=band)
nwl=n_elements(wl)

count=0L
for i=0L,  Nd-1 do begin
 par=emb_fea_pca_par (i, nd, band=band)
 f_emb_model_pca, wl, par, I_out_av, y, band=band
 ;pass=par[0] gt par[4]
 ;if pass   then
 if count eq 0 then begin
 par_data=par
 simdata=y
 count=count+1
endif else  begin
par_data=[par_data, par]
simdata=[simdata, y]
count=count+1
endelse
endfor
simdata=reform(simdata, n_elements(y), count)
par_data=reform(par_data,  n_elements(par), count)
end

pro emb_pca_conv, simdata, Ncoeff,  evec,  edata
Nd=n_elements(simdata[0,*])
f=Nd/20000>1
Nd1=Nd/f
l=randomu(seed, Nd1)*Nd
data1=simdata[*,  l]
carr=transpose(data1)##data1
eval1=la_eigenql(carr, eigenvectors=evec1, /double)
N=n_elements(eval1)
eval=eval1  & evec=evec1
for j=0, N-1 do begin
eval[j]=eval1[N-1 - j]
evec[*,j]=evec1[*, N-1-j]
endfor
edata=fltarr(Ncoeff, Nd)
for i=0L, Nd-1 do for j=0, Ncoeff-1 do edata[j, i]=total(simdata[*,i]*evec[*,j])
end

pro emb_pca_fit, par_data,  evec, edata, wl,  contrast, I_out_av,  par, y, fixvalue=fixvalue1, band=band
common emb_com,  noise, etau0, elam, esrc
common  c_emb_model,  fixvalue

if band eq '6562' then noise=0.0072 else noise=0.01
 if  band eq '6562' then etau0=1.0  else etau0=0.75
 if  band eq '6562' then elam=25./3.e5*6563.  else elam=15./3.e5*8542.
if band eq '6562' then  esrc=10*0.1 else esrc=10*0.1

ncoeff=n_elements(edata[*,0])
Nd=n_elements(edata[0,*])
Ndata=n_elements(contrast)-5
coeff=fltarr(Ncoeff)

weight=[contrast*0.+1./noise^2,  ndata/[etau0, elam, esrc]^2*[1,1,1]]

for j=0, Ncoeff-1  do coeff[j]=total(contrast*evec[*,j])
res=fltarr(nd)
res=total((edata-coeff#replicate(1., nd))^2, 1)/noise^2  $
      + (par_data[4,*]-0)^2*(Ndata*etau0^2)   + par_data[1,*]^2*(Ndata/elam^2) ; $
    ;  + (par_data[3,*]-fixvalue[2])^2*( Ndata/esrc^2)
s=where(res eq min(res), n)
par=reform(par_data[*, s[0]])
f_emb_model_pca, wl,  par, I_out_av, y, band=band

end

pro f_emb_av_model,  xwl, par,  y
common cloud_emb_com,  av_Iout, Iin, positive, pars, fi

wl= xwl[0:n_elements(av_Iout)-1]
pars[fi]=par^(1+positive[fi])

;pars=[ av_tau0, av_lam_c, av_dlam, av_src, del_tau, del_lam_c,  del_dlam, del_src, std_error]
;pars=[ av_lam_c, av_dlam, av_src, del_tau, del_lam_c,  std_error, av_tau0, del_dlam, del_src]
;
; av_lam_c =  pars[0]  & av_dlam= pars[1]     &  av_src = pars[2]
;del_tau = pars[3]     & del_lam_c=  pars[4]
;std_error = pars[5]  & del_src=pars[6]
;
;av_u =(wl-av_lam_c)/av_dlam
;phi_lam_av = exp(-av_u^2)
;
;av_tau0=1.0 & av_tau = av_tau0*phi_lam_av
;disp = (1.-av_src/av_Iout)^2*(    (del_tau*phi_lam_av)^2  $
 ;                         +(phi_lam_av*2*av_u)^2*(del_lam_c/av_dlam)^2) + std_error^2  $
               ;           (del_dlam*av_u/av_dlam)^2)   ) $
  ;           +  (1-exp(-av_tau))^2*(del_src/av_Iout)^2
            ;+std_error^2

;pars=[ av_lam_c, av_dlam, av_src, del_tau, del_lam_c,  std_error,  del_src]; c,avtau0]

 av_lam_c =  pars[0]  & av_dlam= pars[1]     &  av_src = pars[2]
del_tau = pars[3]     & del_lam_c=  pars[4]
std_error = pars[5]
del_src=pars[6]  & av_tau0=1.  & del_dlam=pars[7]
;av_tau0=1. & del_dlam=0. & del_src=0.
av_u =(wl-av_lam_c)/av_dlam
phi_lam_av = exp(-av_u^2)
av_tau=av_tau0*phi_lam_av

disp = (av_src/av_Iout -1.)^2*(    (del_tau*phi_lam_av)^2  $
                          +(2*av_u*av_tau)^2*(del_lam_c/av_dlam)^2   $
                          + (2*av_u^2*av_tau)^2*(del_dlam/av_dlam)^2 $
                           )                + (1-exp(-av_tau))^2/av_Iout^2*del_src^2       $
                          + std_error^2

y=sqrt(disp)

end

pro   emb_av_model, wl,   I_out_av, data,  G_mod, pars1, $
  band=band, reg=reg, fixindex=fixindex,  fixvalue=fixvalue, parguess=parguess,   chisq=chisq,  sig_pars=sig_pars, $
     noisefactor=noisefactor
;+
;/  Inputs
;            wl           wavelengths
;              I_out        observed intensity profile at the point of interest
;              I_out_av   average of intensity profiles over  the ensemble
;             std_I_out   standard deviation of intensity profiles in the ensemble
;
;  Outputs
;             I_in         profile of incident intensity
;             I_mod    model of the observed profile
;             par      parameters of the feature
;            par_av   parameters of the average slab
;-
common cloud_emb_com, av_Iout, Iin, positive, pars, fi

if  n_elements(reg) eq 0 then if  band eq '6562' then reg=1.e-2 else reg=1.e-2
av_Iout=I_out_av
ndata=n_elements(I_out_av)

;data = G_data
xwl=wl

weight=data*0.+1./0.01^2  ; 1./0.001^2*(1+0*(data ge  0.5*max(data)))

if  keyword_set(parguess) then pars=pars1 else begin
av_tau0=1.
av_lam_c =0. ;*wl[ (where(I_out_av eq min(I_out_av)))[0]]
if band eq '6562'  then  av_dlam=0.38  else av_dlam=0.27
if band eq '6562'  then  av_src = 0.12 else av_src=0.10
if band eq '6562' then del_tau = 0.10 else del_tau=0.10
if band eq '6562' then  del_lam_c=0.0  else del_lam_c=0.00
del_dlam = 0.0 & del_src = 0.0
std_error =(median( [data[0:10], data[ ndata-10:ndata-1]]))

;pars=[ av_lam_c, av_dlam, av_src, del_tau, del_lam_c,  std_error, del_src]
pars=[ av_lam_c, av_dlam, av_src, del_tau, del_lam_c,  std_error,  del_src, del_dlam]; , del_dlam,  av_tau0]

 pars1=pars
endelse

npar=n_elements(pars)

positive=replicate(0, npar)
positive[[ 1,2]] =1

fita=replicate(1, npar)
if n_elements(fixindex) ne 0 then begin
fita[fixindex]=0
pars[fixindex]=fixvalue
endif
fi=where(fita ne 0)
par=pars[fi]^(1./(1+positive[fi]))
;help,par, pars

 y=curvefit(xwl,  data, weight,  par, sig_pars, function_name='f_emb_av_model' ,  $
               chisq=chisq, noderiv=1, itmax=100,  tol=1.E-4,  status=status)

f_emb_av_model, xwl, par, y
pars[fi]=par^(1+positive[fi])

pars1=pars

G_mod=y
plot, xwl,  data
oplot, xwl, y, thick=2


end



pro f_emb_model,  xwl, par,  y
common emb_fea_com,  av_Iout, Iin, positive, pars, fi

wl=xwl[0:n_elements(av_Iout)-1]
pars[fi]=par^(1+positive[fi])

tau0 =      pars[0]     &  lam_c =       pars[1]  &      dlam = pars[2]    &      src = pars[3]
av_tau0 = pars[4]    &  av_lam_c =  pars[5]  & av_dlam= pars[6]     &  av_src = pars[7]
del_src=pars[8]

av_u =(wl-av_lam_c)/av_dlam
phi_lam_av = exp(-av_u^2)
av_tau = av_tau0*phi_lam_av
u=(wl-lam_c)/dlam

phi_lam=exp(-u^2)
tau = tau0*phi_lam
c_lam_out = (av_src/av_Iout-1.)*(1-exp(-(tau-av_tau)))+ (1-exp(-tau))*(src-av_src)/av_Iout

tau1=0.01
tmp=(1-(tau+1)*exp(-tau))/(tau>tau1)
ss=where(tau le tau1, count)
if count ge 1 then tmp[ss]= tau[ss]/2.
c_lam_out=c_lam_out+del_src*(tmp-(1-exp(-tau))/2.)/av_Iout

Iin= av_Iout*exp(av_tau)+av_src*(1.-exp(av_tau) )
y=[c_lam_out,   av_tau0, av_dlam, src-av_src,  1./dlam, lam_c]

end

pro   emb_fea_model, wl,  I_out,  I_out_av,  I_mod,  pars1, I_in, $
  band=band, fixindex=fixindex,  fixvalue=fixvalue, parguess=parguess,   chisq=chisq,  sig_pars=sig_pars, $
     noisefactor=noisefactor, nofit=nofit, database=database, status=status
;+
;/  Inputs
;            wl           wavelengths
;              I_out        observed intensity profile at the point of interest
;              I_out_av   average of intensity profiles over  the ensemble
;             std_I_out   standard deviation of intensity profiles in the ensemble
;
;  Outputs
;             I_in         profile of incident intensity
;             I_mod    model of the observed profile
;             par      parameters of the feature
;            par_av   parameters of the average slab
;-
common emb_fea_com, av_Iout, Iin, positive, pars, fi
common emb_com,  noise, etau0, elam, esrc
nrep=500
 if  band eq '6562' then etau0=1.0 else etau0=0.75
 if  band eq '6562' then elam=4*5.4/3.e5*6563.  else elam=6*3./3.e5*8542.
 if  band eq '6562'  then esrc=6*0.03 else esrc=4*0.06
 if band eq '6562' then noise=0.0072 else noise=0.01
 if band eq '6562' then edlam=pars1[6]*0.5 else edlam=pars1[6]
  if band eq '6562' then eavdlam=0.05*2*0.2 else eavdlam=0.05*3.

av_Iout=I_out_av
ndata=n_elements(I_out)
contrast=I_out/I_out_av-1.
data = [contrast,   0., pars1[6],  0,  0,0] & M=1
xwl=[wl,wl]

weight=[contrast*0.+1./noise^2,  ndata/[etau0, eavdlam, esrc,   1./edlam, elam]^2]
if  keyword_set(parguess) then pars=pars1[0:8] else pars=fltarr(9)
npar=n_elements(pars)

fita=replicate(1, npar)
if n_elements(fixindex) ne 0 then begin
fita[fixindex]=0
pars[fixindex]=fixvalue
endif
fi=where(fita ne 0, nfit)

positive=replicate(0, npar)
positive[[0,2, 3,4, 6,7,8]] =1

if keyword_set(parguess) then begin

 f_emb_model, xwl, pars[fi]^(1./(1+positive[fi])), y
h0=total([(y-contrast)^2,  pars[4]^2]*weight)/ndata
pars0=pars
endif else begin
h0=1.e8
pars0=pars
rep=0
dw=reform(float(band)/3.e5*15.)
range=[[0.5,  2.0],[-dw,dw], [0.25, 0.4], [0.1, 0.3], [0.1, 1.5]]


while  (rep lt nrep)  and h0 ge 10. do begin
 w=randomu(seed, 5)
 pars[0:4]= w*range[0,*]+(1-w)*range[1,*]
if nfit lt npar then  pars[fixindex]=fixvalue
 par=pars[fi]^(1./(1+positive[fi]))
 f_emb_model, xwl, par, y

h=total([(y-contrast)^2,  pars[4]^2]*weight)/ndata

if h lt h0 then begin
h0=h
pars0=pars
endif
rep=rep+1
endwhile
endelse

pars=pars0


 par=pars[fi]^(1./(1+positive[fi]))



 if not keyword_set(nofit) then y=curvefit(xwl,  data, weight,  par, sig_pars, $
                function_name='f_emb_model' , noderiv=1,  status=status, itmax=100)  $
                else f_emb_model, xwl, par, y

pars[fi]=par^(1+positive[fi])

I_mod = I_out_av*(1+y[0:ndata-1])
del=(y[0:ndata-1]-data[0:ndata-1])^2*weight[0:ndata-1]
chisq=mean(del)
I_in=Iin
pars1= [pars, chisq]
end

