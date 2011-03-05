;=== constantes ===

FS			equ	16000
TS			equ	0.0000625
KS_BUFSIZE	equ	256
R			equ	0.995
T1			equ	0.16667
T2			equ	0.00833
T3			equ	0.00002
KS_K		equ	0.5
PI			equ	3.14159

;=== variables ===

ksbuf	dsm	KS_BUFSIZE
t	ds	1
vel	ds	1

;=== inicializacion ===

	move	#ksbuf,r2
	move	#KS_BUFSIZE-1,m2

;=== isr ===

; b=sin( pi*f/fs*(1-(fs/f-0.5-L)) ) / sin( pi*f/fs*(1+(fs/f-0.5-L)) );
; L=floor(fs/f-0.5);
ks_start
;calculo los parametros L y b del KS
			move	a,y0		;asumo que f esta en a, lo guardo en y0 = f
			move 	#1,a 		
			div		y0,a
			move	a,x:t		;guardo el periodo. chequear esto
			
			move 	#FS,x0		;calculo L
			move	a,x1
			mpy		x0,x1,a
			move	#KS_K,b
			sub		b,a
			move	a,b			;b = fs/f - 0.5				;vale move a,b ??
			move	#$000000,a0	;L = a [floor(a)]
			
			sub		b,a			;calculo b
			move 	a,y1		; y1 = -(fs/f-0.5-L) Esto sirve para el sin que divide tmb.
			add		#1,a		; 1+ (-(fs/f-0.5-L))
			
			move	a,x1
			move	#TS,x0
			mpy		x0,x1,a		; Ts * (1-(fs/f-0.5-L))
			move	a,x1
			move	#PI,x0
			mpy		x0,x1,a		; PI * Ts * (1-(fs/f-0.5-L))
			move	a,x1
			mpy		x1,x2,a		; f * PI * Ts * (1-(fs/f-0.5-L))
			jsr		sin
			move	a,y2		;y2 = sin( pi*f/fs*(1-(fs/f-0.5-L)) )
			
			move 	#-1,x0
			mpy		x0,y1,a		;+(fs/f-0.5-L)
			add		#1,a
			
			move	a,x1
			move	#TS,x0
			mpy		x0,x1,a		; Ts * (1+(fs/f-0.5-L))
			move	a,x1
			move	#PI,x0
			mpy		x0,x1,a		; PI * Ts * (1+(fs/f-0.5-L))
			move	a,x1
			mpy		x1,x2,a		; f * PI * Ts * (1+(fs/f-0.5-L))
			jsr		sin
			move	a,y1		;y1 = sin( pi*f/fs*(1+(fs/f-0.5-L)) )
			
			move 	#1,a 
			div		y1,a
			move	a,y0		; y0 = 1/y1
			mpy		y0,y2,a		; a = y0*y2 = b
			
			
			
			
sin	move	a,x0	;asumo que me pasan el valor en A y tambien lo devuelvo ahi ( sin(a) )
	mpy		x0,x0,b
	move	b,x1
	mpy		x0,x1,b
	move	b,x2
	move	#T1,y0
	mpy		x2,y0,b
	sub		b,a
	mpy		x1,x2,b
	move	b,x0
	move	#T2,y0
	mpy		x0,y0,b
	add		b,a
	mpy		x0,x1,b
	move	b,x0
	move	#T3,y0
	mpy		x0,y0,b
	sub		b,a
	rts