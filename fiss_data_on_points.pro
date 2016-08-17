pro fiss_get_pos, x, y,  xc,yc, theta, dx, dy,  xx, yy, inv=inv
;+
; Calling sequence
;
;     fiss_get_pos, x, y,  xc,yc, theta, dx, dy,  xx, yy, inv=inv
;
; Inputs
;      x, y   the cooridnates of the position(s) at the reference time
;      xc, yc  the coordinates of the center of rotation
;      theta   the angle of the y-axis of the observed frame with respect to the reference frame
;               (+ means inclined to the right)
;      dx, dy   the relative displacement of the rotated images to the reference image
;
; Outputs
;      xx, yy   the coordinates of the positions in the observed frame
;
; Keyword
;      inv     if set
;                 xx, yy : inputs
;                 x, y : outputs
;-
if not keyword_set(inv) then begin
xx= (x-xc)*cos(theta) + (y-yc)*sin(theta)+xc+dx
yy=-(x-xc)*sin(theta)  + (y-yc)*cos(theta)+yc+dy
endif else begin
;pro fiss_get_pos_inv, xx, yy,  xc,yc, theta, dx, dy,  x, y
x= (xx-xc-dx)*cos(theta) - (yy-yc-dy)*sin(theta)+xc
y= (xx-xc-dx)*sin(theta)  + (yy-yc-dy)*cos(theta)+yc
endelse
end

pro fiss_data_align, files, kref, alignfile, wvref=wvref
;+
; Purpose
;        Determine the values of
;				xc, yc, dx, dy, theta
;         required for the image mapping
; Calling sequence
;
;     fiss_data_align, files, kref, outfile, wvref=wvref
;
;   Inputs
;      files     the file list
;      kref      the index of the reference file
;      alignfile   the name of the file where the outputs are stored
;
;-

if n_elements(wvref) eq 0 then wvref=-3.0
Nf= n_elements(files)
Ns= n_elements(x)
f=files[kref]
h=fxpar(headfits(f), 'COMMENT') ;  assuming compressed file
Nw=fxpar(h, 'NAXIS1')
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')
wavelen=strmid(fxpar(h, 'WAVELEN'),0, 4)
tstring= strmid(files,  strpos(f, 'FISS_')+5, 15)
dtmin=fiss_dt(tstring[kref], tstring)*(24*60.)
theta=dtmin*0.25*!dtor ;  radian


xc=Nx/2
yc=Ny/2


dx=fltarr(nf)
dy=fltarr(nf)


nx1=(nx/2)
ny1=(ny/2)
nx1=(nx1/2)*2
ny1=(ny1/2)*2

x1=xc-nx1/2
y1=yc-ny1/2

xa=(x1+findgen(nx1))#replicate(1., ny1)
ya=replicate(1., nx1)#(y1+findgen(ny1))

cor=fltarr(nf)
cor[kref]=1
check=replicate(1B, nf)
cor_crit=0.8
kstart=0
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
im1=fill_img(fiss_raster(files[k1], wvref, 0.05, x1, x1+nx1-1, y1, y1+ny1-1))
if go then  while (k1-kstart)*(k1-kend) le 0 and  (k2 ge 0 and k2 le nf-1) do begin
fiss_get_pos, xa, ya, xc, yc, theta[k1], 0., 0., xx1, yy1
fiss_get_pos, xa, ya, xc, yc, theta[k2], 0., 0., xx2, yy2
im2=fill_img(fiss_raster(files[k2], wvref, 0.05, x1, x1+nx1-1, y1, y1+ny1-1 ))
img1= interpolate(im1, xx1-x1,yy1-y1)
img2= interpolate(im2, xx2-x1, yy2-y1)
sh=alignoffset(img2,  img1, c)
fiss_get_pos, xa, ya, xc, yc, theta[k1], dx[k1], dy[k1], xx1, yy1
fiss_get_pos, xa, ya, xc, yc, theta[k2], dx[k1]+sh[0],dy[k1]+sh[1],  xx2, yy2
img1= interpolate(im1, xx1-x1,yy1-y1)
img2= interpolate(im2, xx2-x1, yy2-y1)
sh=alignoffset(img2,  img1, c)+sh
if c ge cor_crit then begin
dx[k2]=dx[k1]+sh[0]  & dy[k2]=dy[k1]+sh[1]
cor[k2]=c
fiss_get_pos, xa, ya, xc, yc, theta[k2], dx[k2],dy[k2],  xx2, yy2
img2= interpolate(im2, xx2-x1, yy2-y1)
tv, bytscl(img2/median(img2), 0.5, 1.2)
print, 'k2=', k2
k1=k2
im1=im2
k2=k1+direction
endif else begin
check[k2]=0
k2=k2+direction
endelse
endwhile
wait, 1
endfor
save, file=alignfile+'_align.sav', files, kref,  xc, yc, dx, dy, theta
end
function fiss_image_align,  alignfile,  wvref, ka=ka
;+
;  Purpose
;    Produce a time sequence of aligned images taken at different wavelengths
;
;  Calling sequence
;      images = fiss_image_align(  outfile,  wvref, ka=ka)
;
;   Inputs
;      alignfile
;-
restore, alignfile+'_align.sav'
if n_elements(wvref) eq 0 then wvref=0.0
Nwv=n_elements(wvref)
Nf= n_elements(files)
if n_elements(ka) eq 0 then ka=indgen(Nf)
files1=files[ka]
Ns= n_elements(x)
f=files1[0]
h=fxpar(headfits(f), 'COMMENT') ;  assuming compressed file
Nw=fxpar(h, 'NAXIS1')
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')

