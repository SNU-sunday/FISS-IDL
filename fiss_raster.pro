function fiss_raster, file, wv1, hw1, pca=pca, pixel=pixel
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
;
;-
on_error, 1
if n_elements(pca) eq 0 then pca=1
nsel= n_elements(wv1)
if n_elements(hw1) ne nsel then hw1=replicate(hw1[0], nsel)
null=fiss_read_frame(file, 0, h)
nx=fxpar(h, 'NAXIS3')
ny=fxpar(h, 'NAXIS2')
nw=fxpar(h, 'NAXIS1')

band=fxpar(h, 'WAVELEN')

if  keyword_set(pixel) then begin
wv=wv1
hw=hw1
endif else begin

wc=fxpar(h, 'CRPIX1')
dldw=fxpar(h, 'CDELT1')
wl=(findgen(nw)-wc)*dldw
wv=intarr(nsel)

for l=0, nsel-1 do begin
dwl=abs(wl-wv1[l])
wv[l]=(where(dwl eq min(dwl)))[0]
endfor
hw=round(abs(hw1/dldw))

endelse


images= fltarr(nx, ny, nsel)
for x=0, nx-1 do  begin
sp = fiss_read_frame(file, x, pca=pca)
for l=0, nsel-1 do images[x,*,l]=total(sp[wv[l]-hw[l]:wv[l]+hw[l], *],1)
endfor
return, images
end