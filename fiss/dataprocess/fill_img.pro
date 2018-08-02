function fill_img, img, small=small
;+
; Purpose:
;          Fill the blank columns in the image
; Calling sequence:
;
;            New = Fill_Img(Old, small=small)
;  Input:
;            Old    input image
;  Output
;            New     output image
;
;  Keyword input:
;           small      the cutoff value for blank
;                        normlized by the median vaue
;                       (default =0.01)
;
;-
imgn=img
if  n_elements(small) eq 0 then small=0.01
nx=n_elements(img[*,0])
a=fltarr(nx)  & for x=0, nx-1 do a[x]=stdev(img[x,*])
a=a/median(a)

sel=where(a le small, count)
img1=0. & img2=0.
for s=0, count-1 do begin
x=sel[s]

x1=x-1
found1=0
 if x1 ge 0 then  repeat begin
  if a[x1] gt small then begin
  img1=reform(img[x1,*])
  found1=1
endif     else x1=x1-1
 endrep until found1 or ( x1 eq  -1)

x2=x+1
found2=0
if x2 le nx-1 then repeat begin
 if a[x2] gt small then begin
 img2=reform(img[x2,*])
found2=1
 endif else x2=x2+1
 endrep until found2 or (x2 eq  nx)

if  not found1 and found2 then  img1=img2
if not found2 and found1 then  img2=img1

w=(x-x1)/float(x2-x1)
imgn[x,*]=(1.-w)*img1 + w*img2

endfor
return, imgn
end