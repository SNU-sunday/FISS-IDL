pro loadct_ch,  r, g,   ha=ha, ca=ca

if keyword_set(ha) then begin
 r=0.6
 g=0.2
 endif

if keyword_set(ca) then begin
 r=0.2
 g=0.6
 endif

loadct, 3, /sil & tvlct, rr, gr, br, /get
loadct, 1, /sil & tvlct, rb, gb, bb, /get
loadct, 8, /sil & tvlct, rg, gg, bg, /get

tvlct, byte((rr*r+rg*g+rb*(1-r-g))>0<255),  $
   byte((gr*r+gg*g+gb*(1-r-g))>0<255),  $
   byte((br*r+bg*g+bb*(1-r-g))>0<255)
end