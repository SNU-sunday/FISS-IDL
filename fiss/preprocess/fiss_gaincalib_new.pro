function fiss_gaincalib_new, logsp, x, dx, object=object,  maxiter=maxiter, $
   silent=silent, c=c,  mask=msk
;+
;  NAME:  GAINCALIB
;  PURPOSE:    Produce  a gain table  from a set of FISS spectrograms with relative offsets
;  CALIING SEQUENCE:
;          logflat = fiss_gaincalib(logsp, x, y, object=object, )
; INPUT:
;          logsp  a three-dimensional array representing
;                    a sequence of logarithm of two-dimensional images
;                    images(*,*,k) ( k=0, 1,.., N-1).
;          x        an array of  x-shift: x(k) (k=0,..N-1) (input or output or both)
;          dx       an array of distortion displacement: dx(j) (j=0, ..Ny-1) (input or output ot both)
;
; OUTPUT:
;        Result     the gain table
; INPUT KEYWORDS:
;        maxiter   maximum # of iternation (default=5)
;
;
;
; OUTPUT KEYWORD:
;        object      flat-field corrected object
; History:
;    2010 July, first coded, being adpated from gaincalib (J. Chae)
;-

;alpha=4.

if n_elements(maxiter) eq 0 then maxiter=20

s=size(logsp)
nx=s(1)
ny=s(2)
nf=s(3)

if n_elements(msk) ne nx*ny*nf then  begin
msk = fltarr( nx, ny, nf)
ker=([-1., 8., 1., -16., 1., 8., -1.]/24.) ;# replicate(1./15., 15.)
ker1=[1,-8,0,8,-1]/12.
for k=0, nf-1 do begin
der2=convol(logsp[*,*,k], ker, /edge_trun)
der2=der2-mean(der2)
der1=convol(logsp[*,*,k],ker1, /edge_trun)
der1=der1-mean(der1)

val=logsp[*,*,k]-mean(logsp[*,*,k])

;sigma=stdev(der2) ; sqrt(mean(der2[20:nx-20, 20:ny-20]^2))
msk[*,*,k]= exp(-0.5*abs(der2/stdev(der2))^2 ); $
      ;  -0.5*abs(der1/stdev(der1)) -0.2*0.5*abs(val/stdev(val)))
;msk[0:2, *,k]=0.
;msk[nx-1-2:nx-1,*,k]=0
;msk[*,0:1,k]=0
;msk[*,ny-2:ny-1,k]=0
;msk[*,*,k]=convol(msk[*,*,k], replicate(1., 9)/9.)

endfor

endif
tv, bytscl( msk[*,*,3], 0., 1.)


i = indgen(nx)#replicate(1, ny)
j = replicate(1, nx)#indgen(ny)
C = fltarr(nf)
for k=0, nf-1 do $
C(k)=total(logsp[*,*,k]*msk[*,*,k])/total(msk[*,*,k])
C=C-mean(C)


Flat=fltarr(nx, ny)
; Initial Estimate of l and m
;if shift_flag eq 0 then begin
for ii=0, nx-1 do for jj=0, ny-1 do Flat[ii,jj]=max(logsp[ii,jj,*])
ker=[-1., 8., 1., -16., 1., 8., -1.]/24.
f1d= convol(flat, [-0.5, 0, 0.5]) & f1d=f1d-mean(f1d)
f2d=convol(flat, ker) & f2d=f2d-mean(f2d)
mask_tmp=abs(f2d) le 1*stdev(f2d) and abs(f1d) le 1*stdev(f1d) and (i le 100 or i ge nx-1-100)
w=findgen(nx)
for jj=0, ny-1 do begin
ss=where(reform(mask_tmp[*, jj]))
coeff=poly_fit(w[ss],(flat[*, jj])[ss], 2)
flat[*,jj]=poly(w, coeff)
endfor
;stop
x=fltarr(nf)
ker=[-1., 8., 1., -16., 1., 8., -1.]/24.

