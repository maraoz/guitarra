	
MULFIX		macro			;pisa x0,x1,a . resultado en a y x0
	
		tst	a
		bge	_positivo			
		neg	a		
		
		move	#>64,x0	
		move	a,x1
		mpy	x0,x1,a
		neg	a
		bra	_fin		
_positivo	move	#>64,x0	
		move	a,x1
		mpy	x0,x1,a
_fin		move	a,x0
		endm
	
		
MULFIXB		macro			;pisa x0,x1,b
			
		tst	b
		bge	_positivo			
		neg	b		
		
		move	#>64,y0	
		move	b,y1
		mpy	y0,y1,b
		neg	b
		bra	_fin		
_positivo	move	#>64,y0	
		move	b,y1
		mpy	y0,y1,b
_fin		move	b,y0
		endm
	
	
DIVFIX		macro			;pisa x0,x1,a . resultado en a
		
		tst	a
		bge	_positivo			
		neg	a
			
		move	#$010000,x0
		move	a,x1
		mpy	x0,x1,a
		neg	a
		bra	_fin
	
_positivo	move	#$010000,x0
		move	a,x1
		mpy	x0,x1,a
_fin		nop
		endm	
		
DIVFIXB		macro			;pisa y0,y1,b . resultado en b
		
		tst	b
		bge	_positivo			
		neg	b
			
		move	#$010000,y0
		move	b,y1
		mpy	y0,y1,b
		neg	b
		bra	_fin
	
_positivo	move	#$010000,y0
		move	b,y1
		mpy	y0,y1,b
_fin		nop
		endm	