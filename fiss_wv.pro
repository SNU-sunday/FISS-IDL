function fiss_wv,  file
if n_elements(h) eq 1 then begin
  h=headfits(file)
  if strmid(file, strlen(file)-6, 2) eq '_c' then h=fxpar(h, 'COMMENT')
endif else h=file
wv=(findgen(fxpar(h,'NAXIS1'))-fxpar(h,'CRPIX1'))*fxpar(h,'CDELT1')
return, wv
end