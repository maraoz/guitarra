



	STOREMN	macro	xmn			; Guardo xmn en x0 en formato MN. pisa x0,x1,a 

		move	#(xmn-@cvi (xmn)),x0    ;fractional part to X0
		move	#$010000,x1 		;shift constant in x1
		mpyr	x1,x0,a #@cvi (xmn),x0  ;shift X0;integer part in 
		add	x0,a 			;concatenate int. and frac
		
		move	#>128,x0
		move	a,x1
		mpy	x0,x1,a
		move	a1,x0
		
		endm 				
		
	MPYMN	macro				; Multiplica x0 * x1 en formato MN y lo guarda en x0. pisa x0,x1,a 
		
		mpy	x0,x1,a
		
		move	#>64,x0
		move	a,x1
		mpy	x0,x1,a
		move	a1,x0
		
		endm
		
	MACMN	macro
				
		mac	x0,x1,a
		move	#>64,x0
		move	a,x1
		mpy	x0,x1,a
		move	a1,x0
		
		endm
	