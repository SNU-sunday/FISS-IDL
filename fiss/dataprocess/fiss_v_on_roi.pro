function fiss_v_on_roi, alignfile, k, xr, yr, ds, wr, hw
;+
; Calling sequence
;
;  Result= fiss_v_on_roi(alignfile, k, xr, yr, ds, wr, hw)
;
;  Inputs
;
;     alignfile   the name of file where the alignment data are stored
;     k        the index of the frame of interest ( 0 =< k < Nf-1)      I
;     xr   a two-element array representing the x-range
;     yr   a  two-element array representing the y-range
;     ds    sampling
;     wr     spectral range to be used
;     hw     half width of the lambdeter
;  Outputs
;       Result[0,*,*]   wavelength position image
;       Result[1,*,*]   intensity image
;
;
;
;-
if n_elements(alignfile) eq 1 then restore, alignfile+'_align.sav'
files=align.files & kref=align.kref
xc=align.xc & yc=align.yc & dt=align.dt & dx=align.dx & dy=align.dy & theta=align.theta

Nx1 = round((xr[1]-xr[0])/ds)+1
xg=xr[0]+findgen(Nx1)*ds
Ny1=round((yr[1]-yr[0])/ds)+1
yg=yr[0]+findgen(Ny1)*ds

xa=xg#replicate(1, ny1)
ya=replicate(1, Nx1)#yg
wv=fiss_wv(files[k])
h=fxpar(headfits(files[k]), 'COMMENT') ;  assuming compressed file
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')


swv=where((wv-wr[0])*(wv-wr[1]) le 0., nw)
wv=wv[swv]
data=fltarr(2, Nx1*Ny1)

fiss_get_pos, xa, ya,  xc,yc, theta[k], dx[k], dy[k],  xx, yy

xxr=fix(xx)
xmin=min(xxr)
xmax=max(xxr)
for x=xmin, xmax do begin

s=where(xxr eq x, count)
if count ge 1 then begin
    if x gt xmin then sp=sp1 else sp=(fiss_read_frame(files[k], x>0))[swv,*]
    sp1=(fiss_read_frame(files[k], (x+1)<(Nx-1)))[swv,*]
for j=0, count-1 do begin
y1=yy[s[j]]>0<(Ny-2)

wx=xx[s[j]]-x
wy=y1-fix(y1)

spdata =(1-wx)*(1-wy)*sp[*,fix(y1)] + wx*(1-wy)*sp1[*,fix(y1)] $
          + (1-wx)*wy*sp[*,fix(y1)+1] +  wx*wy*sp1[*,fix(y1)+1]
spdata=spdata*((x ge 0)*((x+2) le Nx)*(yy[s[j]] ge 0)*((yy[s[j]]+2) lt Ny))
wvpos=bisector_d(wv, spdata, hw, intensity)

data[*, s[j]]=[wvpos,intensity]
endfor
endif
endfor
data=reform(data,2 , Nx1, Ny1)

return, data

end
