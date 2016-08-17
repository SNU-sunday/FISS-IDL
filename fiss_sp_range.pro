

function fiss_sp_range, alpha_deg,  order, detector
;+
;
;
;-
      fcol= 1.5  ; FISS collimator forcal length in m
      density_mm=79. ;  FISS grave density
      sigma_ang=1.d7/density_mm
case detector of
'A': begin
      width=512*16.e-6   ;  Detector width  in m
      theta_deg=0.93    ;  Defelction angle
      range=[0.5, -0.5]
     end
'B' : begin
      width=502*16.e-6  ;
      theta_deg=1.92
      range=[-0.5, 0.5]
      end
endcase
      theta_range=theta_deg+range*(width/fcol*!radeg)
      wl_ang=(sigma_ang/order)*(sin(alpha_deg*!dtor)+sin((alpha_deg - theta_range)*!dtor))

return, wl_ang
end





