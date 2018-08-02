function fiss_spec_sim1, detector, alpha_deg, order,  wv, prof, br, file=file
;+
;     alpha, order: input
;     wv: output
;-
blazeangle_deg=62.
density_mm=79.
sigma_ang=1.d7/density_mm
if detector eq 'A' then begin
nw=512
ny=256
theta_deg=0.93
loadct_ch, /ha
endif
if detector eq 'B' then begin
nw=502
ny=250
theta_deg=1.92
loadct_ch, /ca
endif


wr=fiss_sp_range(alpha_deg, order,detector)
wv0=(wr[0]+wr[1])/2.
wv=wr[0]+(wr[1]-wr[0])/(nw-1)*findgen(nw)
prof=wall2011(wv)
spec=prof#replicate(1, ny)



beta_deg = alpha_deg - theta_deg

b=sigma_ang*(cos(blazeangle_deg*!dtor))

X = !pi*b/wv0*(sin((alpha_deg-blazeangle_deg)*!dtor)+sin((beta_deg - blazeangle_deg)*!dtor))

if x eq 0. then brighteness = 1 else br = (sin(x)/x)^2

window, u, /free, xs=nw+50, ys=ny+60
xoff=30 & yoff=40
tv, bytscl(spec, 0., 1.2), xoff, yoff, xs=nw, ys=ny
plot, [0,1],[0,1],/noerase, /nodata, xr=wr, yr=[0, ny-1], xst=1, yst=5, xtitle='wavelength', $
title='alpha='+string(alpha_deg, format='(f5.2)')+', dectector='+detector, $
pos=[xoff, yoff, xoff+nw-1, yoff+ny-1], /dev

spec_plot=tvrd(tr=1)

wdelete, !d.window
if n_elements(file) eq 1 then write_jpeg, file+'.jpg',  spec_plot, tr=1,  qual=100
return, spec_plot
end