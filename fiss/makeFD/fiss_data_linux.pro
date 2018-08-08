function fiss_group_linux, files

nf=n_elements(files)


wv=fltarr(nf)
xpos=fltarr(nf)
ypos=fltarr(nf)
t=fltarr(nf)
index=indgen(nf)
for k=0, nf-1 do begin
tstring= strmid(files[k],  strpos(files[k], 'FISS_')+5, 15)
if k eq 0 then tstringref=tstring
t[k]=fiss_dt(tstringref, tstring)*(24*60.)  ; in min
h=fxpar(headfits(files[k]), 'COMMENT')
wv[k]=fxpar(h, 'CRVAL1')
xpos[k]=fxpar(h, 'TEL_XPOS')
ypos[k]=fxpar(h, 'TEL_YPOS')
endfor


group=0

s1=0

rep=0
while (s1 le nf-1) and (rep le nf-1) do begin
s=where(index ge s1 and abs(wv-wv[s1]) le 1. and $
   abs(xpos-xpos[s1]) le 50. and abs(ypos-ypos[s1]) le 50., count)

if count gt 0 then begin
if s1 eq 0 then sindex=s1 else sindex=[sindex, s1]
endif

s1=max(s)+1
rep=rep+1
endwhile

sindex=[sindex, nf]

return, sindex

end

function fiss_raster_contrast_linux, image
s=size(image)
contrast=fltarr(s[1])
for x=0, s[1]-1 do contrast[x]=stdev(image[x,*], m)/m
return, mean(contrast)
end
pro plot_movies_linux,  id, ids_a, scale_a, ids_b, scale_b


a=readfits(id+'A.fts')
b=readfits(id+'B.fts')
maska=readfits(id+'Amask.fts')
maskb=readfits(id+'Bmask.fts')

t=readfits(id+'t.fts')

sz=size(a)  &  npa=sz[1] & nx=sz[2] & ny=sz[3] & nk=sz[4]
sz=size(b)  &  npb=sz[1]

gap=1
label=20

np=(npa+npb)/2

wxsize=np*(nx+2*gap)
wysize=2*(ny+label+2*gap)+label

wxsize=wxsize+(wxsize mod 2)
wysize=wysize+(wysize mod 2)
window, /free, xsize=wxsize, ysize=wysize

ma=fltarr(npa)
for p=0, npa-1 do  if (p eq 0) or (p mod 2 eq 1) then begin

tmp=a[p,*,*,*]
m=median(tmp)
for rep=0, 3 do begin
s=where(tmp ge m)
tmp=tmp[s]
m=median(tmp)
 endfor
ma[p]=m
endif else ma[p]=median(a[p,*,*,*])

mb=fltarr(npb)
for p=0, npb-1 do  if (p eq 0) or (p mod 2 eq 1) then begin
tmp=b[p,*,*,*]
m=median(tmp)
for rep=0, 3 do begin
s=where(tmp ge m)
tmp=tmp[s]
m=median(tmp)
 endfor
mb[p]=m
endif else mb[p]=median(b[p,*,*,*])


imagefiles='imagetmp'+strtrim(string(indgen(nk),f='(i03)'),2)+'.jpg'
for k=0, nk-1 do begin
erase
loadct, 0, /sil
xyouts,wxsize/2, wysize-label+2,  $
't='+string(t[k], format='(f5.1)')+' min', font=0 , align=0.5, /dev
xyouts,10, wysize-label+2, id, font=0 , align=0.0, /dev

for p=0, npa-1 do begin
xoff=(nx+2*gap)*p+gap
if p le np then yoff=(ny+label+2*gap)*1+gap+label $
else yoff=(ny+label+2*gap)*0+gap+label
if (p eq 0) or (p mod 2 eq 1) then begin
loadct_ch, /ha

