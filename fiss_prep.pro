
pro fiss_prep, datafile, outfile, flatfile, darkfile, slit_pattern,  $
                tilt,  wvpar,  dw, slit_adjust=slit_adjust, atlas=atlas, detector=detector
;fiss_prep, datafiles[k], proc_files[k], flatfiles[k], darkfiles[k], slit_pattern,  tilt,  wvpar,  dw, slit_adjust=useref
;refsp,  $
; tilt=tilt, dw=dw, slit_pattern=slit_pattern, wvpar=wvpar, $
 ;  newref=newref, usepar=usepar, noproc=noproc

;+
;   Name: fiss_prep
;          processes data in a file and prepares a file containing processed data
;
;
;   Syntax: fiss_prep, datafile, outfile, flatfile, darkfile [,refsp], tilt=tilt, dw=dw, $
;           slit_pattern=slit_pattern, wvapr=wvpar, /newref, /usepar, /noproc
;
;
;   Arguments:
;         datafile   name of data file containing data to be processed
;         outfile    name of file into which data are to be written
;         flatfile   name of file containing flat pattern
;         darkfile   name of file contatining dark file
;         refsp       reference spectral profile (optional input or output)
;

;   Keyword inputs/outputs:
;         tilt     set to a named variable containing tilt value (input or output)
;         dw       set to a named variable containing values of horizonal deviation
;                  of a line (input or output)
;         slit_pattern    an image of slit pattern (input or output)
;         wvpar    wavelength parameters coming out of fiss_wv_calib (input or output)
;
;   Keyword controls:
;         newref      if set, reference spectral profiles are newly determined internally.
;         usepar     if set, keyword variables are used as inputs.
;         noproc     if set, variables are determined, but data are not processed.

;   Remarks:
;
;   Required routines: fiss_sp_av, fiss_slit_pattern, fiss_get_dw, fiss_wv_calib
;                 assoreadfits, assowritefits, piecewise_quadratic_fit
;   History:
;         2010 July,  first coded  (J. Chae)
;         2016 July,  Add wavelength calibration part (K. Cho)
;                     apply identical slit pattern (K. Cho)
;-
h=headfits(datafile) 
nd=fxpar(h,'NAXIS')
if nd eq 2 then nx=1
if nd eq 3 then  nx=fxpar(h, 'NAXIS3')
ny=fxpar(h,'NAXIS2') & nw=fxpar(h, 'NAXIS1')

dark=readfits(darkfile, /sil)
flat0=readfits(flatfile, /sil)
if keyword_set(slit_adjust) and (n_elements(slit_pattern) eq 0) then begin
  av= (fiss_sp_av(datafile)-dark)/flat0
  slit_pattern1=fiss_slit_pattern(av, old_pattern=slit_pattern)
endif else slit_pattern1=slit_pattern

flat=flat0*slit_pattern1

assowritefits, unit, file=outfile, header=h, /open
b=assoreadfits(datafile, unit=ui)
i=findgen(nw)#replicate(1, ny) & j=replicate(1, nw)#findgen(ny)

tot=0.
for x=0, nx-1 do begin

a=b[x]

; Dark subtraction and flat fielding
 a=(a-dark)/flat
;slit_pattern1=fiss_slit_pattern(a, old_pattern=slit_pattern)
;a=a/slit_pattern1
; Tilt correction
 a=rot(a, tilt, cubic=-0.5)

; Distortion correction
 a=interpolate(a, i+dw[j], j, cubic=-0.5)
tot=tot+a
assowritefits, unit, data=fix(round(a))
endfor
assowritefits, unit, header=h, /close
free_lun, ui

wvpar=fiss_wv_calib_atlas(tot, h)
fxaddpar, h, 'CRPIX1', wvpar[0], ' pixel position of reference line center'
fxaddpar, h, 'CDELT1', wvpar[1], 'angstrom per pixel'
fxaddpar, h, 'CRVAL1', wvpar[2], 'angstrom of reference line center'
fxaddpar, h, 'WAVELEN', string(wvpar[2], format='(f7.2)'), 'Wavelength at detector center'
fxaddpar, h, 'HISTROY', 'processed by FISS_PREP'
fxaddpar, h, 'HISTORY', 'dark+bias subtracted'
fxaddpar, h, 'HISTORY', 'flat-fieldded'
fxaddpar, h, 'HISTORY', string(tilt, format='(f5.2)')+' degree tilt corrected'
fxaddpar, h, 'HISTORY', 'displacement/distortion corrected'
modfits, outfile, 0, h


end