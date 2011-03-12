countsamples	macro

		move	r0,a
		move 	r2,b
		sub	b,a
		bge	_todomuybien
		move 	#$000400,b
		add	b,a
_todomuybien	move	x1,b
		cmp	b,a
		; el CCR marca N-nsamples
		
		endm
		
