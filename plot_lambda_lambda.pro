pro plot_lambda_lambda, w_ha, w_ca
COMMON COLORS, R_orig, G_orig, B_orig, R_curr, G_curr, B_curr
r_orig=r_curr &  g_orig=g_curr &  b_orig=b_curr
@color
plot, [0.1, 0.7], [0, 0.6], xst=1, yst=1, /nodata, xtitle='Width(H alpha)/A', ytitle='Width(Ca II)/A'

for k=0, 26 do begin
Te = 4000.+1000.*k
xi = (findgen(201)*0.1*1.e5+0.)

dld_ha = sqrt(xi^2+2 *(1.38e-16/1.67e-24)*Te)/3.e10*6563.
dld_ca = sqrt(xi^2+2*(1.38e-16/1.67e-24/40.)*Te)/3.e10*8542.
oplot, dld_ha, dld_ca, color=green, thick=1+(k mod 2)
if k mod 2 eq 0 then xyouts, dld_ha[0]-0.01, dld_ca[0],  ' '+strtrim(string(Te/1000,format='(i5)'),2)+'k K', orien=-60, size=0.7

endfor

for k=0, 20 do begin
Te = 4000.+findgen(101)/100*(30000.-4000.)
xi = 0.+k*1.e5

dld_ha = sqrt(xi^2+2 *(1.38e-16/1.67e-24)*Te)/3.e10*6563.
dld_ca = sqrt(xi^2+2*(1.38e-16/1.67e-24/40.)*Te)/3.e10*8542.
;if k eq 1 then print, dld_ca[0]
oplot, dld_ha, dld_ca, color=blue, thick=1+k mod 2
if k mod 2 eq 0 then xyouts, dld_ha[0], dld_ca[0]-0.01, ' '+strtrim(string(xi/1.e5,format='(i5)'),2)+ ' km/s', align=1.0, size=0.7

endfor

oplot, w_ha*[1,1], [0, 0.7],  color=red, thick=1
oplot, [0,0.7], w_ca*[1,1],  color=red, thick=1
tvlct, r_orig, g_orig, b_orig
end