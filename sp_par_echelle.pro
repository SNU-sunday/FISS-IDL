openw, 2, 'sp_par_echelle.txt'
;




for line=0, 4 do begin

; Spectral Line Parameters

name=(['H alpha', 'He I', 'Ca II', 'Ca II K', 'HeNe'])[line]
order = (1*[34, 21, 26, 57, 36])[line]
wl= ([6562.8,10830., 8542., 3933., 6328])[line] ;A
camera=(['DV887-BI', 'SU640', 'DV885', 'DV887-BI', 'DV887-BI'])[line]
intensity=([2.90e6/3.e-12*0.15, 1.26e6/1.8e-12*0.90, 1.8e6/2.3e-12*0.075, 4.4e6/2.3e-12*0.05, 0.])[line]

; Telescope Parameters

telescope_fratio =26.
telescope_aperture=1600.  ; mm
telescope_flength = telescope_fratio*telescope_aperture ; mm
plate_scale = 206265./telescope_flength ; arc second /mm
transmission=0.01
; Slit Parameters

slit_width = 16.e-3; mm
slit_height = 15 ;  mm

; Grating Parameters

phi = 63.4; 62.
density = 79; 2*sin(phi[0]*!dtor)/(order[0]*wl[0])*1.e7

;print, 'density = ', density, '  phi=', phi[0]

; Spectrograph Parameters

fcam = 1500. ; mm
fcol  =1500. ; mm

;angle=blaze_incidence_angle(phi, density, 6562.8, 33)
alpha=62.28 ; +([0, 0,0])[line]

grating, density, wl, order, alpha, beta
print, 'alpha=', alpha, ' beta=', beta, 'alpha-beta = ', alpha-beta
ana_mag = cos(alpha*!dtor)/cos(beta*!dtor)
print, 'ana_mag=', ana_mag

; Detector Parameters
; Detector Parameters

exposure_time = 0.033 ;s
;if wl le 12000. then camera ='DV887-BI' else camera='RSC'
case camera of
   'pco.1600': begin
     quantum_efficiency = 0.1
     det_xsize = 7.4e-3  ; mm
     det_ysize = 7.4e-3 ; mm
     det_nx =1200
     det_ny = 1600
    end
    'DV887-BI': begin
     quantum_efficiency = ([0.92, 0.10, 0.55, 0.5, 0.9 ])[Line]
     det_xsize = 16.e-3  ; mm
     det_ysize = 16.e-3*2 ; mm
     det_nx =512
     det_ny =512/2
     end
     'DV885': begin
     quantum_efficiency = ([0.63, 0.05, 0.35, 0.25 ])[Line]
     det_xsize = 16.e-3  ; mm
     det_ysize = 16.e-3*2 ; mm
     det_nx =502
     det_ny =502/2
     end

     'SU640' :begin

     quantum_efficiency = ([0.3, 0.90, 0.55])[Line]
     det_xsize = 25.e-3  ; mm
     det_ysize = 25.e-3 ; mm
     det_nx =640
     det_ny =512
     end
     'NIR-600P' :begin

     quantum_efficiency = ([0.0, 0.72, 0.00])[Line]
     det_xsize = 25.e-3  ; mm
     det_ysize = 25.e-3 ; mm
     det_nx =640
     det_ny =512
     end
     'RSC' : begin
      quantum_efficiency = ([0.0, 0.65, 0.00])[Line]
     det_xsize = 18.e-3  ; mm
     det_ysize = 18.e-3 ; mm
     det_nx =1024
     det_ny =1024
      end

end

; Correctinf for the diffraction effect

;tmp=sqrt(( 2*atan(1./(2*telescope_fratio)) )^2+ $
;      (0.88* asin (wl*1.e-7/slit_width))^2 )
telescope_fratio_eff =telescope_fratio ; 1./(2*tan(0.5*tmp))

grating_width_perp=  fcol/telescope_fratio_eff; mm
grating_width_true = grating_width_perp/cos(alpha*!dtor)
slit_width_arcsec = slit_width*plate_scale
slit_height_arcsec = slit_height*plate_scale
detector_pixel_arcsec = det_ysize*plate_scale*fcam/fcol
;print, 'slit width = ', slit_width_arcsec, ' arc sec'
;print, 'slit height = ', slit_height_arcsec, ' arc sec'
;
print, 'grating_width_true = ', grating_width_true, ' mm'

;print, 'alpha = ', alpha, '  beta = ', beta
dispersion = cos(!dtor*beta)/density/order/fcam*1.e7  ; mA/micron
;print, 'dispersion = ', dispersion, ' mA/micron'

grating_resolution = wl*1.e3/(grating_width_true*density)/order  ; mA

;print, 'grating_resolution = ', grating_resolution, ' mA'
spectral_purity = cos(alpha*!dtor)*slit_width*1.e10/density/fcol/order ; mA
;print, 'spectral purity  = ', spectral_purity, ' mA'
detector_resolution = 2*dispersion*det_xsize*1.e3 ; mA
;print, 'detector resolution = ', detector_resolution, ' mA'


