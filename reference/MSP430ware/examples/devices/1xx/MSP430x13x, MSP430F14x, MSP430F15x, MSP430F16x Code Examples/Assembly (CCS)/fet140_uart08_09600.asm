;******************************************************************************
;    MSP-FET430P140 Demo - USART0, UART 9600 Full-Duplex Transceiver, 32K ACLK
;
;   Description: UART0 communicates continously as fast as possible full-duplex
;   with another device. Normal mode is LPM3, with activity only durring RX and
;   TX ISR's. The TX ISR indicates the UART is ready to send another character.
;   The RX ISR indicates the UART has received a character. At 9600 buad, a full
;   character is tranceived ~1ms.
;   The levels on P1.4/5 are TX'ed. RX'ed value is displayed on P1.0/1.
;   ACLK = UCLK1 = LFXT1 = 32768, MCLK = SMCLK = DCO ~800k
;   Baud rate divider with 32768Hz XTAL @9600 = 32768Hz/9600 = 3.41 (0003h 4Ah )
;   //* An external watch crystal is required on XIN XOUT for ACLK *//	
;
;                 MSP430F149                   MSP430F149
;              -----------------            -----------------
;             |              XIN|-      /|\|              XIN|-
;             |                 | 32kHz  | |                 | 32kHz
;             |             XOUT|-       --|RST          XOUT|-
;             |                 | /|\      |                 |
;             |              RST|---       |                 |
;             |                 |          |                 |
;           ->|P1.4             |          |             P1.0|-> LED
;           ->|P1.5             |          |             P1.1|-> LED
;       LED <-|P1.0             |          |             P1.4|<-
;       LED <-|P1.1             |          |             P1.5|<-
;             |        UTXD/P3.4|--------->|P3.5             |
;             |                 |   9600   |                 |
;             |        URXD/P3.5|<---------|P3.4             |
;
;
;   M. Buccini / G. Morton
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430x14x.h"
;-----------------------------------------------------------------------------
            .text                           ; Program Reset
;-----------------------------------------------------------------------------
RESET       mov.w   #0A00h,SP               ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog timer
SetupP1     mov.b   #000h,&P1OUT            ; P1.0/1 setup for LED output
            bis.b   #003h,&P1DIR            ;
SetupP3     bis.b   #030h,&P3SEL            ; P3.4,5 UART option select
SetupUART0  bis.b   #UTXE0+URXE0,&ME1       ; Enable USART0 TXD/RXD
            bis.b   #CHAR,&UCTL0            ; 8-bit characters
            mov.b   #SSEL0,&UTCTL0          ; UCLK = ACLK
            mov.b   #003h,&UBR00            ; 32k/9600 - 3.41
            mov.b   #000h,&UBR10            ;
            mov.b   #04Ah,&UMCTL0           ; Modulation
            bic.b   #SWRST,&UCTL0           ; **Initialize USART state machine**
            bis.b   #URXIE0+UTXIE0,&IE1     ; Enable USART0 RX/TX interrupts
                                            ;
Mainloop    bis.b   #LPM3+GIE,SR            ; Enter LPM3 w/ interrupts enabled
            nop                             ; Required for debugger only
                                            ;
;------------------------------------------------------------------------------
USART0RX_ISR;
;------------------------------------------------------------------------------
            mov.b   &RXBUF0,&P1OUT          ; Display RX'ed charater
            reti                            ; Exit ISR
                                            ;
;------------------------------------------------------------------------------
USART0TX_ISR;
;------------------------------------------------------------------------------
            mov.b   &P1IN,R4                ;
            rrc.b   R4                      ; Justify 4x right
            rrc.b   R4                      ;
            rrc.b   R4                      ;
            rrc.b   R4                      ;
            and.b   #03h,R4                 ;
            mov.b   R4,&TXBUF0              ; Transmit character
            reti                            ; Exit ISR

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ;
            .short  RESET                   ; POR, ext. Reset, Watchdog
            .sect   ".int09"                ;
            .short  USART0RX_ISR            ; USART0 receive
            .sect   ".int08"                ;
            .short  USART0TX_ISR            ; USART0 transmit
            .end                            ;