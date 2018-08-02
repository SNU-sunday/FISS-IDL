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

position=(strpos(f_fiss[0], '*FISS*'))[0]
yr=strmid(f_fiss, position+6, 4)
mon=strmid(f_fiss, position+10, 2)
dat=strmid(f_fiss, position+12, 2)
hr=strmid(f_fiss, position+15, 2)
min=strmid(f_fiss, position+17, 2)
sec=strmid(f_fiss, position+19, 2)
time=julday(mon, dat, yr, hr, min, sec)
return, time
end