
pro fiss_pca_conv, file, outfile,  ncoeff=ncoeff, pfile=pfile, init=init, wr=wr , eval=eval ;, crcor=crcor
;+
;   NAME: FISS_PCA_CONV
;   Purpose: Convert spectrorams into PCA components
;-
;+
;   Name:  fiss_pca_conv
;            decompose spectrograms in a data file based on principal component analysis (PCA)
;
;   Syntax:  fiss_pca_conv, file, ncoeff=ncoeff, pfile=pfile, /init,
;
;   Arguments:
;            file    name of FITS file containing original data
;
;   Keywords:
;           ncoeff    set this keyword to a named variable that conatins the number
;                       of principal components to be retained (default is 20)
;           pfile     set this keyword to a named variable that contains the name
;               		of file storing the basis profiles
;                     if not set, pfile is considered to be the default file.
;           init      if set, the basis profiles are calculated and are stored into
;                        pfile.
;
;   Remarks:
;           The coefficients are saved into the associated file: say 'test_c.fts' for
;           the input file 'test.fts'
;           The basis profiles are saved into the specified pfile or the associated file
;			'test_p.fts'.
;
;   Required routines: assoreadfits
;
;   History:
;         2010 July,  first coded  (J. Chae)
;         2013 May,   BSCALE and BZERO keywords taken into account (J. Chae)
;         2013 July,    if BSCALE keyword is undefined and is set to zero, it is replaced by 1 (J. Chae)
;         2013 July,    the default value of ncoeff is changed to 20 (previously 30)
;         2013 July,    the data are forced to be equal to or greater than icut=1  before compression (J. Chae)
;-
on_error,  2
if n_elements(outfile) eq 0 then outfile= strmid(file, 0, strlen(file)-4)+'_c.fts'
if n_elements(pfile) eq 0 then pfile=strmid(file, 0, strlen(file)-4)+'_p.fts'
h=headfits(file)
nw=fxpar(h,'NAXIS1')
ny=fxpar(h,'NAXIS2')
nx=fxpar(h,'NAXIS3')
bscale=fxpar(h, 'BSCALE')   & if bscale eq 0 then bscale=1.
bzero=fxpar(h, 'BZERO')
if n_elements(wr) ne 2 then wr=[0, nw-1]
nw1=wr[1]-wr[0]+1
t0=systime(/s)
b=assoreadfits(file, unit=ui)
icut=1.
if keyword_set(init) then begin
                           ;  pfile containing eigenvectors shoudl be created

spgr1=fltarr(nw1, 2000)

kk=0
rep=0
repeat begin
x=round(nx*randomu(seed))>0<(nx-1)
tmp=(b[x])[wr[0]:wr[1],   round(ny*randomu(seed))>0<(ny-1)]
if min(tmp) ge icut then begin
spgr1[*,kk]=tmp
kk=kk+1
endif
rep=rep+1
endrep until kk eq 2000 or rep gt 5000
spgr1=spgr1[*,0:kk-1]

av = total(spgr1,1)/nw1
spgr2=spgr1/(replicate(1.,nw1)#av)
carr = transpose(spgr2) ## (spgr2)

tvscl, carr
eval = eigenql(carr, eigenvectors=evec, /double)

if n_elements(ncoeff) eq 0 then ncoeff=20
;evec[*, ncoeff]=0.
evec=float(evec[*, 0:ncoeff-1])
writefits, pfile, evec

endif else  begin
                        ; eigenvectors are read from pfile
evec=readfits(pfile, /sil)
ncoeff = n_elements(evec[0,*])
endelse

;ava=evec[*, ncoeff]#replicate(1., ny)
coeff = fltarr(ncoeff+1, ny, nx)
fxhmake, hout, fix(coeff)
;if !version.os_family eq 'Windows' then delim='\' else delim='/'
fxaddpar, hout, 'PFILE', file_basename(pfile) ;(strsplit(pfile, delim, count=count, /extract))[count-1]
for j=0, n_elements(h)-1 do fxaddpar, hout, 'COMMENT', h[j]

t1=systime(/s)

for x=0, nx-1  do begin
tmp=assoget(b, x, bzero, bscale)>icut
av=(total(tmp, 1)/nw1)
tmp=tmp/(replicate(1.,nw1)#av)
coeff[ncoeff, *, x]=alog10(av)
for y=0, ny-1 do for k=0, ncoeff-1 do coeff[k, y, x] = total(tmp[*,y]*evec[*,k])
endfor


bscale=max(abs(coeff))/ 20000.

coeff=fix(round(coeff/bscale))
fxaddpar, hout, 'BSCALE', bscale

writefits, outfile, coeff, hout
free_lun, ui
t2=systime(/s)

end