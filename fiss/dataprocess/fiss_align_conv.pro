
pro fiss_align_conv, cfiles,  halign, calign,  alignfile=alignfile, del=del

if n_elements(del) ne 2 then del=[-1.6,9.1]

calign=halign
calign.files=cfiles
calign.dx = calign.dx-del[0]
calign.dy = calign.dy-del[1]
if n_elements(alignfile) eq 1 then save, file=alignfile+'_align.sav', align

end