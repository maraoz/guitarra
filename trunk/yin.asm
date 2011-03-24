;=== constantes ===
MIN_CMP		equ	$00199a	;0.1	????
IP_A0	equ		$030000	;3
IP_A1	equ		$FC0000	;-4
IP_A2	equ		$010000	;1
IP_B0	equ		$040000	;4
IP_B1	equ		$F80000	;-8
IP_B2	equ		$040000	;4

;=== memoria ===
;r2 		;recibo la dirección de inicio
;r3,n3 		;uso este AGU	
;move	#BUFSIZE-1,m3
;x:WINDOW_SIZE 	;tamaño de la ventana  ;numero entero??
;x:LOOP_SIZE	;tamaño dividido 2
;x:ACF		;resultados de tamaño 512
;x:RESULT	;para guardar el mínimo del yin

;=== isr ===
		;for n=1:N/2
		;    d(n)=sum((x(1:N-n+1)-x(n:N)).^2);
		;end
yin		jmp fin
		move	#0,n3	
		move	x:WINDOW_SIZE,b0
		asl	b		
		move	b0,x:LOOP_SIZE
;;LOOP
		do 	b0,bigloop
		
		clr	a		
		move	r2,r3
		move	n3,x0	
		move	x:WINDOW_SIZE,b			;Dir de inicio, me muevo con r3			
		sub	x0,b
;;LOOP
		do	b0,littleloop							
		move 	x:(r3+n3),b	
		move	x:(r3)+,x1
		sub 	x1,b
		move	b,x1	 	
		move	b,x0									;Resto y copio el resultado
		mac 	x0,x1,a									;Al cuadrado y sumo	
littleloop
		;MULFIX????? MN??
		;rep	#8
		asl		#8,a,a
		move	#ACF,r3
		move	a,x:(r3+n3)
		move	n3,b0		
		inc	b
		move	b0,n3						
bigloop

		;for n=1:N/2;
		;    dps=dps+d(n);
		;    dp(n)=n*d(n)/dps;
		;end
		clr	a
		clr 	b
		move	#0,n3
		move	#$010000,y0
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
		DIV						;en x1 me queda el resultado
		DIVFIX					
		move	x1,x:(r3+n3)	
		move	y0,a
										;[dpm,T]=min(dp)	
		cmp		x1,a
		blt	lower						;chequiar si puede haber saltos dentro de un loop
		
		move	n3,x:RESULT					;guardo el índice del mínimo
		move	x1,y0
	
lower		move	n3,a0
		inc	a
		move	a,n3
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
		move	#0,x1
		
		move	#MIN_CMP,b
		cmp 	y0,b				;??
		blt		fin
		move	x:RESULT,b
		cmp		#$000001,b
		beq		final
		move	x:LOOP_SIZE,y1
		cmp		y1,b
		beq	final						
		
		move	#ACF,x0
		add		x0,b
		dec		b
		move	b,r3
		clr		b
		move	x:(r3)+,x0
		move	#IP_A0,y0
		move	#IP_B0,y1
		mac		y0,x0,b
		mac		y1,x0,a
		move	x:(r3)+,x0
		move	#IP_A1,y0
		move	#IP_B1,y1
		mac		y0,x0,b
		mac		y1,x0,a		;;??
		move	x:(r3),x0
		move	#IP_A2,y0
		move	#IP_B2,y1
		mac		y0,x0,b
		mac		y1,x0,a	
		
		MULFIX
		MULFIXB
		move	y0,a
		DIV						;en x1 me queda el resultado
		DIVFIX
final	move	x:RESULT,y0
		move	#>32,x0	
		mpy		x0,y0,a
		move	a0,x0
		move	x0,a
		add		x1,a
								;CORREGIR EL RESULTADO
								;CHEQUIÄ
								;DEJALO EN MUESTRAS
											;LA MITAD DE MUESTRAS, GIL
											;Resultado en a en MN

fin		move	#$200000,a
		rts		
	
	
	
	
	


