function wall2011, wv
  cd, current=c
  dir=file_which('wall2011.pro')
  cd, strmid(dir, 0, strlen(dir)-12)
  restore, 'solar_atlas.sav'
  cd, c
  intensity=interpol(intensity, wave, wv)
  return, intensity
end