tmp=alog(a[p,*,*,k]/ma[p]>0.1)
s=where(maska[*,*,k] eq 0)
tmp[s]=0.
tv, bytscl(tmp, alog(1+scale_a[0,p]), alog(1+scale_a[1,p])), xoff, yoff
str=''
endif else begin
loadct, 33, /sil
tmp=reform(a[p,*,*,k])
s=where(maska[*,*,k] eq 1)
;tmp1=tmp-ma[p] ;median(tmp[s])
tmp1=tmp-median(tmp[s])
s=where(maska[*,*,k] eq 0)
tmp1[s]=0.
tv, bytscl(tmp1, scale_a[0,p], scale_a[1,p]), xoff, yoff
str=' '+string(scale_a[1,p],format='(f3.1)')+'km/s'
endelse
loadct, 0,/sil
xyouts, xoff+nx/2,   yoff-label+2, align=0.5, ids_a[p]+str, /dev, font=0

endfor




for p=0, npb-1 do begin
xoff=(nx+2*gap)*p+gap
if p lt np then begin
yoff=(ny+label+2*gap)*0+gap+label
endif else begin
yoff=(ny+label+2*gap)*1+gap+label
xoff=(nx+2*gap)*(p-1)+gap
endelse
if (p eq 0) or (p mod 2 eq 1) then begin
loadct_ch, /ca
tmp=alog(b[p,*,*,k]/mb[p]>0.1)
s=where(maskb[*,*,k] eq 0)
tmp[s]=0.

tv, bytscl(tmp, alog(1+scale_b[0,p]), alog(1+scale_b[1,p])), xoff, yoff
str=''
endif else begin
loadct, 33, /sil
tmp=reform(b[p, *,*,k])
s=where(maskb[*,*,k] eq 1)
;tmp1=tmp-mb[p] ;median(tmp[s])
tmp1=tmp-median(tmp[s])
s=where(maskb[*,*,k] eq 0)
tmp1[s]=0.
tv, bytscl(tmp1, scale_b[0,p], scale_b[1,p]), xoff, yoff
str=' '+string(scale_b[1,p],format='(f3.1)')+'km/s

endelse
loadct, 0,/sil
xyouts, xoff+nx/2,   yoff-label+2, align=0.5, ids_b[p]+str, /dev, font=0
endfor

wait, 0.1
write_jpeg, imagefiles[k], tvrd(tr=1), tr=1, qual=100

endfor

ffmpeg, imagefiles, 10, output=id+'.mp4'

wait, 1
spawn, 'rm -rf imagetmp*.jpg'
end
pro fmargin_linux, align, nx, ny, xmargin, ymargin

x2=nx-1-align.dx-nx/2
x1=0-align.dx-nx/2
y2=ny-1-align.dy-ny/2
y1=0-align.dy-ny/2

a=align.theta+atan(y1, x1)
r=sqrt(x1^2+y1^2)
xx1=r*cos(a)
yy1=r*sin(a)

a=align.theta+atan(y2, x1)
r=sqrt(x1^2+y2^2)
xx2=r*cos(a)
yy2=r*sin(a)

a=align.theta+atan(y1, x2)
r=sqrt(x2^2+y1^2)
xx3=r*cos(a)
yy3=r*sin(a)

a=align.theta+atan(y2, x2)
r=sqrt(x2^2+y2^2)
xx4=r*cos(a)
yy4=r*sin(a)

xmax=max(xx1)>max(xx2)>max(xx3)>max(xx4)
xmin=min(xx1)<min(xx2)<min(xx3)<min(xx4)
ymax=max(yy1)>max(yy2)>max(yy3)>max(yy4)
ymin=min(yy1)<min(yy2)<min(yy3)<min(yy4)
xmargin=round([xmin+nx/2, xmax-nx/2])
ymargin=round([ymin+ny/2, ymax-ny/2])
end
function fiss_find_best_linux, files, wv, hw
nf=n_elements(files)
contrast=fltarr(nf)
for k=0, nf-1 do begin
image=fiss_raster(files[k], wv, hw)
contrast[k]=fiss_raster_contrast_linux(image)
endfor
kref=(where(contrast eq max(contrast)))[0]
return, kref
end

