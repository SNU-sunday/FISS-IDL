function temp_from_width, width_halpha, width_8542, xi


wh = width_halpha/6562.8*3.e10  ; cm/s
wc = width_8542/8542.*3.e10 ; cm/s

vth2 = (wh^2-wc^2)*40./39

t= vth2/(2*1.38e-16)*1.67e-24 ; K
xi =sqrt( wh^2-vth2)/1.e5  ; km/s

return,  t
end
