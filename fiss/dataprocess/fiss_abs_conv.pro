function fiss_abs_conv, wl,  prof, band
if  band eq '6562' then factor=1./interpol(prof,wl, 3.)*0.85*2.85e6    ; erg s-1 cm-2 sr-1 A-1
if  band eq '8542' then factor=1./interpol(prof,wl, 3.)*0.85*1.76e6    ; erg s-1 cm-2 sr-1 A-1
return,  factor
end

