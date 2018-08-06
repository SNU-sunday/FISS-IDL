function fiss_data_correct, w, inten, align, t, nocalib=nocalib, nrep=nrep, mask=mask,$
         offset=offset, xmargin=xmargin, ymargin=ymargin, intensity=int3, ionly=ionly


if n_elements(offset) ne 2 then offset=[0, 0]
if keyword_set(ionly) then vdet=0 else vdet=1

xmargin2=xmargin[1]-xmargin[0]
ymargin2=ymargin[1]-ymargin[0]
xc=align.xc & yc=align.yc & theta=align.theta
 dx=align.dx+offset[0] & dy =align.dy+offset[1] & t=align.dt
nk=n_elements(w[0,0,*])
ny=n_elements(w[0,*,0])
nx=n_elements(w[*,0,0])

if vdet then w3=fltarr(nx+xmargin2,ny+ymargin2,nk)
int3=fltarr(nx+xmargin2,ny+ymargin2,nk)
mask=bytarr(nx+xmargin2, ny+ymargin2, nk)
;if n_elements(nrep) eq 0 then nrep=2
;if keyword_set(nocalib) then nrep=1

;if not keyword_set(nocalib) then
;wvoff=fltarr(nx,nk)
;intoff=fltarr(nx, nk) ;replicate(1., nx, nk)
;for rep=0, nrep do begin
x=(findgen(nx+xmargin2)+xmargin[0])#replicate(1,ny+ymargin2)
y=replicate(1,nx+xmargin2)#(findgen(ny+ymargin2)+ymargin[0])

for k=0, nk-1 do begin
fiss_get_pos,x,y,xc,yc,theta[k],dx[k],dy[k],xx, yy
mask[*,*,k]=(xx ge 0) and (xx le nx-1) and (yy ge 0) and (yy le ny-1)
if vdet then w3[*,*,k]=interpolate(w[*,*,k],xx,yy, missing=0.)
int3[*,*,k]=interpolate(alog(inten[*,*,k]),xx,yy, missing=alog(median(inten[*,*,k])) )
endfor

;if keyword_set(nocalib) then goto, final
;if not vdet then  goto, final
;if rep eq nrep then goto, final

;
;
; vv=fltarr(nx+xmargin2,ny+ymargin2)
;ii=fltarr(nx+xmargin2,ny+ymargin2)
;;m=median(int3)
;;for x=0,nx+xmargin2-1 do for y=0, ny+ymargin2-1 do $
; ;   vv[x,y]=total(w1[x,y,*]*(w1[x,y,*] gt 0.))/(total(w1[x,y,*] gt 0.)>1.)
;for x=0,nx+xmargin2-1 do for y=0, ny+ymargin2-1 do begin
;tmp=w3[(x-5)>0:(x+5)<(nx-1+xmargin2),(y-5)>0:(y+5)<(ny-1+ymargin2),*]
;tmp1=int3[(x-5)>0:(x+5)<(nx-1+xmargin2),(y-5)>0:(y+5)<(ny-1+ymargin2),*]
;s=where(tmp1 ge 0.5*median(tmp1))
; vv[x,y]=median(tmp[s]) ;*(w1[x,y,*] gt 0.))/(total(w1[x,y,*] gt 0.)>1.)
;; ii[x,y]=median()
;endfor
;xx=(findgen(nx)-0.)#replicate(1,ny)
;yy=replicate(1,ny)#(findgen(ny)-0.)
;w2=fltarr(nx,ny, nk)
;int2=fltarr(nx,ny, nk)
;for k=0, nk-1 do  begin
; fiss_get_pos,x,y,xc,yc,theta[k],dx[k],dy[k],xx, yy , /inv
;w2[*,*,k]= w[*,*, k]-interpolate(vv,  x-xmargin[0], y-ymargin[0])
;;int2[*,*,k]= alog(inten[*,*, k])-interpolate(ii,  x-xmargin[0], y-ymargin[0])
;endfor
;;mi=median(inten)
;;int2=inten/mi
;for x=0, nx-1 do for k=0, nk-1 do begin
;;tmp=int2[x,*,k] *(int2[x,*, k] gt 1.)
;intoff[x,k]=median(int2[x,*,k])
; wvoff[x,k]=median(w2[x,*,k]); *tmp)/intoff[x,k]
;endfor
;wvoff=wvoff-median(wvoff)
;intoff=intoff-median(intoff)
;
;;correct:
;;w2=0   ;&  w3=fltarr(nx+xmargin2, ny+ymargin2, nk)
;;int2=0  ;& int3=fltarr(nx+xmargin2, ny+ymargin2, nk)
;;x=(findgen(nx+xmargin2)+xmargin[0])#replicate(1,ny+ymargin2)
;;y=replicate(1,nx+xmargin2)#(findgen(ny+ymargin2)+ymargin[0])
;;for k=0, nk-1 do begin
;;fiss_get_pos,x,y,xc,yc,theta[k],dx[k],dy[k],xx, yy
;; w3[*,*,k]=interpolate(w[*,*,k]-wvoff[*,k]#replicate(1,ny),xx,yy, missing=0.)
;;int3[*,*,k]=interpolate(inten[*,*,k]/(intoff[*,k]#replicate(1,ny)),xx,yy, missing=mean(inten[*,*,k]))
;;endfor
;
;
;endfor
;
final:
if not vdet then w3=0.

int3=exp(int3)
return, w3
end
