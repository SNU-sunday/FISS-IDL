function fiss_raster, file, wv1, hw1, x1, x2, y1, y2, pca=pca, pixel=pixel
;+
;   Name: fiss_raster
;            Construct a set of raster images at different wavelengths
;            either from FITS file or PCA files
;
;
;   Syntax: Result=fiss_raster( file, wv, hw, /pca, /pixel)
;
;   Returned Values: A set of raster images constructed at the specified wavelength(s)
;
;   Arguments:
;             file   name of FISS file to be read
;			  wv	wavelength(s)
;			  hw    half-width(s) for wavelength integration  ; in uint of angstrom
;
;   Keywords:
;           pca     if set, coefficients of principal components are used for
; 					image construction (default is set).
;			pixel   if set, wavelengths and half-widths are in pixel units.
;                   Useful for data not calibrated for wavelength.
;
;   Remarks: By default, wavelengths and half widths are in unit of angstrom, and wavelengths
;            are measured from the center of the reference line.;
;            if pixel keyword is set, wavelengths are measured in unit of pixels and
;            are measured from the first pixel in the row.
;
;   Required routines: fiss_read_frame
;
;   History:
;         2010 July,  first coded  (J. Chae)
;         2013 May, added parameters x1, x2, y1, y2 (J. Chae)
;         2018 August,  wavelength in absolute scale
;-

if n_elements(pca) eq 0 then pca=1

nsel= n_elements(wv1)
if n_elements(hw1) ne nsel then hw1=replicate(hw1[0], nsel)
null=fiss_read_frame(file, 0, h)
nx=fxpar(h, 'NAXIS3')
ny=fxpar(h, 'NAXIS2')
nw=fxpar(h, 'NAXIS1')

band=fxpar(h, 'WAVELEN')

if n_elements(x1) eq 0 then x1=0
if n_elements(x2) eq 0 then x2=nx-1
if n_elements(y1) eq 0 then y1=0
if n_elements(y2) eq 0 then y2=ny-1

if  keyword_set(pixel) then begin
wv=wv1
hw=hw1
endif else begin

wc=fxpar(h, 'CRPIX1')
dldw=fxpar(h, 'CDELT1')
wl=fiss_wv(file) ; (findgen(nw)-wc)*dldw

w1=intarr(nsel)
w2=intarr(nsel)
for l=0, nsel-1 do begin
s=where(abs(wl-wv1[l]) le (hw1[l]>abs(dldw)/2.), count)
w1[l]=s[0]  &  w2[l]=s[count-1]
endfor
;
endelse


images= fltarr(x2-x1+1, y2-y1+1, nsel)

for x=x1, x2 do  begin
sp = fiss_read_frame(file, x, pca=pca)
for l=0, nsel-1 do images[x-x1,*,l]=total(sp[w1[l]:w2[l], y1:y2],1)/(w2[l]-w1[l]+1)
endfor

return, images
end