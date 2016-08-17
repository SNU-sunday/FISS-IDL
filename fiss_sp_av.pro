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
if n_elements(pca) eq 0 then pca=0
if keyword_set(pca) then begin
h=headfits(file)
nf=fxpar(h,'NAXIS3')
if nf eq 0 then nf=1
if !version.os_family eq 'Windows' then delim='\' else delim='/'
pfile=file_dirname(file)+delim+fxpar(h,'pfile')
evec=readfits(pfile, /sil)
coeff=total(readfits(file,/sil),3)/nf
;coeff=readfits_frame(cfile, x)

;ncoeff=n_elements(coeff[*,0])
;b=evec[*, ncoeff]#replicate(1.,n_elements(coeff[0,*]))
;for k=0, ncoeff-1 do b=b+evec[*,k]#coeff[k,*]
ncoeff=n_elements(coeff[*,0])-1
b=0.; evec[*, ncoeff]#replicate(1.,n_elements(coeff[0,*]))
for k=0, ncoeff-1 do b=b+evec[*,k]#coeff[k,*]
b=b*(replicate(1., n_elements(b[*,0]))#10^coeff[ncoeff,*])

endif else begin
a= assoreadfits (file,  unit=unit, nf=nf)
nf=fxpar(headfits(file), 'NAXIS3')
if nf eq 0 then nf=1
b=0.
for k=0, nf-1 do b=b+a(k)
b=b/nf
close, unit & free_lun, unit
endelse

return, b
end