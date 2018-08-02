pro  voigt_model, x,  par, f, pder, amp=amp

amp=par[0]
x0=par[1]
dx = par[2]
a=par[3]
bg=par[4]


u= (x-x0)/dx
if n_params() ge 4 then ch_voigt, a, u, vgt, dis, vgtda, vgtdu else $
ch_voigt, a, u, vgt, dis

f=amp*vgt+bg

if n_params() ge 4 then   $
  pder  = [ [vgt], [amp*vgtdu*(-1./dx)], [amp*vgtdu*(-u/dx)], [amp*vgtda], [x*0+1.]]

end


function voigt_fit, x, y, par, chisq=chisq, sigma=sigma
bg=min(y, max=peak)
s=where(y-bg ge 0.5*(peak-bg))
x0=0.
dx=(max(x[s], min=tmp)-tmp)/1.38
a=0.5
amp=(peak-bg)/voigt(a, 0.)
par=[amp, x0, dx, a, bg]
noise=stdev((y-shift(y,1))[3:n_elements(y)-3])
result=curvefit(x, y, x*0+.1/noise^2, par, sigma, function_name='voigt_model' , chisq=chisq)
return, result
end