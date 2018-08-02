pro fiss_get_flat_v2, fflats, fd, flat_file, tilt, sel=sel, slit_pattern=slit_pattern
;+
;   Name:  fiss_get_flat
;            processes flat observation files to  obtain flat apttern
;            and store it into  a file
;
;   Syntax: fiss_get_flat, fflats, fd, flat_file
;
;   Arguments:
;          fflats    an array of flat observation files
;          fd        name of dark file
;          flat_file  name of file intowhich the flat pattern is stored
;
;   Keywords: None
;
;   Remarks:
;
;   Required routines:  fiss_sp_av,  fiss_gaincalib
;
;   History:
;         2010 July,  first coded  (J. Chae)
;         2015 June. Chae
;                     1. changed function median to function mean to determine tmp for the slit pattern
;         2016 June. Cho : add confirmation part for 'GRATWVLN'  

print, 'starting fiss_get_flats' & wait, 0.5
nf=n_elements(fflats)
if nf eq 1 then begin
logsp = alog10(readfits(fflats[0]))
nw=n_elements(logsp[*,0,0])
ny=n_elements(logsp[0,*,0])
nf=n_elements(logsp[0,0,*])
endif else begin
dark=readfits(fd)
nw=n_elements(dark[*,0]) & ny=n_elements(dark[0,*])
logsp=fltarr(nw,ny, nf)
for k=0, nf-1 do logsp[*,*,k]=alog10(fiss_sp_av(fflats[k])-dark)
endelse
tmp=fltarr(nw, ny)
logsp1=logsp
logflat=tmp*0

for i=0, nw-1 do for j=0, ny-1 do tmp[i,j]=mean(logsp[i,j,*])
slit_pattern= fiss_slit_pattern(tmp, tilt)
print, 'tilt=', tilt, 'degree'
for k=0, nf-1 do logsp1[*,*,k]=logsp[*,*,k]-slit_pattern
logflat=fiss_gaincalib_old(logsp1, maxiter=40, /sil) ;;;
;logflat=convol(logflat, [0.25, 0.5, 0.25], /edge_tr)

flat=10^logflat
slit_pattern=10^(slit_pattern-median(slit_pattern))
tmp=fix(round(10000*flat))>0<65535
fxhmake, h1, tmp
fxaddpar, h1, 'BSCALE', 1.E-4, format='F8.4'
fxaddpar, h1, 'TILT', tilt
fxaddpar, h1, 'GRATWVLN', float(fxpar(headfits(fflats[0]), 'GRATWVLN'))
writefits, flat_file , tmp, h1
print, 'end of fiss_get_flats' & wait, 0.5

end