pro plot_sel_align_linux, id,  aligna, im, ha, hb
set_plot, 'ps'
plot_style
device, file=id+'rep.ps', xoff=2, yoff=2, xs=16, ys=12, bits=8, /color
!p.multi=[0,2,2]
nsel=n_elements(aligna.sel)
plot, aligna.sel[0:nsel-2]+0.5, (aligna.dt[1:nsel-1]-aligna.dt[0:nsel-2])*60, title=id, $
   yr=[0, 60], yst=1, psym=1,syms=0.5, xtitle='File No', ytitle='Interval (s)'
     oplot, aligna.kref+[0,0], [-10, 100], linest=3, thick=1
plot, aligna.sel, aligna.cor, yr=[0.8, 1.05], xtitle='File No', ytitle='Correlation'
          oplot, aligna.kref+[0,0], [0, 2], linest=3, thick=1
plot, aligna.sel, aligna.dx, xtitle='File No', ytitle='Dx(A)'
   oplot, aligna.kref+[0,0], [-10, 10], linest=3, thick=1
plot, aligna.sel, aligna.dy, xtitle='File No', ytitle='Dy(A)'
     oplot, aligna.kref+[0,0], [-10, 10], linest=3, thick=1

xyouts, /dev, 5*1000,  25*1000, 'Observation Summary', size=2., font=1
xyouts, /dev, 5*1000,  24.*1000,'Camera A: '+ fxpar(ha, 'WAVELEN')+', Camera B: ' $
         +fxpar(hb, 'WAVELEN'), size=1.5, font=1
xoff=1.
yoff=13.
sz=size(im)
ysize=8.
xsize=ysize/sz[3]*sz[2]
print, sz
tv, im, xoff, yoff, /cen, xsize=xsize, ysize=ysize, true=1

;plot, /noerase, pos=[xoff, yoff, xoff+xsize, yoff+ysize]*1000., /dev, $
;   xr=[0, sz[1]-1], yr=[0, sz[2]-1], xst=1, yst=1, xtitle='X', ytitle='Y', $
 ;    [0,1], [0,1], /nodata
plots, (xoff+[0,xsize])*1000, (yoff+[0, ysize])*1000, /dev, psym=1
xyouts, (xoff+[0,xsize])*1000, (yoff+[-0.5, ysize+0.5])*1000, align=0.5, $
['(0,0)', '('+string(sz[2],format='(i3)')+','+string(sz[3],format='(i3)')+')'], font=1, /dev

device, /close
set_plot, 'x'

end




pro fiss_data_linux, fa, fb, out_dir, aligna, alignb
t1=systime(/sec)
 cor_crit=0.6
 rno=5
cd, out_dir
set_plot, 'x'
;
;
;
prepare=1
do_align=1

; step:  prepare file list
if prepare then begin
print, 'Peparing...'
wait, 0.1
 nfa=n_elements(fa)
 nfb=n_elements(fb)
 ha=fxpar(headfits(fa[nfa/2]), 'comment')
 hb=fxpar(headfits(fb[nfb/2]), 'comment')
 wva=fxpar(ha, 'CRVAL1')
 wvb=fxpar(hb, 'CRVAL1')
 nya=fxpar(ha, 'NAXIS2')
 nyb=fxpar(hb, 'NAXIS2')
 nx=fxpar(ha, 'NAXIS3')
 bandA=strmid(fxpar(ha, 'WAVELEN'), 0, 6)
 bandB=strmid(fxpar(hb, 'WAVELEN'), 0, 6)


if  abs(wva-5890) le 2  then wvcona=5892.
if  abs(wvb-5435) le 2 then wvconb= 5432.
if  abs(wva-6563) le 2 then wvcona=-3.+wva
if  abs(wvb-8542) le 2 then wvconb=-3.+wvb

