;*******************************************************************************
;   MSP430x261x Demo - DMA0, Repeated single transfer UCA1UART 9600, TACCR2, ACLK
;
;   Description: DMA0 is used to transfer a string byte-by-byte as a repeating
;   block to UCA1TXBUF. Timer_A operates continuously at 32768Hz with CCR2IFG
;   triggering DMA0. "Hello World" is TX'd via 9600 baud UART1.
;   ACLK = TACLK = 32768Hz, MCLK = SMCLK = default DCO 1048576Hz
;   Baud rate divider with 32768hz XTAL @9600 = 32768Hz/9600 = 3.41 
;   Modulation value for UART--See 2xx User's guide for this setting. 
;
;               MSP430xF2618
;             -----------------4
;         /|\|              XIN|-
;          | |                 | 32768Hz
;          --|RST          XOUT|-
;            |                 |
;            |             P3.6|------------> "Hello World"
;            |                 | 9600 - 8N1
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x26x.h"
;-------------------------------------------------------------------------------
LF          .equ     0ah                     ; ASCII Line Feed
CR          .equ     0dh                     ; ASCII Carriage Return
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #0850h,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP3     bis.b   #BIT6+BIT7,&P3SEL       ; P3.6,7 = USART1 TXD/RXD
SetupUSCI1  bis.b   #UCSSEL_1,&UCA1CTL1     ; ACLK
            mov.b   #3,&UCA1BR0             ; 32768Hz 9600 32k/9600=3.41
            mov.b   #0,&UCA1BR1             ; 32768Hz 9600
            mov.b   #UCBRS_3,&UCA1MCTL      ; Modulation UCBRSx = 3
            bic.b   #UCSWRST,&UCA1CTL1      ; **Initialize USCI state machine**
            
SetupDMA0   mov.w   #DMA0TSEL_1,&DMACTL0    ; CCR2 trigger
            movx.a  #String1,&DMA0SA        ; Source block address
            movx.a  #UCA1TXBUF,&DMA0DA      ; Destination single address
            mov.w   #0013,&DMA0SZ           ; Block size
            mov.w   #DMADT_4+DMASRCINCR_3+DMASBDB+DMAEN,&DMA0CTL; Repeat, inc src
SetupTA     mov.w   #07172+01020,&TACCR0          ; Char freq = TACLK/CCR0
            mov.w   #01,&TACCR2             ; DMA0 trigger
            mov.w   #TASSEL_1+MC_1,&TACTL   ; ACLK, up-mode
                                            ;
Mainloop    bis.w   #LPM3,SR                ; Enter LPM3
            nop                             ; Required only for debugger
                                            ;
String1     .word      CR,LF, 'Hello World'
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"	           ; POR, ext. Reset, Watchdog
            .short  RESET
            .end