x=[0, nx-1, nx-1, 0]
y=[0,  0, ny-1, ny-1]
fiss_get_pos, x, y,  xc,yc, max(theta), 0, 0,  xx1, yy1
fiss_get_pos, x, y,  xc,yc, min(theta), 0, 0,  xx2, yy2

xmargin1=round(0-min([xx1, xx2])-min(dx))
xmargin2=round(max([xx1, xx2])-(nx-1)+max(dx))
nx1=nx+xmargin1+xmargin2
ymargin1=round(0-min([yy1, yy2])-min(dy))
ymargin2=round(max([yy1, yy2])-(ny-1)+max(dy))
ny1=ny+ymargin1+ymargin2

xa=(findgen(nx1)-xmargin1)#replicate(1., ny1)
ya=replicate(1., nx1)#(findgen(ny1)-ymargin1)
nf1=n_elements(files1)
img=fltarr(nx1, ny1, Nf1, Nwv)
for kk=0, nf1-1 do begin
k=ka[kk]
fiss_get_pos, xa, ya, xc, yc, theta[k], dx[k], dy[k], xx1, yy1
ims=fiss_raster(files[k], wvref, 0.05, 0, nx-1, 0, ny-1 )
for w=0, nwv-1 do begin
tmp=fill_img(ims[*,*,w])
img[*,*,kk,w]= interpolate(tmp, xx1,yy1, missing=0, cubic=-0.5)
if abs(wvref[w]) le 1.5 then mr=[-0.2,0.2] else mr=[-0.3, 0.05]
tv, bytscl(alog10(img[*,*,kk,w]/median(img[*,*,kk,w])), mr[0], mr[1]), w
endfor
print, 'k=', k
wait, 0.5

endfor


return, img
end


pro fiss_data_on_points, alignfile, k0, xp, yp, ds, outfile, ka=ka

;+
; Calling sequence
;
;  fiss_data_on_points,files, k0, x, y, outfile
;
;  Inputs
;
;     files    an Nf-element array of theoriginal data file names
;     alignfile   the name of file where the alignment data are stored
;     k0         the index of the observed frame ( 0 =< kref < Nf)      I
;     xpoints   an Np-element array of x-coordinates   of the curve on
;                 the observed frame
;     ypoints   an Np-element array of y-coordinates
;
;  Outputs
;     outfile  the name of the IDL save file where the following outputs are saved.
;          files, k0, xpoints, ypoints
;          wv      an Nw-element array of the wavelengths in A measured from the referece wavelegnth
;          ka    a Nf-element array of indice from the first file
;          Data     a Nw x Ns x Nf array of the spectral data
;
;-
restore, alignfile+'_align.sav'

get_curve_smooth, xp, yp, ds, xpoints, ypoints
Np=n_elements(xpoints)
fiss_get_pos, x, y,  xc,yc, theta[k0], dx[k0], dy[k0],  xpoints, ypoints, inv=1
Nf=n_elements(files)
if n_elements(ka) eq 0 then ka=indgen(Nf)
files1=files[ka]
nf1=n_elements(ka)
f=files1[0]
h=fxpar(headfits(f), 'COMMENT') ;  assuming compressed file
Nw=fxpar(h, 'NAXIS1')
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')
tstring= strmid(files[ka],  strpos(f, 'FISS_')+5, 15)
time=fiss_dt(tstring[kref], tstring)*(24*60.); in min


data=fltarr(Nw, nf1, Np)

for kk=0, nf1-1 do begin
k=ka[kk]
fiss_get_pos, x, y,  xc,yc, theta[k], dx[k], dy[k],  xx, yy
;img=fiss_raster(files[k], 0., 0.05)
;tv, bytscl(img/median(img), 0.7, 1.3), nx*kk, 0
;plots, xx+nx*kk, yy, /dev
;wait, 1
for p=0, Np-1 do begin
x1=xx[p]>0<(nx-2)  & y1=yy[p]>0<(ny-2)
wx=x1-fix(x1)
wy=y1-fix(y1)

data[*,kk, p]=(1-wx)*(1-wy)*fiss_read_profile(files[k], fix(x1), fix(y1)) $
           +wx*(1-wy)*fiss_read_profile(files[k], fix(x1)+1, fix(y1)) $
         + (1-wx)*wy*fiss_read_profile(files[k], fix(x1), fix(y1)+1) $
          +wx*wy*fiss_read_profile(files[k], fix(x1)+1, fix(y1)+1)
endfor
endfor

band=strmid(fxpar(h, 'wavelen'),0,4)
wv=fiss_wv_calib(band, total(fiss_sp_av(files[kref]), 2))

save, filename=outfile+'_sub.sav', files,  data, wv, ka, x, y, time

end

alignfile='test'
outfile='slice2'
k0=100
xp=[65.,120 ]
yp=[112.,145]
ds=0.5

;fiss_data_on_points, alignfile, k0, xp, yp,ds, outfile
restore, 'test_sub.sav'
nk=n_elements(data[0,*,0])+4
ns=n_elements(data[0,0,*])
v=fltarr(nk, ns)
sh=where(abs(wv) le 1.)

for k=0, nk-1-4 do for j=0, ns-1 do v[k+4*(k ge 100), j]=bisector_d(wv[sh], data[sh, k, j], 0.05)/6563.*3.e5

window, 2, xs=nk*6, ys=ns*3
loadct, 33, /sil
tv, bytscl(rebin(v, nk*6, ns*3), -3, 3)

end