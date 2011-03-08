ONSETF		equ	0
NENDF		equ	1
STARTKS		equ	2
NEWNOTE		equ	3
STOPKS		equ	4

pitchdetector	equ	*
		brclr	#ONSETF,x:(r6),*	;espero a un onset
		bset	#NEWNOTE,x:(r6)
		
onseton		bclr	#ONSETF,x:(r6)
		move	r1,r2
		
test32		move	#>32,x1
test32l		brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		brclr	#4,n1,test32l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	test64
		move	a,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd
		
test64		move	#>64,x1
test64l		brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		brclr	#5,n1,test64l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	test128
		move	a,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd
		
test128		move	#>128,x1
test128l	brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		brclr	#6,n1,test128l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	test256
		move	a,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd

test256		move	#>256,x1
test256l	brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		brclr	#7,n1,test256l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	test512
		move	a,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd

test512		move	#>512,x1
test512l	brset	#ONSETF,x:(r6),resetpd
		brset	#NENDF,x:(r6),endnotepd
		brclr	#8,n1,test512l
		move	x1,x:WINDOW_SIZE
		jsr	yin
		tst	a
		beq	endnotepd
		move	a,y:t
		brset	#NEWNOTE,x:(r6),kickks
		bra	continuepd
		
		
resetpd		equ	onseton

endnotepd	bset	#STOPKS,x:(r6)
		bra	pitchdetector

kickks		bset	#STARTKS,x:(r6)
		bclr	#NEWNOTE,x:(r6)
continuepd	move	r2,a
		add	x1,a
		move	a,r2
		bra	onseton

;debug
yin		move	#1,a
		rts	