function sgn, x
return, 2*(x gt 0) -1.
end
pro  layer_twoline_model,  wl,  par, f, pder, amp=amp
common layer_twoline_com, i_ha, i_ca, nha

wl_ha = wl[0:nha-1]
wl_ca=wl[nha:*]


lambda_ha=6562.8
lambda_ca=8542.
c=3.e5 ; km/s


vlos= par[0]
vth= par[1]
xi=  par[2]
source_ha = abs(par[3])
tau0_ha =   abs(par[4])
tau1_ha =   abs(par[5])
source_ca = abs(par[6])
tau0_ca = abs(par[7])
tau1_ca = abs(par[8])
a_ca    = abs(par[9])

vth1= par[10]
xi1= par[11]

wlc_ha  = vlos/c*lambda_ha
wlc_ca =  vlos/c*lambda_ca
dwld_ha = sqrt(vth^2+xi^2)/c*lambda_ha
dwld_ca = sqrt(vth^2/40.+xi^2)/c*lambda_ca

dwld1_ha = sqrt(vth1^2+xi1^2)/c*lambda_ha
dwld1_ca = sqrt(vth1^2/40.+xi1^2)/c*lambda_ca

; Profiles and partial derivatives of H alpha line

u_ha= (wl_ha-wlc_ha)/dwld_ha
if n_params() ge 4 then $
 ch_voigt, 0., u_ha, h_ha, null, ha_ha, hu_ha else $
ch_voigt, 0, u_ha, h_ha, null

u1_ha=wl_ha/dwld1_ha
if n_params() ge 4 then $
ch_voigt, 0., u1_ha, h1_ha, null, ha1_ha, hu1_ha else $
ch_voigt, 0, u1_ha, h1_ha, null

dtau_ha = tau0_ha*h_ha- tau1_ha*h1_ha
amp_ha = source_ha/i_ha-1.
exptau_ha = exp(-dtau_ha)
f_ha=amp_ha*(1-exptau_ha)

; Profiles and partial derivatives of Ca II line
u_ca= (wl_ca-wlc_ca)/dwld_ca
if n_params() ge 4 then  $
ch_voigt, a_ca, u_ca, h_ca, null, ha_ca, hu_ca else $
ch_voigt, a_ca, u_ca, h_ca, null

u1_ca=wl_ca/dwld1_ca
if n_params() ge 4 then $
ch_voigt, a_ca, u1_ca, h1_ca, null, ha1_ca, hu1_ca else $
ch_voigt, a_ca, u1_ca, h1_ca, null

dtau_ca = tau0_ca*h_ca- tau1_ca*h1_ca
amp_ca = source_ca/i_ca-1.
exptau_ca = exp(-dtau_ca)
f_ca=amp_ca*(1-exptau_ca)

; Functional values
f=[f_ha, f_ca]
;dwld_ha = sqrt(vth^2+xi^2)/c*lambda_ha

