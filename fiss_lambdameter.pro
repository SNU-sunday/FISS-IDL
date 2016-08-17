function fiss_lambdameter, file, wr, hw, x1, x2, y1, y2, pca=pca, pixel=pixel
;+
;   Name: fiss_raster
;            Construct  maps of wavelength offset and intensity of a spectral line
;            either from FITS file or PCA files
;
;
;   Syntax: Result=fiss_lambdameter(   )
;
;   Returned Values: A set of raster images constructed at the specified wavelength(s)
;
;   Arguments:
;             file   name of FISS file to be read
;			  wr	the set of wavelength range to be used
;                   2xNh element array
;			  hw    half-width(s) for the lambdameter  ; in uint of angstrom
;
;   Keywords:
;           pca     if set, coefficients of principal components are used for
; 					image construction (default is set).
;
;   Remarks: By default, wavelengths and half widths are in unit of angstrom, and wavelengths
;            are measured from the center of the reference line.;
;
;   Required routines: fiss_read_frame
;
;   History:
;         2015 June,  J. Chae, first coded.
;-
on_error, 1
if n_elements(pca) eq 0 then pca=1
null=fiss_read_frame(file, 0, h)
nx=fxpar(h, 'NAXIS3')
ny=fxpar(h, 'NAXIS2')
nw=fxpar(h, 'NAXIS1')

band=fxpar(h, 'WAVELEN')

if n_elements(x1) eq 0 then x1=0
if n_elements(x2) eq 0 then x2=nx-1
if n_elements(y1) eq 0 then y1=0
if n_elements(y2) eq 0 then y2=ny-1

wv=fiss_wv(file)
nhw=n_elements(hw)

if nhw eq 1 then images= fltarr(x2-x1+1, y2-y1+1, 2) $
  else images= fltarr(x2-x1+1, y2-y1+1, 2, nhw)


for x=x1, x2 do  begin
sp = fiss_read_frame(file, x, pca=pca)
for w=0, nhw-1 do begin
s=where((wv-wr[0,w])*(wv-wr[1,w]) le 0.)
images[x-x1,*,0,w]=bisector_d(wv[s], sp[s, y1:y2], hw[w], intensity)
images[x-x1,*,1,w]=intensity
endfor
endfor

return, images
end