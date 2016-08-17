pro  fiss_construct_reference, wv, files, wv1, wv2,  refdata, sigdata, i1, i2

nf=n_elements(files)
h=headfits(files[0])
h1=fxpar(h, 'COMMENT')
band=strmid(fxpar(h1, 'WAVELEN'), 0, 4)

if band eq '6562' then begin
wvs=[-0.6, 0, 0.6]
mes=[0.50, 0.16, 0.50]
devs =[ 0.15, 0.3, 0.15]
wv1=-2. & wv2=-1.

endif else begin
wvs=[0.]
mes=[0.17]
devs=[0.3]
wv1=1. & wv2=0.5
endelse
nwvs=n_elements(wvs)

Ntot=0L
for f=0, nf-1 do begin
wvv=fiss_wv(files[0])


if f eq 0 then begin
wv=wvv
nwv=n_elements(wv)
iw=round(interpol(findgen(nwv), wv, wvs))
i1=round( interpol(findgen(nwv), wv, wv1 ))
i2= round(interpol(findgen(nwv), wv, wv2))
endif

ii=interpol(findgen(nwv), wvv, wv)
jj=findgen(fxpar(h1, 'NAXIS2'))
file=files[f]
h=headfits(file)
nx=fxpar(h, 'NAXIS3')
  for x=0, nx-1, 2 do begin
  data1=interpolate(fiss_read_frame(file, x), ii, jj, /grid)

  yindex=indgen(n_elements(data1[0,*]))
  sel= (yindex mod 2) eq 1
     for kk=0, nwvs-1 do sel=sel and abs(data1[iw[kk],*]/mes[kk] -1.) le devs[kk]
  ss=where(sel, count)
  Ntot=Ntot+count
  if count ge 1 and Ntot le 100000L then  if n_elements(data) eq 0 then data=data1[*, ss] $
       else  data=  [[data], [data1[*, ss]]]
 endfor

endfor

sigma1=stdev(alog10(data[i1,*]), m1)
sigma2=stdev(alog10(data[i1,*]/data[i2,*]), m2)

refdata=fltarr(nwv, 25)
sigdata=fltarr(nwv, 25)

p=[-2.5, -1.5,  -0.5, 0.5,  1.5,  2.5]

for j1=0, 4 do for j2=0, 4 do begin
tmp1=(alog10(data[i1,*])-m1)/sigma1
tmp2=(alog10(data[i1,*]/data[i2,*])-m2)/sigma2
s=where(tmp1 ge p[j1] and tmp1 le p[j1+1] $
  and tmp2 ge p[j2] and tmp2 le p[j2+1], n)
if n ge 20 then begin
tmp=data[*, s[0]] & for kk=1L, n-1 do tmp=tmp+reform((data[*,s[kk]]))

refdata[*, j1*5+j2]=(tmp/n)
tmp=0.
for kk=0L, n-1 do begin
factor=(refdata[i1, j1*5+j2]/data[i1, s[kk]]+refdata[i2, j1*5+j2]/data[i2, s[kk]])/2.
tmp=tmp+(data[*,s[kk]]*factor-refdata[*,j1*5+j2])^2
endfor
sigdata[*,  j1*5+j2]= sqrt(tmp/n)/refdata[*, j1*5+j2]
endif
endfor
end
