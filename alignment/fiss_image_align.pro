function fiss_image_align,  alignfile,  wvref, xmargin1, ymargin1, ka=ka, quiet=quiet
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
if keyword_set(quiet) then quiet=1 else quiet=0
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
if not quiet then tv, bytscl(alog10(img[*,*,kk,w]/median(img[*,*,kk,w])), mr[0], mr[1]), w
endfor
if not quiet then print, 'k=', k
wait, 0.1

endfor

return,img
end
