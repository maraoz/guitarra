;asumo que me pasan el valor en A y tambien lo devuelvo ahi ( sin(a) ). Se pierde el valor de B	
sin			movec	x0,SSL
			movec	x1,SSH
			movec	y0,SSL
			movec	y1,SSH
			move	a,x0	
			mpy		x0,x0,b
			move	b,x1
			mpy		x0,x1,b
			move	b,y1
			move	#T1,y0
			mpy		y1,y0,b
			sub		b,a
			mpy		x1,y1,b
			move	b,x0
			move	#T2,y0
			mpy		x0,y0,b
			add		b,a
			mpy		x0,x1,b
			move	b,x0
			move	#T3,y0
			mpy		x0,y0,b
			sub		b,a
			nop
			movec	SSL,y0
			movec	SSH,y1
			movec	SSL,x0
			movec	SSH,x1
			nop
			rts 