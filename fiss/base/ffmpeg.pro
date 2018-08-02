PRO ffmpeg, FARRAY, FramesPerSecond, OUTPUT=OUTPUT, VCODEC=VCODEC
;+
; Name:ffmpeg
;
; Purpose : make a movie file using image files.
; 
; Input Parameters:
;   FARRAY  - list of image files. 
;             png/jpeg/anything which can read using 'read_image' function are possible.
;             The array should contain the file in order.
;   FramePerSecond  - frame per second of the output movie file.
; 
; Output Parameters :
;   OUTPUT  - output filename. 
;             file will be saved in 'current' directory.
;             recommend 'avi/mov/wmv/mp4' formats for the output file.
;
; History:
;   08-mar-2013 - Heesu Yang
;   13-mar-2013 - Heesu Yang. Check errors before generating the movie.
; 	15-May-2013 - Heesu Yang. mov encoder check.
;   26-Dec-2015 - Heesu Yang. VCODEC keyword added.
;   05-Jan-2016 - Heesu Yang. -c:v modified.
;							  For mp4 extension files, the video codec changed from 'libx264' to 'mpeg4'(native compression).
;						pix_fmt changed from 'rgba' to 'yuv420'

if not keyword_set(FARRAY) then begin
	print, 'File array not set.'
	return
endif
cd, CURRENT=CURRENT_PATH
pngfile_path=FILE_DIRNAME(FILE_EXPAND_PATH(FARRAY[0]))
FARRAY=FILE_BASENAME(FARRAY)
;path1= 'C:\Users\Heesu Yang\Desktop\ffmpeg-20130126-git-c46943e-win32-static\bin'

if not keyword_set(FramesPerSecond) then FramesPerSecond=25
if not keyword_set(OUTPUT) then OUTPUT='out.avi'

if size(FramesPerSecond, /TYPE) ne 2 then begin
  print, "FramesPerSecond should be integer."
  return
endif
m_output_extension=file_extension(OUTPUT)
IF KEYWORD_SET(VCODEC) THEN BEGIN 
    m_codec='-codec '+VCODEC
    ENDIF ELSE BEGIN
        if strcmp(m_output_extension, 'mp4')      then m_codec='libx264' $
        else if strcmp(m_output_extension, 'avi') then m_codec='libxvid' $
        else if strcmp(m_output_extension, 'wmv') then m_codec='' $
        else if strcmp(m_output_extension, 'mov') then m_codec='mpeg4' $
        else m_codec=''
ENDELSE

fps=strtrim(string(FramesPerSecond),1)

ffmpeg_info=ROUTINE_INFO('ffmpeg', /SOURCE)
ffmpeg_path=FILE_DIRNAME(ffmpeg_info.path)
extension=file_extension(FARRAY[0])

imsize=size(read_image(FILEPATH(FARRAY[0], ROOT_DIR=pngfile_path)), /DIMENSION)
rgbpos=where(imsize eq 3)
if rgbpos eq 0 then begin
    XSIZE=imsize[1]
    YSIZE=imsize[2]
endif
if rgbpos eq 2 then begin
    XSIZE=imsize[0]
    YSIZE=imsize[1]
endif
if rgbpos eq 1 then begin
    XSIZE=imsize[0]
    YSIZE=imsize[2]
endif
if rgbpos eq -1 then begin
    XSIZE=imsize[0]
    YSIZE=imsize[1]
endif

  
if ((XSIZE mod 2)+ (YSIZE mod 2)) ne 0 then begin
    print, 'The size of the input image should be even numbers.'
    return
endif





cd, ffmpeg_path
f1=file_search('*.'+extension)
if keyword_set(f1) then  FILE_DELETE, f1
FILE_COPY, pngfile_path+'/'+FARRAY, '_'+strtrim(string(indgen(n_elements(FARRAY))), 1)+'.'+extension, $
            /OVERWRITE, /RECURSIVE
;cmd='copy '+FILE_SEARCH(pngfile_path,FARRAY[i])+' _'+strtrim(string(i),1)+'.'+extension
;spawn, cmd

cmd='ffmpeg -i '+'_%d.'+extension+ $
                ' -c:v '+m_codec+ ' -pix_fmt yuv420p'+$
                ' -s '+strtrim(string(XSIZE), 1)+'x'+strtrim(string(YSIZE), 1)+' -q:v 1 -y -r '+fps+' -y '+OUTPUT
spawn, cmd, res
print, cmd
 ;FILE_DELETE, 'temp.raw', /ALLOW_NONEXISTENT
for i=0, n_elements(FARRAY)-1 do $
    FILE_DELETE, '_'+strtrim(string(i),1)+'.'+extension  

cd, CURRENT_PATH
FILE_MOVE, FILE_SEARCH(ffmpeg_path, OUTPUT), CURRENT_PATH, /OVERWRITE, /REQUIRE_DIRECTORY, /ALLOW_SAME 

end
