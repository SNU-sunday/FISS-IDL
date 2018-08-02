pro fiss_ha_conftell, wl, sp, newldif

;+
;   Name : FISS_HA_CONFTELL
;
;   Purpose :
;       Find the empirical values of the telluric lines from spectrogram, in order to remove them
;       For example > 
;         wvcen=8500.d0+ [36.45, 36.68,  39.888,  40.817, 46.2222]+[-0.07, -0.07, -0.06,-0.065, 0.03]
;       => empirical values mean [-0.07, -0.07, -0.06,-0.065, 0.03] above the equation. 
;   
;   Syntax : fiss_comp_tellwl_caii, wv, sp, wcen, wldif
;   
;   Input :
;       wl : wavelengths(center is 0A) + line center(8542)
;       sp : spectrum line
;   
;   Output : 
;       wldif : empirical values of the telluric lines from spectrogram
;
;  Keywords :
;
;  Required routines : fiss_tell_rm_v2, fiss_gaussfit, st_dev
;  
;  History :
;       2010 Oct, Dong-uk Song
;       2010 Nov, Dong-us Song (Modify)
;       
;-


w=fltarr(100)
result=fltarr(100)
nwldif=11

ww=[0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.,0.]

for re=0, 1 do begin

for k=0, nwldif-1 do begin
  if k lt 10 then wlnum=string(k, format='(i1)') else wlnum=string(k, format='(i2)')

  for i = 0, 99 do begin
    w[i]= (double(string(i))/500.)-0.1

   case wlnum of

  '0': begin
    wldif=[w[i],ww[1],ww[2],ww[3],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '1': begin
    wd1=minw
    wldif=[wd1,w[i],ww[2],ww[3],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end
    
  '2': begin
    wd2=minw
    wldif=[wd1,wd2,w[i],ww[3],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '3': begin
    wd3=minw
    wldif=[wd1,wd2,wd3,w[i],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '4': begin
    wd4=minw
    wldif=[wd1,wd2,wd3,wd4,w[i],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '5': begin
    w[i]= (double(string(i))/20000.)-0.0025
    w[i]=-0.067+w[i]
    wd5=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,w[i],ww[6],ww[7],ww[8],ww[9],ww[10]]

    end
    
  '6': begin
    wd6=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,w[i],ww[7],ww[8],ww[9],ww[10]]
    end  
    
  '7': begin
    wd7=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,w[i],ww[8],ww[9],ww[10]]
    end  
    
  '8': begin

    wd8=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,w[i],ww[9],ww[10]]
    end   

  '9': begin
    wd9=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,wd9,w[i],ww[10]]
    end 
    
  '10': begin
    wd10=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,wd9,wd10,w[i]]
    end                 
  endcase
 
  par=[0,1.]
  p=sp
  p1=fiss_tell_rm_v2(wl, p, par, wldif, nofit=0)

   wc = 6562.817d0
   x=wl-wc
   y=p1[*,100]
   wvband='6562'

   ;fiss_gaussfit_v2, x, y, wvband, yfit, telwave       ; 6- gauss
   fiss_gaussfit, x, y, wvband, yfit, telwave         ;original   -5 gauss
   yy=y-yfit
;   mean='0.'
   mean='0.'
   st_dev, yy, mean, sigma

   result[i]=sigma
   endfor

   minw=w[where(result eq min(result))]
   minw=minw[0]   
   print,'result!!! : ', minw, w[where(result eq min(result))], min(result)
   window, 1, xs=1200, ys=800, title=string(k)
   plot, w, result, psym=1, yst=1
endfor
    wd11=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,wd9,wd10,wd11]
print, 'wldif ; ', wldif
nww=wldif
wldif1=wldif

endfor
; End first step ***************************************************************


; Begin second step*************************************************************  ; COMPLETE

w=fltarr(100)
result=fltarr(100)
nwldif=11

ww=wldif1

for k=0, nwldif-1 do begin
  if k lt 10 then wlnum=string(k, format='(i1)') else wlnum=string(k, format='(i2)')

  for i = 0, 99 do begin
    w[i]= (double(string(i))/2000.)-0.025

   case wlnum of

  '0': begin
    w[i]=ww[0]+w[i]
    wldif=[w[i],ww[1],ww[2],ww[3],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '1': begin
    wd1=minw
    w[i]=ww[1]+w[i]
    wldif=[wd1,w[i],ww[2],ww[3],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end
    
  '2': begin
    wd2=minw
    w[i]=ww[2]+w[i]
    wldif=[wd1,wd2,w[i],ww[3],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '3': begin
    wd3=minw
    w[i]=ww[3]+w[i]
    wldif=[wd1,wd2,wd3,w[i],ww[4],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '4': begin
    wd4=minw
    w[i]=ww[4]+w[i]
    wldif=[wd1,wd2,wd3,wd4,w[i],ww[5],ww[6],ww[7],ww[8],ww[9],ww[10]]
    end

  '5': begin
    w[i]= (double(string(i))/40000.)-0.00125
    w[i]=ww[5]+w[i]
    wd5=minw
    wldif=[wd1,wd2,wd3,wd4,wd5,w[i],ww[6],ww[7],ww[8],ww[9],ww[10]]

    end
    
  '6': begin
    wd6=minw
    w[i]=ww[6]+w[i]
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,w[i],ww[7],ww[8],ww[9],ww[10]]
    end  
    
  '7': begin
    wd7=minw
    w[i]=ww[7]+w[i]
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,w[i],ww[8],ww[9],ww[10]]
    end  
    
  '8': begin
    wd8=minw
    w[i]=ww[8]+w[i]
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,w[i],ww[9],ww[10]]
    end   

  '9': begin
    wd9=minw
    w[i]=ww[9]+w[i]
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,wd9,w[i],ww[10]]
    end 
    
  '10': begin
    wd10=minw
    w[i]=ww[10]+w[i]
    wldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,wd9,wd10,w[i]]
    end                 
  endcase
 
  par=[0,1.]
  p=sp
  p1=fiss_tell_rm_v2(wl, p, par, wldif, nofit=0)

   wc = 6562.817d0
   x=wl-wc
   y=p1[*,100]
   wvband='6562'

   ;fiss_gaussfit_v2, x, y, wvband, yfit, telwave       ; 6- gauss
   fiss_gaussfit, x, y, wvband, yfit, telwave         ;original   -5 gauss
   yy=y-yfit
;   mean='0.'
   mean='0.'
   st_dev, yy, mean, sigma

   result[i]=sigma
   endfor

   minw=w[where(result eq min(result))]
   minw=minw[0]   
   print,'result!!! : ', minw, w[where(result eq min(result))], min(result)
   window, 1, xs=1200, ys=800, title=string(k)
   plot, w, result, psym=1, yst=1
endfor
    wd11=minw
    newldif=[wd1,wd2,wd3,wd4,wd5,wd6,wd7,wd8,wd9,wd10,wd11]
print, 'ww ; ', ww
print, 'newldif ; ', newldif
    

end
