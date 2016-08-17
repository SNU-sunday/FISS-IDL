function fiss_wv_calib1, wvband, profile,  wvpar, dispersion=dldw
;+
;  Name: FISS_WV_CALIB1
;  Purpose:
;       Calibrate wavelengths with respect to H alpah line and Ca II 8542
;-
;+
;   Name: fiss_wv_calib
;          detemines a set of parameters for wavelength calibration
;
;   Syntax: result=fiss_wv_calib(wvband, profile, wvpar)
;
;   Arguments:
;           wvband    a string specifing wavelength band like '8542', '6562'  (input)
;           profile   the spectral profile to be used for the calibration (input)
;           wvpar     the array of parameters for wavelength calibration (output)
;                     0th: pixel value of the center of the reference line
;                     1st: dispersion (angstrom per pixel)
;                     2nd: the wavelength of the reference line in angstrom
;  Output
;           result   wavelength in Agstrom measured from the main line wavelength
;   Keywords:
;
;   Remarks:  The wavelength band is limited to one of '8542' and '6562'.
;
;
;   Required routines: None
;
;   History:
;         2010 July,  first coded  (J. Chae)
;         2011 January, implemented option: method (J. Chae)
;                                  changed to function
;         2013 May,  redefined wvpar[2]
;         2013 May,  created from fiss_wv_calib (J. Chae)
;-

case strmid(wvband, 0, 4) of
'6562': begin
        if n_elements(dldw) eq 0 then dldw=0.01908 ; A/pixe
            dlambda0 = 0.         ;      H alpha
           dlambda1=-3.253     ;   -3.253Ti II
                                              ; originally with reference to the Earth

          end
'8542': begin
           if n_elements(dldw) eq 0 then dldw=-0.02563 ; A/pixe
            dlambda0 = 0.         ;    Ca II 8542.089d0  ; Moore et al. 1972, NSRDS-NBS40
           dlambda1=-4.063     ;  Fe I 8538.0152
                                              ; originally with reference to the Earth
           end
      endcase

nw=n_elements(profile)
w=findgen(nw)
s=where(profile[20:nw-20] eq min(profile[20:nw-20]))+20
wc=s[0]
lambda=(w-wc)*dldw+dlambda0
mask = abs(lambda -dlambda1) le 0.3
wtmp=w[where(mask)]
ptmp=convol(profile[where(mask)], [-1,2,-1])
s=(where(ptmp eq min(ptmp)))[0]
wtmp=wtmp[s-2:s+2]
ptmp=ptmp[s-2:s+2]
c=poly_fit(wtmp-median(wtmp), ptmp, 2)

wl=median(wtmp)-c[1]/(2*c[2])
wc1=wl-(dlambda1-dlambda0)/dldw
wvpar=[wc1, dldw]
result=(findgen(nw)-wvpar[0])*wvpar[1]
return, result
end