print, wvb, wva
hwcont=0.2

if abs(wva-5890) le 2  then begin
      cpar_a=[string(wvcona, format='(i4)')+' Continuum', $
       'Na I 5890+-0.07 Intensity', 'Na I 5890+-0.07 Velocity (km/s)', $
            'Fe I 5893+-0.05 Intensity', 'Fe I 5893+-0.05 Velocity (km/s)'  ]
      ids_a=['Cont', 'NaI5890I','NaI5890V', 'FeI5893I', 'FeI5893V']
      wr_a=[[5890.-1,5890.+1],[5892.7-0.5,5892.7+0.5]]
      hw_a=[0.07, 0.05]
      npar_a=n_elements(cpar_a)
      nv_a=(npar_a-1)/2
      scale_a=[[-0.5, 0.15], [-.5, 0.2], [-1., 1.],  [-0.4, 0.1], [-0.5, 0.5]]
       wvrest_a=[5889.973D, 5892.70D]
       calib_a=[0, 0]
      ;wvtella=5891.64
endif

if abs(wva-6563) le 2  then begin
      cpar_a=[string(wvcona, format='(i4)')+' Continnum', $
       'H I 6562.8+-0.20 Intensity', 'H I 6562.8+-0.20 Velocity(km/s)', $
            'Ti II 6560+-0.05 Intensity', 'Ti II 6560+-005 Velocity (km/s)'  ]
      ids_a=['Cont', 'HI6563I','HI6563V', 'TiII6560I', 'TiII6560V']
      wr_a=[[6562.8-1.5,6562.8+1.5],[6559.58-0.4,6559.58+0.4]]
      hw_a=[0.2, 0.05]
      npar_a=n_elements(cpar_a)
      nv_a=(npar_a-1)/2
      scale_a=[[-0.5, 0.1], [-0.5, 0.3], [-5, 5],  [-0.5, 0.1], [-1, 1]]
      wvrest_a=[6562.817D, 6559.58D]
      calib_a=[0,0]
      ;wvtella= 6563.521
endif

if abs(wvb-5435) le 2  then begin
      cpar_b=[string(wvconb, format='(i4)')+' Continnum', $
        'Fe I 5434.5+-0.03 Intensity', 'Fe I 5434.5+-0.03 Velocity (km/s)', $
            'Ni I 5434.9+-0.03 Intensity', 'Ni I 5435.9+-0.03 Velocity (km/s)'  ]
      ids_b=['FeICont', 'FeI5435I', 'FeI5435V', 'NiI5436I', 'NiI5436V']
      wr_b=[ [5434.5-0.3,5434.5+0.3],[5435.9-0.2,5435.9+0.2]]
      hw_b=[ 0.05, 0.05]
      npar_b=n_elements(cpar_b)
      nv_b=(npar_b-1)/2
      scale_b=[[-0.5, 0.15], [-0.5, 0.15], [-0.5, 0.5], [-0.5, 0.11], [-0.5, 0.5]]
      wvrest_b=[5434.534D,  5435.866D0]
      calib_b=[0,0]
      ;wvtellb=5435.546
endif


if abs(wvb-8542) le 2  then begin
      cpar_b=[string(wvconb, format='(i4)')+' Continnum', $
        'Ca II 8542+-0.1 Intensity', 'Ca II 8542+-0.1 Velocity (km/s)', $
             'Si I 8536+-0.10 Intensity', 'Si I 8536+-0.10 Velocity (km/s)'  ]
      ids_b=['Cont', 'CaII8542I','CaII8542V', 'SiI8536I', 'SiI8536V']
      wvrest_b=[8542.09D, 8536.165D]
      wr_b=[ [wvrest_b[0]-0.5,wvrest_b[0]+0.5], $
            [wvrest_b[1]-0.4, wvrest_b[1]+0.4]]
      hw_b=[ 0.12, 0.10]
      npar_b=n_elements(cpar_b)
      nv_b=(npar_b-1)/2
      scale_b=[[-0.6, 0.15], [-0.6, 0.3], [-5, 5.], [-0.5, 0.1], [-1.,1.]]
       calib_b=[0,0]
      ;wvtellb= 8540.817
