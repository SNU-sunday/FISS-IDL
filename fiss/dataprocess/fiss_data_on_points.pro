pro fiss_data_on_points, align, x, y, dop,  outfile=outfile, ka=ka

;+
; Calling sequence
;
;  fiss_data_on_points,files, k0, x, y, outfile
;
;  Inputs
;
;     files    an Nf-element array of theoriginal data file names
;     alignfile   the name of file where the alignment data are stored
;     k0         the index of the observed frame ( 0 =< kref < Nf)      I
;     xpoints   an Np-element array of x-coordinates   of the curve on
;                 the observed frame
;     ypoints   an Np-element array of y-coordinates
;
;  Outputs
;     outfile  the name of the IDL save file where the following outputs are saved.
;          files, k0, xpoints, ypoints
;          wv      an Nw-element array of the wavelengths in A measured from the referece wavelegnth
;          ka    a Nf-element array of indice from the first file
;          Data     a Nw x Ns x Nf array of the spectral data
;   History
;       2015 May  J. Chae
;-
;restore, alignfile+'_align.sav'

;get_curve_smooth, xp, yp, ds, xpoints, ypoints
Np=n_elements(x)
;k0=kref
kref=align.kref
files=align.files
xc=align.xc & yc=align.yc & dt=align.dt & dx=align.dx & dy=align.dy & theta=align.theta

;fiss_get_pos, x, y,  xc,yc, theta[k0], dx[kref], dy[kref],  xpoints, ypoints, inv=1
Nf=n_elements(files)
if n_elements(ka) eq 0 then ka=indgen(Nf)
files1=files[ka]
nf1=n_elements(ka)
f=files1[0]
h=fxpar(headfits(f), 'COMMENT') ;  assuming compressed file
Nw=fxpar(h, 'NAXIS1')
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')
;tstring1= strmid(files,  strpos(f, 'FISS_')+5, 15)
;tstring=tstring1[ka]
;time=fiss_dt(tstring1[kref], tstring)*(24*60.); in min


data=fltarr(Nw, nf1, Np)

for kk=0, nf1-1 do begin
k=ka[kk]
fiss_get_pos, x, y,  xc,yc, theta[k], dx[k], dy[k],  xx, yy
xxr=fix(xx)
xmin=min(xxr)
xmax=max(xxr)
for i=xmin, xmax do begin

s=where(xxr eq i, count) & if count ge 1 then begin
if i gt xmin then sp=sp1 else sp=fiss_read_frame(files[k], i>0)
sp1=fiss_read_frame(files[k], (i+1)<(Nx-1))
for j=0, count-1 do begin
y1=yy[s[j]]>0<(Ny-2)

wx=xx[s[j]]-i
wy=y1-fix(y1)
data[*,kk,s[j]]=(1-wx)*(1-wy)*sp[*,fix(y1)] $
           + wx*(1-wy)*sp1[*,fix(y1)] $
          + (1-wx)*wy*sp[*,fix(y1)+1] $
          +  wx*wy*sp1[*,fix(y1)+1]
data[*, kk, s[j]]=data[*, kk,  s[j]]*((i ge 0)*((i+2) le Nx)*(yy[s[j]] ge 0)*((yy[s[j]]+2) lt Ny))

endfor
endif
endfor
endfor

band=strmid(fxpar(h, 'wavelen'),0,4)
wv=fiss_wv_calib(band, total(fiss_sp_av(files[kref]), 2))

dop={files:files, ka:ka, data:data, wv:wv, x:x, y:y, dt:dt[ka]}

if n_elements(outfile) eq 1 then save, filename=outfile+'_sub.sav', dop

end
