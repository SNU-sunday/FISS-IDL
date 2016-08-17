function fiss_enhance, sp, mtf
s=size(sp)
data=fltarr(512, 512)
data[0:s[1]-1, 0:s[2]-1]=sp
if s[2] lt 512 then data[0:s[1]-1, s[2]:*]=sp[*, s[2]-1]#replicate(1., 512-s[2])
if s[1] lt 512 then data[s[1]:*, *]=replicate(1., 512-s[1])# data[s[1]-1,*]
mem96, data, new, otf=mtf, /quiet
return, new[0:s[1]-1, 0:s[2]-1]
end