sp_resolution = sqrt(spectral_purity^2+(0.5*detector_resolution)^2+1.*grating_resolution^2)
;print, 'spectral resolution =', sp_resolution, ' mA'
;print, 'spectral resolution R = ', wl/sp_resolution*1000.

wl_coverage =dispersion*det_xsize*det_nx ; A
;print, 'Wavelength coverage = ', wl_coverage , ' A'


solid_angle= slit_width/telescope_flength*(det_xsize*fcol/fcam/telescope_flength)
area=!pi*(telescope_aperture*0.1)^2/4.
number_electron = intensity*transmission*quantum_efficiency*$
     exposure_time*solid_angle*area*detector_resolution/2.*1.e-3
if line eq 0 then begin
info='Input Parameters'
info = [info, strpad('telescope aperture', 20, /after)+string(telescope_aperture, format='(i15)') +' mm']
info = [info, strpad('focal ratio', 20, /after)+string(telescope_fratio, format='(i15)') +' ']
info = [info, strpad('focal length', 20, /after)+  string(fcol, format='(i15)') +' mm']
info = [info, strpad('slit width', 20, /after)+string(  slit_width*1.e3, format='(i15)') +' micron']
info = [info, strpad('slit height',  20, /after)+string( slit_height, format='(i15)') +' mm']
info = [info, strpad('groove density', 20, /after)+string( density, format='(i15)')+ ' /mm']
info = [info, strpad('blaze angle',  20, /after)+string( phi[0], format='(f15.1)')+' deg']
;info = [info, strpad('x pixel size', 20, /after)+string( det_xsize*1.e3, format='(i15)') +' micron']
;info = [info, strpad('number of x-pixels', 20, /after)+string(det_nx, format='(i15)') +' ']
;info = [info, strpad('y pixel size', 20, /after)+string( det_ysize*1.e3, format='(i15)') +' micron']
;info = [info, strpad('number of y-pixels', 20, /after)+string(det_ny, format='(i15)') +' ']
info = [info, strpad('quantum efficiency at H alpha', 20, /after)+string(quantum_efficiency*100, format='(i15)') +' %']
info = [info, strpad('incidence angle',  20, /after)+string( alpha, format='(f15.1)')+' deg']
info = [info, strpad('f-collimator', 20, /after)+string( fcol, format='(i15)') +' mm']
info = [info, strpad('f-camera', 20, /after)+string(fcam, format='(i15)') +' mm']

info =  [info, ' ', 'Common output parameters']
info=[info, strpad('Grating width', 20, /after)+string (grating_width_true, format='(i15)')+ ' mm']
info=[info, strpad('slit width', 20, /after)+ string( slit_width_arcsec, $
      format='(f15.2)')+ ' arc sec']
info=[info, strpad('slit height', 20, /after)+ $
    string( slit_height_arcsec, $
      format='(i15)')+ ' arc sec'  ]




endif
info =  [info,' ',  'Output parameters for line '+name+' line']
info = [info, strpad('wavelength',  20, /after)+string(wl, format='(i15.1)') +' A']
info = [info, strpad('reflection angle', 20, /after)+string(  beta, format='(f15.1)')+' deg']
info = [info, strpad('order',  20, /after)+string(order, format='(i15)')+'']
info=[info, strpad('dispersion', 20, /after)+string (dispersion, format='(f15.1)')+ ' mA/micron']

info=[info, strpad('grating resolution', 20, /after)+string (grating_resolution, format='(i15)')+ ' mA']
info=[info, strpad('spectral purity', 20, /after)+string (spectral_purity, format='(i15)')+ ' mA']
info=[info, strpad('pixel size', 20, /after)+string (detector_resolution/2., format='(i15)')+ ' mA']
info=[info, strpad('spectral coverage', 20, /after)+string (wl_coverage, format='(f15.1)')+ ' A']
info=[info, strpad( 'spectral resolution ', 20, /after)+string( sp_resolution, format='(i15)')+ ' mA']
info=[info, strpad( 'spectral resolution ', 20, /after)+string( round(wl/sp_resolution)*1000, format='(i15)')+ ' ']
 info=[info, strpad('Spatial pixel', 20, /after)+ $
    string( det_ysize*plate_scale*fcol/fcam, $
      format='(f5.2)')+ ' arc sec'  ]
      info=[info, strpad('FOV height', 20, /after)+ $
    string( det_ysize*det_ny*plate_scale*fcol/fcam, $
      format='(i15)')+ ' arc sec'  ]
info=[info, strpad( 'electron count ', 20, /after)+string(number_electron, format='(e10.1)')+ ' ']

endfor
for k=0, n_elements(info)-1 do printf, 2, info[k]

close, 2
xdisplayfile, text=info
end
