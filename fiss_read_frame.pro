function fiss_read_frame, file, x, h,  pca=pca
;+
;   Name:  fiss_read_frame
;           read one frame (spectrogram) from a FISS file or its associated PCA file.
;
;   Syntax: result = fiss_read_frame(file, x [, h], /pca)
;
;   Returned values:
;                  a spectogram
;   Arguments:
;          file    name of file to be read (input)
;;         x       the frame number (input)
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
;         2010 July,  first coded  (J. Chae)
;
;-
file1= strmid(file, 0, strlen(file)-4)
if strmid(file1, strlen(file1)-2, 2) eq '_c' then cfile=file else cfile=file1+'_c.fts'
if n_elements(pca) eq 0 then pca=1
if not file_test(cfile) then pca=0
if keyword_set(pca) then res=fiss_pca_read(file, x, h) $
else begin
res=readfits(file, nslice=x, /sil)
if n_params() gt 2 then h=headfits(file)
endelse

return, res
end