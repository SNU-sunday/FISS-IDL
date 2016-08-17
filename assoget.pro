function  assoget, a, n, bzero, bscale, swap=swap
b= a(n)
if  keyword_set(swap) then  b=swap_endian(b)
return, b*bscale+bzero
end
