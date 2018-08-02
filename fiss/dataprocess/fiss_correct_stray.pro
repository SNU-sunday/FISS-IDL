function fiss_correct_stray, wv,  sp, scf
sp1=sp
nz=n_elements(sp[0,*])
con=0.
for z=0, nz-1 do begin
con=interpol(sp[*,z],wv, 4.5)
con=con/0.85
sp1[*,z]=(sp[*,z]-con*scf)/(1-scf)
endfor
return, sp1
end
