yin
r1 ;dirección de inicio	
x:WINDOW_SIZE 	;tamaño
x:LOOP_SIZE
x:ACF		;resultados de tamaño 512
x:RESULT




;for n=1:N/2
;    d(n)=sum((x(1:N-n+1)-x(n:N)).^2);
;end
		clr		n2
		move 	x:WINDOW_SIZE,b
		asl		b
		move 	b,x:LOOP_SIZE
		
		do 		b,bigloop
		
		clr		a		r1,r2	r1,y0
		inc		n2		x:WINDOW_SIZE,b
		sub		n2,b
		
		do		b,littleloop							
		move 				x:(r2+n2),x0	x:(r2)+,y0  ;Chequiar si se pueden referir los dos al mismo r2
		sub 	x0,y0	 	x0,y0						;Resto y copio el resultado
		mac 	x0,y0,a									;Al cuadrado y sumo	
littleloop
	
		move	(x:ACF),r2
		move 	a,(r2+n2)								;
bigloop

;for n=1:N/2;
;    dps=dps+d(n);
;    dp(n)=n*d(n)/dps;
;end
	
		clr		a		(x:ACF),r2
		dec		r2
		clr		n2
		move	#1,y0
		
		do		x:LOOP_SIZE,loopagain
		add		x:(r2+n2),a					;en a se va a acumulando
		move	x:(r2+n2),x0
		mpy		n2,x0,b
		div		a,b							;en b me queda el resultado
		move	b,x:(r2+n2)
;[dpm,T]=min(dp)	
		cmp		y0,b
		bge		greater
		
		move	n2,x:RESULT					;guardo el mínimo
		move	b,y0
	
greater	inc		n2

loopagain

;if dp(T)<0.1
;    if (T==1)||(T==N/2)
;        f=fs/T;
;    else
;        l=(3*dp(T-1)-4*dp(T)+dp(T+1))/(dp(T-1)-2*dp(T)+dp(T+1))/2;
;        a=T-1+l;
;        f=fs/a;
;    end
;else
;    f=0;
;end
		clr		a
		cmp 	#0.1,y0
		bgt		fin
		cmp		#1,n2
		bgt		final
		cmp		#x:LOOP_SIZE
		bgt		final
		clr		a
		clr		b
		dec		n2
		mpy		#3,x:(r2+n2),a
		mpy		#2,x:(r2+n2),b
		inc		n2
		mpy		#-4,x:(r2+n2),a
		mpy		#-4,x:(r2+n2),b
		inc		n2
		mpy		#1,x:(r2+n2),a
		mpy		#2,x:(r2+n2),b
		div		b,a
		add		n2,a
		sub		#2,a	
final	div		#FS,a
		div		#1,a							;Resultado en a
fin
	
	
	
	
	


