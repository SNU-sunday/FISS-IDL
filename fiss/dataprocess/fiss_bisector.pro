function  fiss_bisector, wl, sp,   spb
ny=n_elements(spb)
y=spb
wlb=fltarr(ny)
nw=n_elements(sp)
for j=0, ny-1 do begin
sp1=sp-y[j]
tmp=sp1[0:nw-2]*sp1[1:nw-1]
s=where(tmp le 0., count)
if  count eq 2 then begin
i=s[0]
wl1=wl[i]-(wl[i+1]-wl[i])/(sp1[i+1]-sp1[i])*sp1[i]
i=s[1]
wl2=wl[i]-(wl[i+1]-wl[i])/(sp1[i+1]-sp1[i])*sp1[i]
wlc=0.5*(wl1+wl2)
wlb[j]=wlc
endif
endfor
return, wlb
end