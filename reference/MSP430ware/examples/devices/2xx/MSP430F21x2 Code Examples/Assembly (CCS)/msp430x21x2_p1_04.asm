;*******************************************************************************
;   MSP430F21x2 Demo - P1 Interrupt from LPM4 with Internal Pull-up
;
;   Description: A hi/low transition on P1.3 will trigger P1_ISR which,
;   toggles P1.0. Normal mode is LPM4 ~ 0.1uA. LPM4 current can be measured
;   with the LED removed, all unused Px.x configured as output or inputs
;   pulled high or low, and ensure the P1.3 interrupt input does not float.
;   Internal pullup enabled on P1.3.
;   ACLK = n/a, MCLK = SMCLK = default DCO
;
;                MSP430F21x2
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;      /|\   |      R          |
;       --o--| P1.3-o      P1.0|-->LED
;      \|/
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
RESET       mov.w   #025Fh,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP1     mov.b   #001h,&P1DIR            ; P1.0 output, else input
            mov.b   #008h,&P1OUT            ; P1.3 pullup
            bis.b   #008h,&P1REN            ; P1.3 pullup
            bis.b   #008h,&P1IE             ; P1.3 Interrupt enabled
            bis.b   #008h,&P1IES            ; P1.3 hi/low edge
            bic.b   #008h,&P1IFG            ; P1.3 IFG Cleared
                                            ;
Mainloop    bis.w   #LPM4+GIE,SR            ; LPM4, enable interrupts
            nop                             ; Required only for debugger
                                            ;
;-------------------------------------------------------------------------------
P1_ISR;     Toggle P1.0 Output
;-------------------------------------------------------------------------------
            xor.b   #001h,&P1OUT            ; P1.0 = toggle
            bic.b   #008h,&P1IFG            ; P1.3 IFG Cleared
            reti                            ; Return from ISR
                                            ;
;-------------------------------------------------------------------------------
 ;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"	            ; MSP430 RESET Vector
            .short  RESET                   ;
            .sect	".int02"            	; P1.x Vector
            .short	P1_ISR                  ;
            .end

