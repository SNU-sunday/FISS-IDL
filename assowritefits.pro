pro assowritefits,  unit, file=file, header=header,  open=open,  $
                         data=data, close=close  
;+
;   NAME: ASSOWRITEFITS
;   PURPOSE:  Write a cube data into a fits file image by image
;   CALLING SEQUENCE:
;            ASSOWRITEFITS, unit, file=file, header=header, open=open, data=data, close=close
;   Examples:
;            ASSOWRITEFITS,  unit, file=file, header=header,/open   
;
;                 open "file" with  "unit" number  and write FITS "header"
;
;            ASSOWRITEFITS,  unit,  data=data
;                  
;                  write "data" 
;
;            ASSOWRITEFITS, unit, header=header, /close
;                   
;                  check the blocksize and close the unit      
;- 
                                              
if  keyword_set(open) then begin
endline = where( strmid(header,0,8) EQ 'END     ', Nend)
nmax = endline(0) + 1
bhdr = replicate(32b, 80l*nmax)
for n = 0l, endline(0) do bhdr(80*n) = byte( header(n) )
 npad = 80l*nmax mod 2880
 openw, unit, /get_lun, file
 writeu, unit, bhdr
 if npad GT 0 then writeu, unit,  replicate(32b, 2880 - npad)
 return
endif                        
 
if keyword_set(data) then begin
big_endian = is_ieee_big()
if not big_endian then begin
newdata = data
host_to_ieee, newdata
writeu, unit, newdata
endif else writeu, unit, data
return
endif
 
 if keyword_set(close) then begin
 bitpix= fxpar(header, 'BITPIX')
 nbytes = (abs(bitpix)/8)*fxpar(header, 'NAXIS1')
 nx2=fxpar(header, 'NAXIS2')
 if !ERR ne -1 then nbytes = nbytes*nx2
 nx3 = fxpar(header, 'NAXIS3')
 if !ERR ne -1 then nbytes = nbytes*nx3
 npad = nbytes mod 2880
 if npad gt 0 then writeu, unit, replicate(0b, 2880-npad)
 free_lun, unit
 return
 endif
 
 end
 
