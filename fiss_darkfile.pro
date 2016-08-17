function fiss_darkfile, datafiles
;+
;   Name: fiss_darkfile
;           Find the name of dark+bias file(s) suited for
;           given data file(s)
;
;   Syntax:  result=fiss_darkfile (darkfile)
;
;   Returned values:
;
;             the full name of dark file
;   Arguments:
;            datafile   the full name of data file
;
;   Keywords: None
;
;   Remarks: The dark file should be in the same directory as the data file
;
;   Required routines:
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-
if !version.os_family eq 'Windows' then delim='\' else delim='/'
nf=n_elements(datafiles)
darkfiles=strarr(nf)
dir=file_dirname(datafiles)
file=file_basename(datafiles)

for k=0, nf-1 do begin
detector=strmid(file[k], strlen(file[k])-5, 1)
dfiles=file_search(dir[k]+delim+'*_'+detector+'_BiasDark.fts')
dfbase=file_basename(dfiles)
s=where(dfbase lt file[k], count)
if count ge 1 then begin
dfbase=dfbase(s)
dfbase=dfbase(reverse(sort(dfbase)))
endif else begin
s=where(dfbase ge file[k], count)
dfbase=dfbase(s)
dfbase=dfbase((sort(dfbase)))
endelse
darkfiles[k]=dir[k]+delim+dfbase[0]
endfor

return, darkfiles

end