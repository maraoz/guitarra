
	STOREMN	macro	xmn			; Guardo xmn en x0 en formato MN. pisa x0,x1,a 

		move	#(xmn-@cvi (xmn)),x0    ;fractional part to X0
		move	#$010000,x1 		;shift constant in x1
		mpyr	x1,x0,a #@cvi (xmn),x0  ;shift X0;integer part in 
		add	x0,a 			;concatenate int. and frac
		MOVEAX0
		endm 
	
	MOVEAX0	macro				;pisa x0,x1,a
		move	#>128,x0	a,x1
		mpy	x0,x1,a
		move	a1,x0	
		endm
	
	MULFIX	macro			;pisa x0,x1,a
				
		move	#>64,x0	a,x1
		mpy	x0,x1,a
		move	a1,x0
		
		endm
	DIVFIX	macro			;pisa x0,a
				
		move	#$010000,x0	
		mpy	x0,x1,a
		move	a1,x1
		
		endm	