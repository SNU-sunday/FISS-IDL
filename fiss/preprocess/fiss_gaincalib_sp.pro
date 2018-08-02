function fiss_gaincalib, logsp, x, dx, object=object,  maxiter=maxiter, $
   silent=silent, c=c, shift_flag=shift_flag, mask=msk
;+
;  NAME:  GAINCALIB
;  PURPOSE:    Produce  a gain table  from a set of FISS spectrograms with relative offsets
;  CALIING SEQUENCE:
;          logflat = fiss_gaincalib_sp(logsp, x, y, object=object, )
; INPUT:
;          logsp  a three-dimensional array representing
;                    a sequence of logarithm of two-dimensional images
;                    images(*,*,k) ( k=0, 1,.., N-1).
;          x        an array of  x-shift: x(k) (k=0,..N-1) (input or output or both)
;          dx       an array of distortion displacement: dx(j) (j=0, ..Ny-1) (input or output ot both)
;
; OUTPUT:
;        Result     the gain table if the keyword  ADDITIVE is not set
;                   or the offset table if the keyword is set.
; INPUT KEYWORDS:
;        maxiter   maximum # of iternation (default=5)
;        shift_flag   keyword parameter containing information on how to handle
;                     shift values.
;    If set equal to 0,  x and y are treated as outputs (default)
;                            (this routine determines their initial guesses
;                            and iterates the values)
;                    1,  x and y are treated as both inputs and outputs
;                           (inputs are intial guesses and outputs are
;                             final values to be determined from iteration)
;                    2,  x and y are treated as inputs.
;                            (this program does not affect the values)
;       msk      binary array of the same format as the logsp
;                 which specifies the pixels to be used (1: use, 0:do not use)
;                 default is to use all the pixels.

;
; OUTPUT KEYWORD:
;        object      flat-field corrected object
; History:
;    2010 first coded, being adpated from gaincalib
;-

;alpha=4.

if n_elements(maxiter) eq 0 then maxiter=10

s=size(logsp)
nx=s(1)
ny=s(2)
nf=s(3)

if n_elements(msk) ne nx*ny*nf then  begin
msk = fltarr( nx, ny, nf)
ker=([-1., 8., 1., -16., 1., 8., -1.]/24.) # replicate(1./15., 15.)

for k=0, nf-1 do begin
der2=convol(logsp[*,*,k], ker, /edge_trun)
sigma=sqrt(mean(der2[20:nx-20, 20:ny-20]^2))
msk[*,*,k]=  exp(-0.5*abs(der2/sigma)^2) ; ge   ;10^((logsp[*,*,k] -convol(logsp[*,*,k], replicate(1., 20)/20., /edge_tr ))*2.)  gt 0.9
endfor

endif

i = indgen(nx)#replicate(1, ny)
j = replicate(1, nx)#indgen(ny)




C = fltarr(nf)
for k=0, nf-1 do $
C(k)=total(logsp[*,*,k]*msk[*,*,k])/total(msk[*,*,k])
C=C-mean(C)


Flat=fltarr(nx, ny)
; Initial Estimate of l and m
;if shift_flag eq 0 then begin


x=fltarr(nf)

for loop=0, 0 do begin

if loop eq 0 then begin
ss=nf/2
Object1 = total(logsp(*,ny/2-10:ny/2+10,ss)-Flat[*,ny/2-10:ny/2+10] -C[ss],2)/21
endif else Object1=object

for k=0, nf-1 do begin
sh =  alignoffset((total(logsp(*,ny/2-10:ny/2+10,k)-Flat[*,ny/2-10:ny/2+10],2)/21)#replicate(1.,3),  object1#replicate(1., 3))
x[k] = sh[0]
endfor

x=x-median(x)

dx = fltarr(ny, nf)
for k=0, nf-1 do begin
ref=total(logsp[*, ny/2-10:ny/2+10, k]-Flat[*,ny/2-10:ny/2+10], 2)/21. # replicate(1., 3)
for jj=0, ny-1 do begin
s=alignoffset((logsp[*,jj,k]-Flat[*,jj])#replicate(1.,3), ref)
dx[jj,k]=s[0]
endfor
endfor

if loop eq 0 then begin

Falt=0.
aa=0. & bb=0.
for k=0, nf-1 do begin
weight=(i+x[k]+dx[j,k]) ge 0  and (i+x[k]+dx[j,k]) lt nx
bb=bb+weight
aa = aa + interpolate(logsp[*,*,k]-Flat, (i+x[k]+dx[j,k])>0<(nx-1), j)*weight
endfor
Object = total(aa,2)/(total(bb, 2)>1.)


Flat=0.
for k=0, nf-1 do $
Flat = Flat+ logsp[*,*,k]-c[k]-interpolate(Object, (i-x[k]-dx[j,k])>0<(nx-1))
Flat=Flat/nf

Flat0=Flat



endif

  ; Start Iteration
t1=systime(/secon)

 for iter=1, maxiter do begin


     aa=0.0 & bb=0.0
    for k=0, nf-1 do begin
    weight = (i+x(k)+dx[j,k] gt 0) and (i+x(k)+dx[j,k] lt nx-1)
    weight=weight*interpolate(msk[*,*,k],(i+x(k)+dx[j,k])>0<(nx-1), j)
    aa = aa + total((C(k) +Object#replicate(1., ny) $
      - interpolate(logsp[*,*,k]-Flat, (i+x(k)+dx[j,k])>0<(nx-1), j, cubic=-0.5) )*weight, 2)
    bb = bb+total(weight,2)
    endfor

   DelObject = -  aa/(bb>1.)
   Object = Object + DelObject


    aa=0. & bb=0.0


    for k=0, nf-1 do begin
    weight = (i-x(k)-dx[j,k] gt 0 ) and (i-x(k)-dx[j,k] lt nx-1)
    weight=weight*msk[*,*,k]
    object1 =interpolate(Object,  (i-x(k)-dx[j,k])>0<(nx-1))
    ob = (C(k)+object1+Flat-  $
             logsp[*,*,k])*weight
    C(k) = C(k) -total(ob)/total(weight)
    aa = aa + ob
    bb = bb+weight

    Oi = interpolate(convol(Object, [-1, 8, 0, -8, 1]/12., /edge_trun),(i-x(k)-dx[j,k])>0<(nx-1))
    x(k)=x(k)-total(ob*oi)/total(weight*oi^2)

     endfor
DelFlat = -(aa)/(bb>1. )
Flat = Flat+DelFlat
error = max(abs(Delflat))
if not keyword_set(silent) then    print, 'iteration #  =', iter , '  max(abs(dellogflat)))=', error
endfor  ; iter

endfor ; loop


final:

mf = mean(flat) ;total(Flat)/nx/ny
mc=mean(c) ;total(C)/nf
object = object+mf+mc

;flat = flat-sfit(flat, 1)
ss=where(i ge 20 and i lt nx-1-20)
;coeff=poly_fit(i[ss], flat[ss],1)
Flat=Flat-median(Flat); poly(i, coeff)
c = c-mc
t2=systime(/secon)

if not keyword_set(silent) then print, t2-t1, ' seconds elapsed in GAINCALIB_SP iteration'
return, flat
end

