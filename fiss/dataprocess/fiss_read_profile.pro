function fiss_read_profile, file, x, y, h,  pca=pca, ncoeff=ncoeff
;+
;   Name:  fiss_read_profile
;           read one profile at a point  from a FISS file or its associated PCA file.
;
;   Syntax: result = fiss_read_profile(file, x, y [, h], /pca)
;
;   Returned values:
;                  a spectogram
;   Arguments:
;          file    name of file to be read (input)
;;         x       the frame number (input)
;          y      the row number
;          h       fits header (optional output)
;   Keywords:
;          pca      if set, data are read from the associated PCA file (default is set )
;                      if not to be set, keyword sould be set to 0.
;
;   Remarks:
;          For example, suppose a file is named as 'test_A1.fts'. Then the associated file
;          name should be 'test_A1_c.fts' in the same directory. This file contains the
;          coefficient of the PCA components. The PCA basis profiles are contained in another
;          file whose name should be specified in the FITS header of 'test_A1_c.fts', e.g., like
;          'test_A1_p.fts'. This file also should be in the same directory as 'test_A1.fts'.
;
;   Required routines: fiss_read_pca_file,   readfits_frame
;
;   History:
;         2011 Januray,  first coded  (J. Chae)
;
;-
file1= strmid(file, 0, strlen(file)-4)
if strmid(file1, strlen(file1)-2, 2) eq '_c' then cfile=file else cfile=file1+'_c.fts'
if n_elements(pca) eq 0 then pca=1
if not file_test(cfile) then pca=0

h=headfits(file)
endline = where( strmid(h,0,8) EQ 'END     ', Nend)
nmax = endline(0) + 1
npad = 80l*nmax mod 2880
offset = 80*nmax+(2880-npad)*(npad gt 0)
nw=fxpar(h, 'NAXIS1')
ny=fxpar(h,'NAXIS2')
nx=fxpar(h,'NAXIS3')
bscale=fxpar(h,'BSCALE')
if bscale eq 0 then bscale=1
openr, unit,/get_lun,  file, /swap_if_little_endia
a=assoc(unit, intarr(nw), offset)
coeff=a[ny*x+y]*bscale
close, unit & free_lun, unit
if keyword_set(pca) then begin
hc=headfits(cfile)
dir=file_dirname(cfile)+'\'
pfile=dir+fxpar(hc,'pfile')
evec=readfits(pfile, /sil)
if n_elements(ncoeff) eq 0 then  ncoeff=n_elements(coeff[*,0])-1 else $
ncoeff=ncoeff<(n_elements(coeff[*,0])-1)
model=0.
for k=0, ncoeff-1 do model=model+evec[*,k]*coeff[k]
model=model*10^coeff[ncoeff]
return, model
endif else begin
model=coeff
endelse
return, model
end