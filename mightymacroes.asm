	
	MULFIX	macro			;pisa x0,x1,a
				
		move	#>64,x0	a,x1
		mpy	x0,x1,a
		move	a1,x0
		
		endm
		
			
	MULFIXB	macro			;pisa x0,x1,b
				
		move	#>64,y0	b,y1
		mpy	y0,y1,b
		move	b1,y0
		
		endm
		
	DIVFIX	macro			;pisa x0,a
				
		move	#$010000,x0	
		mpy	x0,x1,a
		move	a1,x1
		
		endm	