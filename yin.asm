;=== constantes ===
MIN_CMP		equ	$00000f	;0.1	????
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
YIN		macro
		;jmp 	_sapo_pepe
		
		move	#0,n3	
		
		clr		b
		move	x:WINDOW_SIZE,b0
		asr	b		
		move	b0,x:LOOP_SIZE
		
;;bigloop
		do 	b0,_bigloop	;b0
		
		clr	a		
		move	r2,r3
		move	n3,x0	
		move	x:WINDOW_SIZE,b		;Dir de inicio, me muevo con r3			
		sub	x0,b
;;littleloop
		do	b0,_littleloop		;b					
		move 	x:(r3+n3),b	
		move	x:(r3)+,x1
		sub 	x1,b
		move	b,x1	 	
		move	b,x0									;Resto y copio el resultado
		mac 	x0,x1,a									;Al cuadrado y sumo	
_littleloop
		;MULFIX????? MN??
		;rep	#8
		asr	#8,a,a
		move	#ACF,r3
		move	a,x:(r3+n3)
		
		clr		b	
		move	n3,b0		
		inc	b
		move	b0,n3

_bigloop

		;for n=1:N/2;
		;    dps=dps+d(n);
		;    dp(n)=n*d(n)/dps;
		;end
		
		clr		a
		move	x:LOOP_SIZE,a0
		asr		a
		move	x:(r3)+,x0
		rep		a0
		add		x0,b	x:(r3)+,x0
		move	a0,n3
		move	#ACF,r3
		move	#$010000,y0
;;LOOP
		move	x:LOOP_SIZE,a0
		asr		a
		do		a0,_loopagain		;a0
		move	x:(r3+n3),x0
		add		x0,b					;en b se va acumulando
		move	n3,x1
		mpy		x0,x1,a
		;MULFIX
		;DIVFIX
		move	b,x0
		DIV						;en x1 me queda el resultado				
		move	x1,x:(r3+n3)	
		move	y0,a
										;[dpm,T]=min(dp)	
		cmp		x1,a
		blt	_lower						;chequiar si puede haber saltos dentro de un loop
		
		move	n3,x:RESULT					;guardo el índice del mínimo
		move	x1,y0
	
_lower	clr		a	
		move	n3,a0
		inc	a
		move	a0,n3
_loopagain

		;if dp(T)<0.1
		;    if (T==1)||(T==N/2)
		;        f=fs/T;
		;    else
		;        l=(3*dp(T-1)-4*dp(T)+dp(T+1))/(4*dp(T-1)-8*dp(T)+4*dp(T+1));
		;        a=T-1+l;
		;        f=fs/a;
		;    end
		;else
		;    f=0;
		;end-------------------------------------------------------
		move	y0,x:(r4)+
		;----------------------------------------------------------
		clr	a
		move	#$010000,x1
		;bra		_final_yin
		
		move	#MIN_CMP,b
		cmp 	y0,b				;??
		ble	_fin_yin
		clr		b
		move	x:RESULT,b1
		cmp		#>$000001,b
		beq		_final_yin
		move	x:LOOP_SIZE,y1
		cmp	y1,b
		beq	_final_yin						
		
		move	#ACF,x0
		add	x0,b
		dec	b
		move	b,r3
		clr	b
		move	x:(r3)+,x0
		move	#IP_A0,y0
		move	#IP_B0,y1
		mac	y0,x0,b
		mac	y1,x0,a
		move	x:(r3)+,x0
		move	#IP_A1,y0
		move	#IP_B1,y1
		mac	y0,x0,b
		mac	y1,x0,a		;;??
		move	x:(r3),x0
		move	#IP_A2,y0
		move	#IP_B2,y1
		mac	y0,x0,b
		mac	y1,x0,a
		
		
		
		MULFIX
		MULFIXB
		move	y0,a
		DIVFIX
		DIV						;en x1 me queda el resultado
_final_yin
		clr		a
		move	x:RESULT,a1
		asl		#15,a,a
		;--------------------------------------------
		move	#$AAAAAA,x0
		move	x0,x:(r4)+
		move	a1,x:(r4)+
		move	x1,x:(r4)+
		move	#$FFFFFF,x0
		move	x0,x:(r4)+
		;--------------------------------------------
		;sub	#$010000,a
		;add	x1,a
								;CORREGIR EL RESULTADO
								;CHEQUIÄ
								;DEJALO EN MUESTRAS
											;LA MITAD DE MUESTRAS, GIL
											;Resultado en a en MN

_fin_yin	nop					;move	#$200000,a1
		
		endm	
	
	
	
	
	


