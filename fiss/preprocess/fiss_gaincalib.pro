function fiss_gaincalib, logsp, x, dx, object=object,  maxiter=maxiter, $
   silent=silent, c=c,  mask=msk, alpha=alpha
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
if n_elements(alpha) eq 0 then alpha=0.
if n_elements(maxiter) eq 0 then maxiter=20

s=size(logsp)
nx=s(1)
ny=s(2)
nf=s(3)

if n_elements(msk) ne nx*ny*nf then  begin
msk = fltarr( nx, ny, nf)
ker=([-1., 8., 1., -16., 1., 8., -1.]/24.) ;# replicate(1./15., 15.)

for k=0, nf-1 do begin
der2=convol(logsp[*,*,k], ker, /edge_trun)
der2=der2-mean(der2)
sigma=sqrt(mean(der2[20:nx-20, 20:ny-20]^2))
msk[*,*,k]=convol(exp(-0.5*abs(der2/sigma)^2), replicate(1./9., 9.), /edge_tr)

endfor

endif

i = indgen(nx)#replicate(1, ny)
j = replicate(1, nx)#indgen(ny)




C = fltarr(nf)
for k=0, nf-1 do begin
  C(k)=total(logsp[*,*,k]*msk[*,*,k])/total(msk[*,*,k])
endfor
C=C-mean(C)


Flat=fltarr(nx, ny)
; Initial Estimate of l and m
;if shift_flag eq 0 then begin
for ii=0, nx-1 do for jj=0, ny-1 do Flat[ii,jj]=median(logsp[ii,jj,*])
Flat=Flat-median(Flat)
ker=[-1., 8., 1., -16., 1., 8., -1.]/24.
f1d= convol(flat, [-0.5, 0, 0.5]) ;& f1d=f1d-mean(f1d)
f2d=convol(flat, ker) ;& f2d=f2d-mean(f2d)
mask_tmp=abs(f2d) le 1*stdev(f2d) and abs(f1d) le 1*stdev(f1d) and (i le 100 or i ge nx-1-100)
w=findgen(nx)
for jj=0, ny-1 do begin
ss=where(reform(mask_tmp[*, jj]))
coeff=poly_fit(w[ss],(flat[*, jj])[ss], 2)
flat[*,jj]=poly(w, coeff)
endfor

;flat=smooth(flat, 10)
;tvscl, flat

;stop
x=fltarr(nf)
xi = fltarr(nf)
for k=0, nf-1 do xi[k]=(where(logsp[*,128,k] eq min(logsp[2:nx-3,128,k])))[0]
order=indgen(nf) ; sort(xi)
ker=[-1., 8., 1., -16., 1., 8., -1.]/24.


for loop=0, 0  do begin

