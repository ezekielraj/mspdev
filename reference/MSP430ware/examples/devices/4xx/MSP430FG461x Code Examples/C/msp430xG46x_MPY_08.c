//******************************************************************************
//   MSP430xG46x Demo - 8x8 Signed Multiply Accumulate
//
//   Description: Hardware multiplier is used to multiply two numbers.
//   The calculation is automatically initiated after the second operand is
//   loaded.  A second multiply accumulate operation is performed after that.
//   Results are stored in RESLO and RESHI.  SUMEXT contains the extended sign of
//   result.
//
//   ACLK = 32.768kHz, MCLK = SMCLK = default DCO
//
//                 MSP430xG461x
//             -----------------
//         /|\|                 |
//          | |                 |
//          --|RST              |
//            |                 |
//            |                 |
//
//   K. Quiring/ M. Mitchell
//   Texas Instruments Inc.
//   October 2006
//   Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.41A
//******************************************************************************
#include  <msp430xG46x.h>

void main(void)
{
  unsigned char value1,value2;

  WDTCTL = WDTPW+WDTHOLD;                   // Stop WDT
  FLL_CTL0 |= XCAP14PF;                     // Configure load caps

  MPY = 0x1234;                             // Load 1st operand - unsigned mult
  OP2 = 0x5678;                             // Load second operand

  value1 = 0x12;                            // Load first operand - signed MAC
  value2 = 0x96;                            // Load second operand

  // Sign-extend the values
  if (value1 >=0x80)
    MACS = 0xFF00 | value1;
  else
    MACS = value1;
  if (value2 >=0x80)
    OP2 = 0xFF00 | value2;
  else
    OP2 = value2;

  _BIS_SR(LPM4_bits);                       // LPM4
}