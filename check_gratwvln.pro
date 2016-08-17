pro check_gratwvln, file, grat
  grat=fltarr(n_elements(file))
  for i=0, n_elements(file)-1 do begin
    grat[i]=float(fxpar(headfits(file[i]), 'GRATWVLN'))
  endfor
  window, 0
  plot, grat, yrange=[5d3, 9d3], xstyle=3, thick=3, psym=1, $
        xtitle='File NO.', ytitle='GRATWVLN (Angstrom)'
end