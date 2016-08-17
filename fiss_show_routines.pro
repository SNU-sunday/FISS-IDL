pro fiss_show_routines, all=all
;+
;   Name: fiss_show_routines
;          display the list of all routines developed for FISS
;
;   Syntax:  fiss_show_routines
;
;   Arguments: None
;
;   Keywords: None
;
;   Remarks:
;
;   Required routines: None
;
;   History:
;         2010 July,  first coded  (J. Chae)
;
;-


text=[ $
'This is the list of routines developed for FISS', $
'', $
'Data read/show rouitnes f(or users)', '',  $
' fiss_pca_read: reads one spectrogram from a pair of PCA-compressed files', $
' fiss_raster: constructs raster scan images', $
' fiss_read_frame: reads one spectrogram from a FISS file (original or PCA-compressed)', $
' fiss_show_sp: interactively displays spectrograms and spectral profiles']
if keyword_set(all) then $
text=[text, '', '', $
'Data processing/calibration rouitnes (for supporters)', '',  $
'', $
' fiss_sp_av: obtains the averaged spectrogram', $
' fiss_get_dw: determines the amount of deviation from the vertcial straight line', $
' fiss_pca_denoise: reduces noise using the PCA analysis', $
' fiss_slit_pattern: determines the response pattern aring from  non-uniform slit width', $
' fiss_wv_calib: determines wavelength calibration parameters', $
' fiss_darkfile: finds the name of dark data file corresponding to a data file', $
' fiss_gaincalib: determines flat pattern from a set of images', $
' fiss_get_flat: determines flat pattern from data files', $
' fiss_pca_conv: converts normal data files into PCA-compressed data files', $
' fiss_prep: processes raw data files' $
]

xdisplayfile, text=text, title='FISS routines'

end
