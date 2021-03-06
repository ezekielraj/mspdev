;******************************************************************************
;  MSP430F21x2 Demo - Timer0_A3, Toggle P1.1/TA0_0, Up Mode, HF XTAL ACLK
;
;  Description: Toggle P1.1 using hardware TA0_0 output. Timer0_A3 is configured
;  for up mode with TA0CCR0 defining period, TA0_0 also output on P1.1. In this
;  example, TA0CCR0 is loaded with 500-1 and TA0_0 will toggle P1.1 at TA0CLK/500.
;  Thus the output frequency on P1.1 will be the TA0CLK/1000. No CPU or
;  software resources required.
;  ACLK = MCLK = TA0CLK = HF XTAL
;  ;* HF XTAL REQUIRED AND NOT INSTALLED ON FET *;
;  ;* Min Vcc required varies with MCLK frequency - refer to datasheet *;
;  As coded with TA0CLK = ACLK, P1.1 output frequency = HF XTAL/1000
;
;           MSP430F21x2
;         -----------------
;     /|\|              XIN|-
;      | |                 | HF XTAL (3  16MHz crystal or resonator)
;      --|RST          XOUT|-
;        |                 |
;        |       P1.1/TA0_0|--> ACLK/1000
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
SetupP1     bis.b   #002h,&P1DIR            ; P1.1 output
            bis.b   #002h,&P1SEL            ; P1.1 option slect
SetupBC     bis.b   #XTS,&BCSCTL1           ; LFXT1 = HF XTAL
            mov.b   #LFXT1S1,&BCSCTL3       ; LFXT1S1 = 3-16Mhz
SetupOsc    bic.b   #OFIFG,&IFG1            ; Clear OSC fault flag
            mov.w   #0FFh,R15               ; R15 = Delay
SetupOsc1   dec.w   R15                     ; Additional delay to ensure start
            jnz     SetupOsc1               ;
            bit.b   #OFIFG,&IFG1            ; OSC fault flag set?
            jnz     SetupOsc                ; OSC Fault, clear flag again
            bis.b   #SELM_3,&BCSCTL2        ; MCLK = LFXT1
SetupC0     mov.w   #OUTMOD_4,&TA0CCTL0      ; TACCR0 toggle mode
            mov.w   #500-1,&TA0CCR0          ;
SetupTA     mov.w   #TASSEL_1+MC_1,&TA0CTL   ; ACLK, upmode
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