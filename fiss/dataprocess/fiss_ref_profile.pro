function fiss_ref_profile, raster_images, datafile, x, y, mask,  small=small, pca=pca, npoint=npoint

if n_elements(small) eq 0  then small=0.001
nx=n_elements(raster_images[*,0,0])
ny=n_elements(raster_images[0,*,0])
ns=n_elements(raster_images[0,0,*])

if n_elements(mask) ne nx*ny then mask=replicate(1B, nx, ny)

condition=mask

for l=0,ns-1 do $
condition=condition and abs(raster_images[*,*,l]/raster_images[x,y,l]-1.) le small

s=where(condition, count)
if count lt 1 then begin
print, 'no data points for reference'
return, -1
endif
xa=s mod nx & ya=s /nx
prof=0.
npoint=0
for ii=0, nx-1 do begin
ss=where(xa eq ii, count)
if count ge 1 then begin
sp=fiss_read_frame(datafile, ii, pca=pca)
for jj=0, count-1 do prof=prof+sp[*,ya[ss[jj]]]
npoint=npoint+count
endif
endfor
prof=prof/npoint
return, prof



end