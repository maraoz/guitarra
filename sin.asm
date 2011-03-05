;asumo que me pasan el valor en A y tambien lo devuelvo ahi ( sin(a) ). Se pierde el valor de B	
sin			
			movec	x1,ssh
			movec	x0,ssl
			movec	y1,ssh
			movec	y0,ssl
		
			move	a,x0	
			mpy	x0,x0,b
			move	b,x1
			mpy	x0,x1,b
			move	#T1,y0	
			move	b,y1
			mac	-y1,y0,a
			mpy	x1,y1,b
			move	b,x0	#T2,y0	
			mac	x0,y0,a
			mpy	x0,x1,b
			move	b,x0	#T3,y0
			mac	-x0,y0,a

			
			movec	ssl,y0
			movec	ssh,y1
			movec	ssl,x0
			movec	ssh,x1
			nop
			rts 