endif



;  step select the reference file

print, wvcona


k0=(nfa/2-5)>0
kref=fiss_find_best_linux(fa[k0:k0+10],wvcona, hwcont)+k0


id=strmid(file_break(fa[kref]), 0, 20)
id='FD'+strmid(id, 5, 15)



imagea=fiss_raster(fa[kref], [wvcona, mean(wr_a[*,0])], [hwcont, hw_a[0]])
imageb=fiss_raster(fb[kref], [wvconb, mean(wr_b[*,0])], [hwcont, hw_b[0]])

window, 3,  xsize=nx*4, ysize=nya+20, title='Reference Images'
loadct_ch, /ha
tv, replicate(255B, nx*4, nya+20)
tv, bytscl(alog(imagea[*,*,1]/median(imagea[*,*,1])), alog(1+scale_a[0,1]), $
alog(1+scale_a[1,1])), 0,20
tv, bytscl(alog(imagea[*,*,0]/median(imagea[*,*,0])), alog(1+scale_a[0,0]), $
alog(1+ scale_a[1,0]) ), nx,20
loadct_ch, /ca
tv, bytscl(alog(imageb[*,*,0]/median(imageb[*,*,0])), alog(1+scale_b[0,0]), $
alog(1+ scale_b[1,0])), 2*nx,20
tv, bytscl(alog(imageb[*,*,1]/median(imageb[*,*,1])), alog(1+scale_b[0,1]), $
alog(1+ scale_b[1,1])), 3*nx,20
xyouts, nx*[0.5, 1.5, 2.5, 3.5], 5, color=0, /dev, $
[bandA+' line', bandA+string(wvcona, format='(f4.1)'), $
bandB+string(wvconb,format='(f4.1)'), bandB+' line'],align=0.5

im=tvrd( tru=1)

endif


; step: prepare the list of useful files with the image alignment information and

if do_align then begin
print, 'Aligning...'
wait, 0.1
 ny=nya<nyb
 sh=alignoffset(imagea[*, 0:ny-1,0], imageb[*,0:ny-1,0], cor)
 xoffset=sh[0] & yoffset=sh[1]
 print, cor, sh

 fiss_data_align_check, fa, kref, align, sel=sel, wvref=wvcona, cor_crit=cor_crit
 save, file=id+'aligna.sav', align
 aligna=align
 alignb=align
 alignb.files=fb
 alignb.dx = align.dx - xoffset
 alignb.dy = align.dy - yoffset
 align=alignb
 save, file=id+'alignb.sav', align

 plot_sel_align_linux, id,  aligna, im, ha, hb

endif else begin

endelse
; step: Processing Dector A data



lambdameter=1
if lambdameter then begin
print, 'starting lambdameter in A...' & wait, 0.1
restore, id+'aligna.sav'
;restore, 'FD'+strmid(id, 5, 14)+'_alignb.sav'
aligna=align
   f=aligna.files[aligna.sel]
   nk=n_elements(f)
   sp0=total(fiss_sp_av(align.files[align.kref]),2)/nya

  pars=fltarr(npar_a,nx,nya,nk)
  for k=0, nk-1 do begin
    print, 'nk-1-k=', nk-1-k
  if k mod 10 eq 0  then wait, 0.1

  pars[0,*,*,k]=fiss_raster(f[k], wvcona, hwcont, 0, nx-1, 0, nya-1)
  tmp=fiss_lambdameter(f[k], wr_a, hw_a, 0, nx-1, 0, nya-1,sp0=sp0, smoo=1, wv0=wva)

  for line=0, nv_a-1 do begin
   pars[line*2+1,*,*,k]=tmp[0:nx-1,*,1,line]
   pars[line*2+2,*,*,k]=tmp[0:nx-1,*,0,line]
  endfor
  endfor
   save, pars, file='pars.sav'
