;******************************************************************************
;  MSP430F21x2 Demo - Timer1_A, PWM TA1_1, Up Mode, DCO SMCLK
;
;  Description: This program generates one PWM outputs on P3.7 using
;  Timer1_A configured for up mode. The value in TA1CCR0, 512-1, defines the PWM
;  period and the value in TA1CCR1 defines the PWM duty cycle.
;  Using ~1.2MHz SMCLK as TACLK, the timer period is ~425us with
;  a 75% duty cycle on P3.7
;  ACLK = n/a, SMCLK = MCLK = TA1CLK = default DCO ~1.2MHz
;
;               MSP430F21x2
;            -----------------
;        /|\|              XIN|-
;         | |                 |
;         --|RST          XOUT|-
;           |                 |
;           |       P3.7/TA1_1|--> TA1CCR1 - 75% PWM
;           |                 |
;
;  JL Bile
;  Texas Instruments Inc.
;  May 2008
;  Built with Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x21x2.h"
;-------------------------------------------------------------------------------
 			.text							; Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #025Fh,SP         		; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP3     bis.b   #080h,&P3DIR            ; P3.7 output
            bis.b   #080h,&P3SEL            ; P3.7 TA1_1 otion
SetupC0     mov.w   #512-1,&TA1CCR0         ; PWM Period
SetupC1     mov.w   #OUTMOD_7,&TA1CCTL1     ; TACCR1 reset/set
            mov.w   #384,&TA1CCR1           ; TACCR1 PWM Duty Cycle
SetupTA     mov.w   #TASSEL_2+MC_1,&TA1CTL  ; SMCLK, upmode
                                            ;
Mainloop    bis.w   #CPUOFF,SR              ; CPU off
            nop                             ; Required only for debugger
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"				; MSP430 RESET Vector
            .short	RESET                   ;
            .end
            