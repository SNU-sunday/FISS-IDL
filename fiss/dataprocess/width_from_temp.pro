function width_from_temp, t, xi, line=line

;
;   assumptions:
;       *  H alpha abosorbing plasma and Ca II 8542 observing plasma have the same temperature.
;       * The ratio of Ca II microturbulence to H alpha one is given by vratio.
;

if n_elements(vratio) eq 0 then vratio=1.

kb=1.38e-16
mh=1.67e-24
c=3.e10
if line eq 'ha' then begin
A=1.
lambda=6562.8
endif

if line eq 'ca' then begin
A=40.
lambda=8542.
endif

width=sqrt(2*kb*T/(mh*A)+(xi*1.e5)^2)/c*lambda
return,  width
end