if n_params() ge 4 then $
pder= [  $
[amp_ha*exptau_ha*tau0_ha*hu_ha*(-1./dwld_ha/c*lambda_ha), $
 amp_ca*exptau_ca*tau0_ca*hu_ca*(-1./dwld_ca/c*lambda_ca) ], $ ; derviative over vlos
[amp_ha*exptau_ha*(tau0_ha*hu_ha*u_ha-0*tau1_ha* hu1_ha*u1_ha)$ ; derviative over vth
  *(-1/dwld_ha*vth/ sqrt(vth^2+xi^2)/c*lambda_ha), $
 amp_ca*exptau_ca*(tau0_ca*hu_ca*u_ca-0*tau1_ca* hu1_ca*u1_ca) $
 *(-1/dwld_ca*vth/40./ sqrt(vth^2/40.+xi^2)/c*lambda_ca)], $
[amp_ha*exptau_ha*(tau0_ha*hu_ha*u_ha-0*tau1_ha* hu1_ha*u1_ha)$  ; derivative over xi
*(-1/dwld_ha*xi/ sqrt(vth^2+xi^2)/c*lambda_ha), $
 amp_ca*exptau_ca*(tau0_ca*hu_ca*u_ca-0*tau1_ca* hu1_ca*u1_ca)$
 *(-1/dwld_ca*xi/ sqrt(vth^2/40.+xi^2)/c*lambda_ca)], $
[1./i_ha*(1-exptau_ha)*sgn(par[3]),  i_ca*0.], $  ; over Source_ha
[amp_ha*exptau_ha*h_ha*sgn(par[4]), i_ca*0], $     ; tau0_ha
[amp_ha*exptau_ha*(-h1_ha)*sgn(par[5]), i_ca*0], $    ; tau1_ha
[i_ha*0, 1./i_ca*(1-exptau_ca)*sgn(par[6])], $  ; over Source_ha
[i_ha*0, amp_ca*exptau_ca*h_ca*sgn(par[7])], $     ; tau0_ha
[i_ha*0, amp_ca*exptau_ca*(-h1_ca)*sgn(par[8])], $    ; tau1_ha
[i_ha*0, amp_ca*exptau_ca*(tau0_ca*ha_ca-tau1_ca*ha1_ca*sgn(par[9]))] , $
[amp_ha*exptau_ha*(0*tau0_ha*hu_ha*u_ha-tau1_ha* hu1_ha*u1_ha)$ ; derviative over vth1
  *(-1/dwld1_ha*vth1/ sqrt(vth1^2+xi1^2)/c*lambda_ha), $
 amp_ca*exptau_ca*(0*tau0_ca*hu_ca*u_ca-1*tau1_ca* hu1_ca*u1_ca) $
 *(-1/dwld1_ca*vth1/40./ sqrt(vth1^2/40.+xi1^2)/c*lambda_ca)], $
[amp_ha*exptau_ha*(0*tau0_ha*hu_ha*u_ha-1*tau1_ha* hu1_ha*u1_ha)$  ; derivative over xi
*(-1/dwld1_ha*xi1/ sqrt(vth1^2+xi1^2)/c*lambda_ha), $
 amp_ca*exptau_ca*(0*tau0_ca*hu_ca*u_ca-1*tau1_ca* hu1_ca*u1_ca)$
 *(-1/dwld1_ca*xi1/ sqrt(vth1^2/40.+xi1^2)/c*lambda_ca)] ]


end


pro layer_twoline_fit, wl_ha, prof_ha, ref_ha, $
 wl_ca, prof_ca, ref_ca, par, sigma, hafit=hafit, cafit=cafit, ca_weight=ca_weight

common layer_twoline_com, i_ha, i_ca, nha
if n_elements(ca_weight) eq 0 then ca_weight=2.

nha=n_elements(wl_ha)

i_ha=ref_ha
i_ca=ref_ca

s=where(abs(wl_ha) le 0.1)
coeff=poly_fit(wl_ha[s], ref_ha[s], 2)
wl0_ha=-0.5*coeff[1]/coeff[2]
s=where(abs(wl_ca) le 0.1)
coeff=poly_fit(wl_ca[s], ref_ca[s], 2)
wl0_ca=-0.5*coeff[1]/coeff[2]
wl1_ha=wl_ha-wl0_ha
wl1_ca=wl_ca-wl0_ca


npar=12
par=fltarr(npar)

vlos=(wl1_ha[(where(prof_ha eq min(prof_ha)))[0]]/6563.*3.e5 + $
      wl1_ca[(where(prof_ca eq min(prof_ca)))[0]]/8542.*3.e5)/2.
par[0]=vlos
temp=0.8e4
vth=sqrt(temp*(2*1.38e-16/1.67e-24))/1.e5 ; km/s
par[1]=vth
xi=6.0  ; km/s
par[2]=xi

Source_ha = min(ref_ha)
par[3]=source_ha
tau0_ha = 1.0
tau1_ha = 1.0
par[4]=tau0_ha
par[5]=tau1_ha


source_ca = min(ref_ca)
par[6] = source_ca
tau0_ca = 0.5
par[7] = tau0_ca
tau1_ca = 0.5
par[8] = tau1_ca
a_ca    = 0.5
par[9] =  a_ca

par[10]=10.
par[11]=3.

x=[wl1_ha, wl1_ca]
y=[prof_ha/ref_ha-1.,  prof_ca/ref_ca-1.]
ny=n_elements(y)

noise_ha=stdev(y[1:nha-3]-y[2:nha-2])/1.414
noise_ca=stdev(y[nha+1:ny-3]-y[nha+2:ny-2])/1.414
weight=[replicate(1./noise_ha^1, nha), ca_weight*replicate(1./noise_ca^1, ny-nha)]
result=curvefit(x, y,weight, par, sigma,function_name='layer_twoline_model' )
hafit=result[0:nha-1]
cafit=result[nha:*]

par[3:9]=abs(par[3:9])

end