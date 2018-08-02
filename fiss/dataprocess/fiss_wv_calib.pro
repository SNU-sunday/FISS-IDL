function fiss_wv_calib, wvband, profile, wvpar, method=method
;+
;  Name: FISS_WV_CALIB
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
;
;-

if n_elements(method) eq 0 then method=1
case strmid(wvband, 0, 4) of
'6562': begin
          dldw = 0.019  ; A/pix
          lambda0=6562.817d0  ; Moore et al. 1972, NSRDS-NBS40
          case method of
          0: begin
          lines=['H I', 'Ti II']
          lambda_line=[6562.817d0, 6559.580d0]
          end
          1: begin
          lines=[ 'H2O', 'H2O']
          lambda_line=[6561.097d0, 6564.206d0]
      end
     endcase
          lamc=lambda_line[0]
          end
'8542': begin
           dldw=-0.026 ; A/pixe
             lambda0 =8542.089d0  ; Moore et al. 1972, NSRDS-NBS40

           case method of
          0: begin
           lines=['Ca II', 'Kr I']
           lambda_line=[8542.089d0, 8537.93d0]
           end
           1:begin
            lines=['H2O', 'H2O']
            lambda_line=[8540.817d0, 8546.222d0]
           end
          endcase
           lamc=lambda_line[0]
          ; dlambda_line=lambda_line-lamc
            end
endcase

nw=n_elements(profile)
w=findgen(nw)
s=where(profile[20:nw-20] eq min(profile[20:nw-20]))+20
wc=s[0]
lambda=(w-wc)*dldw+lambda0
wl=lambda_line*0.
for line=0, 1 do begin
mask = abs(lambda -lambda_line[line]) le 0.3
wtmp=w[where(mask)]
ptmp=convol(profile[where(mask)], [-1,2,-1])
s=(where(ptmp eq min(ptmp)))[0]
wtmp=wtmp[s-3:s+3]
ptmp=ptmp[s-3:s+3]
c=poly_fit(wtmp-median(wtmp), ptmp, 2)
wl[line]=median(wtmp)-c[1]/(2*c[2])
endfor
dldw=(lambda_line[1]-lambda_line[0])/(wl[1]-wl[0])
wc=wl[0]
wc1=wc-(lamc-lambda0)/dldw
wvpar=[wc1, dldw]
result=(findgen(nw)-wvpar[0])*wvpar[1]
return, result
end