endif
;
correct=1
if correct then begin
print, 'starting data-correcting...' & wait, 0.1
   restore, 'pars.sav'
   fmargin_linux, aligna, nx, nya, xmargin, ymargin
   pars_a=fltarr(npar_a, nx+xmargin[1]-xmargin[0], nya+ymargin[1]-ymargin[0],nk)
   wvav=fltarr(nv_a)
   ;wvoffs=fltarr(nv_a,nx, nk)

   tmp=reform(pars[0,*,*,*])
   dyummy=fiss_data_correct(tmp*0, tmp,  aligna, t, $
     xmargin=xmargin, ymargin=ymargin, inten=inten, ionly=1, mask=mask)
    pars_a[0,*,*,*]=inten
   for line=0, nv_a-1 do begin
   tmpint=reform(pars[line*2+1,*,*,*])
   tmp=reform(pars[line*2+2,*,*,*])
   pars_a[line*2+2,*,*,*]=fiss_data_correct(tmp, tmpint,  aligna, t,  $
     xmargin=xmargin, ymargin=ymargin, inten=inten)
    pars_a[line*2+2,*,*,*]=(pars_a[line*2+2,*,*,*]+(wva-wvrest_a[line]) )*(3.e5/wvrest_a[line]) ; km/s

   pars_a[line*2+1,*,*,*]=inten
   endfor
   m=median(pars_a[2,*,*,*])
   for k=0, nk-1 do begin & wait, 0.1 & tv, bytscl(pars_a[2,*,*,k]-m, scale_a[0,2], scale_a[1,2]) & endfor
endif

if 1 then begin
print, 'Saving Data A...' & wait, 0.1
fxhmake, h,  pars_a, /init
for p=0, npar_a-1 do fxaddpar, h, 'ID'+string(p, format='(i1)'), ids_a[p], cpar_a[p]
fxaddpar, h, 'REFNO', (where(aligna.cor eq 1.))[0],  'the number of frame used as the reference'
fxaddpar, h, 'REFTIME', strmid(id, 2, 15), ' reference time'
for line=0, nv_a-1 do $
fxaddpar, h, 'WVREST'+string(line, format='(i1)'),  wvrest_a[line], 'Rest wavelength of line '+string(line, format='(i1)')
fxaddpar, h, 'XOFFSET', xmargin[0], 'Xoffset to be added to image coordinantes'
fxaddpar, h, 'YOFFSET' , ymargin[0], 'Yoffset to be added to image coordinates'
;xdisplayfile, text=h
writefits, id+'A.fts',  pars_a, h
writefits, id+'Amask.fts', mask

fxhmake, h, aligna.dt, /init
fxaddpar, h, 'REFNO', (where(aligna.cor eq 1.))[0],  'the number of frame used as the reference'
fxaddpar, h, 'REFTIME', strmid(id, 5, 15), ' reference time'
fxaddpar, h, 'UNIT',  'min'
writefits, id+'t.fts', aligna.dt, h


endif

lambdameter=1
if lambdameter then begin
print, 'starting lambdameter in B...'  & wait, 0.1
;restore, 'FD'+strmid(id, 5, 14)+'_aligna.sav'
restore, id+'alignb.sav'
alignb=align
   f=alignb.files[alignb.sel]
   sp0=total(fiss_sp_av(alignb.files[alignb.kref]),2)/nyb
   wv=fiss_wv(alignb.files[alignb.kref])
   nk=n_elements(f)
  pars=fltarr(npar_b,nx,nyb,nk)
  for k=0, nk-1 do begin
    print, 'nk-1-k=', nk-1-k
    if k mod 10 eq 0  then wait, 0.1
  pars[0,*,*,k]=fiss_raster(f[k], wvconb, hwcont, 0, nx-1, 0, nyb-1)
  tmp=fiss_lambdameter(f[k], wr_b, hw_b, 0, nx-1, 0, nyb-1, sp0=sp0, smoo=1, wv0=wvb)

