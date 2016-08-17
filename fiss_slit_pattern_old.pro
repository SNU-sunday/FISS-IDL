function fiss_slit_pattern_old, image, tilt, tilt_only=tilt_only, old_pattern=old_pattern
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
;           tilt    tilt of spectrogram measured counter-clockwise (output)
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
;
;-
nx=n_elements(image[*,0])
ny=n_elements(image[0,*])

if keyword_set(old_pattern) then begin
ker=transpose([-1., 8., 1., -16., 1., 8., -1.]/24.)
s=alignoffset(convol(image, ker), convol(old_pattern, ker))
pattern = shift_sub(old_pattern, 0, s[1], cubic=-0.5)
return, pattern
endif


;;modify xc1 and xc2: xc1=50-->30
ic1=fltarr(ny) & ic2=fltarr(ny)
xc1=20
xc2=nx-1-20
for jj=0, ny-1 do begin
tmp=image[xc1-10:xc1+10,jj]
ic1[jj]=mean(tmp)
tmp=image[xc2-10:xc2+10,jj]
ic2[jj]=mean(tmp)
endfor
s=alignoffset( ic2#replicate(1., 3), ic1#replicate(1., 3), cor)
tilt=0;atan(s[0]/(xc2-xc1))*!radeg


if keyword_set(tilt_only) then return, 0
;print, 'cor=', cor, 'tilt=', tilt
image1= rot(image, tilt, cubic=-0.5)
for jj=0, ny-1 do ic1[jj]=mean(image1[xc1-10:xc2+10, jj]) ;(mean(image1[xc1-10:xc1+10,jj])+mean(image1[xc2-10:xc2+10,jj]))/2.

i=findgen(nx)#replicate(1, ny)
j=replicate(1., nx)#findgen(ny)
pattern = interpolate(ic1, j-(i-nx/2.)*tan(tilt*!dtor), cubic=-0.5)
return, pattern
end