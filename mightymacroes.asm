	
MULFIX		macro			;pisa x0,x1,a . resultado en a y x0
	
		tst	a
		bge	_positivo			
		neg	a		
		
		rep	#7
		asl	a
		
		neg	a
		bra	_fin
		
_positivo	rep	#7
		asl	a
		
_fin		move	a0,x0
		endm
	
		
MULFIXB		macro			;pisa x0,x1,b
			
		tst	b
		bge	_positivo			
		neg	b		
		
		rep	#7
		asl	b
		
		neg	b
		bra	_fin
			
_positivo	rep	#7
		asl	b
		
_fin		move	b0,y0
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
