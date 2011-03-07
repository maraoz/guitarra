;=== constantes ===
R			equ	0.995
T1			equ	0.16667
T2			equ	0.00833
T3			equ	0.00002
KS_K			equ	$004000	; 0.25

;=== isr ===

;calculo los parametros L y b del KS
ks_start	move	#0,a
		move	#$010000,a1	y:t,x0 		;asumo que t esta en y:t, lo guardo en y0 = t
		jsr	sig24div
		DIVFIX
		move	x1,y:f				;guardo la frecuencia a partir del t calculado. 
				
		move 	y:t,x0		#0,a
		move	#KS_K,a1
		sub	x0,a				;a = 1/f - 0.5	
		
		and	#$FF0000,a							
		move	a1,y:ks_l			; saco floor y guardo en ks_l
;
	b = sin( f * (1.5+L) - 1 ) / sin( f * (0.5-L) + 1 )

		move	#0,a
		move	#$018000,a1	y:ks_l,x0	; cargo 1.5
		add	x0,a				; 1.5+L = A
		move	y:f,x0		a1,x1
		mpy	x0,x1,a
		MULFIX					; f*(1.5+L) = x0
		move	#0,a
		move	#$FE0000,a1
		add	x0,a				; f * (1.5+L) - 1 = A
			
		sub	b,a			;calculo b
		move 	a,y1			; y1 = -(fs/f-0.5-L) Esto sirve para el sin que divide tmb.
		add	#1,a			; 1+ (-(fs/f-0.5-L))
			
		move	a,x1
		move	#TS,x0
		mpy	x0,x1,a		; Ts * (1-(fs/f-0.5-L))
		move	a,x1
		move	#PI,x0
		mpy	x0,x1,a		; PI * Ts * (1-(fs/f-0.5-L))
		move	a,x1
		move	y:f,x0
		mpy	x0,x1,a		; f * PI * Ts * (1-(fs/f-0.5-L))
		jsr	sin
		move	a,y0		;y0 = sin( pi*f/fs*(1-(fs/f-0.5-L)) )
		
		move 	#-1,x0
		mpy	x0,y1,a		;+(fs/f-0.5-L)
		add	#1,a
		
		move	a,x1
		move	#TS,x0
		mpy	x0,x1,a		; Ts * (1+(fs/f-0.5-L))
		move	a,x1
		move	#PI,x0
		mpy	x0,x1,a		; PI * Ts * (1+(fs/f-0.5-L))
		move	a,x1
		move	y:f,x0
		mpy	x0,x1,a		; f * PI * Ts * (1+(fs/f-0.5-L))
		jsr	sin
		move	a,y1		;y1 = sin( pi*f/fs*(1+(fs/f-0.5-L)) )
		
		move	y0,b
		div	y1,b		; y0 resultado b
		move	b,y:ks_b
		
;filtro del ks
		move	x:onset,x0
		move	x0,b
		tst	b
		ble	ks_main	
		move	#0,x0
		move	x0,x:onset
		move	#3,x1
		move	x1,y:ks_cnt	; Si es Nueva nota refresco x(n) con la delta. vel > 0 indica nueva nota.
		
ks_main		move	#0,a
		move	y:ks_cnt,x1
		move	x1,b
		tst	b
		beq	ks_continua		;cnt == 0 => ya paso la delta
		move	x1,b
		sub	#1,b
		tst	b
		bne	ks_mayora1		
		move	y:ks_b,y0
		jmp	ks_mul
		
ks_mayora1	sub	#1,b
		tst	b
		bne	ks_mayora2
		move	y:ks_b,b
		add	#1,b
		move	b,y0			
		jmp	ks_mul
		
ks_mayora2	move	#1,y0		

ks_mul		mpy	x0,y0,a			; vel * algo
		move	y:ks_cnt,b		; decremento ks_cnt
		sub	#1,b
		move	b,y:ks_cnt		
		
ks_continua	move	#R,y0
		move	y:ks_b,y1
		mpy	y1,y0,b			; b = R*b
			
		move	y:ks_l,n7			
		move	y:(r7+n7),x1
		move	b,x0			; x0 = R*b
		mpy	x1,x0,b			; b = R*b*y(n-L)
		add	b,a				; a = termino1
			
		move	x0,b
		add	y0,b			; b = R * (b+1) 
		move	b,x0
		move	y:ks_l,b
		add	#1,b
		move	b,n7			
		move	y:(r7+n7),x1
		mpy	x0,x1,b			; b = R * (b+a) * y(n-L-1)
		add	b,a				; a = termino1 + termino 2

		move	y:ks_l,b
		add	#2,b
		move	b,n7			
		move	y:(r7+n7),x1
		mpy	y0,x1,b			; b = R*y(n-L-2)
		add	b,a				; a = termino1 + termino2 + termino3
		
		move	#1,n7			
		move	y:(r7+n7),x1
		mpy	x1,y1,b			; b = R * y(n-1)
		move	b,x0
		move	#2,x1
		mpy	x0,x1,b			; b = 2 * b * y(n-1)
		sub	b,a				; a = termino1 + termino2 + termino3 - termino 4
		
		move	#0.5,x0
		move	a,x1
		mpy	x0,x1,a			;  a = (termino1 + termino2 + termino3 - termino4 ) * 0.5
		
		move	a,y:(r7)-
	
