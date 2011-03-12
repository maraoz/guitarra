ONSETF		equ	0
NENDF		equ	1
STARTKS		equ	2
NEWNOTE		equ	3
STOPKS		equ	4

pitchdetector	equ	*
		brclr	#ONSETF,x:(r6),*	;espero a un onset
onseton		bset	#NEWNOTE,x:(r6)		
		bclr	#ONSETF,x:(r6)
		move	r1,r2
		
test32		move	#>32,x1
test32l		brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		countsamples
		blt	test32l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		
		tst	a
		beq	test64
		;bset	#STARTKS,x:(r6)
		move	a1,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd
		
test64		move	#>64,x1
test64l		brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		countsamples
		blt	test64l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	test128
		move	a1,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd
		
test128		move	#>128,x1
test128l	brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		countsamples
		blt	test128l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	test256
		move	a1,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd

test256		move	#>256,x1
test256l	brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		countsamples
		blt	test256l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	test512
		move	a1,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd

test512		move	#>512,x1
test512l	brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		countsamples
		blt	test512l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	endnotepd
		move	a1,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd
		
		
resetpd		equ	onseton

endnotepd	bset	#STOPKS,x:(r6)
		bclr	#NENDF,x:(r6)
		bra	pitchdetector

kickks		bset	#STARTKS,x:(r6)
		bclr	#NEWNOTE,x:(r6)
continuepd	move	r2,a
		add	x1,a
		move	a,r2
		bra	test32

;debug
yin		;move	#1,a		
		move	#$200000,a1
		rts	