for k=0, nf-2 do begin
;sh =  alignoffset(convol(total(logsp(*,ny/2-10:ny/2+10, order[k+1])-Flat[*,ny/2-10:ny/2+10],2)/21, ker)#replicate(1.,3), $
; convol(total(logsp(*,ny/2-10:ny/2+10, order[k])-Flat[*,ny/2-10:ny/2+10],2)/21, ker)#replicate(1.,3), cor)
tmp =  alignoffset(total(logsp(*,ny/2-10:ny/2+10, order[k+1])-Flat[*,ny/2-10:ny/2+10],2)/21#replicate(1.,3), $
                   total(logsp(*,ny/2-10:ny/2+10, order[k])  -Flat[*,ny/2-10:ny/2+10],2)/21#replicate(1.,3), cor)
 dx=round(tmp[0])
if dx lt 0 then begin
 sh =  alignoffset(total(logsp(0:(nx-1+dx),ny/2-10:ny/2+10, order[k+1])-Flat[*,ny/2-10:ny/2+10],2)/21#replicate(1.,3), $
                   total(logsp(-dx:(nx-1),ny/2-10:ny/2+10, order[k])-Flat[*,ny/2-10:ny/2+10],2)/21#replicate(1.,3), cor)
endif else begin
 sh =  alignoffset(total(logsp(dx:(nx-1),ny/2-10:ny/2+10, order[k+1])-Flat[*,ny/2-10:ny/2+10],2)/21#replicate(1.,3), $
                   total(logsp(0:(nx-1-dx), ny/2-10:ny/2+10, order[k])-Flat[*,ny/2-10:ny/2+10],2)/21#replicate(1.,3), cor)
endelse
 print, k, x[order[k+1]], cor
if cor le 0.6 then begin;was 0.8 modified by Kwangsu

print, 'correlation is too poor!'
stop
endif

x[order[k+1]] =x[order[k]]+ sh[0]+dx
endfor

x=x-median(x)


dx = fltarr(ny, nf)


for k=0, nf-1 do begin
ref=convol(total(logsp[*, ny/2-10:ny/2+10, k]-Flat[*,ny/2-10:ny/2+10], 2)/21.,ker) # replicate(1., 3)
for jj=0, ny-1 do begin
s=alignoffset(convol(logsp[*,jj,k]-Flat[*,jj], ker)#replicate(1.,3), ref)
dx[jj,k]=s[0]
endfor
piecewise_quadratic_fit, findgen(ny), dx[*,k], dxn, npoint=100
dx[*,k]=dxn
endfor

ioff=nx/2
nxbig=2*nx
ibig = indgen(nxbig)#replicate(1, ny)
jbig = replicate(1, nxbig)#indgen(ny)

if loop eq 0 then begin

;Falt=0.
aa=0. & bb=0.
for k=0, nf-1 do begin
weight=(ibig-ioff+x[k]+dx[jbig,k]) ge 0  and (ibig-ioff+x[k]+dx[jbig, k]) lt nx
weight=weight*interpolate(msk[*,*,k],(ibig-ioff+x(k)+dx[jbig,k])>0<(nx-1), jbig)
bb=bb+weight
aa = aa + interpolate(logsp[*,*,k]-Flat, (ibig-ioff+x[k]+dx[jbig,k])>0<(nx-1), jbig)*weight
endfor
Object = total(aa,2)/(total(bb, 2)>1.)
endif

  ; Start Iteration
t1=systime(/secon)

 for iter=1, maxiter do begin

    aa=0. & bb=0.0


    for k=0, nf-1 do begin
    weight = (i-x(k)-dx[j,k]+ioff ge 0 ) and (i-x(k)-dx[j,k]+ioff lt nxbig)
    weight=weight*msk[*,*,k]
    object1 =interpolate(Object,  (i-x(k)-dx[j,k]+ioff)>0<(nxbig-1))
    ob = (C(k)+object1+Flat-  $
             logsp[*,*,k])*weight
    C(k) = C(k) -total(ob)/total(weight)
    aa = aa + ob+alpha*(Flat-Flat[(i-1)>0,j])*(i gt 0)+0*alpha*(Flat-Flat[i, (j-1)>0])*(j gt 0)
    bb = bb+weight+alpha*(i gt 0)+0*alpha*(j gt 0)

    Oi = interpolate(convol(Object, [-1, 8, 0, -8, 1]/12., /edge_trun),(i-x(k)-dx[j,k]+ioff)>0<(nxbig-1))
    x(k)=x(k)-total(ob*oi)/total(weight*oi^2)

     endfor
DelFlat = -(aa)/(bb>1)
Flat = Flat+DelFlat

     aa=0.0 & bb=0.0
    for k=0, nf-1 do begin
    weight = (ibig-ioff+x(k)+dx[jbig,k] gt 0) and (ibig-ioff+x(k)+dx[jbig,k] lt nx)
    weight=weight*interpolate(msk[*,*,k],(ibig-ioff+x(k)+dx[jbig,k])>0<(nx-1), jbig)
    aa = aa + total((C(k) +Object#replicate(1., ny) $
      - interpolate(logsp[*,*,k]-Flat, (ibig-ioff+x(k)+dx[jbig,k])>0<(nx-1), jbig, cubic=-0.5) )*weight, 2)
    bb = bb+total(weight,2)
    endfor

   DelObject = -  aa/(bb>1)
   Object = Object + DelObject



error = max(abs(Delflat))
if not keyword_set(silent) then    print, 'iteration #  =', iter , '  max(abs(dellogflat)))=', error
endfor  ; iter

endfor ; loop


;plot, object
;stop
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

