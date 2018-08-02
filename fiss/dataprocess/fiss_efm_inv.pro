function fiss_efm_inv, band, file, ref_arch_file, x1, x2, y1, y2, slength, wl, I_out, I_out_av, I_mod, I_in

 apar=fltarr(12, x2-x1+1, y2-y1+1)
 restore, ref_arch_file
wv1=fiss_wv(file)
if band eq '6562' then hwidth=0.5 else hwidth=0.2
for x=x1,x2 do begin
if x eq x1 then begin
da1=fiss_read_frame(file, x-1)
da=fiss_read_frame(file, x)
endif
da2=fiss_read_frame(file, x+1)
 for y=y1, y2 do   begin
wl=wv[sel]
case slength of
    1:I_out1=da[*,y]
    2: I_out1= total(da[*, y:y+1]+da2[*,y:y+1], 2)/4.
    3: I_out1= total(da1[*,y-1:y+1]+ da[*, y-1:y+1]+da2[*,y-1:y+1], 2)/9.
  endcase
  I_out1=interpol(I_out1, wv1, wv)

select_reference, I_out1, refdata, sigdata, i1, i2, ref, sig

;plot,wv, I_out1, thick=2, xr=[-2,2]
;8oplot, wv, ref
;stop
I_out_av= ref[sel]
I_out=I_out1[sel]

    ss=where(abs(wl) ge 0.5*max(abs(wl))  )
    I_out_av=I_out_av*median((I_out/I_out_av)[ss])

; emb_av_model, wv[sel], ref[sel], sig[sel],  G_mod, pars_G, band=band
   if band eq '6562' then  pars_G[2]=0.12 else pars_G[2]=0.06
 fixindex = [5,7]  &  fixvalue=pars_G[[0,2]]

emb_pca_fit, par_data,  evec, edata, wl,  I_out/I_out_av-1., I_out_av,  par, yy, band=band
pars=par
pars=fltarr(9)
pars[0:4]=par
pars[5:7]=pars_G[0:2]
wlb=bisector_d(wl, I_out, hwidth, spv)
emb_fea_model, wl,  I_out,  I_out_av,     I_mod,     pars,  I_in, $
       band=band,  fixvalue=fixvalue, fixindex=fixindex, parguess=1
  apar[0:8, x-x1,y-y1]=pars
  apar[9, x-x1, y-y1]= wlb
  sc=where(abs(wv-0.) le 3*abs(wv[1]-wv[0]), count)
  apar[10, x-x1, y-y1]=total(I_out1(sc))/count  ; line center
   sc=where(abs(wv+4.) le 3*abs(wv[1]-wv[0]), count)
  apar[11,x-x1,y-y1]=total(I_out1(sc))/count  ; continuum
endfor
da1=da
da=da2
endfor

return, apar
end