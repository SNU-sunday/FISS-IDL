function line_width, temperature, xi, amass, wavelength

;  xi: in km/s
;  Temperature  in K
;  amass : in unit of hydrogen mass
;  wavelength : angstrom


return, sqrt((xi*1.e5)^2+ (2*1.38e-16)/(amass*1.67e-24)*temperature)/3.e10*wavelength

end