;*******************************************************************************
;   MSP430F21x2 Demo - ADC10, DTC Sample A0 -> TA1, AVcc, HF XTAL
;
;   Description: Use DTC to sample A0 with reference to AVcc continously and
;   directly transfer code to Timer_A CCR1 output unit. Timer_A has been
;   configured for 10-bit PWM mode. CCR1 duty cycle is automatically
;   proportional to ADC10 A0. No CPU resources are required and in this
;   example the CPU is turned off. ADC10 A0 sampling and transfer to TA1 done
;   continuously and automatically by the DTC.
;   MCLK = SMCLK = HF XTAL = 8MHz, ACLK = (HF XTAL)/8
;   As coded, ADC10CLK = ACLK/8 = 125kHz, and each A0 sample and transfer to
;   TA1 requires 77 ADC10CLK. With an 8MHz HF XTAL, loop transfer rate is
;   125k/77 = 1623/second.
;   //* An external HF XTAL on XIN XOUT is required for ACLK *//
;
;                MSP430F21x2
;             -----------------
;         /|\|              XIN|-
;          | |                 | HF XTAL (3  16MHz crystal or resonator)
;          --|RST          XOUT|-
;            |                 |
;        >---|P2.0/A0      P1.2|--> TACCR1 - 0-1024 PWM
;
;  JL Bile
;  Texas Instruments Inc.
;  May 2008
;  Built with Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x21x2.h"
;-------------------------------------------------------------------------------
 			.text							;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #025Fh,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupBC     bis.b   #XTS+DIVA_3,&BCSCTL1    ; ACLK = (LFXT1 = HF XTAL)/8
            bis.b   #LFXT1S1,&BCSCTL3       ; 3  16MHz crystal or resonator
SetupOsc    bic.b   #OFIFG,&IFG1            ; Clear OSC fault flag
            mov.w   #0FFh,R15               ; R15 = Delay
SetupOsc1   dec.w   R15                     ; Additional delay to ensure start
            jnz     SetupOsc1               ;
            bit.b   #OFIFG,&IFG1            ; OSC fault flag set?
            jnz     SetupOsc                ; OSC Fault, clear flag again
            bis.b   #SELM_3+SELS,&BCSCTL2   ; MCLK = SMCLK = LFXT1
SetupP1     bis.b   #004h,&P1DIR            ; P1.2 = output
            bis.b   #004h,&P1SEL            ; P1.2 = TA1 outputs
SetupC0     mov.w   #1024-1,&TACCR0         ; PWM Period
SetupC1     mov.w   #OUTMOD_7,&TACCTL1      ; TACCR1 reset/set
            mov.w   #512,&TACCR1            ; TACCR1 PWM Duty Cycle
SetupTA     mov.w   #TASSEL_2+MC_1,&TACTL   ; SMCLK, upmode
SetupADC10  mov.w   #ADC10DIV_7+ADC10SSEL_1+CONSEQ_2,&ADC10CTL1 ; ACLK
            mov.w   #ADC10SHT_3+MSC+ADC10ON,&ADC10CTL0 ; 64x, multi conv.
            bis.b   #01h,&ADC10AE0          ; P2.0 ADC option select
            bis.b   #ADC10CT,&ADC10DTC0     ; Continous transfers
            mov.b   #001h,&ADC10DTC1        ; 1 conversion location
            mov.w   #TACCR1,&ADC10SA        ; Data trasfer location
            bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Start sampling
                                            ;
Mainloop    bis.b   #CPUOFF,SR              ; CPU not required
            nop                             ; Required only for debugger
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"            ; POR, ext. Reset
            .short	RESET
            .end