;if k eq 2 then stop

  for line=0, nv_b-1 do begin
   pars[line*2+1,*,*,k]=tmp[*,*,1,line]
   pars[line*2+2,*,*,k]=tmp[*,*,0,line]
  endfor
  endfor
   save, pars, file='pars_b.sav'
endif
;
correct=1
if correct then begin
print, 'starting data-correcting...' & wait, 0.1
   restore, 'pars_b.sav'
   fmargin_linux, aligna, nx, nya, xmargina, ymargina
   xmargin=xmargina
   ymargin=ymargina
   ymargin[1]=nya-nyb+ymargina[1]

   pars_b=fltarr(npar_b, nx+xmargin[1]-xmargin[0], nyb+ymargin[1]-ymargin[0],nk)
   wvav=fltarr(nv_b)
   ;wvoffs=fltarr(nv_b,nx, nk)

   tmp=reform(pars[0,*,*,*])
   dyummy=fiss_data_correct(tmp*0, tmp,  alignb, t,  $
     xmargin=xmargin, ymargin=ymargin, inten=inten, ionly=1, mask=maskb)
    pars_b[0,*,*,*]=inten
   for line=0, nv_b-1 do begin
   tmpint=reform(pars[line*2+1,*,*,*])
   tmp=reform(pars[line*2+2,*,*,*])

  pars_b[line*2+2,*,*,*]=fiss_data_correct(tmp, tmpint,alignb, t, $
               xmargin=xmargin, ymargin=ymargin, inten=inten)
   pars_b[line*2+2,*,*,*]=(pars_b[line*2+2,*,*,*]+(wvb-wvrest_b[line]) )*(3.e5/wvrest_b[line]) ; km/s
   pars_b[line*2+1,*,*,*]=inten
   endfor
   m=median(pars_b[4,*,*,*])
   for k=0, nk-1 do begin & wait, 0.1 & tv, bytscl(pars_b[4,*,*,k]-m, scale_b[0,4],scale_b[1,4]) & endfor
endif

print, 'saving Data B ...' & wait, 0.1
fxhmake, h,  pars_b, /init
for p=0, npar_b-1 do fxaddpar, h, 'ID'+string(p, format='(i1)'), ids_b[p], cpar_b[p]
fxaddpar, h, 'REFNO', (where(alignb.cor eq 1.))[0],  'the number of frame used as the reference'
fxaddpar, h, 'REFTIME', strmid(id, 2, 15), ' reference time'
for line=0, nv_b-1 do $
fxaddpar, h, 'WVREST'+string(line, format='(i1)'),  wvrest_b[line], 'Rest wavelength of line '+string(line, format='(i1)')
fxaddpar, h, 'XOFFSET', xmargin[0], 'Xoffset to be added to image coordinantes'
fxaddpar, h, 'YOFFSET' , ymargin[0], 'Yoffset to be added to image coordinates'
;xdisplayfile, text=h
writefits, id+'B.fts',  pars_b, h
writefits, id+'Bmask.fts', maskb


plot_movies_linux,  id, ids_a, scale_a, ids_b, scale_b


t2=systime(/sec)
print, 'It took ', (t2-t1)/60., ' minutes to finishd FISS_DATA!'

end



;;;

;  1, Dopplershift in km/s, with the specification of rest wavelengths
;  2. Specification of spectral bands  in fits header
;

;fiss_data, in_dir, out_dir

;pro fiss_data, in_dir, out_dir


