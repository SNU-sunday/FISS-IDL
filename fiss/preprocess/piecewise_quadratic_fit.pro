pro piecewise_quadratic_fit, t, y, ym,  vy, ay, npoint=Npoint, sel=sel
;+
;   Name:
;
;
;   Syntax:
;
;   Arguments:
;
;   Keywords:
;
;   Remarks:
;
;   Required routines:
;
;   History:
;
;         2010 July,  revised  (J. Chae)
;
;-
n= n_elements(t)
if n_elements(sel) eq 0 then sel=replicate(1B, n)
if n_elements(Npoint) eq 0 then Npoint=5
M=(Npoint<n)-1
ym=y*0
vy=y*0
ay=y*0
for j=0, n-1 do begin
i=(j-M/2)>0
f=(i+M)<(n-1)
i=f-M
s=where(sel[indgen(f-i+1)+i])
c=poly_fit((t[i:f])[s], (y[i:f])[s], 2)
ym[j]=poly(t[j], c)
vy[j]=c[1]+2*c[2]*t[j]
ay[j]=2*c[2]
endfor
end