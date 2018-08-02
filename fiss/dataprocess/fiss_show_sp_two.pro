pro fiss_show_sp_two, file1, file2, wv1, wv2,  hw1, hw2,  x=x, y=y, dy=dy,  pca=pca,  scale1=scale1, scale2=scale2
;+
;   Name: fiss_show_sp_two
;           interactively shows the profiles and spectrograms when a position is selected
;           on the raster images
;
;   Syntax:  fiss_show_sp_two, file1, file2, wv1, wv2,  hw1, hw2,
;
;   Arguments:
;      file1,f ile1    the names of data file
;      wv1, wv2     arrays of    wavelength of the raster images to be constructed
;      hw1, hw2         half width(s) of the band used for the raster image construction (optional)
;
;   Keywords:
;
;    scale1, scale2        factor(s) to be multiplied to the standard deviation of image values
;                   to construct byte-scaled images (default=4.)
;
;   Remarks:     Whenever left mouse button is pressed down, the spectrogram and profile
;                   are drawn.  When right button is pressed, the program finishes.
;
;
;   Required routines: fiss_raster, fiss_read_frame
;
;   History:
;         2011 January, adapted from fiss_show_sp (J. Chae)
;         2016  April (J. Chae)
;
;-
if n_elements(dy) eq 0 then dy=7
nwv1=n_elements(wv1)
if n_elements(scale1) eq 0 then scale1=3.
if n_elements(scale1) eq 1 then scale1=replicate(scale1, nwv1, 2)
if n_elements(scale1[*,0]) ne nwv1 then scale1=replicate(3., nwv1, 2)

nwv2=n_elements(wv2)
if n_elements(scale2) eq 0 then scale2=3.
if n_elements(scale2) eq 1 then scale2=replicate(scale2, nwv2, 2)
if n_elements(scale2[*,0]) ne nwv2 then scale2=replicate(3., nwv2, 2)

if nwv1 ge 1 then begin
if n_elements(hw1) eq 0 then hw1=0.04
image1= alog10(fiss_raster(file1, wv1, hw1, pca=pca))
nx1=n_elements(image1[*,0])
ny1=n_elements(image1[0,*])
raster_image1=bytarr(nx1*nwv1, ny1)
for w=0, nwv1-1 do begin
s=where(image1[*,*,w] gt 1.)
stdv =stdev((image1[*,*,w])[s], m)
raster_image1[w*nx1:(w+1)*nx1-1,*] =bytscl(image1[*,*,w], m-scale1[w,0]*stdv, m+scale1[w, 1]*stdv)
endfor

endif

if nwv2 ge 1 then begin
if n_elements(hw2) eq 0 then hw2=0.04
image2= alog10(fiss_raster(file2, wv2, hw2, pca=pca))
nx2=n_elements(image2[*,0])
ny2=n_elements(image2[0,*])
raster_image2=bytarr(nx2*nwv2, ny2)
for w=0, nwv2-1 do begin
s=where(image2[*,*,w] gt 1.)
stdv =stdev((image2[*,*,w])[s], m)
raster_image2[w*nx2:(w+1)*nx2-1,*] =bytscl(image2[*,*,w], m-scale2[w, 0]*stdv, m+scale2[w,1]*stdv)
endfor
endif

sp1_ref=0.
for x=0, nx1-1 do sp1_ref=sp1_ref+fiss_read_frame(file1,x)
sp1_ref=total(sp1_ref, 2)/ny1/ (total(image1[*,ny1/2,0] ge 0.5*median(image1[*,ny1/2,0])))
sp2_ref=0.
for x=0, nx2-1 do sp2_ref=sp2_ref+fiss_read_frame(file2,x)
sp2_ref=total(sp2_ref,2)/ny2/ (total(image2[*,ny2/2,0] ge 0.5*median(image2[*,ny2/2,0])))


