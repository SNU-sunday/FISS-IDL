function fiss_calfile_v2, datafiles, cal_dir, type=type, detector=detector
;+
;   Name: fiss_calfile
;           Find the name of  calib file(s) suited for
;           given data file(s)
;
;   Syntax:  result=fiss_calfile (datafiles)
;
;   Returned values:
;
;             the full name of calibration  files
;   Arguments:
;            datafiles   the full name of data file
;
;   Keywords: None
;
;   Remarks: The calib file should be in the calib directory
;   Required routines:
;
;   History:
;         2010 July,  first coded  (J. Chae)
;         2017 June,  Add GRAtWVLN part
;-
;lif !version.os_family eq 'Windows' then delim='\' else delim='/'

delim=path_sep();get_delim()

nf=n_elements(datafiles)
calfiles=strarr(nf)
file=file_basename(datafiles)
tstr=strmid(file, 5, 15)
if n_elements(type) eq 0 then type='cal'



for k=0, nf-1 do begin
  data_gratwvln=float(fxpar(headfits(datafiles[k]), 'GRATWVLN'))
  if n_elements(detector) eq 0 then detector=strmid(file[k], 25, 1)
  case type of
   'cal' :  id='FISS_*'+detector+'_Cal.fts'
   'flat': id='FISS_FLAT_*'+detector+'.fts'
   'slit': id='FISS_SLIT_*'+detector+'.fts'
  endcase
  
  dfiles=file_search(cal_dir+id, count=count)
  flat_gratwvln=fltarr(count)
  for ii=0, count-1 do flat_gratwvln[ii]=float(fxpar(headfits(dfiles[ii]), 'GRATWVLN'))
  dfiles=dfiles[where(flat_gratwvln eq data_gratwvln, /null)]
  count=n_elements(dfiles)
  if count eq 0 then begin
  print, 'no files of type: '+type+' are found! ..returning from fiss_calfile.'
  print, 'Please check the "GRATWVLN" of file headers.'
  print, 'You can change the "GRATWVLN" value using "change_gratwvln.pro"'' 
  stop
  return, ''
  endif
  dfbase=file_basename(dfiles)
  
  case type of
   'cal':  dtstr = strmid(dfbase, 5, 15)
   'flat': dtstr=strmid(dfbase, 10, 15)
   'slit': dtstr=strmid(dfbase, 10, 15)
   endcase
  dt=julday(strmid(dtstr, 4,2), strmid(dtstr, 6,2), strmid(dtstr, 0, 4), $
                strmid(dtstr, 9,2), strmid(dtstr, 11, 2), strmid(dtstr,13, 2)) $
   -julday(strmid(tstr[k], 4,2), strmid(tstr[k], 6,2), strmid(tstr[k], 0, 4), $
                strmid(tstr[k], 9,2), strmid(tstr[k], 11, 2), strmid(tstr[k],13, 2))
  
  
  s=(where(abs(dt) eq min(abs(dt))))[0]
  
  calfiles[k]=cal_dir+dfbase[s]
endfor
if n_elements(calfiles) eq 1 then calfiles=calfiles[0]
return, calfiles

end