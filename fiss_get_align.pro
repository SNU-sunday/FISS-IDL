function fill_img, img, small=small
imgn=img
if  n_elements(small) eq 0 then small=0.01
nx=n_elements(img[*,0])
a=fltarr(nx)  & for x=0, nx-1 do a[x]=stdev(img[x,*])
a=a/median(a)

sel=where(a le small, count)
img1=0. & img2=0.
for s=0, count-1 do begin
x=sel[s]

x1=x-1
found1=0
 if x1 ge 0 then  repeat begin
  if a[x1] gt small then begin
  img1=reform(img[x1,*])
  found1=1
endif     else x1=x1-1
 endrep until found1 or ( x1 eq  -1)

x2=x+1
found2=0
if x2 le nx-1 then repeat begin
 if a[x2] gt small then begin
 img2=reform(img[x2,*])
found2=1
 endif else x2=x2+1
 endrep until found2 or (x2 eq  nx)

if  not found1 and found2 then  img1=img2
if not found2 and found1 then  img2=img1

w=(x-x1)/float(x2-x1)
imgn[x,*]=(1.-w)*img1 + w*img2

endfor
return, imgn
end
pro fiss_get_pos, x, y,  xc,yc, theta, dx, dy,  xx, yy
xx= (x-xc)*cos(theta) + (y-yc)*sin(theta)+xc+dx
yy=-(x-xc)*sin(theta)  + (y-yc)*cos(theta)+yc+dy
end
pro fiss_get_pos_inv, xx, yy,  xc,yc, theta, dx, dy,  x, y
x= (xx-xc-dx)*cos(theta) - (yy-yc-dy)*sin(theta)+xc
y= (xx-xc-dx)*sin(theta)  + (yy-yc-dy)*cos(theta)+yc
end

pro fiss_get_img, ff,   wvref, imgs, tstring

nf=n_elements(ff)
h=fxpar(headfits(ff[0]), 'COMMENT') ;  assuming compressed file
nx=fxpar(h, 'NAXIS3')
ny=fxpar(h, 'NAXIS2')
imgs=fltarr(nx,ny,nf)
for k=0, nf-1 do begin
imgs[*,*,k]=fiss_raster(ff[k], wvref, 0.03)
endfor
tstring= strmid(ff,  strpos(ff[0], 'FISS_')+5, 15)
end

pro fiss_get_doppler, ff, hwv, dop, dop1, dop2

nf=n_elements(ff)
h=fxpar(headfits(ff[0]), 'COMMENT') ;  assuming compressed file
nx=fxpar(h, 'NAXIS3')
ny=fxpar(h, 'NAXIS2')
dop=fltarr(nx,ny,2, nf)
dop1=fltarr(nx, ny, 2, nf)
band=strmid(fxpar(h, 'wavelen'),0,4)
wv=fiss_wv_calib(band, total(fiss_sp_av(ff[nf/2]), 2))
if band eq '6562' then s=where(abs(wv) le 0.5, count)  else s=where(abs(wv) le 0.4, count)
if band eq '6562' then s1=where(abs(wv+3.23) le 0.2, count1) else s1=where(abs(wv+5.9) le 0.3, count1)
if band eq '6562' then s2=where(abs(wv-1.38) le 0.05, count2) else  s2=where(abs(wv-4.12) le 0.1, count2)
if band eq '6562' then hwv2=0.03 else hwv2=0.04
if  band eq '6562' then hwv1=0.05 else hwv1=0.1
dop2=fltarr(nx, nf)

for k=0, nf-1 do begin
wv1=fiss_wv_calib(band, total(fiss_sp_av(ff[k]), 2)/ny)
for x=0, nx-1 do begin
sp=fiss_read_frame(ff[k], x)
dop2[x, k]=bisector_d(wv1[s2],(total(sp, 2)/ny)[s2], hwv2, sp0)
dop[x,*, 0,k]=bisector_d(wv1[s],sp[s,*], hwv, sp0)
dop[x,*,1, k]=sp0
if count1 ge 10 then begin
dop1[x,*, 0,k]=bisector_d(wv1[s1],sp[s1,*], hwv1, sp1)
dop1[x,*,1, k]=sp1
endif
endfor
m=median(dop2[*,k])
for x=0, nx-1 do dop[x,*,0,k]=dop[x,*,0,k]-(dop2[x,k]-m)
for x=0, nx-1 do dop1[x,*,0,k]=dop1[x,*,0,k]-(dop2[x,k]-m)
endfor
end

pro fiss_get_img1, ff,   wvs, imgs, tstring

nf=n_elements(ff)
h=fxpar(headfits(ff[0]), 'COMMENT') ;  assuming compressed file
nx=fxpar(h, 'NAXIS3')
ny=fxpar(h, 'NAXIS2')
nwv=n_elements(wvs)
imgs=fltarr(nx,ny,nf, nwv)
for k=0, nf-1 do begin
imgs[*,*,k, *]=fiss_raster(ff[k], wvs, 0.05)
endfor
tstring= strmid(ff,  strpos(ff[0], 'FISS_')+5, 15)
end
pro fiss_get_align, img, tstring, kref,   theta,  dx, dy, check, cor, xc=xc, yc=yc, cor_crit=cor_crit
;    theta[kref]=dx[kref]=dy[kref]= 0

if n_elements(cor_crit) eq 0 then cor_crit=0.90
dtmin=fiss_dt(tstring[kref], tstring)*(24*60.)
theta=dtmin*0.25*!dtor ;  radian
nf=n_elements(img[0,0,*])
nx=n_elements(img[*,0,0])
ny=n_elements(img[0,*,0])

dx=fltarr(nf)
dy=fltarr(nf)
if n_elements(xc) eq 0 then xc=nx/2
if n_elements(yc) eq 0 then yc=ny/2

