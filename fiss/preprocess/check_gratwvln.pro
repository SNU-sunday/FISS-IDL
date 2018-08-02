pro check_gratwvln, file, grat, plot=plot
  if ~keyword_set(plot) then plot=0
  grat=fltarr(n_elements(file))
  for i=0, n_elements(file)-1 do begin
    grat[i]=float(fxpar(headfits(file[i]), 'GRATWVLN'))
  endfor
  if plot then begin 
    window, 0
    plot, grat, yrange=[5d3, 9d3], xstyle=3, thick=3, psym=1, $
          xtitle='File NO.', ytitle='GRATWVLN (Angstrom)'
  endif          
end