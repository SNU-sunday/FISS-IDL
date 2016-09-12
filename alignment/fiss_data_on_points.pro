pro fiss_data_on_points, alignfile, k0, xp, yp, ds, outfile, ka=ka,ncoeff=ncoeff

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
;
;-
restore, alignfile+'_align.sav'

get_curve_smooth, xp, yp, ds, xpoints, ypoints
Np=n_elements(xpoints)
fiss_get_pos, x, y,  xc,yc, theta[k0], dx[k0], dy[k0],  xpoints, ypoints, inv=1
Nf=n_elements(files)
if n_elements(ka) eq 0 then ka=indgen(Nf)
files1=files[ka]
nf1=n_elements(ka)
f=files1[0]
h=fxpar(headfits(f), 'COMMENT') ;  assuming compressed file
Nw=fxpar(h, 'NAXIS1')
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')
tstring= strmid(files[ka],  strpos(f, 'FISS_')+5, 15)
time=fiss_dt(tstring[kref], tstring)*(24*60.); in min


data=fltarr(Nw, nf1, Np)

for kk=0, nf1-1 do begin
k=ka[kk]
fiss_get_pos, x, y,  xc,yc, theta[k], dx[k], dy[k],  xx, yy
for p=0, Np-1 do begin
x1=xx[p]>0<(nx-2)  & y1=yy[p]>0<(ny-2)
wx=x1-fix(x1)
wy=y1-fix(y1)

data[*,kk, p]=(1-wx)*(1-wy)*fiss_read_profile(files[k], fix(x1), fix(y1),ncoeff=ncoeff) $
           +wx*(1-wy)*fiss_read_profile(files[k], fix(x1)+1, fix(y1),ncoeff=ncoeff) $
         + (1-wx)*wy*fiss_read_profile(files[k], fix(x1), fix(y1)+1,ncoeff=ncoeff) $
          +wx*wy*fiss_read_profile(files[k], fix(x1)+1, fix(y1)+1,ncoeff=ncoeff)
endfor
endfor

band=strmid(fxpar(h, 'wavelen'),0,4)
wv=fiss_wv_calib(band, total(fiss_sp_av(files[kref]), 2))

save, filename=outfile+'_sub.sav', files,  data, wv, ka, x, y, time

end
