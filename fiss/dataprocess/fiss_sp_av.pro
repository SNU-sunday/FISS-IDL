function fiss_sp_av,  file, pca=pca
;+
;   Name:
;
;
;   Syntax:
;
;   Returned values:
;
;
;   Arguments:
;
;   Keywords:
;
;   Remarks:
;
;   Required routines:
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-
file1= strmid(file, 0, strlen(file)-4)
if strmid(file1, strlen(file1)-2, 2) eq '_c' then cfile=file else cfile=file1+'_c.fts'
if n_elements(pca) eq 0 then pca=1
if not file_test(cfile) then pca=0
if keyword_set(pca) then begin
h=headfits(file)
;nx=fxpar(h,'NAXIS1')
;nz=fxpar(h,'NAXIS2')
nf=fxpar(h,'NAXIS3')
if nf eq 0 then nf=1
if !version.os_family eq 'Windows' then delim='\' else delim='/'
pfile=file_dirname(file)+delim+fxpar(h,'pfile')
evec=readfits(pfile, /sil)
coeff=readfits(file,/sil)

;model=0.; evec[*, ncoeff]#replicate(1.,n_elements(coeff[0,*]))
;for k=0, ncoeff-1 do model=model+evec[*,k]#coeff[k,*]
;model=model*(replicate(1., n_elements(model[*,0]))#10^coeff[ncoeff,*])

;coeff=readfits_frame(cfile, x)

;ncoeff=n_elements(coeff[*,0])
;b=evec[*, ncoeff]#replicate(1.,n_elements(coeff[0,*]))
;for k=0, ncoeff-1 do b=b+evec[*,k]#coeff[k,*]
ncoeff=n_elements(coeff[*,0,0])-1

xtmp=replicate(1., n_elements(evec[*,0]))
b=0.
count=0
for frame=0, nf-1 do begin
b1=0.; evec[*, ncoeff]#replicate(1.,n_elements(coeff[0,*]))
for k=0, ncoeff-1 do b1=b1+reform(evec[*,k])#reform(coeff[k,*, frame])
b1=b1*(xtmp#10^reform(coeff[ncoeff,*, frame]))
if  median(b1) ge  100 or 1  then begin
b=b+b1
count=count+1
endif
endfor
b=b/count
endif else begin
a= assoreadfits (file,  unit=unit, nf=nf)
nf=fxpar(headfits(file), 'NAXIS3')
if nf eq 0 then nf=1
b=0.
count=0
for k=0, nf-1 do begin
c=a[k]
if median(c) ge 100 then begin
b=b+c
count=count+1
endif
endfor
b=b/count
close, unit & free_lun, unit
endelse

return, b
end