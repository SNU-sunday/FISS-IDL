function fiss_cont_correct, profile, wl, offset

a=interpol(smooth(profile,5), wl, offset)
b=interpol(smooth(profile,5), wl,-offset)
cor=1./(1+(a-b)/(0.5*(a+b))/(2*offset)*wl)

return, profile*cor
end
