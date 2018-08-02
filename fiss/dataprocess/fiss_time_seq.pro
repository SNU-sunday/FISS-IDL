function fiss_time_seq, f, x, y
;+

;-

nk=n_elements(f)
a=fiss_read_frame(f[0])
nw=n_elements(a[*,0])
result=fltarr(nw, nk)
for k=0, nk-1 do result[*,k]=fiss_read_profile(f[k],x,y)
return, result
end