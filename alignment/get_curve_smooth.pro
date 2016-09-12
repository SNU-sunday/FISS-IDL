pro get_curve_smooth, x0, y0,  del,  x, y

n0=n_elements(x0)
if n0 ge 4 then lsq=1  else lsq=0
if n0 eq 3 then q=1 else q=0
alength=fltarr(n0)
x1=float(x0)
y1=float(y0)
for j=0, 1 do begin
for i=1, n0-1 do alength[i]=alength[i-1]+$
   sqrt((x1[i]-x1[i-1])^2+(y1[i]-y1[i-1])^2)
; piecewise_quadratic_fit, alength,  x0, x1
 x1=interpol(float(x0), alength, alength, lsquadratic=lsq, quadratic=q)
; piecewise_quadratic_fit, alength,  y0, y1
 y1=interpol(float(y0), alength, alength, lsquadratic=lsq, quadratic=q)
endfor
n=round(alength[n0-1]/del)+1

sl = findgen(n)*del

x=interpol(x1, alength,  sl, lsquadratic=lsq, quadratic=q)
y=interpol(y1, alength,  sl, lsquadratic=lsq, quadratic=q)



end
