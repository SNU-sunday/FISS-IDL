function  assoreadfits,  file,  bzero, bscale,  h, unit=unit,  nf=nf
;+
; NAME:  assoreadfits
; PURPOSE: read a FITS file into an associated variable
; CALLING SEQUENCE:
;       a= assoreadfits (file, bscale, bzero,  h, unit=unit, nf=nf)
; INPUTS:
;       FILE  file name
;        CLOSE   keyword, if set the file is closed.
; OUPUTS:
;       H    FITS header
;       BSCALE
;       BZERO
;       A     the associated variable
;       UNIT   file unit number (should be INPUT when using the CLOSE keyword)
;       NF       the number of all the images
;
;  REMARKS:
;     This routine is mainly intended to read a file with a large set of
;     image data. Since it reads a single image when the associated variable
;     is referred to with a proper index,  it saves the computer memory.
;
;     When reading is finished, the file should be closed using the command
;       IDL> close, unit
;
; HISTORY:
;      developed by J. Chae 1999 October
;
; -
if keyword_set(close) then begin
free_lun, unit
a=-1
return, a
endif

h=headfits(file)
endline = where( strmid(h,0,8) EQ 'END     ', Nend)
nmax = endline(0) + 1
npad = 80l*nmax mod 2880
offset = 80*nmax+(2880-npad)*(npad gt 0)
nx=fxpar(h, 'NAXIS1')
ny=fxpar(h, 'NAXIS2')
nf=fxpar(h, 'NAXIS3')
openr, unit, /get_lun,  file, /swap_if_little_endian
case fxpar(h, 'BITPIX') of
       8: a = assoc(unit, bytarr(nx, ny), offset)
     16: a = assoc(unit, intarr(nx, ny), offset)
     32: a = assoc(unit, lonarr(nx, ny), offset)
   -32: a = assoc(unit, fltarr(nx, ny), offset)
   else: begin
           end
 endcase


 bscale = float( fxpar( h, 'BSCALE' ))
 if !ERR NE -1  then begin
           fxaddpar, h, 'BSCALE', 1.
            fxaddpar, h, 'O_BSCALE', bscale,' Original BSCALE Value'
     endif else begin
               bscale =1.
               fxaddpar, h, 'BSCALE', 1.
                   fxaddpar, h, 'O_BSCALE', bscale,' Original BSCALE Value'
       endelse


  bzero = float( fxpar ( h, 'BZERO' ) )
     if !ERR NE -1  then  begin
                     fxaddpar, h, 'BZERO', 0.
                     fxaddpar, h, 'O_BZERO', Bzero,' Original BZERO Value'
               endif else begin
                 bzero=0.
                 fxaddpar, h, 'BZERO', 0.
                     fxaddpar, h, 'O_BZERO', Bzero,' Original BZERO Value'
           endelse
 return,  a
 end