window, w0, free=n_elements(w0) eq 0 , xs=nx1*(nwv2>nwv1), ys=ny1+ny2+40
w0=!d.window
loadct_ch, /ha
tv, raster_image1 , 0,  ny2+20
for w=0, nwv1-1 do xyouts, (w+0.5)*nx1, ny1+2+ny2+20, /dev, string(wv1[w], format='(f5.2)'), align=0.5
loadct_ch, /ca
tv, raster_image2 , 0,  0
for w=0, nwv1-1 do xyouts, (w+0.5)*nx1, ny2+2, /dev, string(wv2[w], format='(f5.2)'), align=0.5

print, 'Left mouse button to select the point, right button to finish!'
cursor, x11, y11, /dev, /up

while (!mouse.button ne 4)  do begin
x1=x11 mod nx1
x2=x1
y2=-1
if y11 lt ny2 then  begin
y2=y11
y1=y2+dy
endif else if y11 ge ny2+20 and y11 lt ny2+20+ny1 then begin
  y1=y11-(ny2+20)
y2=y1-dy
endif
if y2 ge 0 then begin
loadct_ch, /ha & tv, raster_image1 , 0,  ny2+20
loadct_ch, /ca & tv, raster_image2 , 0,  0
for w=0, nwv1-1 do plots, /dev, x1+nx1*w, y1+ny2+20, psym=1
for w=0, nwv2-1 do plots, /dev, x1+nx1*w, y2, psym=1

sp1=fiss_read_frame(file1, x1, h1, pca=pca)
nw1=n_elements(sp1[*,0])
ny1=n_elements(sp1[0,*])
wvl1=(findgen(n_elements(sp1[*,0]))-fxpar(h1,'CRPIX1'))*fxpar(h1,'CDELT1')

sp2=fiss_read_frame(file2, x2, h2, pca=pca)
nw2=n_elements(sp2[*,0])
ny2=n_elements(sp2[0,*])
wvl2=(findgen(n_elements(sp2[*,0]))-fxpar(h2,'CRPIX1'))*fxpar(h2,'CDELT1')
if n_elements(w1) eq 0 then begin
window, w1, free=1, xs=nw1+nw2+150, ys=(ny1>ny2)*2+100
  w1=!d.window
  endif else wset, w1
  erase
  loadct, 0, /sil
plot, wvl1, sp1_ref, pos=[50, ny1+50, 50+nw1-1, 2*ny1-1+50], /dev, linest=1,  $
  xst=1, title='(x,y)=('+strtrim(string(x1),2)+','+strtrim(string(y1),2)+')', thick=2
oplot, wvl1,sp1[*, y1], linest=0, thick=2
sp11=bytscl(sp1)
loadct_ch, /ha
if fxpar(h1, 'CDELT1') lt 0 then tv,  rotate(sp11,5), 50,0 else tv, sp11, 50,0
plots, [0, n_elements(sp1[*,0])]*0.2+50, y1*[1,1], /dev, color=0, linest=3

;if n_elements(w2) eq 0 then begin
;window, w2, free=1, xs=nw2+100, ys=ny2*2+100
;  w2=!d.window
;  endif else wset, w2
;  erase
  loadct, 0, /sil
plot, wvl2, sp2_ref,  pos=[50+nw1+50, ny1+50, 50+nw2-1+nw1+50, 2*ny1-1+50], /dev, linest=1, $
  xst=1, title='(x,y)=('+strtrim(string(x2),2)+','+strtrim(string(y2),2)+')', /noerase, thick=2
oplot, wvl2, sp2[*, y2],linest=0, thick=2
sp21=bytscl(sp2)
loadct_ch, /ca
if fxpar(h2, 'CDELT1') lt 0 then tv,  rotate(sp21,5), 50+nw1+50,dy else tv, sp21, 50+nw1+50,dy
plots, [0, n_elements(sp2[*,0])]*0.2+50+50+nw1, y2*[1,1]+dy, /dev, color=0, linest=3

wset, w0
endif
cursor, x11, y11, /dev, /up
endwhile
wdelete, w0
if n_elements(w1) eq 1 then wdelete, w1
if n_elements(w2) eq 1 then wdelete, w2


end