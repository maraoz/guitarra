;***************************************************************************
	nolist
	include 'ioequ.asm'
	include 'intequ.asm'
	include 'ada_equ.asm'
	include 'vectors.asm'  
	include 'sig24div.asm'
	include 'countsamples.asm'
	include	'mightymacroes.asm'
	include 'sin.asm'
	list
;******************************************************************************

		OPT	CEX			;Expand DC 

BUFSIZE		equ	1024
KS_BUFSIZE	equ	256
	

Left_ch		equ	0


CTRL_WD_12      equ     MIN_LEFT_ATTN+MIN_RIGHT_ATTN+LIN2+RIN2
CTRL_WD_34      equ     MIN_LEFT_GAIN+MIN_RIGHT_GAIN

;===========================================================

datin   	equ     $ffff           ;location in Y memory of input file
datout  	equ     $fffe           ;location in Y memory of output file

;========data===========================
       	org     x:0
inbuf  		dsm     	BUFSIZE        ;buffer de entrada
endinbuf	equ		*
bits		ds		1
flags		ds		1
WINDOW_SIZE	ds		1
decay		dc		0.99975
envt		dc		0.002
denvt		dc		0.0006
endt		dc		0.0006
mint		dc		0.003

	org		y:0
; variables del KS
ksbuf		dsm	KS_BUFSIZE
f			ds	1
t			ds	1
vel			ds	1
ks_l		ds	1
ks_b		ds	1
ks_cnt		ds	1

env1		ds		1
env2		ds		1
denv		ds		1
lastmin		ds		1
ignore		ds		1
innote		ds		1


        org     p:$100
START
main
        	movep   #$040007,x:M_PCTL  ; PLL 8 X 12.288 = 98.304MHz
        	ori     #3,mr              ; mask interrupts
        	movec   #0,sp              ; clear hardware stack pointer
        	move    #0,omr             ; operating mode 0
			
; init KS
		move	#ksbuf,r7
		move	#KS_BUFSIZE-1,m7
		move	#0,y0
		move	y0,y:vel
		move	#$200000,y0
		move	y0,y:t			

;==================

		move    #0,X0
		move    X0,x:bits


	
inifil		move    #inbuf,r0      ;point to input buffer
		move    #BUFSIZE-1,m0     ;mod(BUFSIZE)
		move	#inbuf,r1
		move    #BUFSIZE-1,m1 		;mod(BUFSIZE) (puntero para bloques)
	;	move    #outbuf,r4      	;point to output buffer
	;	move    #BUFSIZE-1,m4     	;mod(BUFSIZE)

		move	#flags,r6
				
			
		move	#0.999,y0
		move	y0,y:lastmin
		move	#0,x0
		move	x0,x:(r6)
		move	x0,y:ignore
		move	x0,y:env1
		move	x0,y:env2
;========================================


;=====================================
;      Inicializo port b for test
;=====================================

		movep	#$0001,X:M_HPCR 	;Port B I/O mode select
		movep	#$0001,X:M_HDDR 	;PB0 out
       
  

;========================================
 
	        jsr     ada_init            	;initialize codec

;ACA VA EL PITCH DETECT, MOTHERFUCKERS  

		include	'pitchdetector.asm'
        	
        	jmp	*	;si llegue aca hay algo mal.
        	
        	include 'ada_init.asm'			;used to include codec initialization routines
		
		end

 
