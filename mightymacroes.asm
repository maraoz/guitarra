	
MULFIX		macro			;pisa x0,x1,a
	
		tst	a
		bge	_positivo			
		neg	a		
		
		move	#>64,x0	
		move	a,x1
		mpy	x0,x1,a
		nop
		move	a1,x0
		neg	a
		bra	_fin		
_positivo	move	#>64,x0	
		move	a,x1
		mpy	x0,x1,a
		nop
		move	a1,x0
_fin		nop		
		endm
	
		
MULFIXB		macro			;pisa x0,x1,b
			
		tst	b
		bge	_positivo			
		neg	b		
		
		move	#>64,y0	
		move	b,y1
		mpy	y0,y1,b
		nop
		move	b1,y0
		neg	b
		bra	_fin		
_positivo	move	#>64,y0	
		move	b,y1
		mpy	y0,y1,b
		nop
		move	b1,y0
_fin		nop
		endm
	
	
DIVFIX		macro			;pisa x0,a
		
		tst	a
		bge	_positivo			
		neg	a
			
		move	#$010000,x0
		mpy	x0,x1,a
		nop
		move	a1,x1
		neg	a
		bra	_fin
	
_positivo	move	#$010000,x0
		mpy	x0,x1,a
		nop
		move	a1,x1
_fin		nop
		endm	
