pro fiss_get_pos, x, y,  xc,yc, theta, dx, dy,  xx, yy, inv=inv
;+
; Calling sequence
;
;     fiss_get_pos, x, y,  xc,yc, theta, dx, dy,  xx, yy, inv=inv
;
; Inputs
;      x, y   the cooridnates of the position(s) at the reference time
;      xc, yc  the coordinates of the center of rotation
;      theta   the angle of the y-axis of the observed frame with respect to the reference frame
;               (+ means inclined to the right)
;      dx, dy   the relative displacement of the rotated images to the reference image
;
; Outputs
;      xx, yy   the coordinates of the positions in the observed frame
;
; Keyword
;      inv     if set
;                 xx, yy : inputs
;                 x, y : outputs
;-
if not keyword_set(inv) then begin
xx= (x-xc)*cos(theta) + (y-yc)*sin(theta)+xc+dx
yy=-(x-xc)*sin(theta)  + (y-yc)*cos(theta)+yc+dy
endif else begin
;pro fiss_get_pos_inv, xx, yy,  xc,yc, theta, dx, dy,  x, y
x= (xx-xc-dx)*cos(theta) - (yy-yc-dy)*sin(theta)+xc
y= (xx-xc-dx)*sin(theta)  + (yy-yc-dy)*cos(theta)+yc
endelse
end
