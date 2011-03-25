	
MULFIX		macro			;pisa a  
							;resultado en a y x0
		tst	a
		bge	_positivo			
		neg	a		
		
		asl	#7,a,a
		
		neg	a
		bra	_fin
		
_positivo	
		asl	#7,a,a
		
_fin		move	a,x0
		endm
	
		
MULFIXB		macro			;pisa b
							;resultado en b y y0
		tst	b
		bge	_positivo			
		neg	b		
		
		asl	#7,b,b
		
		neg	b
		bra	_fin
			
_positivo
		asl	#7,b,b
		
_fin		move	b,y0
		endm
	
	
DIVFIX		macro			;pisa x0,x1,a . resultado en a
		
		tst	a
		bge	_positivo			
		neg	a	
		asr		#7,a,a
		neg	a
		bra	_fin
	
_positivo	asr	#7,a,a
_fin		nop
		endm	
		
DIVFIXB		macro			;pisa y0,y1,b . resultado en b
		
		tst	b
		bge	_positivo			
		neg	b
		asr		#7,b,b
		neg	b
		bra	_fin
	
_positivo	asr		#7,b,b
_fin		nop
		endm	
