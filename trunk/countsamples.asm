countsamples	macro	nsamples

		move	r0,a
		move 	r2,b
		sub	b,a
		and	#0001FF,a
		move	#nsamples,b
		cmp	b,a
		; el CCR marca N-nsamples
		
