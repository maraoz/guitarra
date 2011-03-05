;*************************************************************************
;SUBROUTINE	:	SIG24DIV.ASM
;PURPOSE	 	
;		This is a division subroutine which implements a 4 quadrant
;		divide (i.e. a signed divisor and a signed dividend) and 
;		generates a 24-bit signed quotient and a 48-bit signed
;		remainder, Given a 48 bit dividend and a 24 bit divisor.
;INPUTS		
;		Dividend must be stored in the low 48 bits of accumulator a
;		and must be a positive number
;
;		Divisor must be stored in x0, and must be larger than the
;		dividend to produce a fractional result.
;
;OUTPUTS
;		The quotient will be in x1
;	
;		The remainder will be in b1
;**************************************************************************

sig24div	abs	a	a,b	;make dividend positive, copy a1 to b1
		eor	x0,b	b,y0	;save rem. sign in x1, quo sign in N
		and	#$FE,ccr 	;clear carry bit C (quotient sign bit)
		rep	#$18		;form a 24-bit quotient
		div	x0,a		;form quotient in a0, remainder in a1
		tfr	a,b		;save remainder and quotient in b
		jpl	saveq		;of quotient is positive, go to saveq
		neg	b		;complement quotient if N bit is set
saveq		tfr	x0,b	b0,x1	;save quo. in x1, get signed divisor
		abs	b		;get absolute value of signed divisor
		add	a,b		;restore remainder in b1
		jclr	#23,y0,done	;go to done if remainder is positive
		move	#$0,b0		;prevent unwanted carry
		neg	b		;complement remainder
		rts
