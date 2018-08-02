
files=file_search('c:\work\fiss\ar\20140603\*A1_c.fts')
files=files[0:99]
kref=50
alignfile='test'
window, 2
if 0 then fiss_data_align, files, kref, alignfile, wvref=-3.


if 0 then imgs=fiss_image_align(  alignfile, [-3, -1, -0.5, 0, 0.5], xoff, yoff)

loadct, 3
m=median(imgs[*,*,0,0])
if 1 then for k=0, 99 do begin
 tv, bytscl(imgs[*,*,k, 0], 0.5*m, 1.1*m)
 plots, /dev, 80*[1,1], [0,200], color=255
plots, /dev, [0,200], 120*[1,1], color=255
 wait, 0.2
  endfor

stop
outfile='test'
k0=kref
xp=[75.,130 ]
yp=[112.,112]
ds=0.5

tv, bytscl(imgs[*,*,kref, 0]/median(imgs[*,*,kref,0]), 0.5, 1.1)
plots, /dev, xp+xoff, yp+yoff

stop
if 1 then fiss_data_on_points, alignfile, k0, xp, yp,ds, outfile

restore, outfile+'_sub.sav'


nk=n_elements(data[0,*,0])
ns=n_elements(data[0,0,*])
v=fltarr(nk, ns)
sh=where(abs(wv) le 1.)

for k=0, nk-1 do for j=0, ns-1 do v[k, j]=bisector_d(wv[sh], data[sh, k, j], 0.05)/6563.*3.e5

window, 2, xs=nk*6, ys=ns*3
loadct, 33, /sil
tv, bytscl(rebin(v, nk*6, ns*3), -3, 3)

end