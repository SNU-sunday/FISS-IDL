function sgn, x
return, 2*(x gt 0) -1.
end
pro  layer_model,  wl,  par, f, pder, amp=amp

common cloud_model_com, i_in, npar, dwldr
source = abs(par[0])
tau0=abs(par[1])
dwl = par[2]
dwld = abs(par[3])
tau1=  abs(par[4])
a= abs(par[5])
u= (wl-dwl)/dwld

if n_params() ge 4 then ch_voigt, a, u, vgt, dis, vgtda, vgtdu else $
ch_voigt, a, u, vgt, dis

ur=wl/dwld
if n_params() ge 4 then ch_voigt, a, ur, vgtr, disr, vgtdar, vgtdur else $
ch_voigt, a, ur, vgtr, disr

tau = tau0*vgt
taur = tau1*vgtr
dtau = tau- taur
amp = source/i_in-1.
exptau = exp(-dtau)

f=amp*(1-exptau)

if n_params() ge 4  then  $
  pder  = [ $
  [(1-exptau)/i_in*sgn(par[0])], $  ; derivative over S
  [ amp*exptau*vgt*sgn(par[1])], $  ; derivative over tau0
  [ amp*exptau*tau0*vgtdu*(-1./dwld)], $    ; derviatiev over dwl
  [amp*exptau*(tau0*vgtdu*(-u/dwld)-1*tau1*vgtdur*(-ur/dwld))*sgn(par[3])] , $   ; derviative over dwld
  [amp*exptau*(-vgtr)*sgn(par[4])]  , $ ; derviative over tau1
  [amp*exptau*(tau0*vgtda-tau1*vgtdar)*sgn(par[5])] ] ; derviative over a
;  else $ ; derivative over a
;  pder  = [ $
;  [(1-exptau)/i_in*(2*(par[0] gt 0)-1)], $
;  [ amp*exptau*vgt*(2*(par[1] gt 0 )-1)], $
;  [ amp*exptau*tau0*vgtdu*(-1./dwld)], $
;  [amp*exptau*tau0*vgtdu*(-(wl-dwl)/dwld^2)*(2*(par[3] gt 0)-1)]]

end


function layer_model_fit, wl, contrast, ref, par, sigma,  line=line

common cloud_model_com, i_in, npar, dwldr

if line eq 'H alpha' then dwldr=line_width(8000., 5., 1., 6563.)
if line eq 'CaII 8542' then dwldr= line_width(8000., 5., 40., 8542.)
;print, line, dwldr
i_in = ref

s=where(abs(wl) le 0.1)
coeff=poly_fit(wl[s], ref[s],2)
wl0=-coeff[1]/(2*coeff[2])


;if keyword_set(gaussian) then npar=4 else npar=5
npar=6

par=fltarr(npar)
source= 1.*min(ref)
s=(where(contrast eq min(contrast)))[0]
dwl=   wl[s]-wl0
dtau=  alog(1./(1-contrast[s]/(source/ref[s]-1.)))
dwld=0.3
tau1=0.5
a=1.0
tau0=dtau+tau1
par[0]=source
par[1]=tau0
par[2]=dwl
par[3]=dwld
par[4]=tau1
par[5]=a
noise=stdev((contrast-shift(contrast,1))[10:n_elements(contrast)-10])
result=curvefit(wl-wl0, contrast, wl*0+.1/noise^2, par, sigma, function_name='layer_model' )
par[[0,1,3,4]]=abs(par[[0,1,3,4]])
return, result
end