pro fiss_data_run, rootdir
  device,decomposed=0
  if ~file_exist(rootdir) then begin
    print, 'The input directory does not exist.'
    stop
  endif
  
  rootdir = path_sep() + strjoin(strsplit(rootdir,path_sep(),/regex,/extract),'/') + path_sep()
  targetdir = file_search(rootdir + 'comp/*/*',count=nd)
  
  
  for i=0,nd-1 do begin
    in_dir = targetdir[i] + path_sep()
    out_dir = strjoin(strsplit(in_dir,"comp",/regex,/fold,/extract),'phys')
    file_mkdir,out_dir
    fa=(file_search(in_dir+'*A1_c.fts',count=nfa))[*]
    fb=(file_search(in_dir+'*B1_c.fts',count=nfb))[*]

    if nfa ne nfb then begin
      print, 'The number of A files is not the same as that of B files!'
      stop
    endif
    
    sindex=fiss_group_linux(fa)
    print, sindex
    ngroup=n_elements(sindex)-1
    print, 'The files consist of ', ngroup, '  groups!'
    for g=0, ngroup-1 do begin
      print, 'Group #=', g
      s1=sindex[g]
      s2=sindex[g+1]-1
      print, 's1=',s1, ', s2=', s2
      fa1=fa[s1:s2]
      fb1=fb[s1:s2]
      fiss_data_linux, fa1, fb1, out_dir, aligna, alignb
    endfor
  endfor
  
  
end

in_dir = 'c:\work\fiss\data\20180623\sunspot\'
out_dir = 'c:\work\fiss\cross\'
fa=(file_search(in_dir+'*A1_c.fts'))[*]
fb=(file_search(in_dir+'*B1_c.fts'))[*]

nfa=n_elements(fa)
nfb=n_elements(fb)
if nfa ne nfb then begin
print, 'The number of A files is not the same as that of B files!'
stop
endif


sindex=fiss_group_linux(fa)
print, sindex
ngroup=n_elements(sindex)-1
print, 'The files consist of ', ngroup, '  groups!'
for g=0, ngroup-1 do begin
print, 'Group #=', g
s1=sindex[g]
s2=sindex[g+1]-1
print, 's1=',s1, ', s2=', s2
fa1=fa[s1:s2]
fb1=fb[s1:s2]
fiss_data_linux, fa1, fb1, out_dir, aligna, alignb

endfor



;nf=n_elements(aligna.files)
;k1=min(aligna.sel, max=k2)  & print, 'k1=',k1, ', k2=', k2
;
;if k1 ge 50 then begin
;fiss_data, fa[0:k1-1], fb[0:k1-1], out_dir, aligna1, alignb1
;  nf1=n_elements(aligna1.files)
; k11=min(aligna1.sel, max=k12)  & print, 'k11=',k11, ', k12=', k2
;
; if k11 ge 50 then fiss_data, (fa[0:k1-1])[0:k11-1], (fb[0:k1-1])[0:k11-1], $
;     out_dir, aligna11, alignb11
; if k12 le nf1-1-50 then $
;fiss_data, (fa[0:k1-1])[k12+1:*], (fb[0:k1-1])[k12+1:*], out_dir, aligna12, alignb12
;
;endif
;if k2 le nf-1-50 then begin
;fiss_data, fa[k2+1:*], fb[k2+1:*], out_dir, aligna2, alignb2
;
;  nf2=n_elements(aligna2.files)
; k21=min(aligna2.sel, max=k22)  & print, 'k21=',k21, ', k22=', k22
;
; if k21 ge 50 then fiss_data, (fa[k2+1:*])[0:k21-1], (fb[k2+1:*])[0:k21-1], $
;     out_dir, aligna21, alignb21
; if k22 le nf2-1-50 then $
;fiss_data, (fa[k2+1:*])[k22+1:*], (fb[k2+1:*])[k22+1:*], out_dir, aligna22, alignb22
;
;endif

end