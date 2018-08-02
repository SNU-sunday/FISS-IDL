function fiss_mtf,  fwhm
a=fwhm/2./1.55
r=dist(512) & psf=1./((r/a)^2+1.)^2 & psf=psf/total(psf)  & mtf=abs(fft(psf, 1))
return, mtf

end