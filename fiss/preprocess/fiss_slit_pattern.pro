function fiss_slit_pattern, image, tilt, tilt_only=tilt_only, old_pattern=old_pattern
;+
;   Name:   fiss_slit_pattern
;               obtains the pattern of slit on the image
;
;   Syntax: Result = fiss_slit_pattern(image [, tilt], /tilt_only,  old_pattern=old_pattern)
;
;   Return values: A two dimensional array showing the pattern orginating from
;                the non-uniformity of a slit width
;
;
;   Arguments:
;			image   spectrgram  used to infer the slit pattern (input)
;     tilt    tilt of spectrogram measured counter-clockwise (input or output)
;
;   Keyword control:
;          tilt_only   if set, only tilt is calculated and result contains null value.
;   Keyword input:
;          old_pattenr
;
;
;   Remarks:
;
;   Required routines:
;
;   History:
;         2010 July,  first coded  (J. Chae)
;         2013 July,   1. correlation analysis is done to 2nd derivative images that better show hroizontal lines
;                      2. if correlation value is smaller than 0.5, the tilt is set to zero (for safety).
;         2015 June    1. Changed the algoirthm of determining the titlt. Now using the spectral lines.
;         2016 June    1. fixed minor bug
;         2018 May     1. change tilt value as input or output (K. Cho)                           
;-
nx=n_elements(image[*,0])
ny=n_elements(image[0,*])

if keyword_set(old_pattern) then begin
ker=transpose([-1., 8., 1., -16., 1., 8., -1.]/24.)
s=alignoffset(convol(image, ker), convol(old_pattern, ker))
pattern = shift_sub(old_pattern, 0, s[1], cubic=-0.5)
return, pattern
endif



ic1=fltarr(ny) ;& ic2=fltarr(ny)
xc1=50
xc2=nx-1-50

if ~n_elements(tilt) then begin
  ;image1=convol(image, transpose([-1,2,-1]))
  ;for jj=0, ny-1 do begin
  ;tmp=image1[xc1-10:xc1+10,jj]
  ;ic1[jj]=mean(tmp)
  ;tmp=image1[xc2-10:xc2+10,jj]
  ;ic2[jj]=mean(tmp)
  ;endfor
  
  yc2=ny/2-40 & yc1=ny/2+40
  ic2=image[*,yc2] & ic1=image[*,yc1]
  
  s=alignoffset( ic2#replicate(1., 3), ic1#replicate(1., 3), cor)
  tilt=(atan(s[0]/(yc1-yc2))*!radeg)*(cor gt 0.5)
  print, 'tilt=', tilt
endif

if keyword_set(tilt_only) then return, 0
;print, 'cor=', cor, 'tilt=', tilt
image1= rot(image, tilt, cubic=-0.5)
ic1=fltarr(ny) & ic2=fltarr(ny)
for jj=0, ny-1 do ic1[jj]=mean(image1[xc1-10:xc2+10, jj])

i=findgen(nx)#replicate(1, ny)
j=replicate(1., nx)#findgen(ny)
pattern = interpolate(ic1, j-(i-nx/2.)*tan(tilt*!dtor), cubic=-0.5)
return, pattern
end