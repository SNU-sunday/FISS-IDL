function fiss_data_profiles, align, x, y, s1, s2
f=align.files[align.sel]

if n_elements(s1) eq 0  then s1=0
if n_elements(s2) eq 0 then s2=n_elements(f)-1

for s=s1, s2 do begin
fiss_get_pos,x,y,align.xc, align.yc,align.theta[s],align.dx[s],align.dy[s],xx, yy
profile=fiss_read_profile(f[s], round(xx), round(yy))
if s eq s1 then profiles=fltarr(n_elements(profile), s2-s1+1)
profiles[*,s-s1]=profile
endfor

return, profiles
end