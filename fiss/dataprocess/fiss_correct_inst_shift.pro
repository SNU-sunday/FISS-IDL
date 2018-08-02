function fiss_correct_inst_shift, w, alignfile, t, wvoff, nocalib=nocalib, nrep=nrep, offset=offset, margin=margin
restore, alignfile
if n_elements(offset) ne 2 then offset=[0, 0]
if n_elements(margin) ne 2 then margin=[10,10]
xmargin=margin[0] & xmargin2=xmargin*2
ymargin=margin[1]  & ymargin2=ymargin*2
xc=align.xc & yc=align.yc & theta=align.theta
 dx=align.dx+offset[0] & dy =align.dy+offset[1] & t=align.dt
nk=n_elements(w[0,0,*])
ny=n_elements(w[0,*,0])
nx=n_elements(w[*,0,0])
w1=fltarr(nx+xmargin2,ny+ymargin2,nk)
x=(findgen(nx+xmargin2)-xmargin)#replicate(1,ny+ymargin2)
y=replicate(1,nx+xmargin2)#(findgen(ny+ymargin2)-ymargin)
if n_elements(nrep) eq 0 then nrep=2
if keyword_set(nocalib) then nrep=1

;if not keyword_set(nocalib) then
 wvoff=fltarr(nx,nk)

for rep=0, nrep-1 do begin
if keyword_set(nocalib) then goto, correct

for k=0, nk-1 do  begin
 fiss_get_pos,x,y,xc,yc,theta[k],dx[k],dy[k],xx, yy
 w1[*,*,k]=interpolate(w[*,*,k]-wvoff[*,k]#replicate(1,ny),xx,yy)
endfor
vv=fltarr(nx+xmargin2,ny+ymargin2)
;for x=0,nx+xmargin2-1 do for y=0, ny+ymargin2-1 do $
 ;   vv[x,y]=total(w1[x,y,*]*(w1[x,y,*] gt 0.))/(total(w1[x,y,*] gt 0.)>1.)
for x=0,nx+xmargin2-1 do for y=0, ny+ymargin2-1 do $
    vv[x,y]=median(w1[(x-10)>0:(x+10)<(nx-1+xmargin2),(y-5)>0:(y+5)<(ny-1+ymargin2),*]) ;*(w1[x,y,*] gt 0.))/(total(w1[x,y,*] gt 0.)>1.)

xx=(findgen(nx)-0.)#replicate(1,ny)
yy=replicate(1,ny)#(findgen(ny)-0.)
w2=fltarr(nx,ny, nk)
for k=0, nk-1 do  begin
 fiss_get_pos,x,y,xc,yc,theta[k],dx[k],dy[k],xx, yy , /inv
w2[*,*,k]= w[*,*, k]-interpolate(vv,  x+xmargin, y+ymargin)
endfor
for x=0, nx-1 do for k=0, nk-1 do wvoff[x,k]=median(w2[x,*,k])

wvoff=wvoff-median(wvoff)

correct:
w3=fltarr(nx+xmargin2, ny+ymargin2, nk)
x=(findgen(nx+xmargin2)-xmargin)#replicate(1,ny+ymargin2)
y=replicate(1,nx+xmargin2)#(findgen(ny+ymargin2)-ymargin)
for k=0, nk-1 do begin
fiss_get_pos,x,y,xc,yc,theta[k],dx[k],dy[k],xx, yy
w3[*,*,k]=interpolate(w[*,*,k]-wvoff[*,k]#replicate(1,ny),xx,yy, missing=0.)
endfor


endfor
return, w3
end
