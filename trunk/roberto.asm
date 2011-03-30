;=== constantes ===
MIN_CMP		equ	$0019aa	;0.1  0019aa	????
IP_A0	equ		$030000	;3
IP_A1	equ		$FC0000	;-4
IP_A2	equ		$010000	;1
IP_B0	equ		$040000	;4
IP_B1	equ		$F80000	;-8
IP_B2	equ		$040000	;4

;=== memoria ===
;r2 		;recibo la direcci�n de inicio
;r3,n3 		;uso este AGU	
;move	#BUFSIZE-1,m3
;x:WINDOW_SIZE 	;tama�o de la ventana  ;numero entero??
;x:LOOP_SIZE	;tama�o dividido 2
;x:ACF		;resultados de tama�o 512
;x:RESULT	;para guardar el m�nimo del yin

;=== isr ===
		;for n=1:N/2
		;    d(n)=sum((x(1:N-n+1)-x(n:N)).^2);
		;end
YIN		macro
		;jmp 	_fin_yin
		
		move	#0,n3	
		
		clr		b
		move	x:WINDOW_SIZE,b0
		asr	b		
		move	b0,x:ACF_LOOP_SIZE
		
;;bigloop
		do 	b0,_bigloop	;b0
		
		clr	a		
		move	r2,r3
		move	n3,x0	
		move	x:WINDOW_SIZE,b		;Dir de inicio, me muevo con r3			
		sub	x0,b
;;littleloop
		do	b1,_littleloop		;b				
		move 	x:(r3+n3),b	
		move	x:(r3)+,x1
		sub 	x1,b
		move	b,x1	 	
		move	b,x0									;Resto y copio el resultado
		mac 	x0,x1,a									;Al cuadrado y sumo	
_littleloop
		;MULFIX
		asr	#8,a,a				;ALE: alcanza el formato mn para guardar acf?
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
		
		clr		b
		clr		a
		move	x:ACF_LOOP_SIZE,a0
		asr		a
		move	a0,n3
		dec		a
		move	x:(r3)+,x0
		rep		a0
		add		x0,b	x:(r3)+,x0	;ALE: alcanza el formato mn para guardar esta suma?
		move		b,x:ACF_ACCUM
		
		move		#ACF,r3
			
		move		#0,x0
		move		x0,x:ACF_RESULT
		move		x0,y:bajando
		move		#$010000,y1
		
_loopagain
		move		x:(r3+n3),x0
		move		x:ACF_ACCUM,b
		add		x0,b					;en b se va acumulando
		move		b,x:ACF_ACCUM
		move	n3,a
		asl	#16,a,a
		move		a,x1
		mpy		x0,x1,a
		;MULFIX
		;DIVFIX
		move	b,x0
		DIV
		move	x1,x:(r3+n3)			;ALE: alcanza el formato mn para guardar esta autocorrelacion?
		
		move	x1,a
		cmp	y1,a
		bge	_nobaja
		
		move	#>$000001,y0
		move	y0,y:bajando
		bra	_overthres
										;[dpm,T]=min(dp)	
_nobaja	move	y:bajando,a
		move	#>$000000,y0
		move	y0,y:bajando
		tst	a
		beq	_overthres

		move	#>MIN_CMP,a
		cmp		y1,a
		ble	_overthres
		
		clr	a
		move n3,a0
		dec	a
		move	a0,x:ACF_RESULT
		
		bra	_encontremin
	
_overthres	clr		a	
		move	n3,a0
		inc	a
		move	a0,n3
		
		move		x1,y1
		
		move		x:ACF_LOOP_SIZE,a
		move	n3,y0
		cmp	y0,a
		bne		_loopagain		
;;loopagain

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
		;end
		
_encontremin	
		move	#$008000,x1
		move	x:ACF_RESULT,a
		tst		a
		beq	_fin_yin
		;move	x:ACF_LOOP_SIZE,b
		;sub	#>$000001,b
		;cmp	x0,b					;hay que comparar con N/2-1
		;ble	_final_yin
		;add	#>$000001,b
		;asr	b						
		;cmp		x0,b		;hay que comparar con N/4
		;bge		_final_yin
		
		bra		_final_yin
		move	#ACF,x0
		add		x0,a
		sub		#>$000001,a
		move	a,r3
		clr	a
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
		move	x:ACF_RESULT,a1
		asl		#15,a,a
		sub		#>$008000,a
		add	x1,a
								;CORREGIR EL RESULTADO
								;CHEQUI�
								;DEJALO EN MUESTRAS
											;LA MITAD DE MUESTRAS, GIL
											;Resultado en a en MN

_fin_yin	nop					;move	#$200000,a1
		
		endm	
	
	
	
	
	

