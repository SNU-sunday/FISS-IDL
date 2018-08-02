function FILE_EXTENSION, FILENAME
;Check Extension
extension=''
for i=0, 24 do begin
  extension=STRMID(FILENAME, i, /REVERSE_OFFSET)
  if strmatch(extension, '.*') then i=24
endfor  

return, STRMID(extension, 1)
end