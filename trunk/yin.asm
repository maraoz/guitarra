;=== constantes ===
MIN_CMP		equ	$00A000	;0.1	????
IP_A0	equ		$030000	;3
IP_A1	equ		$FC0000	;-4
IP_A2	equ		$010000	;1
IP_B0	equ		$020000	;2
IP_B1	equ		$FC0000	;-4
IP_B2	equ		$020000	;2

;=== memoria ===
r1 ;recivo la dirección de inicio
r2,n2 ;uso este AGU	
x:WINDOW_SIZE 	;tamaño de la ventana
x:LOOP_SIZE		;tamaño dividido 2
x:ACF		;resultados de tamaño 512
x:RESULT	;para guardar el mínimo del yin

;=== isr ===
		;for n=1:N/2
		;    d(n)=sum((x(1:N-n+1)-x(n:N)).^2);
		;end
yin_start		clr		n2
		move 	x:WINDOW_SIZE,b0
		asl		b0
		move 	b0,x:LOOP_SIZE
;;LOOP
		do 		x:LOOP_SIZE,bigloop
		
		clr		a		
		move	r1,r2
		inc		n2		
		move	x:WINDOW_SIZE,b0
		sub		n2,b0
;;LOOP
		do		b0,littleloop							
		move 				x:(r2+n2),x0	x:(r2)+,y0  ;Chequiar si se pueden referir los dos al mismo r2
		sub 	x0,y0	 	x0,y0						;Resto y copio el resultado
		mac 	x0,y0,a									;Al cuadrado y sumo	
littleloop
	
		move	#ACF,r2
		move 	a0,x:(r2+n2)								
bigloop

		;for n=1:N/2;
		;    dps=dps+d(n);
		;    dp(n)=n*d(n)/dps;
		;end
		clr		a		
		move	#ACF,r2
		clr		n2
		move	#1,y0
;;LOOP
		do		x:LOOP_SIZE,loopagain
		add		x:(r2+n2),a0					;en a se va acumulando
		move	x:(r2+n2),x0
		mpy		n2,x0,b
		div		a,b							;en b me queda el resultado
		move	b0,x:(r2+n2)
		;[dpm,T]=min(dp)	
		cmp		y0,b0
		bge		greater
		
		move	n2,x:RESULT					;guardo el mínimo
		move	b0,y0
	
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
		cmp 	#MIN_CMP,y0				;??
		blt		fin
		move	n2,a0
		cmp		#1,n2
		beq		final
		cmp		x:LOOP_SIZE,n2
		beq		final
		clr		a
		clr		b
		dec		n2
		mpy		#IP_A0,x:(r2+n2),a
		mpy		#IP_B0,x:(r2+n2),b
		inc		n2
		mpy		#IP_A1,x:(r2+n2),a		;;??
		mpy		#IP_B1,x:(r2+n2),b		;;??
		inc		n2
		mpy		#IP_A2,x:(r2+n2),a
		mpy		#IP_B2,x:(r2+n2),b
		div		b,a
		add		n2,a
		sub		#2,a	
final	div		#FS,a
		div		#1,a							;Resultado en a

fin		rts		
	
	
	
	
	


