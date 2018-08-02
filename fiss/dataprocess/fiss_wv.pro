function fiss_wv,  file
h=headfits(file)
pfile=fxpar(h, 'PFILE', count=count)
if count eq 1  then h=fxpar(h, 'COMMENT')
wv=(findgen(fxpar(h,'NAXIS1'))-fxpar(h,'CRPIX1'))*fxpar(h,'CDELT1')
return, wv
end