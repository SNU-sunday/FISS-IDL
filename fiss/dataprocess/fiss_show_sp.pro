pro fiss_show_sp, datafile, wv, hw, pca=pca, image=image, srange=srange, irange=irange
;+
;   Name: fiss_show_sp
;           interactively shows the profile and spectrogram when a position is selected
;           on the raster image that may be internally constructed
;
;   Syntax:  fiss_show_sp, datafile [, wv, hw], /pca, image=image
;
;   Arguments:
;      datafile    the name of data file
;      wv          wavelength of the raster image to be constructed  (optional)
;      hw          half width of the band used for the raster image construction (optional)
;
;   Keywords:
;      pca          if set, data are read from the associated PCA-compressed file
;      image        set this keword to a named variable that will contain
;                   the byte-scaled raster image (either input or output).
;
;
;   Remarks:      1)  if arguments wv and hw are specified, keyword image is considered
;                   to be output.  if not, image is considered to be input.
;
;                 2) Whenever left mouse button is pressed down, the spectrogram and profile
;                   are drawn.  When right button is pressed, the program finishes.
;
;
;   Required routines: fiss_raster, fiss_read_frame
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-
if n_elements(pca) eq 0 then pca=1
;if n_elements(irange) ne 2 then irange=[0.7, 1.3]

if n_params() ge 2 then begin
if n_elements(hw) eq 0 then hw=0.04
image= fiss_raster(datafile, wv, hw, pca=pca)
endif
m=median(image)
image1=image ;/m ; median(abs(image-m))
if n_elements(irange) ne 2 then irange=[min(image1), max(image1)]

raster_image=bytscl(image1,   irange[0], irange[1])

window, w0, free=n_elements(w0) eq 0 , $
xs=n_elements(raster_image[*,0]), ys=n_elements(raster_image[0,*])
w0=!d.window
tv, raster_image
print, 'Left mouse button to select the point, right button to finish!'
cursor, x, y, /dev, /up
while (!mouse.button ne 4)  do begin

tv, raster_image
plots, /dev, x, y, psym=1


sp=fiss_read_frame(datafile, x, h, pca=pca)

nw=n_elements(sp[*,0])
ny=n_elements(sp[0,*])
wvl=(findgen(n_elements(sp[*,0]))-fxpar(h,'CRPIX1'))*fxpar(h,'CDELT1')

;if !mouse.button eq 1 then begin
if n_elements(w1) eq 0 then begin
window, w1, free=1, xs=nw+100, ys=ny*2+100
  w1=!d.window
  endif else wset, w1
  erase
plot, wvl, sp[*, y], pos=[50, ny+50, 50+nw-1, 2*ny-1+50], /dev, $
  xst=1, title='(x,y)=('+strtrim(string(x),2)+','+strtrim(string(y),2)+')'
oplot, wvl,total(sp,2)/n_elements(sp[0,*]), linest=1

if n_elements(srange) ne 2 then srange=[min(sp), max(sp)]/median(sp)
sp1=bytscl(sp) ; bytscl(sp/median(sp), srange[0], srange[1])
if fxpar(h, 'CDELT1') lt 0 then tv,  rotate(sp1,5), 50,0 else tv, sp1, 50,0
plots, [0, n_elements(sp[*,0])]+50, y*[1,1], /dev, color=0, linest=4

;endif


wset, w0

cursor, x, y, /dev, /up
endwhile
wdelete, w0
if n_elements(w1) eq 1 then wdelete, w1

end