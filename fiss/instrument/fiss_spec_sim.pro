function fiss_spec_sim, detector, wv0, alpha, order, wv, prof

if detector eq 'A' then begin
get_echelle_grating, 79, 62., 0.93, wv0, order, alpha, br
nw=512
ny=256
endif
if detector eq 'B' then begin
get_echelle_grating, 79, 62., 1.92, wv0, order, alpha, br
nw=502
ny=250
endif


wr=fiss_sp_range(alpha, order,detector)

wv=wr[0]+(wr[1]-wr[0])/(nw-1)*findgen(nw)
prof=wall2011(wv)
spec=prof#replicate(1, ny)

return, spec
end