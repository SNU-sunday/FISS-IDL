function fiss_get_tell, wv, sp, band=band
; wv : wavelength measured from the laboratory wavelegnth of the central line in reference to Earth

if band eq '8542' then begin
wvlines=[-1.27]
dwn2=[-0.5]
dwn=[-0.30]
dwp=[0.30]
dwp2=[0.50]

endif
if band eq '6562' then begin
wvlines=[1.3, -1.72, 0.701,-0.37 ]
dwn2=[-0.45,  -0.2, -0.2, -0.2 ]
dwn=[-0.25, -0.15, -0.15, -0.15]
dwp=[0.30,  0.15, 0.15, 0.15]
dwp2=[0.45,  0.2, 0.2, 0.2 ]

endif
absorp=sp*0.
nlines=n_elements(wvlines)

for  line=0, nlines-1 do begin

wv1=wv-wvlines[line]
s=where((wv1-(0.75*dwn[line]+0.25*dwn2[line]))*(wv1-(0.75*dwp[line]+0.25*dwp2[line])) le 0.)
ss=where((wv1-dwn[line])*(wv1-dwn2[line]) le 0. or (wv1-dwp[line])*(wv1-dwp2[line]) le 0.)
x=wv1[ss]
y=alog(sp[ss])
c=poly_fit(x,y, 3)
absorp[s]=alog(sp[s])-poly(wv1[s], c)
endfor
;if band eq '6562' then begin
;s=where(abs(wv-0.701) le 0.3)
;absorp[s]=interpol(absorp, wv,  wv[s]-0.701-1.72) *(4.5/5.)
;s=where(abs(wv+0.37) le 0.3)
;absorp[s]=interpol(absorp, wv,  wv[s]+0.37-1.72) *(2.5/5.)
;endif

return, exp(absorp)
end