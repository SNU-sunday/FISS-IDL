;------------------------------------------------------------------
;+
; NAME:
;		DRAW_CLOCK
; PURPOSE:
;		Draw a clock on the window.
; EXPLANATION:
;		This procedure draws the clock on the window. 
;		Size, position, color changeable.
;		Time input type is '2011-03-31T18:30:30' that in most 
;		of the fits file header contain the same type of time.
;
; CALLING SEQUENCE:
;		draw_clock, 50, 50, '2011-03-31T18:30:30', color=255, clocksize=20
; INPUTS:
;		x = x position of the clock center where you draw the clock.
;		y = y position of the clock center where you draw the clock.
;
; H.Yang

pro draw_clock, x, y, DATE, clocksize=clocksize, color=color
	  
      if not keyword_set(x) then return
      if not keyword_set(y) then return
      if not keyword_set(DATE) then return
      
      if not keyword_set(clocksize) then clocksize=50
	  if not keyword_set(color)	then color=0

	
	  time=(strsplit(DATE, 'T', /extract))[1]
	  hour=(strsplit(time, ':', /extract))[0]
	  minute=(strsplit(time, ':', /extract))[1]


      hourangle=-30.*!pi/180.*float(hour)-!pi/180.*float(minute)/60.*30.

      minuteangle=-!pi/180.*6*float(minute)




       ;draw the mark
       fourposx=[-0.5 , 0, 0.5, 0, -0.5]*clocksize/50.
       fourposy=[0, 2, 0, -2, 0]*clocksize/50.
       angle=[0., 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330]/180.*!pi
       
     
       for i=0, 11 do begin
        markx=fourposx*cos(angle(i))-fourposy*sin(angle(i))
        marky=fourposx*sin(angle(i))+fourposy*cos(angle(i))
          usersym, markx, marky, /fill
          plots, x+clocksize*cos(angle(i)+!pi/2), y+clocksize*sin(angle(i)+!pi/2), /device, psym=8, color=color
       endfor

      ;hour arrow
      arrow_widex=[-0.8, 0, 0.8, 0, -0.8]*clocksize/30.
      arrow_widey=[1, 4, 1, 0, 1]*clocksize/30.
      arrow_hourx=arrow_widex*cos(hourangle)-arrow_widey*sin(hourangle)
      arrow_houry=arrow_widex*sin(hourangle)+arrow_widey*cos(hourangle)
      usersym, arrow_hourx, arrow_houry, /fil
      plots, x,y, /device, psym=8, color=color
      
      ;minute arrow
      arrow_widex=[-0.8, 0, 0.8, 0, -0.8]*clocksize/60.
      arrow_widey=[1, 4, 1, 0, 1]*clocksize/20.
      arrow_minutex=arrow_widex*cos(minuteangle)-arrow_widey*sin(minuteangle)
      arrow_minutey=arrow_widex*sin(minuteangle)+arrow_widey*cos(minuteangle)
      usersym, arrow_minutex, arrow_minutey, /fil
      plots, x,y, /device, psym=8, color=color
end
