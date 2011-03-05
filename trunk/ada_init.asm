	page    132,60
;**************************************************************************
;       ADA_INIT.ASM    Ver 1.2
;       Example program to initialize the CS4218
;
;       Copyright (c) MOTOROLA 1995, 1996, 1997, 1998
;		      Semiconductor Products Sector 
;		      Wireless Signal Processing Division
; 
;       History:
;               	14 June 1996:  RLR/LJD - ver 1.0
;               	21 July 1997:  BEA     - ver 1.1
;		    	23 Sept 1998:  TTL     - ver 1.2	
;**************************************************************************
 
N_IGNORE	equ 1000
        org     x:

; Codec control constants
CTRL_WD_HI      ds      1
CTRL_WD_LO      ds      1


; GPIO  pin constants 

                                ; ESSI0 - audio data GPIO mode
                                ; DSP                   CODEC
                                ; ---------------------------
CODEC_RESET     equ     0       ; bit0  SC00    --->    CODEC_RESET~

                                ; ESSI1 - control data GPIO Mode
                                ; DSP                   CODEC
                                ;----------------------------
CCS             equ     0       ; bit0  SC10    --->    CCS~
CCLK            equ     1       ; bit1  SC11    --->    CCLK
CDIN            equ     2       ; bit2  SC12    --->    CDIN

;**************************************************************************
; Initialize the CS4218 codec
; ---------------------------
; Serial Mode 4 (SM4), DSP Slave/Codec Master, 32-bits per frame
;
; After a reset, the control port must be written once to initialize it
; if the port will be accessed to read or write control bits.  The initial
; write is a "dummy" write since the data is ignored by the codec.  A second
; write is needed to configure the codec as desired.  Then, the control port
; only needs to be written to when a change is desired, or to obtain status
; information.
;
; Although only 23 bits contain useful data in CDIN, a minimum of 31 bits
; must be written.
;
; CDIN
;------------------------------------------------       
; bit 31                0
;------------------------------------------------       
; bit 30                mask interrupt
;                       0=no mask on MF5:\INT pin
;                       1=mask on MF5:\INT pin
;------------------------------------------------       
; bit 29                DO1
;------------------------------------------------       
; bits 28-24            left output D/A sttenuation  (1.5dB steps)
;                       00000=No attenuation 0dB
;                       11111=Max attenuation -46.5dB
;------------------------------------------------       
; bits 23-19            right output D/A attenuation (1.5dB steps)
;                       00000=No attenuation 0dB
;                       11111=Max attenuation -46.5dB
;------------------------------------------------       
; bit 18                mute D/A outputs
;                       0=outputs ON
;                       1=outputs MUTED
;------------------------------------------------       
; bit 17                input mux, left select
;                       0=RIN1
;                       1=RIN2 (used on EVM)
;------------------------------------------------       
; bit 16                input mux, right select
;                       0=LIN1
;                       1=LIN2 (used on EVM)
;------------------------------------------------
; bits 15-12            left input A/D gain (1.5dB steps)
;                       0000=No gain 0dB
;                       1111=Max gain +22.5dB
;------------------------------------------------       
; bits 11-8             right input A/D gain (1.5dB steps)
;                       0000=No gain 0dB
;                       1111=Max gain +22.5dB
;------------------------------------------------
; bits 7-0              00000000
;------------------------------------------------
;**************************************************************************


        org     p:
ada_init
	
	; reset ESSI ports
	movep   	#$0000,x:M_PCRC         ; reset ESSI0 port 
	movep		#$0000,x:M_PCRD		; reset ESSI1 port	      

	; Set Control Register A and B
	movep   	#$101807,x:M_CRA0       ; 12.288MHz/16 = 768KHz SCLK                                       
							; prescale modulus = 8
                                        	; frame rate divider = 2
                                        	; 16-bits per word
                                        	; 32-bits per frame
                                        	; 16-bit data aligned to bit 23

      movep   	#$ff330c,x:M_CRB0       ; Enable REIE,TEIE,RLIE,TLIE,
                                        	; RIE,TIE,RE,TE0
                                        	; network mode, synchronous,
                                        	; out on rising/in on falling
                                        	; shift MSB first
                                        	; external clock source drives SCK 
                                        	; (codec is master)
                                        	; RX frame sync pulses active for
                                        	; 1 bit clock immediately before
                                        	; transfer period
                                        	; positive frame sync polarity
                                        	; frame sync length is 1-bit                                        
      
	; Configure GPIO pins -- (functionality and direction)
      movep   	#$0000,x:M_PCRC         ; Enable GPIO pin 0 SC00=CODEC_RESET
      movep	#$0000,x:M_PCRD			; Enable GPIO CSS (pin 0),CCLK (pin 1), CDIN (pin 2)
                          
      movep   	#$0001,x:M_PRRC         ; set PC0=CODEC_RESET~ as output
      movep  	#$0007,x:M_PRRD         ; set PD0=CCS~ as output
                                        ; set PD1=CCLK as output
                                        ; set PD2=CDIN as output

