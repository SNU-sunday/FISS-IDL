function fiss_wv,  file
;+
;
; History:
;          2018-08, J. Chae
;-

h=headfits(file)
pfile=fxpar(h, 'PFILE', count=count)
if count eq 1  then h=fxpar(h, 'COMMENT')
wv=(findgen(fxpar(h,'NAXIS1'))-fxpar(h,'CRPIX1'))*fxpar(h,'CDELT1')+fxpar(h,'CRVAL1')
return, wv
end