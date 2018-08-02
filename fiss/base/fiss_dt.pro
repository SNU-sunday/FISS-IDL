function fiss_dt,  tstr1, tstr2
;+
;  Purpose:
;             Determine day difference between two time strings
;  Calling sequence
;            dt=fiss_dt(tsrtr1, tstr2)
;
;  Inputs:
;              tstr1  time string of reference like '20100630_183942'
;              tsrt2  time string of interest (array is allwed)
;  Outpus:
;           dt  in day
;-
dt=julday(strmid(tstr2, 4,2), strmid(tstr2, 6,2), strmid(tstr2, 0, 4), $
              strmid(tstr2, 9,2), strmid(tstr2, 11, 2), strmid(tstr2,13, 2)) $
 -julday(strmid(tstr1, 4,2), strmid(tstr1, 6,2), strmid(tstr1, 0, 4), $
              strmid(tstr1, 9,2), strmid(tstr1, 11, 2), strmid(tstr1,13, 2))  ; in day

return, dt
end