xa=findgen(nx)#replicate(1., ny)
ya=replicate(1., nx)#findgen(ny)

cor=fltarr(nf)
cor[kref]=1
check=replicate(1B, nf)
;for k=0, nf-1 do begin
;bad=img[1:nx-2, ny/2, k] lt 10
;if total(bad) ge 2 then check[k]=0 else begin
;s=where (img[*,*,k] ge median(img[*,*,k])*0.9)
;rms=stdev((img[*,*,k])[s], m)/m
;if rms lt rms_crit then check[k]=0
;endelse
;endfor
;
;ka=indgen(nf)
;sel=where(check or (ka eq kref), nsel)


for direction=-1,1, 2 do begin
if direction eq -1 then if kref gt 0 then begin
kstart=kref
kend=1;
go=1
endif else go=0
if direction eq 1 then if kref lt nf-1 then begin
go=1
kstart=kref
kend= nf-2
endif else go=0
k1=kstart
k2=k1+direction
if go then  while (k1-kstart)*(k1-kend) le 0 and  (k2 ge 0 and k2 le nf-1) do begin
fiss_get_pos, xa, ya, xc, yc, theta[k1], 0., 0., xx1, yy1
fiss_get_pos, xa, ya, xc, yc, theta[k2], 0., 0., xx2, yy2
img1= interpolate(img[*,*,k1], xx1,yy1)
img2= interpolate(img[*,*,k2], xx2, yy2)
sh=alignoffset(img2[10:nx-11, 10:ny-11],  img1[10:nx-11,10:ny-11], c)
fiss_get_pos, xa, ya, xc, yc, theta[k1], dx[k1], dy[k1], xx1, yy1
fiss_get_pos, xa, ya, xc, yc, theta[k2], dx[k1]+sh[0],dy[k1]+sh[1],  xx2, yy2
img1= interpolate(img[*,*,k1], xx1,yy1)
img2= interpolate(img[*,*,k2], xx2, yy2)
sh=alignoffset(img2[10:nx-11, 10:ny-11],  img1[10:nx-11,10:ny-11], c)+sh
;if k1 ge 75 and k1 le 95 then print, k1, k2, c
if c ge cor_crit then begin
dx[k2]=dx[k1]+sh[0]  & dy[k2]=dy[k1]+sh[1]
cor[k2]=c
k1=k2
k2=k1+direction
endif else begin
check[k2]=0
k2=k2+direction
endelse
;fiss_get_pos, xa, ya, xc, yc, theta[k1], dx[k1], dy[k1], xx1, yy1
;fiss_get_pos, xa, ya, xc, yc, theta[k2], dx[k2],dy[k2],  xx2, yy2
;img1= interpolate(img[*,*,k1], xx1,yy1)
;img2= interpolate(img[*,*,k2], xx2, yy2)

endwhile
endfor

end
pro fiss_img_gird, img,  x, y, xmar=xmar, ymar=ymar
nx=n_elements(img[*,0])
ny=n_elements(img[0,*])
if n_elements(xmar) eq 0 then xmar=0.10
xmargin=fix(xmar*nx) ; ny*sin(max(abs(theta-theta(kref))))
if n_elements(ymar) eq 0 then ymar=0.10
ymargin=fix(ymar*ny) ; nx*sin(max(abs(theta-theta(kref))))

nx1=nx+xmargin*2
ny1=ny+ymargin*2
x=(findgen(nx1)-xmargin)#replicate(1, ny1)
y=replicate(1, nx1)#(findgen(ny1)-ymargin)
end

function fiss_img_align, imgs, x, y,  xc, yc,  theta, dx, dy, missing=missing

if n_elements(missing) eq 0. then missing=0.
nf=n_elements(imgs[0,0,*])

nx1=n_elements(x[*,0])
ny1=n_elements(x[0,*])
result=fltarr(nx1, ny1, nf)
for k=0, nf-1 do begin
fiss_get_pos, x, y, xc, yc, theta[k], dx[k],dy[k],  xx, yy
result[*,*,k]=interpolate(fill_img(imgs[*,*,k]), xx, yy, missing=missing)
end
return, result
end
function fiss_get_tseq, ff,  k,   x, y, xc, yc,  theta, dx, dy, check, pos=pos

 nf=n_elements(ff)
h=fxpar(headfits(ff[0]), 'COMMENT') ;  assuming compressed file
nw=fxpar(h, 'NAXIS1')
nx=fxpar(h, 'NAXIS3')
ny=fxpar(h, 'NAXIS2')
wavelen=strmid(fxpar(h, 'WAVELEN'),0, 4)
if wavelen eq '6562' then del=0 else del=5
 fiss_get_pos_inv, x, y,  xc,yc, theta[k], dx[k], dy[k],  x0, y0

data=fltarr(nw, nf)
pos=fltarr(nf, 2)
for kk=0, nf-1 do if check[kk] then begin
fiss_get_pos, x0, y0,  xc,yc, theta[kk], dx[kk], dy[kk]+del,  xx, yy
;xx=round(xx) & yy=round(yy)
xx=xx>0<(nx-1)  & yy=yy>0<(ny-1)
pos[kk, *]=[xx, yy]
wx=xx-fix(xx)
wy=yy-fix(yy)

data[*,kk]=(1-wx)*(1-wy)*fiss_read_profile(ff[kk], fix(xx), fix(yy)) +wx*(1-wy)*fiss_read_profile(ff[kk], fix(xx)+1, fix(yy)) $
     + (1-wx)*wy*fiss_read_profile(ff[kk], fix(xx), fix(yy)+1) +wx*wy*fiss_read_profile(ff[kk], fix(xx)+1, fix(yy)+1)
endif
return, data
end
