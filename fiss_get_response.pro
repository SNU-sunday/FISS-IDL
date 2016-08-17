function  fiss_get_response, sp, wv,  caii=caii
if not keyword_set(caii) then begin
halpha_flux, wl0, sp0
ws=[-4.95, -4.45, -3.9, -3.5, -2.7, 2.3, 3.0, 3.4, 4., 4.5]
endif else begin
caii8542_flux, wl0, sp0
ws=[-5., -4.8, -4.6, -3.7,-3.0, -2.5, 2.4, 3.0, 3.5, 4.5, 5.0, 6.3 ]
endelse
response=sp*0
tmp=interpol(sp0, wl0, ws)
nz=n_elements(sp[0,*])
for z=0,nz -1 do begin
z1=(z-1)>0
z2=(z+1)<(nz-1)
ratio= tmp/interpol(total(sp[*, z1:z2],2)/(z2-z1+1), wv, ws)
coeff=poly_fit(ws, ratio, 2)
response[*,z]=poly(wv, coeff)
endfor
return, response
end
