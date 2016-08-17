function fiss_pca_read, file, x, h
;
;+
;   Name: fiss_pca_read
;           composes a spectrogram from coefficients of principal components (PC)
;
;   Syntax: Result = fiss_pca_read(file, x [, h])
;
;   Returned values:
;                 spectrogram
;   Arguments:
;             file     name of file to be read (input)
;             x        frame number (input)
;             h        fits header  (optional output)
;
;   Keywords:  None
;
;   Remarks: The name of file can be either the associated standard fits file or
;            the coefficient file.  For example,  suppose the name of the associated
;            standard file name is 'test_A1.fts'. The name of the coefficient file
;            name is 'test_A1_c.fts' in the same directory.  The PCA basis profiles are
;            contained in another  file whose name should be specified in the FITS header
;            of 'test_A1_c.fts', e.g., like 'test_A1_p.fts'. This file also should be
;            in the same directory as 'test_A1_c.fts'.
;
;                result=fiss_pca_read('test_A1.fts', 10)
;                result=fiss_pca-read('test_A1_c.fts',10)
;
;   Required routines:
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-
file1= strmid(file, 0, strlen(file)-4)
if strmid(file1, strlen(file1)-2, 2) eq '_c' then cfile=file else cfile=file1+'_c.fts'
hc=headfits(cfile)
if n_params() gt 2 then h=fxpar(hc, 'COMMENT')
dir=file_dirname(cfile)+'\'
pfile=dir+fxpar(hc,'pfile')
evec=readfits(pfile, /sil)
coeff=readfits(cfile, nslice=x, /sil)
ncoeff=n_elements(coeff[*,0])-1
model=0.; evec[*, ncoeff]#replicate(1.,n_elements(coeff[0,*]))
for k=0, ncoeff-1 do model=model+evec[*,k]#coeff[k,*]
model=model*(replicate(1., n_elements(model[*,0]))#10^coeff[ncoeff,*])
return, model
end