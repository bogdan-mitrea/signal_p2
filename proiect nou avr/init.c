/* initialization file */

#include <mega164a.h>
#include <delay.h>

#include "defs.h"
                                          

/*
 * most intialization values are generated using Code Wizard and depend on clock value
 */
void Init_initController(void)
{
// Crystal Oscillator division factor: 1
#pragma optsize-
CLKPR=0x80;
CLKPR=0x00;
#ifdef _OPTIMIZE_SIZE_
#pragma optsize+
#endif

// Input/Output Ports initialization
// Port A initialization
// Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRA=0b00001111; // PORTA 7-4 In , PORTA 3-0 Out
PORTA=0b11111111; // Pull up - PORTA 7-4 (in) , out in logic 1 - PORTA 3-0

// Port B initialization    - PB3-0 outputs
DDRB=0x0F;
PORTB=0x00;

// Port C initialization
// Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out 
DDRC=0b11111111; // PORTC out
PORTC = 0b00000000; //PORTC out in 0 logic

// Port D initialization
PORTD=0b00100000; // D.5 needs pull-up resistor
DDRD= 0b01010000; // D.6 is LED, D.4 is test output

// Timer/Counter 0 initialization
// Clock source: System Clock
// Clock value: Timer 0 Stopped
// Mode: Normal top=FFh
// OC0 output: Disconnected
TCCR0A=0x00;
TCCR0B=0x00;
TCNT0=0x00;
OCR0A=0x00;
OCR0B=0x00;

// Timer/Counter 1 initialization
// Clock source: System Clock
// Clock value: 19.531 kHz = CLOCK/256
// Mode: CTC top=OCR1A
// OC1A output: Discon.
// OC1B output: Discon.
// Noise Canceler: Off
// Input Capture on Falling Edge
// Timer 1 Overflow Interrupt: Off
// Input Capture Interrupt: Off
// Compare A Match Interrupt: On
// Compare B Match Interrupt: Off

TCCR1A=0x00;
TCCR1B=0x0D;
TCNT1H=0x00;
TCNT1L=0x00;
ICR1H=0x00;
ICR1L=0x00;

// 1 sec = 19531 counts = 4C4BH counts 
// 4C4BH = 4CH (MSB) and 4BH (LSB)


//1 sec
//OCR1AH=0x4C;
//OCR1AL=0x4B;

// 20 ms
OCR1AH=0x01;
OCR1AL=0x86;

//OCR1AH=0x00;
//OCR1AL=0x40;


OCR1BH=0x00;
OCR1BL=0x00;

// Timer/Counter 2 initialization
// Clock source: System Clock
// Clock value: Timer2 Stopped
// Mode: Normal top=0xFF
// OC2A output: Disconnected
// OC2B output: Disconnected
ASSR=0x00;
TCCR2A=0x00;
TCCR2B=0x00;
TCNT2=0x00;
OCR2A=0x00;
OCR2B=0x00;

// External Interrupt(s) initialization
// INT0: Off
// INT1: Off
// INT2: Off
// Interrupt on any change on pins PCINT0-7: Off
// Interrupt on any change on pins PCINT8-15: Off
// Interrupt on any change on pins PCINT16-23: Off
// Interrupt on any change on pins PCINT24-31: Off
EICRA=0x00;
EIMSK=0x00;
PCICR=0x00;

// Timer/Counter 0,1,2 Interrupt(s) initialization
TIMSK0=0x00;
TIMSK1=0x02;
TIMSK2=0x00;

// USART0 initialization
// Communication Parameters: 8 Data, 1 Stop, No Parity
// USART0 Receiver: On
// USART0 Transmitter: On
// USART0 Mode: Asynchronous
// USART0 Baud rate: 9600
UCSR0A=0x00;
UCSR0B=0xD8;
UCSR0C=0x06;
UBRR0H=0x00;
UBRR0L=0x81;

// USART1 initialization
// USART1 disabled
UCSR1B=0x00;


// Analog Comparator initialization
// Analog Comparator: Off
// Analog Comparator Input Capture by Timer/Counter 1: Off
ACSR=0x80;
ADCSRB=0x00;
DIDR1=0x00;

// Watchdog Timer initialization
// Watchdog Timer Prescaler: OSC/2048  
#pragma optsize-


#asm("wdr")
// Write 2 consecutive values to enable watchdog
// this is NOT a mistake !
WDTCSR=0x18;
WDTCSR=0x08;


//  disable JTAG
   MCUCR|= (1<<JTD);
   MCUCR|= (1<<JTD);
   
#ifdef _OPTIMIZE_SIZE_
#pragma optsize+
#endif

}



