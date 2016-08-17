function fiss_wvoffset, file, ref, ifrac, wr=wr


wv=fiss_wv(file)
nw=n_elements(wv)
if n_elements(wr) ne 2  then wr=[min(wv, max=m), m]
s=where((wv-wr[0])*(wv-wr[1]) le 0.)

h=headfits(file)
;if fxpar(h, 'NAXIS1') le 50 then h=fxpar(h, 'COMMENT')
nx=fxpar(h,'NAXIS3')

wvoffset=fltarr(nx)
ifrac=fltarr(nx)
ref1=ref[s]
for x=0, nx-1 do begin
sp=(fiss_read_frame(file, x))[s,*]
sp=sp/(replicate(1, nw)#(total(sp, 1)/nw))
wvoffset[x]=get_lag(ref1, sp, c)*(wv[1]-wv[0])
ifrac[x]=median(sp)/median(ref1)
endfor

return, wvoffset

end