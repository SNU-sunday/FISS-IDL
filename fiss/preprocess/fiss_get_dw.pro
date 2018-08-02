function fiss_get_dw, sp, ref, wr=wr
;+
;   Name: fiss_get_dw
;          determies the horizonal shift of a spectral line as a function
;          of position along the slit.
;
;   Syntax:  Result = fiss_get_dw(sp, ref, wr=wr)
;
;   Returned values:
;               an array of horizontal shift values
;   Arguments:
;            sp    spectrogram to be examined
;            ref   reference profil
;
;   Keywords:
;            wr    can be set to a named variable that contains a two-element array.
;                  indicating the range of horizontal pixels to be used for comparison
;   Remarks:
;
;   Required routines: alignoffset
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-
nw=n_elements(sp[*,0])
ny=n_elements(sp[0,*])
if n_elements(wr) ne 2 then wr=[0, nw-1]
w1=wr[0]
w2=wr[1]
dw = fltarr(ny)
ker=[-1., 8., 1., -16., 1., 8., -1.]/24.
sp1=convol(sp, ker)
ref0=convol(ref, ker)# replicate(1., 3)
for jj=0, ny-1 do begin
s=alignoffset(sp1[*,jj]#replicate(1.,3), ref0)
dw[jj]=s[0]
endfor
return, dw
end
