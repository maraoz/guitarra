
;=== constantes ===
R			equ	$00FEB8
T1			equ	$03243F	;Taylor
T3			equ	$052AEF
T5			equ	$028CD8
T7			equ	$009969
KS_K			equ	$004000	; 0.25
 
;=== isr ===
		move	x:bicho,x0
		tst	x0
		beq	salto
		nop
		move	#1,x:bicho
salto
		
		move	#$7FFFFF,x0
		move	x0,y:vel
;calculo los parametros L y b del KS
ks_start	move	#$010000,a
		DIVFIX
		move	x:t,x0 		;asumo que t esta en x:t, lo guardo en y0 = t	
		DIV
		
		move	x1,x:f				;guardo la frecuencia a partir del t calculado. 
		; L = floor (1/f - 0.25)
		move 	x:t,a
		move	#KS_K,x0
		sub	x0,a				;a = 1/f - 0.25	
		
		and	#$FF8000,a							
		move	a,x:ks_l			; saco floor y guardo en ks_l
		
		; b  = sin( f * (1.5+L) - 1 ) / sin( f * (0.5-L) + 1 )
		move	#$00C000,a	
		move	x:ks_l,x0			; cargo 0.75
		add	x0,a				; 0.75+L = A
		move	x:f,x0		
		move	a,x1		
		mpy	x0,x1,a
		MULFIX					; f*(0.75+L) = x0		
		move	#$FF0000,a			;cargo -1
		add	x0,a				; f * (0.75+L) - 1 = A
		nop
		move	a,x0	
		
		SIN
		
		move	x0,y1				; Queda guardado en Y1, el valor de sin(blabla)

		move	#$004000,a	
		move	x:ks_l,x0	; cargo 0.25
		sub	x0,a				; 0.25-L = A
		move	x:f,x0		
		move	a,x1
		mpy	x0,x1,a
		MULFIX					; f*(0.25-L) = x0
		move	#$010000,a			;cargo +1
		add	x0,a				; f*(0.25-L) + 1 = A
		nop
		move	a,x0
		SIN				; Queda guardado en X0, el valor de sin(blabla)	
		
		move	y1,b
		DIVFIXB
		move	b,a
		DIV
		move	x1,x:ks_b			; guardo valor de b en ks_b
		
;filtro del ks
		brclr	#STOPKS,x:(r6),ks_sigo
		bclr	#STOPKS,x:(r6)
		
		move	#$00E979,y0
		move	y0,x:ks_r

ks_sigo	brclr	#STARTKS,x:(r6),ks_main
		bclr	#STARTKS,x:(r6)
		
		move	#$00FEB8,y0
		move	y0,x:ks_r
		
		move	#>$3,x1
		move	x1,y:ks_cnt	; Si es Nueva nota refresco x(n) con la delta. 
		
ks_main	clr	a	y:ks_cnt,b
		tst	b
		beq	ks_continua		;cnt == 0 => ya paso la delta
		cmp	#>$1,b
		bne	ks_mayora1		
		move	x:ks_b,y0
		jmp	ks_mul
		
ks_mayora1	cmp	#>$2,b
		bne	ks_mayora2
		move	x:ks_b,b
		add	#$010000,b
		move	b,y0			
		jmp	ks_mul
		
ks_mayora2	move	#$010000,y0		

ks_mul	move	y:vel,a

		DIVFIX
		move	a,x0
		
		mpy	x0,y0,a			; vel * algo
		
		move	y:ks_cnt,b		; decremento ks_cnt
		sub	#>$1,b
		move	b,y:ks_cnt		
		
ks_continua	move	x:ks_l,y1

		move	#$000100,y0
		mpy	y0,y1,b
		
		move	b,n7
		move	#R,x0
		move	x:ks_b,x1
		mpy	x1,x0,b			; b = R*b
		MULFIXB

		move	y:(r7+n7),y1
		mac	y1,y0,a			; A = R*b*y(n-L); A = termino1

		move	n7,b0
		inc	b
		move	b0,n7
		
		move	x0,b
		add	y0,b			; B = R * (b+1) 
		nop
		move	y:(r7+n7),y1	
		move	b,y0
		mac	y0,y1,a			; A = R * (b+1) * y(n-L-1); A = termino1 + termino 2

		move	n7,b0
		inc		b
		move	b0,n7		
		move	y:(r7+n7),y1
		mac	x0,y1,a			; A = R*y(n-L-2); A = termino1 + termino2 + termino3
		
		move	#>$000001,n7			
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
