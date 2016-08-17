function fiss_get_dx, sp, ref,  xr=xr

nx=n_elements(sp[*,0])
ny=n_elements(sp[0,*])
if n_elements(xr) ne 2 then xr=[0, nx-1]
x1=xr[0]
x2=xr[1]
dx = fltarr(ny)
ref0=ref[x1:x2]# replicate(1., 3)
for jj=0, ny-1 do begin
s=alignoffset(sp[x1:x2,jj]#replicate(1.,3), ref0)
dx[jj]=s[0]
endfor
return, dx
end
