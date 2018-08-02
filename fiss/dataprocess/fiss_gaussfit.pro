pro fiss_gaussfit, x, y, wvband, yfit, telwave
;+
;
;  Name : fiss_gaussfit
;  
;  Purpose :
;       line-fitting for fiss data -> gauss fitting
;
;  Syntax : fiss_gaussfit, x, y, wvband, yfit, telwave
;
;  Input :
;      x : wavelength (wavelengths - line center)
;      y : line profile
;      wvband : '6562' or '8542' -> Ha or Ca II 8542 line
;
;  Output :
;      yfit : fitting values
;      telwave : wavelength at atm line
;
;  Keywords :
;
;  Required routines : mpfitexpr, GAUSS1
;
;  History
;       2010 Oct, Dong-uk Song
;
;-
   
; Input values for test *********************************
;   x=wv
;   y=p1[*,100]
;********************************************************
   
   sy = sqrt(y)                                    ; Poisson errors
   expr = 'P[0]*X^3+P[1]*X^2+P[2]*X+P[3]+ GAUSS1(X, P[4:6])+GAUSS1(X, P[7:9])+GAUSS1(X, P[10:12])+GAUSS1(X, P[13:15])+GAUSS1(X, P[16:18])'               ; fitting function
   
case strmid(wvband,0,4) of
  '8542': begin
   p0 = [10.d,3.71d0,46.0059d0, 4091.24d0,0.015d0, 1.909d0, -1399.d0,-0.029d0, 0.188d0, -1181.d0,-0.037d0, 0.703d0, -536.d0,-4.214d0, 0.088d0, -89.8277d0,-5.97d0, 0.087d0, -807,965d0]              ;8542
   telwave=8500.d0+ [36.45, 36.68,  39.888,  40.817, 46.2222]-8542.089d0
   end
  '6562': begin
   p0 = [10.d,0.074d0,-14.517d0, 2627.88d0,-0.06d0, 1.00d0, -580.55d0,-0.394d0, 0.264d0, -1019.3d0,0.199d0, 0.307d0, -1123.68d0,-2.336d0, 0.041d0, -354.15d0,-3.281d0,0.039d0,-309.63d0]
   telwave=6500.D0+[64.206, 64.061, 63.521, 62.44, 61.097, 60.555, 59.813, 58.65, 58.149, $
                            65.545, 66.55 ]-6562.817d0
   end
endcase             

   p = mpfitexpr(expr, x, y, sy, p0)               ; Fit the expression
   yfit=P[0]*X^3+P[1]*X^2+P[2]*X+P[3]+ GAUSS1(X, P[4:6])+GAUSS1(X, P[7:9])+GAUSS1(X, P[10:12])+GAUSS1(X, P[13:15])+GAUSS1(X, P[16:18])
   print, p
 
 ; WINDOW PLOT ************************************************************************************************************************
 ;  loadct, 3
 ;  window, 3, xs=1300, ys=1080
 ;  plot, x, y, psym=4, xtitle='wavelength [A]', charsize=2, position=[0.05,0.35,0.95,0.95]
 ;  ;ploterr, x, y, sy                                   ; Plot data
 ;  oplot, x, yfit, color=150, thick=2
   
 ;  for i = 0, n_elements(telwave)-1 do begin                         
 ;     oplot, [telwave[i],telwave[i]],[0,9000], linestyle=1
 ;  endfor 
   
 ;  yy=y-yfit
 ;  plot, x, yy, psym=1, position=[0.05,0.05,0.95,0.25], /noerase, xtitle='wavelength [A]', charsize=2, yrange=[-100,100]
 ;  oplot, [-20,20],[0,0], linestyle=3, color=150
 
 ;  for i = 0, n_elements(telwave)-1 do begin                         
 ;     oplot, [telwave[i],telwave[i]],[-2000,2000], linestyle=1
 ;  endfor 
; *************************************************************************************************************************************   
end