; H alpha : 6562.817
; Ca II 8542 : 8542.09
; Na I D2 : 5889.95
; Fe I 5434 : 5434.5235
; He I D3 : 5875.618

pro change_gratwvln, file, wave
  if size(wave, /type) eq 7 then begin
    case wave of 
      'H alpha'    : wv=6562.817
      'Na I D2'    : wv=5889.95
      'He I D3'    : wv=5875.618
;      'Ca II 8542' : wv=8542.09      ;; Camera B --> X
;      'Fe I 5434'  : wv=5434.5235

    endcase
  endif else wv=wave
  for i=0, n_elements(file)-1 do begin
    h=headfits(file[i])
    fxaddpar, h, 'GRATWVLN', wv
    modfits, file[i], 0, h
  endfor  
end

dir=find_all_dir('/data/home/chokh/local/20150619')
f=file_search(dir, '*.fts')
change_gratwvln, f, 5875.618
end
