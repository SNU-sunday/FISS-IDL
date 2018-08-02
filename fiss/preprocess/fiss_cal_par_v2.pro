
pro fiss_cal_par_v2, calfile, flatfile,   darkfile, slit_pattern,  tilt,  dw
;+
;
;      ouputs:
;         slit_pattern    an image of slit pattern (input or output)
;         tilt     set to a named variable containing tilt value (input or output)
;         dw       set to a named variable containing values of horizonal deviation
;                  of a line (input or output)

;
;
;   Remarks:
;
;   Required routines: fiss_sp_av, fiss_get_dw
;                           piecewise_quadratic_fit
;   History:
;         2010 July,  first coded  (J. Chae)
;         2015 June,   Chae:  removed wavelength calibration part and slit pattern caculation part
;         2016 June, Cho
;             - slit_pattern : output -> input (to apply identical slit pattern)
;-
h=headfits(calfile) & nx=fxpar(h, 'NAXIS3') & ny=fxpar(h,'NAXIS2') & nw=fxpar(h, 'NAXIS1')
if darkfile eq '' then dark=0. else dark=readfits(darkfile, /sil)
av= (fiss_sp_av(calfile)-dark)/readfits(flatfile, /sil)
if n_elements(slit_pattern) eq 0 then begin
  slit_pattern=fiss_slit_pattern(av, tilt)
  slit_pattern1=slit_pattern/median(slit_pattern)
endif else slit_pattern1=slit_pattern
av=av/slit_pattern1
av1=rot(av, tilt, cubic=-0.5)
refsp=total(av1[*,ny/2-5:ny/2+5],2)
;fiss_wv_calib, strmid(fxpar(h, 'wavelen'),0,4), refsp, wvpar
dw1 = fiss_get_dw(av1, refsp)
y=findgen(ny)
ay=total(av1, 2)
piecewise_quadratic_fit, y, dw1, dw, npoint=30, sel=ay ge median(ay, 30)*0.5
end