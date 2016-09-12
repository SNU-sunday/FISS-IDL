pro fiss_data_align, files, kref, alignfile, wvref=wvref, quiet=quiet
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
if keyword_set(quiet) then quiet=1 else quiet=0
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
if not quiet then begin
tv, bytscl(img2/median(img2), 0.5, 1.2)
print, 'k2=', k2
endif
k1=k2
im1=im2
k2=k1+direction
endif else begin
check[k2]=0
k2=k2+direction
endelse
endwhile
endfor
save, file=alignfile+'_align.sav', files, kref,  xc, yc, dx, dy, theta
end