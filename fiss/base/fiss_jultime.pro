;  Name : FISS_jultime
;  
;  Purpose : return the Julian Day value from the FISS data filename
;  
;  Calling Sequence : time = FISS_jultime(f_fiss)
;  
;  Input 
;    - f_fiss : FISS file name(array)
;    
;  Output : Julian day (double type)    

function fiss_jultime, f_fiss

if n_elements(f_fiss) eq 0 then begin
    message, 'Incorrect argument  (!ºoº)!', /cont
    message, 'Calling sequence : time = fiss_jultime(filename)', /cont
    return, -1
endif
;time=dblarr(n_elements(f_fiss))
;for i=0, n_elements(f_fiss)-1 do begin
;    date=fxpar(headfits(f_fiss[i]), 'date')
;    yr=strmid(date, 0, 4)
;    mon=strmid(date, 5, 2)
;    dat=strmid(date, 8, 2)
;    hr=strmid(date, 11, 2)
;    min=strmid(date, 14, 2)
;    sec=strmid(date, 17, 2)
;    time[i]=julday(mon, dat, yr, hr, min, sec)
;;    stop
;endfor

base=file_basename(f_fiss)
yr=strmid(base,5, 4)
mon=strmid(base,9, 2)
dat=strmid(base, 11, 2)
hr=strmid(base, 14, 2)
min=strmid(base, 16, 2)
sec=strmid(base, 18, 2)
time=julday(mon, dat, yr, hr, min, sec)
return, time
end