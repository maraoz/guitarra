;asumo que me pasan el valor en A y tambien lo devuelvo ahi ( sin(a) ). Se pierde el valor de B	
sin			
			movec	x1,ssh
			movec	x0,ssl
			movec	y1,ssh
			movec	y0,ssl
		
			move	a,x0	
			mpy		x0,x0,b
			nop
			move	b,x1
			mpy		x0,x1,b
			nop
			move	b,y1
			move	#T1,y0
			mpy		y1,y0,b
			sub		b,a
			mpy		x1,y1,b
			nop
			move	b,x0
			move	#T2,y0
			mpy		x0,y0,b
			nop
			add		b,a
			mpy		x0,x1,b
			nop
			move	b,x0
			move	#T3,y0
			mpy		x0,y0,b
			sub		b,a
			nop
			
			movec	ssl,y0
			movec	ssh,y1
			movec	ssl,x0
			movec	ssh,x1
			nop
			rts 
