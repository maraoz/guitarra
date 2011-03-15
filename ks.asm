
;=== constantes ===
R			equ	$00FEB8
T1			equ	$00860A	;Taylor
T2			equ	$00150E
T3			equ	$000193
KS_K			equ	$004000	; 0.25
 
;=== isr ===
		;move	#$F00000,x0
		;move	x0,y:vel
;calculo los parametros L y b del KS
ks_start	move	#$010000,a
		DIVFIX	
		move	y:t,x0 		;asumo que t esta en y:t, lo guardo en y0 = t
		jsr	sig24div
		move	x1,y:f				;guardo la frecuencia a partir del t calculado. 
		
		; L = floor (1/f - 0.25)
		move 	y:t,x0
		move	#KS_K,a
		sub	x0,a				;a = 1/f - 0.25	
		
		and	#$FF0000,a							
		move	a,y:ks_l			; saco floor y guardo en ks_l
		
		; b  = sin( f * (1.5+L) - 1 ) / sin( f * (0.5-L) + 1 )
		move	#$00C000,a	
		move	y:ks_l,x0			; cargo 0.75
		add	x0,a				; 0.75+L = A
		move	y:f,x0		
		move	a1,x1
		mpy	x0,x1,a
		MULFIX					; f*(0.75+L) = x0
		move	#$FF0000,a			;cargo -1
		add	x0,a				; f * (0.75+L) - 1 = A
		nop
		move	a,x0
		jsr	sin
		move	x0,y1				; Queda guardado en Y1, el valor de sin(blabla)

		move	#$004000,a	
		move	y:ks_l,x0	; cargo 0.25
		sub	x0,a				; 0.25-L = A
		move	y:f,x0		
		move	a1,x1
		mpy	x0,x1,a
		MULFIX					; f*(0.25-L) = x0
		move	#$010000,a			;cargo +1
		add	x0,a				; f*(0.25-L) + 1 = A
		nop
		move	a,x0
		jsr	sin				; Queda guardado en X0, el valor de sin(blabla)	
		
		move	y1,a
		DIVFIXB
		jsr	sig24div
		move	x1,y:ks_b			; guardo valor de b en ks_b
		
;filtro del ks
		brclr	#STARTKS,x:(r6),ks_main
		bclr	#STARTKS,x:(r6)
		move	#$030000,x1
		move	x1,y:ks_cnt	; Si es Nueva nota refresco x(n) con la delta. 
		
ks_main		clr	a	y:ks_cnt,b
		tst	b
		beq	ks_continua		;cnt == 0 => ya paso la delta
		sub	#$010000,b
		bne	ks_mayora1		
		move	y:ks_b,y0
		jmp	ks_mul
		
ks_mayora1	sub	#$010000,b
		bne	ks_mayora2
		move	y:ks_b,b
		add	#$010000,b
		move	b,y0			
		jmp	ks_mul
		
ks_mayora2	move	#$010000,y0		

ks_mul		move	y:vel,x1

		move	#$010000,x0
		mpy	x0,x1,a
		move	a,x1
		
		mpy	x1,y0,a			; vel * algo
		move	y:ks_cnt,b		; decremento ks_cnt
		sub	#$010000,b
		move	b,y:ks_cnt		
		
ks_continua	move	y:ks_l,y0
		move	#$000100,y1
		mpy	y0,y1,b
		move	b,n7
		
		move	#R,x0
		move	y:ks_b,x1
		mpy	x1,x0,b			; b = R*b
		MULFIXB

		move	y:(r7+n7),y1	
		move	b,y0			; y0 = R*b
		mac	y1,y0,a			; A = R*b*y(n-L); A = termino1

		move	n7,b0
		inc	b
		move	b0,n7
		
		move	x0,b
		add	y0,b			; B = R * (b+1) 
		nop
		move	y:(r7+n7),y1	
		move	b1,y0
		mac	y0,y1,a			; A = R * (b+1) * y(n-L-1); A = termino1 + termino 2

		move	#0,b
		move	n7,b1
		add	#$000001,b
		nop
		move	b1,n7		
		move	y:(r7+n7),y1
		mac	x0,y1,a			; A = R*y(n-L-2); A = termino1 + termino2 + termino3
		
		move	#$000001,n7			
		move	y:(r7+n7),y1
		mpy	x1,y1,b			; b = b * y(n-1)
		MULFIXB
		move	#$020000,x1
		mac	-y0,x1,a		; b = 2 * b * y(n-1); a = termino1 + termino2 + termino3 - termino 4
		MULFIX
		
		move	#$008000,x1
		mpy	x0,x1,a			;  a = (termino1 + termino2 + termino3 - termino4 ) * 0.5
		MULFIX
		
		move	x0,y:(r7)-
		
		move	x0,a
		MULFIX
