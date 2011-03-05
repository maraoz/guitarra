ssi_rx_isr
	
        movep   x:M_RX0,x0         	; Read a/d data
        move	X:bits,y0
        jset    #Left_ch,y0,esright 
        
;ONSET DETECTION
		
		move x0,a	

		abs	a	x0,x:(r0)+	;guardo la muestra en inbuf, y calculo el abs(x(n))
		
		move	y:env1,b
		cmp	b,a				; abs(x(n))>=env(n-1)?
		
		bge	envge
		move	x:decay,x0		;si x<env, hago que env decaiga
		move	b,y0
		mpy 	x0,y0,a			;env*decay->env
		
envge	move	b,y:env2			; env(n-1)->env2
		move	a,y:env1			; env(n)->env1
		
		
		move y:ignore,b
		tst b
		bne	ignoring
		
		move y:env2,b
		cmp b,a
		blt nodecrece	
		
		move y:lastmin,b
		cmp b,a
		tlt a,b	
		move	b,y:lastmin
		
nodecrece	move	y:innote,y0
		move y:env2,b
		sub b,a	x:denvt,b
		cmp b,a	x:envt,b
		blt	noonset
		brset	#1,y0,yesonset
		move y:env1,a
		cmp b,a	y:lastmin,b
		blt	noonset
		sub	b,a	x:mint,b
		cmp	b,a
		blt	noonset
		
yesonset	bset #1,y:innote
		move	#0.999,a
		move a,y:lastmin
		move #N_IGNORE,a
		move a,y:ignore
	;flags para main
		move #0.999,a ;DEBUG
		jmp	finiupi

ignoring	dec b
		move b,y:ignore
		bra	noend
noonset	move	y:innote,y0
		brclr	#1,y0,noend
		move	y:env1,a
		move	x:endt,b
		cmp b,a
		bge	noend
endnote	bclr	#1,y:innote
		move		#0.999,y0
		move		y0,y:lastmin
noend	move #0,a ;DEBUG

;FIN DE ONSET DETECTION

finiupi	move	a,x0
		jmp	endisr
	       
;KARPLUS

	
esright move	#0,x0			;mute the other channel
    
endisr  movep   x0,x:M_TX00        	; write d/a data
	bchg	#Left_ch,x:bits
	rti



