;==================================================================================
; swap
;
;==================================================================================
pro swap, a, b, sign=sign
 if(NOT keyword_set(sign)) then sign = [1,1]
 z = a
 a = b *sign[0]
 b = z *sign[1]
end
;==================================================================================
