;******************************************************************************
;   MSP-FET430P120 Demo - USART0, Ultra-Low Pwr UART 9600 String, 32kHz ACLK
;
;   Description: This program demonstrates a full-duplex 9600-baud UART using
;   USART0 and a 32kHz crystal.  The program will wait in LPM3, and will
;   respond to a received 'u' character using 8N1 protocol. The response will
;   be the string 'Hello World.
;   Baud rate divider with 32768Hz XTAL @9600 = 32768Hz/9600 = 3.41 (0003h 4Ah)
;   ACLK = LFXT1 = UCLK0, MCLK = SMCLK = default DCO ~800kHz
;   //* An external watch crystal is required on XIN XOUT for ACLK *//	
;
;               MSP430F123(2)
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |             P3.4|----------->
;            |                 | 9600 - 8N1
;            |             P3.5|<-----------
;
;   CPU registers used
Pointer .equ     R4
;
LF          .equ    0ah                     ; ASCII Line Feed
CR          .equ    0dh                     ; ASCII Carriage Return
;
;   M. Buccini / M. Raju
;   Texas Instruments Inc.
;   May 2005
;   Built with Code Composer Essentials Version: 1.0
;******************************************************************************
 .cdecls C,LIST,  "msp430x12x2.h"
;------------------------------------------------------------------------------
            .text                           ; Program Start
;------------------------------------------------------------------------------
RESET       mov.w   #300h,SP                ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP3     bis.b   #030h,&P3SEL            ; P3.4,5 = USART0 TXD/RXD
SetupUART0  bis.b   #UTXE0+URXE0,&ME2       ; Enable USART0 TXD/RXD
            bis.b   #CHAR,&UCTL0            ; 8-bit characters
            mov.b   #SSEL0,&UTCTL0          ; UCLK = ACLK
            mov.b   #003h,&UBR00            ; 32k/9600 - 3.41
            mov.b   #000h,&UBR10            ;
            mov.b   #04Ah,&UMCTL0           ; Modulation
            bic.b   #SWRST,&UCTL0           ; **Initialize USART state machine**
            bis.b   #URXIE0+UTXIE0,&IE2     ; Enable USART0 RX/TX interrupt
            bic.b   #UTXIFG0,&IFG2          ; Clear inital flag on POR
                                            ;
Mainloop    bis.w   #LPM3+GIE,SR            ; Enter LPM3 w/ int until Byte RXed
            nop                             ; Required only for debugger
                                            ;
;------------------------------------------------------------------------------
USART0TX_ISR;
;------------------------------------------------------------------------------
            cmp.w   #String1+13,Pointer     ;
            jeq     Done                    ;
            mov.b   @Pointer+,&TXBUF0       ;
Done        reti                            ;
                                            ;
;-----------------------------------------------------------------------------
USART0RX_ISR;
;-----------------------------------------------------------------------------
            cmp.b   #'u',&RXBUF0            ;
            jne     USART_Done              ;
            mov.w   #String1,Pointer        ;
            mov.b   @Pointer+,&TXBUF0       ;
USART_Done  reti                            ;		
                                            ;
String1     .byte  "Hello World",CR,LF

;------------------------------------------------------------------------------
;           Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ;
            .short  RESET                   ; POR, ext. Reset, Watchdog
            .sect   ".int07"                ;
            .short  USART0RX_ISR            ; USART0 receive
            .sect   ".int06"                ;
            .short  USART0TX_ISR            ; USART0 transmit
            .end