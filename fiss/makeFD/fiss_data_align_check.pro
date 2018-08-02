pro fiss_data_align_check, files, kref, align, alignfile=alignfile, wvref=wvref, $
 quiet=quiet, cor_crit=cor_crit, sel=sel
;+
; Purpose
;        Determine the values of
;				xc, yc, dx, dy, theta
;         required for the image mapping
; Calling sequence
;
;     fiss_data_align, files, kref,  align, alignfile=alinfile, wvref=wvref, quiet=quiet
;
;  Inputs
;      files     the file list
;      kref      the index of the reference file
;
;  Outputs
;        align    a structure variable  with tags
;                   files, kref, xc, yc, dt, dx, dy, theta
;
;  Keyword inputs
;
;     alignfile   if specified, the outputs are stored in this file
;
;     wvref       wavelength of the reference for image alignment (default=-3.0 angstrom)
;
;      quiet      if sepcified, no display of intermeidate results
;
;  History
;      2015 May   J. Chae
;-

if n_elements(wvref) eq 0 then wvref=-3.0
if keyword_set(quiet) then quiet=1 else quiet=0
if n_elements(cor_crit) eq 0  then cor_crit=0.97

Nf= n_elements(files)
Ns= n_elements(x)
f=files[kref]
h=fxpar(headfits(f), 'COMMENT') ;  assuming compressed file
Nw=fxpar(h, 'NAXIS1')
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')
wavelen=strmid(fxpar(h, 'WAVELEN'),0, 4)
tstring= strmid(files,  strpos(f, 'FISS_')+5, 15)
dtmins=fiss_dt(tstring[kref], tstring)*(24*60.)
thetas=dtmins*0.25*!dtor ;  radian


xc=float(Nx/2)
yc=float(Ny/2)

f1=f
dx1=0.
dy1=0.
sel=kref & dx=dx1  & dy=dy1  & theta=thetas[kref]  & dtmin=dtmins[kref] & cor=1.

;dx=fltarr(nf)
;dy=fltarr(nf)


nx1=(nx/2)>64<nx
ny1=(ny/2)
nx1=(nx1/2)*2
ny1=(ny1/2)*2

x1=xc-nx1/2
y1=yc-ny1/2

xa=(x1+findgen(nx1))#replicate(1., ny1)
ya=replicate(1., nx1)#(y1+findgen(ny1))

check=replicate(1B, nf)
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
k1=kstart    & c=1.0
k2=k1+direction
;f1=files(k1)
;f2=files(k2)
theta1=thetas[k1]
dx1=0.
dy1=0.
im1=fill_img(fiss_raster(files[k1], wvref, 0.1, x1, x1+nx1-1, y1, y1+ny1-1))
;if go then  while (k1-kstart)*(k1-kend) le 0 and  $
;(k2 ge 0 and k2 le nf-1) and (c ge cor_crit-0.05) do begin
if go then  while (k1-kstart)*(k1-kend) le 0 and  $
  (k2 ge 0 and k2 le nf-1) do begin
theta2=thetas[k2]
fiss_get_pos, xa, ya, xc, yc, theta1, 0., 0., xx1, yy1
fiss_get_pos, xa, ya, xc, yc, theta2, 0., 0., xx2, yy2
im2=fill_img(fiss_raster(files[k2], wvref, 0.1, x1, x1+nx1-1, y1, y1+ny1-1 ))
img1= interpolate(im1, xx1-x1,yy1-y1)
img2= interpolate(im2, xx2-x1, yy2-y1)
sh=alignoffset(img2,  img1, c)
fiss_get_pos, xa, ya, xc, yc, theta1, dx1, dy1, xx1, yy1
fiss_get_pos, xa, ya, xc, yc, theta2, dx1+sh[0],dy1+sh[1],  xx2, yy2
img1= interpolate(im1, xx1-x1,yy1-y1)
img2= interpolate(im2, xx2-x1, yy2-y1)
tv, bytscl(img1/median(img1), 0.5, 1.2), 0
tv, bytscl(img2/median(img2), 0.5, 1.2)*0, 1
tv, bytscl(img2/median(img2), 0.5, 1.2), 2


sh=alignoffset(img2,  img1, c)+sh
print, 'k1=', k1, ', k2=', k2, c
if c ge cor_crit then begin
dx2=dx1+sh[0]  & dy2=dy1+sh[1]
fiss_get_pos, xa, ya, xc, yc, theta2, dx2,dy2,  xx2, yy2
img2= interpolate(im2, xx2-x1, yy2-y1)
if not quiet then begin
tv, bytscl(img2/median(img2), 0.5, 1.2), 1
wait, 0.1
endif
k1=k2
dx1=dx2
dy1=dy2
theta1=theta2
im1=im2
sel=[sel, k1]
dx=[dx, dx1]
dy=[dy, dy1]
theta=[theta, theta1]
dtmin=[dtmin, dtmins[k1]]
cor=[cor, c]
k2=k1+direction
endif else begin
k2=k2+direction
endelse
endwhile
wait, 1
endfor

s=sort(sel)
sel=sel[s] & dx=dx[s] & dy=dy[s] & dtmin=dtmin[s] & theta=theta[s] & cor=cor[s]


align={files:files, kref:kref,  xc:xc, yc:yc, dt:dtmin, dx:dx, dy:dy, theta:theta, $
cor:cor, sel:sel}

;align={files:files, kref:kref,  xc:xc, yc:yc, dt:dtmin, dx:dx, dy:dy, theta:theta}
if n_elements(alignfile) eq 1 then save, file=alignfile+'_align.sav', align
end