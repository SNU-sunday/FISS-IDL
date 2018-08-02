pro get_echelle_grating, density_mm, blazeangle_deg, theta_deg, wl_ang, order, alpha_deg, brightness
;+
;
;    Name: get_echelle_grating
;    Purpose:
;         Determine the parameters of an Echelle grating
;    Calling Sequence:
;       get_echelle_grating, density_mm, blazeangle_deg, theta_deg, wl_ang, order, alpha_deg, brightness
;
;    Inputs:
;        density_mm         # of grooves per mm
;        blazeangle_deg     blaze angle
;        theta_deg          deflection angle (angle between incidence and reflection)
;        wl_ang             wavelength of light in Angstrom
;    Outputs:
;        order              the order of peak brightness
;        alpha_deg          incidence angle
;        brightness         relative brightness
;
;-
sigma_ang=1.d7/density_mm
tmp = (2*sigma_ang*sin(blazeangle_deg*!dtor)/wl_ang)

ordera=round(tmp)+[-2,-1,0,1,2]
alpha_dega=fltarr(5)
brightnessa=fltarr(5)
for run=0, 4 do begin
order=ordera[run]
alpha =blazeangle_deg*!dtor

for iter=0, 10 do begin
f = (sin(alpha)+sin(alpha - theta_deg*!dtor))- order*wl_ang/sigma_ang
df  = (cos(alpha)+cos(alpha - theta_deg*!dtor))
alpha = alpha - f/df
endfor


alpha_deg=alpha/!dtor

beta_deg = alpha_deg - theta_deg

beta_bl_deg =  2*blazeangle_deg -alpha_deg

wl_bl_ang = sigma_ang*(sin(alpha)+sin(beta_bl_deg*!dtor))/order

b=sigma_ang*(cos(blazeangle_deg*!dtor))

X = !pi*b/wl_ang*(sin(alpha-blazeangle_deg*!dtor)+sin((beta_deg - blazeangle_deg)*!dtor))

if x eq 0. then brighteness = 1 else brightness = (sin(x)/x)^2

alpha_dega[run]=alpha_deg
brightnessa[run]=brightness
endfor

r=(where(brightnessa eq max(brightnessa)))[0]
;r1=(r-1)>0 & r2=(r+1)<4
order=ordera[r]
alpha_deg=alpha_dega[r]
brightness=brightnessa[r]

end

