function bisector_d, wl, sp,   hdlvalue, spvalue,   wvinput=wvinput
;+
;  Name: bisector_d
;  Purpose: determine bisector points from a spectrogram
;
;  Calling sequence:
;                      centers = bisector_d(wl, sp,  hwv,  spv, wvinput=wvinput)
;  Inputs
;              wl      1-d array of wavelengths measured from the reference of the line
;              sp       spectral profile (1-d array) or an array of spectral profiles (2-d array)
; Output
;            centers   an array of central wavelength of each horizonal line segment
;  Keyword   input
;             wvinput    if set to 1, then hwv is considered as an input, and spv, as an output (default)
;                               if set to 0,  then spv is considered as an input, and hwv, as an output
;  Case 1 ( wvinput=1)
;  Input
;           hwv        half width of the horizontal(equi-intensity) line segment (a scalar value)
;  Output
;            spv        an array of   intensities of the horiztla seqment
;  Case 2 (wvinput=0)
;  Input
;            spv        an intensity of the horiztla seqment  (a scalar value)
;  Output
;             hwv        an array of half widths of the horizontal(equi-intensity) line segment
; History
;             2018-07-28  updated by Chae
;-
;sp= spp; convol(spp, [1, 1., 1]/3., /edge_tr)
if n_elements(wvinput) eq 0 then wvinput=1
nw=n_elements(sp[*,0])
nz=n_elements(sp[0,*])
zpos=findgen(nz)
wlc=fltarr(nz)
if wvinput and hdlvalue eq 0. then begin

spvalue=fltarr(nz)
for z=0, nz-1 do  begin
  s=(where(sp[*,z] eq min(sp[*,z])))[0]
 wtmp=wl[s-5:s+5]
 sp1= sp[s-5:s+5, z]
 c=poly_fit(wtmp-median(wtmp), sp1, 2)
 wlc[z]=median(wtmp)-c[1]/(2*c[2])
 spvalue[z]= poly(wlc[z]-median(wtmp), c)
endfor
return, wlc
endif
if not wvinput then sp0=replicate(spvalue, nz) else begin
sp0=fltarr(nz)
for z=0, nz-1 do  begin
  s=where(sp[*,z] eq min(sp[*,z]))
  wlc[z]=wl[s[0]]
 endfor
  sp0=0.5*(interpolate(sp, ((wlc-1*hdlvalue)-wl[0])/(wl[1]-wl[0]),zpos,  cubic=-0.5) $
+ interpolate(sp, ((wlc+1*hdlvalue)-wl[0])/(wl[1]-wl[0]),zpos,  cubic=-0.5))

endelse

i1=intarr(nz)
i2=intarr(nz)
zz=indgen(nz)
rep=0
repeat begin
sp1=sp-replicate(1., nw)#sp0
tmp=sp1[0:nw-2,*]*sp1[1:nw-1,*]

for z=0, nz-1 do begin
s=where(tmp[*, z] le 0., count)
if count eq 2 then begin
i1[z]=s[0]
i2[z]=s[1]
endif else begin
j=count/2
i1[z]=s[(j-1)>0]
i2[z]=s[j]
endelse
endfor
wl1=wl[i1]-(wl[i1+1]-wl[i1])/(sp1[i1+1,zz]-sp1[i1,zz])*sp1[i1,zz]
wl2=wl[i2]-(wl[i2+1]-wl[i2])/(sp1[i2+1,zz]-sp1[i2,zz])*sp1[i2,zz]
wlc=0.5*(wl1+wl2)
hdl=abs(wl2-wl1)/2.

if wvinput then begin

sp0=0.5*(interpolate(sp, ((wlc-1*hdlvalue)-wl[0])/(wl[1]-wl[0]),zpos,  cubic=-0.5) $
+ interpolate(sp, ((wlc+1*hdlvalue)-wl[0])/(wl[1]-wl[0]),zpos,  cubic=-0.5))


del=hdl-hdlvalue
done= (max(abs(del)) le 0.0001) and (rep ge 3)
;print, 'rep=', rep, ' max del=', max(abs(del))
endif  else done =1
rep=rep+1
done =rep ge 5 or done
endrep until done
if nz eq 1 then begin
sp0=sp0[0]
wlc=wlc[0]
endif
if not wvinput  then hdlvalue=hdl else spvalue=sp0
return, wlc
end