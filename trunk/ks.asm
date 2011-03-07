;=== constantes ===
FS			equ	16000
TS			equ	0.0000625
R			equ	0.995
T1			equ	0.16667
T2			equ	0.00833
T3			equ	0.00002
KS_K			equ	0.5
PI			equ	3.14159

;=== variables ===
;	org	y:
;	ksbuf	dsm	KS_BUFSIZE
;	f		ds	1
;	t		ds	1
;	vel		ds	1
;	ks_l	ds	1
;	ks_b	ds	1 
;	ks_cnt	ds	1
	
;=== inicializacion ===

;	move	#ksbuf,r7
;	move	#KS_BUFSIZE-1,m7
;	move	#1,y:vel
;	move	#0.005,y:t

;=== isr ===


;calculo los parametros L y b del KS
ks_start	move	#1,x0	 		;asumo que t esta en y:t, lo guardo en y0 = t
		move 	y:t,a		
		jsr	sig24div
		move	x1,y:f				;guardo el periodo. 
		move	#FS,x0
				
		move	a,x1
		mpy	x0,x1,a		#KS_K,b		;calculo L
		
		sub	b,a
		move	a,b					;b = fs/f - 0.5				;vale move a,b ??
		move	#$000000,a0			;L = a [floor(a)]
		move	a,y:ks_l
			
		sub	b,a			;calculo b
		move 	a,y1		; y1 = -(fs/f-0.5-L) Esto sirve para el sin que divide tmb.
		add	#1,a		; 1+ (-(fs/f-0.5-L))
			
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
	
