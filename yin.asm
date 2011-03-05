yin
r1 ;dirección de inicio	
x:WINDOW_SIZE 	;tamaño
x:RESULTS		;resultados de tamaño 512

	clr		n2
	move 	x:WINDOW_SIZE,b
	asl		b
	
	do 		b,bigloop
	
	clr		a		r1,r2	r1,y0
	inc		n2		x:WINDOW_SIZE,b
	sub		n2,b
	
	do		b,littleloop							
	move 				x:(r2+n2),x0	x:(r2)+,y0  ;Chequiar si se pueden referir los dos al mismo r2
	sub 	x0,y0	 	x0,y0						;Resto y copio el resultado
	mac 	x0,y0,a									;Al cuadrado y sumo	
littleloop
	
	move	(x:RESULTS),r2
	move 	a,(r2+n2)								;
bigloop
