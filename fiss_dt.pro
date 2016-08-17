function fiss_dt,  tstr1, tstr2


; tstr1='20100630_183942'
;tsrt2='20100630_203217'
dt=julday(strmid(tstr2, 4,2), strmid(tstr2, 6,2), strmid(tstr2, 0, 4), $
              strmid(tstr2, 9,2), strmid(tstr2, 11, 2), strmid(tstr2,13, 2)) $
 -julday(strmid(tstr1, 4,2), strmid(tstr1, 6,2), strmid(tstr1, 0, 4), $
              strmid(tstr1, 9,2), strmid(tstr1, 11, 2), strmid(tstr1,13, 2))  ; in day

return, dt
end