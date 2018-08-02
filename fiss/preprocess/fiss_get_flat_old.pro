function fiss_get_flat, qsfile, darkfile, wr=wr, xpos=xpos
;
; wr : wavelength pixel range of a reference line
;
if n_elements(darkfile) eq 0 then dark = readfits(darkfile) else dark=0
a=assoreadfits(qsfile, h, unit=unit, nf=nf)
if n_elements(xpos) eq 0 then xpos=indgen(nf)
nf1=n_elements(xpos)
b=0.
for k=0, nf1-1 do b=b+a[xpos[k]]
b=b-float(dark)*nf1
b=b/median(b)
;writefits, flatfile, b

b1=convol(b, transpose([1., 1., 1.]/3.), /edge_truncate)
ny=n_elements(b1[0,*])
ref=b1[*, ny/2]

nw=n_elements(b1[*,0])
w=findgen(nw)
del=fltarr(ny)
if n_elements(wr) ne 2 then begin
;wr=[440, 460]
s=(where(ref[50:nw-1-50] eq min(ref[50:nw-1-50])))[0]+50
wr=s+[-20, 20]
end
w1=wr[0] & w2=wr[1]

for j=0, ny-1 do begin
;result=gaussfit(w[w1:w2]-(w1+w2)/2., reform(b1[w1:w2, j]), par, nterms=4)
weight = reform(-b1[w1:w2, j])+max(reform(b1[w1:w2, j]))
weight=weight*(weight ge max(weight)*0.3)
del[j]=total((w[w1:w2]-(w1+w2)/2.)*weight)/total(weight)
end
del=del-del[ny/2]
y=findgen(ny)
itot =total(b,1)
s=where(itot ge 0.8*median(itot))
coeff = poly_fit(y[s], del[s], 4)
del_m = poly(y,coeff)
plot, del
oplot, del_m, thick=2

;del_m=del

av=0.
for j=0, ny-1 do av=av+interpolate(reform(b1[*, j]), w+del_m[j], cubic=-0.5)
av=av/ny
ref_image=fltarr(n_elements(av), ny)
for j=0, ny-1 do ref_image[*,j]=interpolate(av, w-del_m[j], cubic=-0.5)

free_lun, unit
flat=b/ref_image

return, flat
end

