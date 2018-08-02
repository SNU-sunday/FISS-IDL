
function fiss_pca_denoise, sp,  ncoeff=ncoeff
;   NAME: FISS_PCA_denoise
;   Purpose: Remove noise in a spectrogram using PCA anlaysis
;-
;+
;   Name: fiss_pca_denoise
;         reduces noise in a spectrogram based on PCA-compression
;
;   Syntax:  result= fiss_pca_denoise(sp, ncoeff=ncoeff)
;
;   Returned values:
;                 noise-reduced spectrogram
;   Arguments:
;           sp   spectrogram to be processed
;
;   Keywords:
;          ncoeff   optionally set this keyword to a named variable that  contains
;                   an integer. This is the number of coefficients for the principal components
;                   to be retained for the final result.
;
;   Remarks:       In general, the smaller ncoeff  is  the more the noise is recued,
;                  but there is a worry that real features might
;                  be washed out as well. The default value is 20.
;
;   Required routines:
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-
spgr1=sp
ny=n_elements(sp[0,*])
carr = transpose(spgr1) ## (spgr1)
eval = eigenql(carr, eigenvectors=evec)
if n_elements(ncoeff) eq 0 then ncoeff=20
tmp=sp*0
for k=0, ncoeff-1 do tmp=tmp+ reform(evec[*,k])#total(sp*(reform(evec[*,k])#replicate(1., ny)),1)


return, tmp

end