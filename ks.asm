;=== constantes ===
R			equ	$00FEB8
T1			equ	$00860A	;Taylor
T2			equ	$00150E
T3			equ	$000193
KS_K			equ	$004000	; 0.25

;=== isr ===

;calculo los parametros L y b del KS
ks_start	move	#0,a
		move	#$010000,a1	y:t,x0 		;asumo que t esta en y:t, lo guardo en y0 = t
		jsr	sig24div
		DIVFIX
		move	x1,y:f				;guardo la frecuencia a partir del t calculado. 
		
		; L = floor (1/f - 0.25)
		move 	y:t,x0		#0,a
		move	#KS_K,a1
		sub	x0,a				;a = 1/f - 0.25	
		
		and	#$FF0000,a							
		move	a1,y:ks_l			; saco floor y guardo en ks_l
		
		; b  = sin( f * (1.5+L) - 1 ) / sin( f * (0.5-L) + 1 )
		move	#0,a
		move	#$00C000,a1	y:ks_l,x0	; cargo 0.75
		add	x0,a				; 0.75+L = A
		move	y:f,x0		a1,x1
		mpy	x0,x1,a
		MULFIX					; f*(0.75+L) = x0
		move	#0,a
		move	#$FF0000,a1			;cargo -1
		add	x0,a				; f * (0.75+L) - 1 = A
		move	a1,x0
		jsr	sin
		move	x0,y1				; Queda guardado en Y1, el valor de sin(blabla)

		move	#0,a
		move	#$004000,a1	y:ks_l,x0	; cargo 0.25
		sub	x0,a				; 0.25-L = A
		move	y:f,x0		a1,x1
		mpy	x0,x1,a
		MULFIX					; f*(0.25-L) = x0
		move	#0,a
		move	#$010000,a1			;cargo +1
		add	x0,a				; f*(0.25-L) + 1 = A
		move	a1,x0
		jsr	sin				; Queda guardado en X0, el valor de sin(blabla)	
		
		move	#0,a
		move	y1,a1
		jsr	sig24div
		DIVFIX
		move	x1,y:ks_b			; guardo valor de b en ks_b
		
;filtro del ks
		brclr	#STARTKS,x:(r6),ks_main
		bclr	#STARTKS,x:(r6)
		move	#$030000,x1
		move	x1,y:ks_cnt	; Si es Nueva nota refresco x(n) con la delta. vel > 0 indica nueva nota.
		
ks_main		move	#0,a	#0,b
		move	y:ks_cnt,b1
		tst	b
		beq	ks_continua		;cnt == 0 => ya paso la delta
		sub	#$00010000000000,b
		tst	b
		bne	ks_mayora1		
		move	y:ks_b,y0
		jmp	ks_mul
		
ks_mayora1	sub	#$00010000000000,b
		tst	b
		bne	ks_mayora2
		move	#0,b
		move	y:ks_b,b1
		add	#$00010000000000,b
		move	b1,y0			
		jmp	ks_mul
		
ks_mayora2	move	#$010000,y0		

ks_mul		move	y:vel,x1
		DIVFIX
		mpy	x1,y0,a			; vel * algo
		move	#0,b
		move	y:ks_cnt,b1		; decremento ks_cnt
		sub	#$00010000000000,b
		move	b1,y:ks_cnt		
		
ks_continua	move	#R,x0
		move	y:ks_b,x1
		mpy	x1,x0,b			; b = R*b
		MULFIXB
		;;;;;;;;;;;;;;;;;ESTAMOS ACAAAAAAAAA;;;;;;;;;;;;;;;;;;
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
	
