;=== constantes ===
MIN_CMP		equ	$0018C6	;0.1	????
IP_A0	equ		$030000	;3
IP_A1	equ		$FC0000	;-4
IP_A2	equ		$010000	;1
IP_B0	equ		$040000	;2
IP_B1	equ		$F80000	;-4
IP_B2	equ		$040000	;2

;=== memoria ===
r2 		;recibo la dirección de inicio
r3,n3 		;uso este AGU	
move	#BUFSIZE-1,m3
x:WINDOW_SIZE 	;tamaño de la ventana
x:LOOP_SIZE	;tamaño dividido 2
x:ACF		;resultados de tamaño 512
x:RESULT	;para guardar el mínimo del yin

;=== isr ===
		;for n=1:N/2
		;    d(n)=sum((x(1:N-n+1)-x(n:N)).^2);
		;end
yin_start	move	#0,n1	x:WINDOW_SIZE,b0
		asl	b		
		move	b0,x:LOOP_SIZE
;;LOOP
		do 	b0,bigloop
		
		clr	a		
		move	r2,r3
		move	n3,b0
		inc	b
		move	b0,n3	x:WINDOW_SIZE,x0			;Dir de inicio, me muevo con r3			
		sub	b0,x0
;;LOOP
		do	x0,littleloop							
		move 	x:(r3+n3),x0	
		move	x:(r3)+,x1
		sub 	x1,x0	 	
		move	x0,x1									;Resto y copio el resultado
		mac 	x0,x1,a									;Al cuadrado y sumo	
littleloop
		MULFIX
		move	#ACF,r3		
		move	x0,x:(r3+n3)						
bigloop

		;for n=1:N/2;
		;    dps=dps+d(n);
		;    dp(n)=n*d(n)/dps;
		;end
		clr	a
		clr 	b
		move	#0,n3
		move	#1,y0
;;LOOP
		move	x:LOOP_SIZE,a0
		do	a0,loopagain
		move	x:(r3+n3),x0
		add	x0,b					;en b se va acumulando
		move	n3,x1
		mpy	x0,x1,a
		MULFIX
		move	x0,a
		move	b,x0
		jsr	sig24div						;en x1 me queda el resultado
		DIVFIX					
		move	x1,x:(r3+n3)
										;[dpm,T]=min(dp)	
		cmp	y0,x1
		bge	greater						;chequiar si puede haber saltos dentro de un loop
		
		move	n3,x:RESULT					;guardo el índice del mínimo
		move	x1,y0
	
greater		move	n3,a0
		inc	a
		move	a0,n3
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
		clr	a
		clr	b
		
		move	#MIN_CMP,y1
		cmp 	y1,y0				;??
		bge	fin
		move	x:RESULT,x0
		cmp	#1,x0
		beq	final
		move	x:LOOP_SIZE,x1
		cmp	x1,x0
		beq	final
		
		move	#ACF,y0
		add	y0,x0
		move	x0,r3
		move	x:(-r3),x0
		move	#IP_A0,y0
		move	#IP_B0,y1
		mac	y0,x0,b
		mac	y1,x0,a
		move	x:(+r3),x0
		move	#IP_A1,y0
		move	#IP_B1,y1
		mac	y0,x0,b
		mac	y1,x0,a		;;??
		move	x:(+r3),x0
		move	#IP_A2,y0
		move	#IP_B2,y1
		mac	y0,x0,b
		mac	y1,x0,a	
		
		MULFIX
		MULFIXB
		move	y0,a
		jsr	sig24div						;en x1 me queda el resultado
		DIVFIX
		move	x:RESULT,x0
		addr	x1,x0
final		move	x0,a
								;CORREGIR EL RESULTADO
								;CHEQUIÄ
								;DEJALO EN MUESTRAS
											;LA MITAD DE MUESTRAS, GIL
											;Resultado en a

fin		rts		
	
	
	
	
	


