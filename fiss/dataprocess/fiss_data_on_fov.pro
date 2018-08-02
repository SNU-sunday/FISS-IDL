pro fiss_data_on_fov, alignfile, k, xr, yr, ds, outfile

;+
; Calling sequence
;
;  fiss_data_on_files, alignfile, k, xr, yr, ds,  outfile
;
;  Inputs
;
;     alignfile   the name of file where the alignment data are stored
;     k        the index of the frame of interest ( 0 =< k < Nf-1)      I
;     xr   a two-element array representing the x-range
;     yr   a  two-element array representing the y-range
;     ds    sampling
;  Outputs

;     outfile  the name of the IDL save file where the following outputs are saved.
;          files, k
;          wv      an Nw-element array of the wavelengths in A measured from the referece wavelegnth
;          xp       a Nx-array of the x-position
;          yp       a Ny-array of the y-position
;          Data     a Nw x Nx x Ny array of the spectral data
;
;-
restore, alignfile+'_align.sav'


Nx1 = round((xr[1]-xr[0])/ds)
xg=xr[0]+findgen(Nx1)*ds
Ny1=round((yr[1]-yr[0])/ds)
yg=yr[0]+findgen(Ny1)*ds

xa=xg#replicate(1, ny1)
ya=replicate(1, Nx1)#yg

h=fxpar(headfits(files[k]), 'COMMENT') ;  assuming compressed file
Nw=fxpar(h, 'NAXIS1')
Nx=fxpar(h, 'NAXIS3')
Ny=fxpar(h, 'NAXIS2')

data=fltarr(Nw, Nx1*Ny1)

fiss_get_pos, xa, ya,  xc,yc, theta[k], dx[k], dy[k],  xx, yy

xxr=fix(xx)
xmin=min(xxr)
xmax=max(xxr)
for x=xmin, xmax do begin

s=where(xxr eq x, count) & if count ge 1 then begin
if x gt xmin then sp=sp1 else sp=fiss_read_frame(files[k], x>0)
sp1=fiss_read_frame(files[k], (x+1)<(Nx-1))
for j=0, count-1 do begin
y1=yy[s[j]]>0<(Ny-2)

wx=xx[s[j]]-x
wy=y1-fix(y1)

data[*,s[j]]=(1-wx)*(1-wy)*sp[*,fix(y1)] $ ;fiss_read_profile(files[k], fix(x1), fix(y1)) $
           + wx*(1-wy)*sp1[*,fix(y1)] $    ; fiss_read_profile(files[k], fix(x1)+1, fix(y1)) $
          + (1-wx)*wy*sp[*,fix(y1)+1] $    ; fiss_read_profile(files[k], fix(x1), fix(y1)+1) $
          +  wx*wy*sp1[*,fix(y1)+1]       ;fiss_read_profile(files[k], fix(x1)+1, fix(y1)+1)
endfor
endif
endfor
data=reform(data, Nw, Nx1, Ny1)

band=strmid(fxpar(h, 'wavelen'),0,4)
wv=fiss_wv_calib(band, total(fiss_sp_av(files[kref]), 2))

fov={fov, data:data, k:k, wv:wv, xg:xg, yg:yg}
save, filename=outfile+'_fov.sav',  fov

end
