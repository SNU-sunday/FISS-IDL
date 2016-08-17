function fiss_wv_par, detector, wv0, order, alpha, br
;+
;    Calling sequence
;         wvpar= fiss_wv_par(detector, wv0, order, alpha, br)
;
;    Inputs:
;         detector   'A' or 'B'
;         wv0        wavelength at detector center
;    Outputs:
;         wvpar    : three-element array of wavelength calibration
;                     0th: pixel value of the center of the reference line
;                     1st: dispersion (angstrom per pixel)
;                     2nd: the wavelength of the reference line in angstrom
;     Optiona Outputs:
;          order
;           alpha        incident angle
;          br           brightness
;-

if detector eq 'A' then begin
get_echelle_grating, 79, 62., 0.93, wv0, order, alpha, br
nw=512
ny=256
endif
if detector eq 'B' then begin
get_echelle_grating, 79, 62., 1.92, wv0, order, alpha, br
nw=502
ny=250
endif
wr=fiss_sp_range(alpha, order,detector)
wvpar=[nw/2, (wr[1]-wr[0])/nw, wv0]
return, wvpar
end