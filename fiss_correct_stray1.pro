function fiss_correct_stray1, wv,  sp, sp0,  zeta=zeta, epsilon=epsilon
;+
;-
if n_elements(zeta) eq 0  then zeta=0.065
if n_elements(epsilon) eq 0 then epsilon=0.027
S = 1.   ; near disk center
V =1.0
ocon0=interpol(sp0,wv, 4.5)/0.85
con0=ocon0
sp1=sp
sz=size(sp)  & nw=sz[1] & nz=sz[2]
ocon=fltarr(nz)
for z=0, nz-1 do begin
ocon[z]=interpol(sp[*,z],wv, 4.5)/0.85
endfor
con=(ocon/ocon0-epsilon*S)/(1-epsilon)*con0

con=replicate(1., nw)#con
ocon = replicate(1., nw)#ocon
sp1=(sp/ocon-zeta*V)/(1-zeta)*con

return, sp1
end
