pro fiss_wv_calib, wvband, profile, wvpar
;+
;  Name: FISS_WV_CALIB
;  Purpose:
;       Calibrate wavelengths with respect to H alpah line and Ca II 8542
;-
;+
;   Name: fiss_wv_calib
;          ddetemines a set of parameters for wavelength calibration
;
;   Syntax: fiss_wv_calib, wvband, profile, wvapr
;
;   Arguments:
;           wvband    a string specifing wavelength band like '8542', '6562'  (input)
;           profile   the spectral profile to be used for the calibration (input)
;           wvpar     the array of parameters for wavelength calibration (output)
;                     0th: pixel value of the center of the reference line
;                     1st: dispersion (angstrom per pixel)
;                     2nd: the wavelength of the reference line in angstrom
;   Keywords:
;
;   Remarks:  The wavelength band is limited to one of '8542' and '6562'.
;
;
;   Required routines: None
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-
case strmid(wvband, 0, 4) of
'6562': begin
          dldw = 0.019  ; A/pix
          lines=['H I', 'Ti II']
          lambda_line=[6562.817d0, 6559.580d0]
          lamc=lambda_line[0]
          dlambda_line=lambda_line-lamc
          end
'8542': begin
           dldw=-0.026 ; A/pixe
           lines=['Ca II', 'Kr I']
           lambda_line=[8542.09d0, 8537.93d0]
           lamc=lambda_line[0]
           dlambda_line=lambda_line-lamc
            end
endcase

nw=n_elements(profile)
w=findgen(nw)
s=where(profile[20:nw-20] eq min(profile[20:nw-20]))+20
wc=s[0]
dlambda=(w-wc)*dldw

wl=dlambda_line*0.


for line=0, 1 do begin
mask = abs(dlambda -dlambda_line[line]) le 0.5

wtmp=w[where(mask)]
ptmp=profile[where(mask)]

s=(where(ptmp eq min(ptmp)))[0]

wtmp=wtmp[s-3:s+3]
ptmp=ptmp[s-3:s+3]


c=poly_fit(wtmp-median(wtmp), ptmp, 2)
wl[line]=median(wtmp)-c[1]/(2*c[2])
;plot, wtmp, ptmp, linest=1, yst=1
;oplot, wtmp, poly(wtmp-median(wtmp), c), thick=2
;oplot, wl[line]+[0,0], [0, 1]*max(ptmp)
;stop
endfor
dldw=(dlambda_line[1]-dlambda_line[0])/(wl[1]-wl[0])
wc=wl[0]
;dlambda= (w-wl[0])*dldw+ dlambda_line[0]
wvpar= [wc, dldw, lamc]
end