;*******************************************************************************
;   MSP430F41x2 Demo - ADC10, DTC Sample A0 64x, 1.5V, Repeat Single, DCO
;
;   Description: Use DTC to sample A0 64 times with reference to internal 1.5v.
;   Vref Software writes to ADC10SC to trigger sample burst. In Mainloop MSP430
;   waits in LPM0 to save power until ADC10 conversion complete, ADC10_ISR(DTC)
;   will force exit from LPM0 in Mainloop on reti. ADC10 internal
;   oscillator times sample period (16x) and conversion (13x). DTC transfers
;   conversion code to RAM 200h - 280h. P5.1 set at start of conversion burst,
;   reset on completion.
;
;                MSP430F41x2
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST          XOUT|-
;            |                 |
;        >---|P7.4/A0      P5.1|-->LED
;
;  P. Thanigai
;  Texas Instruments Inc.
;  January 2009
;  Built with CCE Version: 3.1   
;******************************************************************************
 .cdecls C,LIST, "msp430x41x2.h" 

            .global _main
;------------------------------------------------------------------------------
            .text                           ; Program Start
;------------------------------------------------------------------------------
_main
RESET       mov.w   #0400h,SP               ; Initialize stack pointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupADC10  mov.w   #CONSEQ_2,&ADC10CTL1    ; Repeat single channel
            mov.w   #SREF_1+ADC10SHT_2+MSC+REFON+ADC10ON+ADC10IE,&ADC10CTL0;
            mov.w   #30,&TACCR0             ; Delay to allow Ref to settle
            bis.w   #CCIE,&TACCTL0          ; Compare-mode interrupt.
            mov.w   #TACLR+MC_1+TASSEL_2,&TACTL; up mode, SMCLK
            bis.w   #LPM0+GIE,SR            ; Enter LPM0, enable interrupts
            bic.w   #CCIE,&TACCTL0          ; Disable timer interrupt
            mov.b   #040h,&ADC10DTC1        ; 64 conversions
            bis.b   #01h,&ADC10AE0          ; P7.4 ADC option select
SetupP5     bis.b   #002h,&P5DIR            ; P5.1 output
                                            ;
Mainloop    bic.w   #ENC,&ADC10CTL0         ;
busy_test   bit     #BUSY,&ADC10CTL1        ; ADC10 core inactive?
            jnz     busy_test               ;
            mov.w   #0200h,&ADC10SA         ; Data buffer start
            bis.b   #002h,&P5OUT            ; P5.1 = 1
            bis.w   #ENC+ADC10SC,&ADC10CTL0 ; Start sampling
            bis.w   #CPUOFF+GIE,SR          ; LPM0, ADC10_ISR will force exit
            bic.b   #002h,&P5OUT            ; P5.1 = 0
            jmp     Mainloop                ; Again
                                            ;
;-------------------------------------------------------------------------------
TA0_ISR;    ISR for TACCR0
;-------------------------------------------------------------------------------
            clr.w   &TACTL                  ; Clear Timer_A control registers
            bic.w   #LPM0,0(SP)             ; Exit LPM0 on reti
            reti                            ;
;-------------------------------------------------------------------------------
ADC10_ISR;  Exit LPM0 on reti
;-------------------------------------------------------------------------------
            bic.w   #LPM0,0(SP)             ; Exit LPM0 on reti
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".int07"            	; ADC10 Vector
            .short  ADC10_ISR
            .sect   ".int06"          		; Timer_A0 Vector
            .short  TA0_ISR
            .sect   ".reset"	            ; POR, ext. Reset
            .short  RESET
            .end
            
