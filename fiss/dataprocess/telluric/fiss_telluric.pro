function fiss_tell_lines,  wv

if  abs(median(wv)-6562.8) le 3. then line='H_I_6563'
if abs(median(wv)-8542.) le 8. then line='Ca_II_8542'
case line of
   'H_I_6563':  begin            ; H alpha
wvcen=[64.206, 64.061+0.00, 63.521, 62.44+0.007, 61.097+0.020, 60.555-0.046, 59.813-0.01, 58.65-0.012, 58.149+0.017, $
                            65.545-0.020, 66.55+0.017 ]+6500.D0
wvdop=replicate(0.014, n_elements(wvcen))
adamp=replicate(2.6, n_elements(wvcen))
tau0=[0.29,0.09, 0.09, 0.04, 0.08,0.15,0.015, 0.03,  0.11, $
                               0.033, 0.025  ]
                        end
    'Ca_II_8542': begin
;            wvs=               [36.165,  36.45, 36.68,  38.0152,  38.25,  39.888, 40.817,  42.089,   46.222]+8500.D0
;            ews=                 [58.,        3.,        3.,         31.,        2.,          3.5,        8.,           3670.,   5. ]
;            elms=                ['Si I',      '' ,        '',         'Fe I',     'CN',      'H2O',    'H2O',     'Ca II', 'H2O']
;            ref=                 ['NIST',  'utrecht',  ' ',   'NAVE', 'utrecht',    'utecht', 'NSRD', 'utrecht']
;
           wvcen=8500.d0+ [36.45, 36.68,  39.888,  40.817, 46.2222]+[-0.07, -0.07, -0.06,-0.065, 0.03]
            wvdop=replicate( 0.028, n_elements(wvcen))
            adamp=replicate(2.6, n_elements(wvcen))
            tau0=[0.030, 0.030, 0.06, 0.17,  0.06]
       end
else     : begin
             wvcen=median(wv)
             tau0=0.
             adamp=0.
             wvdop=0.1
            end
 endcase
nline=n_elements(wvcen)
tau=0.
for line=0, nline-1 do begin
u=(wv-wvcen[line])/wvdop[line]
tau=tau+tau0[line]*voigt(adamp[line],u)/voigt(adamp[line],0)
endfor

return, tau
end
pro fiss_tell_model,  wv,  par, f
dwv = par[0]
amp=par[1]
disp=par[2]
f=convol(-amp*fiss_tell_line((wv-median(wv))*disp+median(wv)+dwv), [-1,1])
end

function fiss_tell_rm, wv, sp, par, nofit=nofit
if not keyword_set(nofit) then begin
par=[0., 1.0, 1.0]
y=convol(alog(total(sp,2)/n_elements(sp[0,*])), [-1, 1])
res=curvefit(wv,  y,  fiss_tell_line(wv) ge 0.01, par,  /noderivative, funct='fiss_tell_model')
endif
model=sp*(exp(par[1]*fiss_tell_line((wv-median(wv))*par[2]+median(wv)+par[0]))#replicate(1., n_elements(sp[0,*])))
return, model
end

ha=1
if ha then f=(file_search('E:\BBSO Data\20100723\comp\qr\*A1_c.fts'))[50] else $
f=(file_search('E:\BBSO Data\20100723\comp\qr\*B1_c.fts'))[50]

;a=fiss_sp_av(f, /pca)
wv=fiss_wv(f)
d=fiss_read_frame(f, 50)
if  ha  then wc=6562.817d0  else wc=8542.089d0

;a1=fiss_rm_telluric(wv+wc, a, par)
;d1=d*exp(fiss_telluric(wv+wc)#replicate(1., 250));
d1=fiss_tell_rm(wv+wc, d, par)
print, par
window, 2, xs=512, ys=256*2
;tvscl, rotate(a,5), 0
;tvscl, rotate(a1,5), 1
if ha then begin
tvscl, d, 0
tvscl, d1, 1
endif else begin
tvscl, rotate(d,5),0
tvscl, rotate(d1,5), 1
endelse
end