k=nf/2
x[k]=0.
for dir=1, -1, -2 do begin
repeat  begin
sh =  alignoffset(convol(total(logsp[*,ny/2-10:ny/2+10,k+dir]-Flat[*,ny/2-10:ny/2+10],2)/21, ker)#replicate(1.,3), $
 convol(total(logsp[*,ny/2-10:ny/2+10, k]-Flat[*,ny/2-10:ny/2+10],2)/21, ker)#replicate(1.,3), cor)
 if cor gt 0.8 then begin
 x[k+dir]=x[k]+sh[0]
 k=k+dir
 print, k, x[k], cor
endif
 endrep until cor le 0.8 or k eq nf-1 or k eq 0
 if dir eq 1 then kf=k else ki=k
 k=nf/2
 endfor
 print, 'ki=', ki, '  kf=', kf

logsp1=logsp[*,*,ki:kf]
x=x[ki:kf]
x=x-median(x)
nf1=kf-ki+1

for loop=0, 1  do begin



dx = fltarr(ny, nf1)


for k=0, nf1-1 do begin
ref=convol(total(logsp1[*, ny/2-10:ny/2+10, k]-Flat[*,ny/2-10:ny/2+10], 2)/21.,ker) # replicate(1., 3)
for jj=0, ny-1 do begin
s=alignoffset(convol(logsp1[*,jj,k]-Flat[*,jj], ker)#replicate(1.,3), ref)
dx[jj,k]=s[0]
endfor
piecewise_quadratic_fit, findgen(ny), dx[*,k], dxn, npoint=100
dx[*,k]=dxn
endfor

if loop eq 0 then begin

;Falt=0.
aa=0. & bb=0.
for k=0, nf1-1 do begin
weight=(i+x[k]+dx[j,k]) ge 0  and (i+x[k]+dx[j,k]) lt nx
bb=bb+weight
aa = aa + interpolate(logsp1[*,*,k]-Flat, (i+x[k]+dx[j,k])>0<(nx-1), j)*weight
endfor
Object = total(aa,2)/(total(bb, 2)>1.)


endif

  ; Start Iteration
t1=systime(/secon)

 for iter=1, maxiter do begin

    aa=0. & bb=0.0


    for k=0, nf1-1 do begin
    weight = (i-x(k)-dx[j,k] gt 0 ) and (i-x(k)-dx[j,k] lt nx-1)
    weight=weight*msk[*,*,k+ki]
    object1 =interpolate(Object,  (i-x(k)-dx[j,k])>0<(nx-1))
    ob = (C(k)+object1+Flat-  $
             logsp1[*,*,k])*weight
    C(k) = C(k) -total(ob)/total(weight)
    aa = aa + ob
    bb = bb+weight

    Oi = interpolate(convol(Object, [-1, 8, 0, -8, 1]/12., /edge_trun),(i-x(k)-dx[j,k])>0<(nx-1))
    x(k)=x(k)-total(ob*oi)/total(weight*oi^2)

     endfor
DelFlat = -(aa)/(bb>1. )
Flat = Flat+DelFlat

     aa=0.0 & bb=0.0
    for k=0, nf1-1 do begin
    weight = (i+x(k)+dx[j,k] gt 0) and (i+x(k)+dx[j,k] lt nx-1)
    weight=weight*interpolate(msk[*,*,k+ki],(i+x(k)+dx[j,k])>0<(nx-1), j)
    aa = aa + total((C(k) +Object#replicate(1., ny) $
      - interpolate(logsp1[*,*,k]-Flat, (i+x(k)+dx[j,k])>0<(nx-1), j, cubic=-0.5) )*weight, 2)
    bb = bb+total(weight,2)
    endfor

   DelObject = -  aa/(bb>1.)
   Object = Object + DelObject



error = max(abs(Delflat))
if not keyword_set(silent) then    print, 'iteration #  =', iter , '  max(abs(dellogflat)))=', error
endfor  ; iter

endfor ; loop


final:

mf = mean(flat) ;total(Flat)/nx/ny
mc=mean(c) ;total(C)/nf
object = object+mf+mc

;flat = flat-sfit(flat, 1)
;ss=where(i ge 20 and i lt nx-1-20)
;coeff=poly_fit(i[ss], flat[ss],1)
Flat=Flat-median(Flat); poly(i, coeff)
c = c-mc
t2=systime(/secon)

if not keyword_set(silent) then print, t2-t1, ' seconds elapsed in GAINCALIB_SP iteration'
return, flat
end

