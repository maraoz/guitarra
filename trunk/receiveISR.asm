ssi_rx_isr
		movec	x1,ssh
		movec	x0,ssl
		movec	y1,ssh
		movec	y0,ssl
		movec	a1,ssh
		movec	a0,ssl
		movec	a2,ssh
		movec	b1,ssh
		movec	b0,ssl
		movec	b2,ssh
		
        	movep   x:M_RX0,x0 	       	; Read a/d data
        	move	x:bits,y0
        	jset    #Left_ch,y0,esright
        	 
        
;ONSET DETECTION
		move 	x0,a	

		abs	a	x0,x:(r0)+	;guardo la muestra en inbuf, y calculo el abs(x(n))
		
		move	y:env0,b
		cmp	b,a			; abs(x(n))>=env(n-1)?
		
		bge	envge
		move	x:decay,x0		;si x<env, hago que env decaiga
		move	b,y0
		mpy 	x0,y0,a			;env*decay->env
		

envge		move	b,y:env0		; env(n-1)->env0

		move	a,x0
		
		mpyi	#0.005,x0,a	y:env1,y0
		move	y0,y:env2
		macri	#0,995,y0,a
		
		move	a,y:env1		; env(n)->env1
		
		
		move 	y:ignore,b		;estoy ignorando?
		tst 	b
		bne	ignoring
		
		move 	y:env2,b			;env esta decreciendo?
		cmp 	b,a
		blt 	nodecrece	
		
		move 	y:lastmin,b			;env<lastmin?
		cmp 	b,a
		tlt 	a,b	
		move	b,y:lastmin
		
nodecrece	move	y:innote,y0
		move 	y:env2,b
		sub 	b,a		x:denvt,b
		cmp 	b,a		x:envt,b	;denv<denvt?
		blt	noonset
		brset	#1,y0,yesonset
		move 	y:env1,a
		cmp 	b,a	y:lastmin,b		;env<envt?
		blt	noonset
		sub	b,a	x:mint,b	
		cmp	b,a				;(env-lastmin)<mint?
		blt	noonset
		
yesonset	bset 	#1,y:innote
		move	#0.999,a
		move 	a,y:lastmin
		move 	#N_IGNORE,a
		move 	a,y:ignore
							;flags para main
		move	r0,r1
		;move	#0,n1
		bset	#ONSETF,x:(r6)
		move	y:env1,y0
		move	y0,y:vel	
		;move 	#0.999,a 		;DEBUG
		jmp	finiupi

ignoring	dec 	b
		move 	b,y:ignore
		bra	noend

noonset		move	y:innote,y0
		brclr	#1,y0,noend
		move	y:env1,a
		move	x:endt,b
		cmp 	b,a
		bge	noend
endnote		bclr	#1,y:innote
		bset	#NENDF,x:(r6)
		move	#0.999,y0
		move	y0,y:lastmin
noend		;move 	#0,a 			;DEBUG

;FIN DE ONSET DETECTION
	
finiupi	
		include 'ks.asm'
		;debug
		;brclr	#STARTKS,x:(r6),nonote
		;bclr	#STARTKS,x:(r6)
		;move	#0.9999,x0
		;brclr	#DEBUG,x:(r6),doff
		;bclr	#DEBUG,x:(r6)
		;move	#$FFFFFF,x0
		
		jmp	endisr
		
doff		move	#$7FFFFF,a
		bset #DEBUG,x:(r6)
		;end debug			
		move	a,x0 
		jmp	endisr
	       

	
esright 	move	#0,x0			;mute the other channel
    
endisr  	movep   x0,x:M_TX00        	; write d/a data
		bchg	#Left_ch,x:bits

		movec	ssh,b2
		movec	ssl,b0
		movec	ssh,b1		
		movec	ssh,a2
		movec	ssl,a0
		movec	ssh,a1
		movec	ssl,y0
		movec	ssh,y1
		movec	ssl,x0
		movec	ssh,x1
		nop
		rti
	