; Codec Reset
	bclr    	#CODEC_RESET,x:M_PDRC   ; assert CODEC_RESET~
      	bclr    	#CCS,x:M_PDRD           ; assert CCS~ -- allows control register to be written to
	
	; Delay to allow Codec to reset
	do      	#1000,_delay_loop
      	rep     	#1000                   ; minimum 50 ms delay 
      	nop
_delay_loop

        
; Setting up to send Codec control information  
      	bset    	#CODEC_RESET,x:M_PDRC   ; deassert CODEC_RESET~
	

	; Sending control words
set_control
      	move    	#CTRL_WD_12,x0		; transfer control value to control variable
      	move    	x0,x:CTRL_WD_HI         
	move    	#CTRL_WD_34,x0
      	move    	x0,x:CTRL_WD_LO         
      	jsr     	codec_control		; send in dummy control information 
	jsr     	codec_control		; send in correct control information	

        
	; Set and enable interrupts
	movep   #$000c,x:M_IPRP         ; set interrupt priority level for ESSI0 to 3
      	andi    #$fc,mr                 ; enable interrupts

	; Set ESSI functionality 
	movep   #$003e,x:M_PCRC         ; enable ESSI0 except SC00=CODEC_RESET
	
	rts
 

;-------------------------------------------------------------
; codec_control routine
;	Input:  CTRL_WD_LO and CTRL_WD_HI	
;	Output: CDIN
;	Description: Used to send control information to CODEC
;	NOTE: does not preserve the 'a' register.
;-------------------------------------------------------------
codec_control
        clr     a
        bclr    #CCS,x:M_PDRD         	; assert CCS 
        move    x:CTRL_WD_HI,a1       	; upper 16 bits of control data
        jsr     send_codec 			; shift out upper control word
        move    x:CTRL_WD_LO,a1       	; lower 16 bits of control data
        jsr     send_codec			; shift out lower control word
        bset    #CCS,x:M_PDRD         	; deassert CCS
        rts


;---------------------------------------------------------------
; send_codec routine
;	Input:  a1 containing control information
;	Output: sends bits to CDIN
;	Description: Determines bits to send to CDIN
;---------------------------------------------------------------

send_codec  
		do      #16,end_send_codec    ; 16 bits per word
        	bset    #CCLK,x:M_PDRD        ; toggle CCLK clock high
        	jclr    #23,a1,bit_low        ; test msb
        	bset    #CDIN,x:M_PDRD        ; send high into CDIN 
        	jmp     continue
bit_low
        	bclr    #CDIN,x:M_PDRD		; send low into CDIN
continue
        	rep     #2                    ; delay
        	nop
        	bclr    #CCLK,x:M_PDRD        ; restart cycle
        	lsl     a                     ; shift control word to 1 bit 
							; to left
end_send_codec
        rts




;****************************************************************************
;	SSI0_ISR.ASM    Ver.2.0
;	Example program to handle interrupts through
;       the 56307 SSI0 to move audio through the CS4218
;
;       Copyright (c) MOTOROLA 1995, 1996, 1997, 1998
;		      Semiconductor Products Sector 
;		      Digital Signal Processing Division
;
;
;       History:
;               	14 June 1996: RLR/LJD - ver 1.0
;			23 July 1997: BEA     - ver 1.1
;			1  june 2001: Dany
;******************************************************************************


;----the actual interrupt service routines (ISRs)  follow:

;************************ SSI TRANSMIT ISR *********************************
ssi_txe_isr
        bclr    #4,x:M_SSISR0           ; Read SSISR to clear exception flag
                                        ; explicitly clears underrun flag
ssi_tx_isr

	rti
	
 

;********************* SSI TRANSMIT LAST SLOT ISR **************************
ssi_txls_isr
  	bset	#Left_ch,x:bits
        rti

;************************** SSI receive ISR ********************************
ssi_rxe_isr
        bclr    #5,x:M_SSISR0           ; Read SSISR to clear exception flag
								; explicitly clears overrun flag
;ssi_rx_isr
	include 'receiveISR.asm'
                                        

;********************** SSI receive last slot ISR **************************
ssi_rxls_isr


        rti
