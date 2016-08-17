function fiss_wv_line, wv, profile, linecenter,  range=range, npixel=npixel
;+
;
;  Remark:
;           It is implictly assumed that the center of the line of interest
;           is within +- RANGE  from wv=0. If not, the center of the line
;           is outside this range, a properly chosen offset should be
;          subtracted from wv before  it is supplied to this routine as
;          an input.
;-
if n_elements(range) eq 0 then range=0.3
if n_elements(npixel) eq 0 then npixel=5
ss=where( abs(wv) le range)
wc=(where(profile eq min(profile[ss])))[0]
s1=(wc-(npixel/2))>0
s2=(wc+(npixel/2))<(n_elements(wv)-1)
coeff=poly_fit(wv[s1:s2], profile[s1:s2],  2, yfit=yfit, /double)
wvline= -0.5*coeff[1]/coeff[2]
linecenter=poly(wvline, coeff)
return, wvline
end