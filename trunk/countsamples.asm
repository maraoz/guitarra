countsamples	macro

		move	r0,a
		move 	r2,b
		sub	b,a
		bge	_cspos
		move 	#BUFSIZE,b
		add	b,a
_cspos	move	x1,b
		cmp	b,a
		; el CCR marca N-nsamples
		
		endm
		
