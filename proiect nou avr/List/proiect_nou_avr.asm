
;CodeVisionAVR C Compiler V2.05.6 Evaluation
;(C) Copyright 1998-2012 Pavel Haiduc, HP InfoTech s.r.l.
;http://www.hpinfotech.com

;Chip type              : ATmega164A
;Program type           : Application
;Clock frequency        : 20.000000 MHz
;Memory model           : Small
;Optimize for           : Size
;(s)printf features     : int, width
;(s)scanf features      : int, width
;External RAM size      : 0
;Data Stack size        : 256 byte(s)
;Heap size              : 0 byte(s)
;Promote 'char' to 'int': Yes
;'char' is unsigned     : Yes
;8 bit enums            : Yes
;Global 'const' stored in FLASH: No
;Enhanced function parameter passing: Yes
;Enhanced core instructions: On
;Automatic register allocation for global variables: On
;Smart register allocation: On

	#pragma AVRPART ADMIN PART_NAME ATmega164A
	#pragma AVRPART MEMORY PROG_FLASH 16384
	#pragma AVRPART MEMORY EEPROM 512
	#pragma AVRPART MEMORY INT_SRAM SIZE 1024
	#pragma AVRPART MEMORY INT_SRAM START_ADDR 0x100

	#define CALL_SUPPORTED 1

	.LISTMAC
	.EQU EERE=0x0
	.EQU EEWE=0x1
	.EQU EEMWE=0x2
	.EQU UDRE=0x5
	.EQU RXC=0x7
	.EQU EECR=0x1F
	.EQU EEDR=0x20
	.EQU EEARL=0x21
	.EQU EEARH=0x22
	.EQU SPSR=0x2D
	.EQU SPDR=0x2E
	.EQU SMCR=0x33
	.EQU MCUSR=0x34
	.EQU MCUCR=0x35
	.EQU WDTCSR=0x60
	.EQU UCSR0A=0xC0
	.EQU UDR0=0xC6
	.EQU SPL=0x3D
	.EQU SPH=0x3E
	.EQU SREG=0x3F
	.EQU GPIOR0=0x1E

	.DEF R0X0=R0
	.DEF R0X1=R1
	.DEF R0X2=R2
	.DEF R0X3=R3
	.DEF R0X4=R4
	.DEF R0X5=R5
	.DEF R0X6=R6
	.DEF R0X7=R7
	.DEF R0X8=R8
	.DEF R0X9=R9
	.DEF R0XA=R10
	.DEF R0XB=R11
	.DEF R0XC=R12
	.DEF R0XD=R13
	.DEF R0XE=R14
	.DEF R0XF=R15
	.DEF R0X10=R16
	.DEF R0X11=R17
	.DEF R0X12=R18
	.DEF R0X13=R19
	.DEF R0X14=R20
	.DEF R0X15=R21
	.DEF R0X16=R22
	.DEF R0X17=R23
	.DEF R0X18=R24
	.DEF R0X19=R25
	.DEF R0X1A=R26
	.DEF R0X1B=R27
	.DEF R0X1C=R28
	.DEF R0X1D=R29
	.DEF R0X1E=R30
	.DEF R0X1F=R31

	.EQU __SRAM_START=0x0100
	.EQU __SRAM_END=0x04FF
	.EQU __DSTACK_SIZE=0x0100
	.EQU __HEAP_SIZE=0x0000
	.EQU __CLEAR_SRAM_SIZE=__SRAM_END-__SRAM_START+1

	.MACRO __CPD1N
	CPI  R30,LOW(@0)
	LDI  R26,HIGH(@0)
	CPC  R31,R26
	LDI  R26,BYTE3(@0)
	CPC  R22,R26
	LDI  R26,BYTE4(@0)
	CPC  R23,R26
	.ENDM

	.MACRO __CPD2N
	CPI  R26,LOW(@0)
	LDI  R30,HIGH(@0)
	CPC  R27,R30
	LDI  R30,BYTE3(@0)
	CPC  R24,R30
	LDI  R30,BYTE4(@0)
	CPC  R25,R30
	.ENDM

	.MACRO __CPWRR
	CP   R@0,R@2
	CPC  R@1,R@3
	.ENDM

	.MACRO __CPWRN
	CPI  R@0,LOW(@2)
	LDI  R30,HIGH(@2)
	CPC  R@1,R30
	.ENDM

	.MACRO __ADDB1MN
	SUBI R30,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDB2MN
	SUBI R26,LOW(-@0-(@1))
	.ENDM

	.MACRO __ADDW1MN
	SUBI R30,LOW(-@0-(@1))
	SBCI R31,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW2MN
	SUBI R26,LOW(-@0-(@1))
	SBCI R27,HIGH(-@0-(@1))
	.ENDM

	.MACRO __ADDW1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1FN
	SUBI R30,LOW(-2*@0-(@1))
	SBCI R31,HIGH(-2*@0-(@1))
	SBCI R22,BYTE3(-2*@0-(@1))
	.ENDM

	.MACRO __ADDD1N
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	SBCI R22,BYTE3(-@0)
	SBCI R23,BYTE4(-@0)
	.ENDM

	.MACRO __ADDD2N
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	SBCI R24,BYTE3(-@0)
	SBCI R25,BYTE4(-@0)
	.ENDM

	.MACRO __SUBD1N
	SUBI R30,LOW(@0)
	SBCI R31,HIGH(@0)
	SBCI R22,BYTE3(@0)
	SBCI R23,BYTE4(@0)
	.ENDM

	.MACRO __SUBD2N
	SUBI R26,LOW(@0)
	SBCI R27,HIGH(@0)
	SBCI R24,BYTE3(@0)
	SBCI R25,BYTE4(@0)
	.ENDM

	.MACRO __ANDBMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ANDWMNN
	LDS  R30,@0+(@1)
	ANDI R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ANDI R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ANDD1N
	ANDI R30,LOW(@0)
	ANDI R31,HIGH(@0)
	ANDI R22,BYTE3(@0)
	ANDI R23,BYTE4(@0)
	.ENDM

	.MACRO __ANDD2N
	ANDI R26,LOW(@0)
	ANDI R27,HIGH(@0)
	ANDI R24,BYTE3(@0)
	ANDI R25,BYTE4(@0)
	.ENDM

	.MACRO __ORBMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	.ENDM

	.MACRO __ORWMNN
	LDS  R30,@0+(@1)
	ORI  R30,LOW(@2)
	STS  @0+(@1),R30
	LDS  R30,@0+(@1)+1
	ORI  R30,HIGH(@2)
	STS  @0+(@1)+1,R30
	.ENDM

	.MACRO __ORD1N
	ORI  R30,LOW(@0)
	ORI  R31,HIGH(@0)
	ORI  R22,BYTE3(@0)
	ORI  R23,BYTE4(@0)
	.ENDM

	.MACRO __ORD2N
	ORI  R26,LOW(@0)
	ORI  R27,HIGH(@0)
	ORI  R24,BYTE3(@0)
	ORI  R25,BYTE4(@0)
	.ENDM

	.MACRO __DELAY_USB
	LDI  R24,LOW(@0)
__DELAY_USB_LOOP:
	DEC  R24
	BRNE __DELAY_USB_LOOP
	.ENDM

	.MACRO __DELAY_USW
	LDI  R24,LOW(@0)
	LDI  R25,HIGH(@0)
__DELAY_USW_LOOP:
	SBIW R24,1
	BRNE __DELAY_USW_LOOP
	.ENDM

	.MACRO __GETD1S
	LDD  R30,Y+@0
	LDD  R31,Y+@0+1
	LDD  R22,Y+@0+2
	LDD  R23,Y+@0+3
	.ENDM

	.MACRO __GETD2S
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	LDD  R24,Y+@0+2
	LDD  R25,Y+@0+3
	.ENDM

	.MACRO __PUTD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R31
	STD  Y+@0+2,R22
	STD  Y+@0+3,R23
	.ENDM

	.MACRO __PUTD2S
	STD  Y+@0,R26
	STD  Y+@0+1,R27
	STD  Y+@0+2,R24
	STD  Y+@0+3,R25
	.ENDM

	.MACRO __PUTDZ2
	STD  Z+@0,R26
	STD  Z+@0+1,R27
	STD  Z+@0+2,R24
	STD  Z+@0+3,R25
	.ENDM

	.MACRO __CLRD1S
	STD  Y+@0,R30
	STD  Y+@0+1,R30
	STD  Y+@0+2,R30
	STD  Y+@0+3,R30
	.ENDM

	.MACRO __POINTB1MN
	LDI  R30,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW1MN
	LDI  R30,LOW(@0+(@1))
	LDI  R31,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTD1M
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __POINTW1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	LDI  R22,BYTE3(2*@0+(@1))
	LDI  R23,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTB2MN
	LDI  R26,LOW(@0+(@1))
	.ENDM

	.MACRO __POINTW2MN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	.ENDM

	.MACRO __POINTW2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	.ENDM

	.MACRO __POINTD2FN
	LDI  R26,LOW(2*@0+(@1))
	LDI  R27,HIGH(2*@0+(@1))
	LDI  R24,BYTE3(2*@0+(@1))
	LDI  R25,BYTE4(2*@0+(@1))
	.ENDM

	.MACRO __POINTBRM
	LDI  R@0,LOW(@1)
	.ENDM

	.MACRO __POINTWRM
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __POINTBRMN
	LDI  R@0,LOW(@1+(@2))
	.ENDM

	.MACRO __POINTWRMN
	LDI  R@0,LOW(@2+(@3))
	LDI  R@1,HIGH(@2+(@3))
	.ENDM

	.MACRO __POINTWRFN
	LDI  R@0,LOW(@2*2+(@3))
	LDI  R@1,HIGH(@2*2+(@3))
	.ENDM

	.MACRO __GETD1N
	LDI  R30,LOW(@0)
	LDI  R31,HIGH(@0)
	LDI  R22,BYTE3(@0)
	LDI  R23,BYTE4(@0)
	.ENDM

	.MACRO __GETD2N
	LDI  R26,LOW(@0)
	LDI  R27,HIGH(@0)
	LDI  R24,BYTE3(@0)
	LDI  R25,BYTE4(@0)
	.ENDM

	.MACRO __GETB1MN
	LDS  R30,@0+(@1)
	.ENDM

	.MACRO __GETB1HMN
	LDS  R31,@0+(@1)
	.ENDM

	.MACRO __GETW1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	.ENDM

	.MACRO __GETD1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	LDS  R22,@0+(@1)+2
	LDS  R23,@0+(@1)+3
	.ENDM

	.MACRO __GETBRMN
	LDS  R@0,@1+(@2)
	.ENDM

	.MACRO __GETWRMN
	LDS  R@0,@2+(@3)
	LDS  R@1,@2+(@3)+1
	.ENDM

	.MACRO __GETWRZ
	LDD  R@0,Z+@2
	LDD  R@1,Z+@2+1
	.ENDM

	.MACRO __GETD2Z
	LDD  R26,Z+@0
	LDD  R27,Z+@0+1
	LDD  R24,Z+@0+2
	LDD  R25,Z+@0+3
	.ENDM

	.MACRO __GETB2MN
	LDS  R26,@0+(@1)
	.ENDM

	.MACRO __GETW2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	.ENDM

	.MACRO __GETD2MN
	LDS  R26,@0+(@1)
	LDS  R27,@0+(@1)+1
	LDS  R24,@0+(@1)+2
	LDS  R25,@0+(@1)+3
	.ENDM

	.MACRO __PUTB1MN
	STS  @0+(@1),R30
	.ENDM

	.MACRO __PUTW1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	.ENDM

	.MACRO __PUTD1MN
	STS  @0+(@1),R30
	STS  @0+(@1)+1,R31
	STS  @0+(@1)+2,R22
	STS  @0+(@1)+3,R23
	.ENDM

	.MACRO __PUTB1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRB
	.ENDM

	.MACRO __PUTW1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRW
	.ENDM

	.MACRO __PUTD1EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMWRD
	.ENDM

	.MACRO __PUTBR0MN
	STS  @0+(@1),R0
	.ENDM

	.MACRO __PUTBMRN
	STS  @0+(@1),R@2
	.ENDM

	.MACRO __PUTWMRN
	STS  @0+(@1),R@2
	STS  @0+(@1)+1,R@3
	.ENDM

	.MACRO __PUTBZR
	STD  Z+@1,R@0
	.ENDM

	.MACRO __PUTWZR
	STD  Z+@2,R@0
	STD  Z+@2+1,R@1
	.ENDM

	.MACRO __GETW1R
	MOV  R30,R@0
	MOV  R31,R@1
	.ENDM

	.MACRO __GETW2R
	MOV  R26,R@0
	MOV  R27,R@1
	.ENDM

	.MACRO __GETWRN
	LDI  R@0,LOW(@2)
	LDI  R@1,HIGH(@2)
	.ENDM

	.MACRO __PUTW1R
	MOV  R@0,R30
	MOV  R@1,R31
	.ENDM

	.MACRO __PUTW2R
	MOV  R@0,R26
	MOV  R@1,R27
	.ENDM

	.MACRO __ADDWRN
	SUBI R@0,LOW(-@2)
	SBCI R@1,HIGH(-@2)
	.ENDM

	.MACRO __ADDWRR
	ADD  R@0,R@2
	ADC  R@1,R@3
	.ENDM

	.MACRO __SUBWRN
	SUBI R@0,LOW(@2)
	SBCI R@1,HIGH(@2)
	.ENDM

	.MACRO __SUBWRR
	SUB  R@0,R@2
	SBC  R@1,R@3
	.ENDM

	.MACRO __ANDWRN
	ANDI R@0,LOW(@2)
	ANDI R@1,HIGH(@2)
	.ENDM

	.MACRO __ANDWRR
	AND  R@0,R@2
	AND  R@1,R@3
	.ENDM

	.MACRO __ORWRN
	ORI  R@0,LOW(@2)
	ORI  R@1,HIGH(@2)
	.ENDM

	.MACRO __ORWRR
	OR   R@0,R@2
	OR   R@1,R@3
	.ENDM

	.MACRO __EORWRR
	EOR  R@0,R@2
	EOR  R@1,R@3
	.ENDM

	.MACRO __GETWRS
	LDD  R@0,Y+@2
	LDD  R@1,Y+@2+1
	.ENDM

	.MACRO __PUTBSR
	STD  Y+@1,R@0
	.ENDM

	.MACRO __PUTWSR
	STD  Y+@2,R@0
	STD  Y+@2+1,R@1
	.ENDM

	.MACRO __MOVEWRR
	MOV  R@0,R@2
	MOV  R@1,R@3
	.ENDM

	.MACRO __INWR
	IN   R@0,@2
	IN   R@1,@2+1
	.ENDM

	.MACRO __OUTWR
	OUT  @2+1,R@1
	OUT  @2,R@0
	.ENDM

	.MACRO __CALL1MN
	LDS  R30,@0+(@1)
	LDS  R31,@0+(@1)+1
	ICALL
	.ENDM

	.MACRO __CALL1FN
	LDI  R30,LOW(2*@0+(@1))
	LDI  R31,HIGH(2*@0+(@1))
	CALL __GETW1PF
	ICALL
	.ENDM

	.MACRO __CALL2EN
	LDI  R26,LOW(@0+(@1))
	LDI  R27,HIGH(@0+(@1))
	CALL __EEPROMRDW
	ICALL
	.ENDM

	.MACRO __GETW1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X
	.ENDM

	.MACRO __GETD1STACK
	IN   R26,SPL
	IN   R27,SPH
	ADIW R26,@0+1
	LD   R30,X+
	LD   R31,X+
	LD   R22,X
	.ENDM

	.MACRO __NBST
	BST  R@0,@1
	IN   R30,SREG
	LDI  R31,0x40
	EOR  R30,R31
	OUT  SREG,R30
	.ENDM


	.MACRO __PUTB1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SN
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNS
	LDD  R26,Y+@0
	LDD  R27,Y+@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMN
	LDS  R26,@0
	LDS  R27,@0+1
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1PMNS
	LDS  R26,@0
	LDS  R27,@0+1
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RN
	MOVW R26,R@0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RNS
	MOVW R26,R@0
	ADIW R26,@1
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RNS
	MOVW R26,R@0
	ADIW R26,@1
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RON
	MOV  R26,R@0
	MOV  R27,R@1
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	CALL __PUTDP1
	.ENDM

	.MACRO __PUTB1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X,R30
	.ENDM

	.MACRO __PUTW1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1RONS
	MOV  R26,R@0
	MOV  R27,R@1
	ADIW R26,@2
	CALL __PUTDP1
	.ENDM


	.MACRO __GETB1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R30,Z
	.ENDM

	.MACRO __GETB1HSX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	.ENDM

	.MACRO __GETW1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R31,Z
	MOV  R30,R0
	.ENDM

	.MACRO __GETD1SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R0,Z+
	LD   R1,Z+
	LD   R22,Z+
	LD   R23,Z
	MOVW R30,R0
	.ENDM

	.MACRO __GETB2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R26,X
	.ENDM

	.MACRO __GETW2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	.ENDM

	.MACRO __GETD2SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R1,X+
	LD   R24,X+
	LD   R25,X
	MOVW R26,R0
	.ENDM

	.MACRO __GETBRSX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	LD   R@0,Z
	.ENDM

	.MACRO __GETWRSX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	LD   R@0,Z+
	LD   R@1,Z
	.ENDM

	.MACRO __GETBRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	LD   R@0,X
	.ENDM

	.MACRO __GETWRSX2
	MOVW R26,R28
	SUBI R26,LOW(-@2)
	SBCI R27,HIGH(-@2)
	LD   R@0,X+
	LD   R@1,X
	.ENDM

	.MACRO __LSLW8SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	LD   R31,Z
	CLR  R30
	.ENDM

	.MACRO __PUTB1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __CLRW1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __CLRD1SX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	ST   X+,R30
	ST   X+,R30
	ST   X+,R30
	ST   X,R30
	.ENDM

	.MACRO __PUTB2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z,R26
	.ENDM

	.MACRO __PUTW2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z,R27
	.ENDM

	.MACRO __PUTD2SX
	MOVW R30,R28
	SUBI R30,LOW(-@0)
	SBCI R31,HIGH(-@0)
	ST   Z+,R26
	ST   Z+,R27
	ST   Z+,R24
	ST   Z,R25
	.ENDM

	.MACRO __PUTBSRX
	MOVW R30,R28
	SUBI R30,LOW(-@1)
	SBCI R31,HIGH(-@1)
	ST   Z,R@0
	.ENDM

	.MACRO __PUTWSRX
	MOVW R30,R28
	SUBI R30,LOW(-@2)
	SBCI R31,HIGH(-@2)
	ST   Z+,R@0
	ST   Z,R@1
	.ENDM

	.MACRO __PUTB1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X,R30
	.ENDM

	.MACRO __PUTW1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X,R31
	.ENDM

	.MACRO __PUTD1SNX
	MOVW R26,R28
	SUBI R26,LOW(-@0)
	SBCI R27,HIGH(-@0)
	LD   R0,X+
	LD   R27,X
	MOV  R26,R0
	SUBI R26,LOW(-@1)
	SBCI R27,HIGH(-@1)
	ST   X+,R30
	ST   X+,R31
	ST   X+,R22
	ST   X,R23
	.ENDM

	.MACRO __MULBRR
	MULS R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRRU
	MUL  R@0,R@1
	MOVW R30,R0
	.ENDM

	.MACRO __MULBRR0
	MULS R@0,R@1
	.ENDM

	.MACRO __MULBRRU0
	MUL  R@0,R@1
	.ENDM

	.MACRO __MULBNWRU
	LDI  R26,@2
	MUL  R26,R@0
	MOVW R30,R0
	MUL  R26,R@1
	ADD  R31,R0
	.ENDM

;NAME DEFINITIONS FOR GLOBAL VARIABLES ALLOCATED TO REGISTERS
	.DEF _rx_wr_index0=R5
	.DEF _rx_rd_index0=R4
	.DEF _rx_counter0=R7
	.DEF _cnt=R6
	.DEF _key=R9
	.DEF _cnt_key=R8
	.DEF _build_PF=R11
	.DEF _build_LED=R10
	.DEF _error_LED=R13
	.DEF _freq_test_LED=R12

;GPIOR0 INITIALIZATION VALUE
	.EQU __GPIOR0_INIT=0x00

	.CSEG
	.ORG 0x00

;START OF CODE MARKER
__START_OF_CODE:

;INTERRUPT VECTORS
	JMP  __RESET
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _timer1_compa_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  _usart0_rx_isr
	JMP  0x00
	JMP  _usart0_tx_isr
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00
	JMP  0x00

_tbl10_G100:
	.DB  0x10,0x27,0xE8,0x3,0x64,0x0,0xA,0x0
	.DB  0x1,0x0
_tbl16_G100:
	.DB  0x0,0x10,0x0,0x1,0x10,0x0,0x1,0x0

;GLOBAL REGISTER VARIABLES INITIALIZATION
__REG_VARS:
	.DB  0x0,0x0,0x4,0x8

_0x20003:
	.DB  0x2
_0x20004:
	.DB  0x1
_0x2040060:
	.DB  0x1
_0x2040000:
	.DB  0x2D,0x4E,0x41,0x4E,0x0,0x49,0x4E,0x46
	.DB  0x0

__GLOBAL_INI_TBL:
	.DW  0x04
	.DW  0x0A
	.DW  __REG_VARS*2

	.DW  0x01
	.DW  _DTMF_test_LED
	.DW  _0x20003*2

	.DW  0x01
	.DW  _stop_LED
	.DW  _0x20004*2

	.DW  0x01
	.DW  __seed_G102
	.DW  _0x2040060*2

_0xFFFFFFFF:
	.DW  0

__RESET:
	CLI
	CLR  R30
	OUT  EECR,R30

;INTERRUPT VECTORS ARE PLACED
;AT THE START OF FLASH
	LDI  R31,1
	OUT  MCUCR,R31
	OUT  MCUCR,R30

;DISABLE WATCHDOG
	LDI  R31,0x18
	WDR
	IN   R26,MCUSR
	CBR  R26,8
	OUT  MCUSR,R26
	STS  WDTCSR,R31
	STS  WDTCSR,R30

;CLEAR R2-R14
	LDI  R24,(14-2)+1
	LDI  R26,2
	CLR  R27
__CLEAR_REG:
	ST   X+,R30
	DEC  R24
	BRNE __CLEAR_REG

;CLEAR SRAM
	LDI  R24,LOW(__CLEAR_SRAM_SIZE)
	LDI  R25,HIGH(__CLEAR_SRAM_SIZE)
	LDI  R26,LOW(__SRAM_START)
	LDI  R27,HIGH(__SRAM_START)
__CLEAR_SRAM:
	ST   X+,R30
	SBIW R24,1
	BRNE __CLEAR_SRAM

;GLOBAL VARIABLES INITIALIZATION
	LDI  R30,LOW(__GLOBAL_INI_TBL*2)
	LDI  R31,HIGH(__GLOBAL_INI_TBL*2)
__GLOBAL_INI_NEXT:
	LPM  R24,Z+
	LPM  R25,Z+
	SBIW R24,0
	BREQ __GLOBAL_INI_END
	LPM  R26,Z+
	LPM  R27,Z+
	LPM  R0,Z+
	LPM  R1,Z+
	MOVW R22,R30
	MOVW R30,R0
__GLOBAL_INI_LOOP:
	LPM  R0,Z+
	ST   X+,R0
	SBIW R24,1
	BRNE __GLOBAL_INI_LOOP
	MOVW R30,R22
	RJMP __GLOBAL_INI_NEXT
__GLOBAL_INI_END:

;GPIOR0 INITIALIZATION
	LDI  R30,__GPIOR0_INIT
	OUT  GPIOR0,R30

;HARDWARE STACK POINTER INITIALIZATION
	LDI  R30,LOW(__SRAM_END-__HEAP_SIZE)
	OUT  SPL,R30
	LDI  R30,HIGH(__SRAM_END-__HEAP_SIZE)
	OUT  SPH,R30

;DATA STACK POINTER INITIALIZATION
	LDI  R28,LOW(__SRAM_START+__DSTACK_SIZE)
	LDI  R29,HIGH(__SRAM_START+__DSTACK_SIZE)

	JMP  _main

	.ESEG
	.ORG 0

	.DSEG
	.ORG 0x200

	.CSEG
;/* initialization file */
;
;#include <mega164a.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.EQU __sm_adc_noise_red=0x02
	.SET power_ctrl_reg=smcr
	#endif
;#include <delay.h>
;
;#include "defs.h"
;
;
;/*
; * most intialization values are generated using Code Wizard and depend on clock value
; */
;void Init_initController(void)
; 0000 000D {

	.CSEG
_Init_initController:
; 0000 000E // Crystal Oscillator division factor: 1
; 0000 000F #pragma optsize-
; 0000 0010 CLKPR=0x80;
	LDI  R30,LOW(128)
	STS  97,R30
; 0000 0011 CLKPR=0x00;
	LDI  R30,LOW(0)
	STS  97,R30
; 0000 0012 #ifdef _OPTIMIZE_SIZE_
; 0000 0013 #pragma optsize+
; 0000 0014 #endif
; 0000 0015 
; 0000 0016 // Input/Output Ports initialization
; 0000 0017 // Port A initialization
; 0000 0018 // Function: Bit7=In Bit6=In Bit5=In Bit4=In Bit3=Out Bit2=Out Bit1=Out Bit0=Out
; 0000 0019 DDRA=0b00001111; // PORTA 7-4 In , PORTA 3-0 Out
	LDI  R30,LOW(15)
	OUT  0x1,R30
; 0000 001A PORTA=0b11111111; // Pull up - PORTA 7-4 (in) , out in logic 1 - PORTA 3-0
	LDI  R30,LOW(255)
	OUT  0x2,R30
; 0000 001B 
; 0000 001C // Port B initialization    - outputs
; 0000 001D DDRB=0x0F;
	LDI  R30,LOW(15)
	OUT  0x4,R30
; 0000 001E PORTB=0x00;
	LDI  R30,LOW(0)
	OUT  0x5,R30
; 0000 001F 
; 0000 0020 // Port C initialization
; 0000 0021 // Function: Bit7=Out Bit6=Out Bit5=Out Bit4=Out Bit3=Out Bit2=Out Bit1=Out Bit0=Out
; 0000 0022 DDRC=0b11111111; // PORTC out
	LDI  R30,LOW(255)
	OUT  0x7,R30
; 0000 0023 PORTC = 0b00000000; //PORTC out in 0 logic
	LDI  R30,LOW(0)
	OUT  0x8,R30
; 0000 0024 
; 0000 0025 // Port D initialization
; 0000 0026 PORTD=0b00100000; // D.5 needs pull-up resistor
	LDI  R30,LOW(32)
	OUT  0xB,R30
; 0000 0027 DDRD= 0b01010000; // D.6 is LED, D.4 is test output
	LDI  R30,LOW(80)
	OUT  0xA,R30
; 0000 0028 
; 0000 0029 // Timer/Counter 0 initialization
; 0000 002A // Clock source: System Clock
; 0000 002B // Clock value: Timer 0 Stopped
; 0000 002C // Mode: Normal top=FFh
; 0000 002D // OC0 output: Disconnected
; 0000 002E TCCR0A=0x00;
	LDI  R30,LOW(0)
	OUT  0x24,R30
; 0000 002F TCCR0B=0x00;
	OUT  0x25,R30
; 0000 0030 TCNT0=0x00;
	OUT  0x26,R30
; 0000 0031 OCR0A=0x00;
	OUT  0x27,R30
; 0000 0032 OCR0B=0x00;
	OUT  0x28,R30
; 0000 0033 
; 0000 0034 // Timer/Counter 1 initialization
; 0000 0035 // Clock source: System Clock
; 0000 0036 // Clock value: 19.531 kHz = CLOCK/256
; 0000 0037 // Mode: CTC top=OCR1A
; 0000 0038 // OC1A output: Discon.
; 0000 0039 // OC1B output: Discon.
; 0000 003A // Noise Canceler: Off
; 0000 003B // Input Capture on Falling Edge
; 0000 003C // Timer 1 Overflow Interrupt: Off
; 0000 003D // Input Capture Interrupt: Off
; 0000 003E // Compare A Match Interrupt: On
; 0000 003F // Compare B Match Interrupt: Off
; 0000 0040 
; 0000 0041 TCCR1A=0x00;
	STS  128,R30
; 0000 0042 TCCR1B=0x0D;
	LDI  R30,LOW(13)
	STS  129,R30
; 0000 0043 TCNT1H=0x00;
	LDI  R30,LOW(0)
	STS  133,R30
; 0000 0044 TCNT1L=0x00;
	STS  132,R30
; 0000 0045 ICR1H=0x00;
	STS  135,R30
; 0000 0046 ICR1L=0x00;
	STS  134,R30
; 0000 0047 
; 0000 0048 // 1 sec = 19531 counts = 4C4BH counts
; 0000 0049 // 4C4BH = 4CH (MSB) and 4BH (LSB)
; 0000 004A 
; 0000 004B 
; 0000 004C //1 sec
; 0000 004D //OCR1AH=0x4C;
; 0000 004E //OCR1AL=0x4B;
; 0000 004F 
; 0000 0050 // 20 ms
; 0000 0051 OCR1AH=0x01;
	LDI  R30,LOW(1)
	STS  137,R30
; 0000 0052 OCR1AL=0x86;
	LDI  R30,LOW(134)
	STS  136,R30
; 0000 0053 
; 0000 0054 //OCR1AH=0x00;
; 0000 0055 //OCR1AL=0x40;
; 0000 0056 
; 0000 0057 
; 0000 0058 OCR1BH=0x00;
	LDI  R30,LOW(0)
	STS  139,R30
; 0000 0059 OCR1BL=0x00;
	STS  138,R30
; 0000 005A 
; 0000 005B // Timer/Counter 2 initialization
; 0000 005C // Clock source: System Clock
; 0000 005D // Clock value: Timer2 Stopped
; 0000 005E // Mode: Normal top=0xFF
; 0000 005F // OC2A output: Disconnected
; 0000 0060 // OC2B output: Disconnected
; 0000 0061 ASSR=0x00;
	STS  182,R30
; 0000 0062 TCCR2A=0x00;
	STS  176,R30
; 0000 0063 TCCR2B=0x00;
	STS  177,R30
; 0000 0064 TCNT2=0x00;
	STS  178,R30
; 0000 0065 OCR2A=0x00;
	STS  179,R30
; 0000 0066 OCR2B=0x00;
	STS  180,R30
; 0000 0067 
; 0000 0068 // External Interrupt(s) initialization
; 0000 0069 // INT0: Off
; 0000 006A // INT1: Off
; 0000 006B // INT2: Off
; 0000 006C // Interrupt on any change on pins PCINT0-7: Off
; 0000 006D // Interrupt on any change on pins PCINT8-15: Off
; 0000 006E // Interrupt on any change on pins PCINT16-23: Off
; 0000 006F // Interrupt on any change on pins PCINT24-31: Off
; 0000 0070 EICRA=0x00;
	STS  105,R30
; 0000 0071 EIMSK=0x00;
	OUT  0x1D,R30
; 0000 0072 PCICR=0x00;
	STS  104,R30
; 0000 0073 
; 0000 0074 // Timer/Counter 0,1,2 Interrupt(s) initialization
; 0000 0075 TIMSK0=0x00;
	STS  110,R30
; 0000 0076 TIMSK1=0x02;
	LDI  R30,LOW(2)
	STS  111,R30
; 0000 0077 TIMSK2=0x00;
	LDI  R30,LOW(0)
	STS  112,R30
; 0000 0078 
; 0000 0079 // USART0 initialization
; 0000 007A // Communication Parameters: 8 Data, 1 Stop, No Parity
; 0000 007B // USART0 Receiver: On
; 0000 007C // USART0 Transmitter: On
; 0000 007D // USART0 Mode: Asynchronous
; 0000 007E // USART0 Baud rate: 9600
; 0000 007F UCSR0A=0x00;
	STS  192,R30
; 0000 0080 UCSR0B=0xD8;
	LDI  R30,LOW(216)
	STS  193,R30
; 0000 0081 UCSR0C=0x06;
	LDI  R30,LOW(6)
	STS  194,R30
; 0000 0082 UBRR0H=0x00;
	LDI  R30,LOW(0)
	STS  197,R30
; 0000 0083 UBRR0L=0x81;
	LDI  R30,LOW(129)
	STS  196,R30
; 0000 0084 
; 0000 0085 // USART1 initialization
; 0000 0086 // USART1 disabled
; 0000 0087 UCSR1B=0x00;
	LDI  R30,LOW(0)
	STS  201,R30
; 0000 0088 
; 0000 0089 
; 0000 008A // Analog Comparator initialization
; 0000 008B // Analog Comparator: Off
; 0000 008C // Analog Comparator Input Capture by Timer/Counter 1: Off
; 0000 008D ACSR=0x80;
	LDI  R30,LOW(128)
	OUT  0x30,R30
; 0000 008E ADCSRB=0x00;
	LDI  R30,LOW(0)
	STS  123,R30
; 0000 008F DIDR1=0x00;
	STS  127,R30
; 0000 0090 
; 0000 0091 // Watchdog Timer initialization
; 0000 0092 // Watchdog Timer Prescaler: OSC/2048
; 0000 0093 #pragma optsize-
; 0000 0094 
; 0000 0095 /*
; 0000 0096 #asm("wdr")
; 0000 0097 // Write 2 consecutive values to enable watchdog
; 0000 0098 // this is NOT a mistake !
; 0000 0099 WDTCSR=0x18;
; 0000 009A WDTCSR=0x08;
; 0000 009B */
; 0000 009C 
; 0000 009D //  disable JTAG
; 0000 009E    MCUCR|= (1<<JTD);
	IN   R30,0x35
	ORI  R30,0x80
	OUT  0x35,R30
; 0000 009F    MCUCR|= (1<<JTD);
	IN   R30,0x35
	ORI  R30,0x80
	OUT  0x35,R30
; 0000 00A0 
; 0000 00A1 #ifdef _OPTIMIZE_SIZE_
; 0000 00A2 #pragma optsize+
; 0000 00A3 #endif
; 0000 00A4 
; 0000 00A5 }
	RET
;
;
;
;/*********************************************
;Project : Test software
;**********************************************
;Chip type: ATmega164A
;Clock frequency: 20 MHz
;Compilers:  CVAVR 2.x
;*********************************************/
;
;#include <mega164a.h>
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.EQU __sm_adc_noise_red=0x02
	.SET power_ctrl_reg=smcr
	#endif
;
;#include <stdio.h>
;#include <delay.h>
;#include <string.h>
;#include <stdlib.h>
;#include "defs.h"
;
;//*************************************************************************************************
;//*********** BEGIN SERIAL STUFF (interrupt-driven, generated by Code Wizard) *********************
;//*************************************************************************************************
;
;#ifndef RXB8
;#define RXB8 1
;#endif
;
;#ifndef TXB8
;#define TXB8 0
;#endif
;
;#ifndef UPE
;#define UPE 2
;#endif
;
;#ifndef DOR
;#define DOR 3
;#endif
;
;#ifndef FE
;#define FE 4
;#endif
;
;#ifndef UDRE
;#define UDRE 5
;#endif
;
;#ifndef RXC
;#define RXC 7
;#endif
;
;#define FRAMING_ERROR (1<<FE)
;#define PARITY_ERROR (1<<UPE)
;#define DATA_OVERRUN (1<<DOR)
;#define DATA_REGISTER_EMPTY (1<<UDRE)
;#define RX_COMPLETE (1<<RXC)
;
;// USART0 Receiver buffer
;#define RX_BUFFER_SIZE0 8
;char rx_buffer0[RX_BUFFER_SIZE0];
;
;#if RX_BUFFER_SIZE0 <= 256
;unsigned char rx_wr_index0,rx_rd_index0,rx_counter0;
;#else
;unsigned int rx_wr_index0,rx_rd_index0,rx_counter0;
;#endif
;
;// This flag is set on USART0 Receiver buffer overflow
;bit rx_buffer_overflow0;
;
;//
;unsigned char cnt;     // interrupts count
;char key;              // key pressed
;unsigned char cnt_key; // number of keys pressed
;bit ok;                // check if command is ok
;char build_PF = 0x00;  // PF to be built and then transmitted
;char build_LED = 0x00; // LED to be built and then transmitted
;char error_LED = 0x8;
;char freq_test_LED = 0x4;
;char DTMF_test_LED = 0x2;

	.DSEG
;char stop_LED = 0x1;
;
;char read_keyboard(void);
;void write_LED(char a);
;void write_PF(char a);
;void build_PF_1(char a);
;void build_PF_2(char a);
;void build_PF_3(char a);
;//char read_LED(void);
;void MyApplication(void);
;
;//
;
;
;// USART0 Receiver interrupt service routine
;interrupt [USART0_RXC] void usart0_rx_isr(void)
; 0001 005E {

	.CSEG
_usart0_rx_isr:
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0001 005F char status,data;
; 0001 0060 status=UCSR0A;
	ST   -Y,R17
	ST   -Y,R16
;	status -> R17
;	data -> R16
	LDS  R17,192
; 0001 0061 data=UDR0;
	LDS  R16,198
; 0001 0062 if ((status & (FRAMING_ERROR | PARITY_ERROR | DATA_OVERRUN))==0)
	MOV  R30,R17
	ANDI R30,LOW(0x1C)
	BRNE _0x20005
; 0001 0063    {
; 0001 0064    rx_buffer0[rx_wr_index0++]=data;
	MOV  R30,R5
	INC  R5
	LDI  R31,0
	SUBI R30,LOW(-_rx_buffer0)
	SBCI R31,HIGH(-_rx_buffer0)
	ST   Z,R16
; 0001 0065 #if RX_BUFFER_SIZE0 == 256
; 0001 0066    // special case for receiver buffer size=256
; 0001 0067    if (++rx_counter0 == 0) rx_buffer_overflow0=1;
; 0001 0068 #else
; 0001 0069    if (rx_wr_index0 == RX_BUFFER_SIZE0) rx_wr_index0=0;
	LDI  R30,LOW(8)
	CP   R30,R5
	BRNE _0x20006
	CLR  R5
; 0001 006A    if (++rx_counter0 == RX_BUFFER_SIZE0)
_0x20006:
	INC  R7
	LDI  R30,LOW(8)
	CP   R30,R7
	BRNE _0x20007
; 0001 006B       {
; 0001 006C       rx_counter0=0;
	CLR  R7
; 0001 006D       rx_buffer_overflow0=1;
	SBI  0x1E,0
; 0001 006E       }
; 0001 006F #endif
; 0001 0070    }
_0x20007:
; 0001 0071 }
_0x20005:
	LD   R16,Y+
	LD   R17,Y+
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	RETI
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Get a character from the USART0 Receiver buffer
;#define _ALTERNATE_GETCHAR_
;#pragma used+
;char getchar(void)
; 0001 0078 {
; 0001 0079 char data;
; 0001 007A while (rx_counter0==0);
;	data -> R17
; 0001 007B data=rx_buffer0[rx_rd_index0++];
; 0001 007C #if RX_BUFFER_SIZE0 != 256
; 0001 007D if (rx_rd_index0 == RX_BUFFER_SIZE0) rx_rd_index0=0;
; 0001 007E #endif
; 0001 007F #asm("cli")
; 0001 0080 --rx_counter0;
; 0001 0081 #asm("sei")
; 0001 0082 return data;
; 0001 0083 }
;#pragma used-
;#endif
;
;// USART0 Transmitter buffer
;#define TX_BUFFER_SIZE0 8
;char tx_buffer0[TX_BUFFER_SIZE0];
;
;#if TX_BUFFER_SIZE0 <= 256
;unsigned char tx_wr_index0,tx_rd_index0,tx_counter0;
;#else
;unsigned int tx_wr_index0,tx_rd_index0,tx_counter0;
;#endif
;
;// USART0 Transmitter interrupt service routine
;interrupt [USART0_TXC] void usart0_tx_isr(void)
; 0001 0093 {
_usart0_tx_isr:
	ST   -Y,R26
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0001 0094 if (tx_counter0)
	LDS  R30,_tx_counter0
	CPI  R30,0
	BREQ _0x2000E
; 0001 0095    {
; 0001 0096    --tx_counter0;
	SUBI R30,LOW(1)
	STS  _tx_counter0,R30
; 0001 0097    UDR0=tx_buffer0[tx_rd_index0++];
	LDS  R30,_tx_rd_index0
	SUBI R30,-LOW(1)
	STS  _tx_rd_index0,R30
	SUBI R30,LOW(1)
	LDI  R31,0
	SUBI R30,LOW(-_tx_buffer0)
	SBCI R31,HIGH(-_tx_buffer0)
	LD   R30,Z
	STS  198,R30
; 0001 0098 #if TX_BUFFER_SIZE0 != 256
; 0001 0099    if (tx_rd_index0 == TX_BUFFER_SIZE0) tx_rd_index0=0;
	LDS  R26,_tx_rd_index0
	CPI  R26,LOW(0x8)
	BRNE _0x2000F
	LDI  R30,LOW(0)
	STS  _tx_rd_index0,R30
; 0001 009A #endif
; 0001 009B    }
_0x2000F:
; 0001 009C }
_0x2000E:
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R26,Y+
	RETI
;
;#ifndef _DEBUG_TERMINAL_IO_
;// Write a character to the USART0 Transmitter buffer
;#define _ALTERNATE_PUTCHAR_
;#pragma used+
;void putchar(char c)
; 0001 00A3 {
; 0001 00A4 while (tx_counter0 == TX_BUFFER_SIZE0);
;	c -> Y+0
; 0001 00A5 #asm("cli")
; 0001 00A6 if (tx_counter0 || ((UCSR0A & DATA_REGISTER_EMPTY)==0))
; 0001 00A7    {
; 0001 00A8    tx_buffer0[tx_wr_index0++]=c;
; 0001 00A9 #if TX_BUFFER_SIZE0 != 256
; 0001 00AA    if (tx_wr_index0 == TX_BUFFER_SIZE0) tx_wr_index0=0;
; 0001 00AB #endif
; 0001 00AC    ++tx_counter0;
; 0001 00AD    }
; 0001 00AE else
; 0001 00AF    UDR0=c;
; 0001 00B0 #asm("sei")
; 0001 00B1 }
;#pragma used-
;#endif
;//*************************************************************************************************
;//********************END SERIAL STUFF (USART0)  **************************************************
;//*************************************************************************************************
;//*******   if you need USART1, enable it in Code Wizard and copy coresponding code here  *********
;//*************************************************************************************************
;
;/*
; * Timer 1 Output Compare A interrupt is used to blink LED
; */
;interrupt [TIM1_COMPA] void timer1_compa_isr(void)
; 0001 00BE {
_timer1_compa_isr:
	ST   -Y,R0
	ST   -Y,R1
	ST   -Y,R15
	ST   -Y,R22
	ST   -Y,R23
	ST   -Y,R24
	ST   -Y,R25
	ST   -Y,R26
	ST   -Y,R27
	ST   -Y,R30
	ST   -Y,R31
	IN   R30,SREG
	ST   -Y,R30
; 0001 00BF 
; 0001 00C0 cnt=(cnt+1)%50;
	MOV  R30,R6
	LDI  R31,0
	ADIW R30,1
	MOVW R26,R30
	LDI  R30,LOW(50)
	LDI  R31,HIGH(50)
	CALL __MODW21
	MOV  R6,R30
; 0001 00C1 if (cnt==0) LED1 = ~LED1; // invert LED
	TST  R6
	BRNE _0x20018
	SBIS 0xB,6
	RJMP _0x20019
	CBI  0xB,6
	RJMP _0x2001A
_0x20019:
	SBI  0xB,6
_0x2001A:
; 0001 00C2 //
; 0001 00C3  MyApplication();
_0x20018:
	RCALL _MyApplication
; 0001 00C4 }
	LD   R30,Y+
	OUT  SREG,R30
	LD   R31,Y+
	LD   R30,Y+
	LD   R27,Y+
	LD   R26,Y+
	LD   R25,Y+
	LD   R24,Y+
	LD   R23,Y+
	LD   R22,Y+
	LD   R15,Y+
	LD   R1,Y+
	LD   R0,Y+
	RETI
;
;/*
; * main function of program
; */
;void main (void)
; 0001 00CA {
_main:
; 0001 00CB //unsigned char temp,i;
; 0001 00CC 
; 0001 00CD     Init_initController();  // this must be the first "init" action/call!
	RCALL _Init_initController
; 0001 00CE     #asm("sei")             // enable interrupts
	sei
; 0001 00CF     LED1 = 1;               // initial state, will be changed by timer 1
	SBI  0xB,6
; 0001 00D0 
; 0001 00D1     cnt_key = 0;
	CLR  R8
; 0001 00D2     ok = 1;
	SBI  0x1E,1
; 0001 00D3 
; 0001 00D4     while(TRUE)
_0x2001F:
; 0001 00D5     {
; 0001 00D6     }
	RJMP _0x2001F
; 0001 00D7     /*
; 0001 00D8         wdogtrig();            // call often else processor will reset
; 0001 00D9         if(rx_counter0)     // if a character is available on serial port USART0
; 0001 00DA         {
; 0001 00DB             temp = getchar();
; 0001 00DC             if(temp == '?')
; 0001 00DD                 printf("\r\nSwVersion:%d.%d\r\n", SW_VERSION/10, SW_VERSION%10);
; 0001 00DE             else
; 0001 00DF                 putchar(temp+1);        // echo back the character + 1 ("a" becomes "b", etc)
; 0001 00E0         }
; 0001 00E1 
; 0001 00E2         if(SW1 == 0)        // pressed
; 0001 00E3         {
; 0001 00E4             delay_ms(30);   // debounce switch
; 0001 00E5             if(SW1 == 0)
; 0001 00E6             {                // LED will blink slow or fast
; 0001 00E7                 while(SW1==0)
; 0001 00E8                     wdogtrig();    // wait for release
; 0001 00E9                 // alternate between values and values/4 for OCR1A register
; 0001 00EA                 // 0186 H / 4 = 0061 H
; 0001 00EB                 // new frequency = old frequency * 4
; 0001 00EC                 if(OCR1AH == 0x01)
; 0001 00ED                     {TCNT1H=0; TCNT1L=0; OCR1AH = 0x00; OCR1AL = 0x61;}
; 0001 00EE                 else
; 0001 00EF                     {TCNT1H=0; TCNT1L=0; OCR1AH = 0x01; OCR1AL = 0x86;}
; 0001 00F0             }
; 0001 00F1         }
; 0001 00F2 
; 0001 00F3         // measure time intervals on oscilloscope connected to pin TESTP
; 0001 00F4         for(i=0; i<3; i++) {
; 0001 00F5             TESTP = 1;
; 0001 00F6             delay_us(1);
; 0001 00F7             TESTP = 0;   // may check accuracy of 1us interval on oscilloscope
; 0001 00F8         }
; 0001 00F9     }
; 0001 00FA     */
; 0001 00FB 
; 0001 00FC }// end main loop
_0x20022:
	RJMP _0x20022
;
;/*******************************************
;My application function
;
;********************************************/
;void MyApplication (void)
; 0001 0103 {
_MyApplication:
; 0001 0104     key = read_keyboard();
	RCALL _read_keyboard
	MOV  R9,R30
; 0001 0105     if(key != -1) {
	MOV  R26,R9
	LDI  R30,LOW(255)
	LDI  R27,0
	SER  R31
	CP   R30,R26
	CPC  R31,R27
	BRNE PC+3
	JMP _0x20023
; 0001 0106 
; 0001 0107     if(ok == 0)
	SBIC 0x1E,1
	RJMP _0x20024
; 0001 0108     {
; 0001 0109         if(key == 0x0F) {
	LDI  R30,LOW(15)
	CP   R30,R9
	BREQ _0x20A0003
; 0001 010A             cnt_key = 0;
; 0001 010B             ok = 1;
; 0001 010C             write_LED(error_LED);
; 0001 010D             return;
; 0001 010E         }
; 0001 010F         if(key != 0x0F) return;
	CP   R30,R9
	BREQ _0x20028
	RET
; 0001 0110     }
_0x20028:
; 0001 0111 
; 0001 0112     switch (cnt_key)
_0x20024:
	MOV  R30,R8
	LDI  R31,0
; 0001 0113     {
; 0001 0114         case 0:
	SBIW R30,0
	BRNE _0x2002C
; 0001 0115         {
; 0001 0116             build_PF = 0;
	CLR  R11
; 0001 0117             build_LED = 0;
	CLR  R10
; 0001 0118             write_PF(0); // sets PF to initial command
	LDI  R26,LOW(0)
	RCALL _write_PF
; 0001 0119             write_LED(0); // sets LEDs to LOW
	LDI  R26,LOW(0)
	RCALL _write_LED
; 0001 011A             if(key == 0x0F) {
	LDI  R30,LOW(15)
	CP   R30,R9
	BRNE _0x2002D
; 0001 011B                 cnt_key = 0;
_0x20A0003:
	CLR  R8
; 0001 011C                 ok = 1;
	SBI  0x1E,1
; 0001 011D                 write_LED(error_LED);
	MOV  R26,R13
	RCALL _write_LED
; 0001 011E                 return;
	RET
; 0001 011F             }
; 0001 0120             if(key > 0x3) ok = 0;
_0x2002D:
	LDI  R30,LOW(3)
	CP   R30,R9
	BRSH _0x20030
	CBI  0x1E,1
; 0001 0121             else {
	RJMP _0x20033
_0x20030:
; 0001 0122                 cnt_key++;
	INC  R8
; 0001 0123                 build_PF_1(key);
	MOV  R26,R9
	RCALL _build_PF_1
; 0001 0124             }
_0x20033:
; 0001 0125         }
; 0001 0126         break;
	RJMP _0x2002B
; 0001 0127 
; 0001 0128         case 1:
_0x2002C:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x20034
; 0001 0129         {
; 0001 012A             if(key < 0x1 || key > 0x3) ok = 0;
	LDI  R30,LOW(1)
	CP   R9,R30
	BRLO _0x20036
	LDI  R30,LOW(3)
	CP   R30,R9
	BRSH _0x20035
_0x20036:
	CBI  0x1E,1
; 0001 012B             else switch(key)
	RJMP _0x2003A
_0x20035:
	MOV  R30,R9
	LDI  R31,0
; 0001 012C             {
; 0001 012D                 case 1:
	CPI  R30,LOW(0x1)
	LDI  R26,HIGH(0x1)
	CPC  R31,R26
	BRNE _0x2003E
; 0001 012E                 {
; 0001 012F                     cnt_key++;
	INC  R8
; 0001 0130                     build_LED = freq_test_LED;
	MOV  R10,R12
; 0001 0131                     build_PF_2(key);
	RJMP _0x2005C
; 0001 0132                 }
; 0001 0133                 break;
; 0001 0134 
; 0001 0135                 case 2:
_0x2003E:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x2003F
; 0001 0136                 {
; 0001 0137                     cnt_key++;
	INC  R8
; 0001 0138                     build_LED = DTMF_test_LED;
	LDS  R10,_DTMF_test_LED
; 0001 0139                     build_PF_2(key);
	RJMP _0x2005C
; 0001 013A                 }
; 0001 013B                 break;
; 0001 013C 
; 0001 013D                 case 3:
_0x2003F:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x2003D
; 0001 013E                 {
; 0001 013F                     cnt_key++;
	INC  R8
; 0001 0140                     build_LED = stop_LED;
	LDS  R10,_stop_LED
; 0001 0141                     build_PF_2(key);
_0x2005C:
	MOV  R26,R9
	RCALL _build_PF_2
; 0001 0142                 }
; 0001 0143                 break;
; 0001 0144             }
_0x2003D:
_0x2003A:
; 0001 0145         }
; 0001 0146         break;
	RJMP _0x2002B
; 0001 0147 
; 0001 0148         case 2:
_0x20034:
	CPI  R30,LOW(0x2)
	LDI  R26,HIGH(0x2)
	CPC  R31,R26
	BRNE _0x20041
; 0001 0149         {
; 0001 014A             if(build_LED == stop_LED)
	LDS  R30,_stop_LED
	CP   R30,R10
	BRNE _0x20042
; 0001 014B             {
; 0001 014C                 if(key != 0x0F) ok = 0;
	LDI  R30,LOW(15)
	CP   R30,R9
	BREQ _0x20043
	CBI  0x1E,1
; 0001 014D                 else {
	RJMP _0x20046
_0x20043:
; 0001 014E                     cnt_key = 0;
	CALL SUBOPT_0x0
; 0001 014F                     write_PF(build_PF);
; 0001 0150                     write_LED(build_LED);
; 0001 0151                 }
_0x20046:
; 0001 0152             }
; 0001 0153             else if(build_LED == freq_test_LED)
	RJMP _0x20047
_0x20042:
	CP   R12,R10
	BRNE _0x20048
; 0001 0154             {
; 0001 0155                 if(key > 0x7) ok = 0;
	LDI  R30,LOW(7)
	CP   R30,R9
	BRSH _0x20049
	CBI  0x1E,1
; 0001 0156                 else {
	RJMP _0x2004C
_0x20049:
; 0001 0157                     cnt_key++;
	INC  R8
; 0001 0158                     build_PF_3(key);
	MOV  R26,R9
	RCALL _build_PF_3
; 0001 0159                 }
_0x2004C:
; 0001 015A             }
; 0001 015B             else if(build_LED == DTMF_test_LED)
	RJMP _0x2004D
_0x20048:
	LDS  R30,_DTMF_test_LED
	CP   R30,R10
	BRNE _0x2004E
; 0001 015C             {
; 0001 015D                 cnt_key++;
	INC  R8
; 0001 015E                 build_PF_3(key);
	MOV  R26,R9
	RCALL _build_PF_3
; 0001 015F             }
; 0001 0160         }
_0x2004E:
_0x2004D:
_0x20047:
; 0001 0161         break;
	RJMP _0x2002B
; 0001 0162 
; 0001 0163         case 3:
_0x20041:
	CPI  R30,LOW(0x3)
	LDI  R26,HIGH(0x3)
	CPC  R31,R26
	BRNE _0x2002B
; 0001 0164         {
; 0001 0165             if(key != 0x0F) ok = 0;
	LDI  R30,LOW(15)
	CP   R30,R9
	BREQ _0x20050
	CBI  0x1E,1
; 0001 0166             else {
	RJMP _0x20053
_0x20050:
; 0001 0167                 cnt_key = 0;
	CALL SUBOPT_0x0
; 0001 0168                 write_PF(build_PF);
; 0001 0169                 write_LED(build_LED);
; 0001 016A             }
_0x20053:
; 0001 016B         }
; 0001 016C         break;
; 0001 016D     }
_0x2002B:
; 0001 016E     }
; 0001 016F }
_0x20023:
	RET
;
;// initial MyApplication():
;/*
;  key=read_keyboard();
;if (key!=-1)
;    {
;    write_LED(key);
;    //write_PF(key);
;    }
;//key=read_PF();
;//write_LED(key);
;write_PF(key);
;*/
;
;/*******************************************
;Other functions
;
;*******************************************/
;
;char read_keyboard(void)
; 0001 0184 {
_read_keyboard:
; 0001 0185 // line 0 - PA0,  line 1 - PA1,  line 2 - PA2,  line 3 - PA3 - outputs
; 0001 0186 char scan[4]={0xFE,0xFD,0xFB, 0xF7};
; 0001 0187 char row,col;
; 0001 0188 char cod=0xFF;
; 0001 0189 
; 0001 018A for (row=0; row<4; row++)
	SBIW R28,4
	LDI  R30,LOW(254)
	ST   Y,R30
	LDI  R30,LOW(253)
	STD  Y+1,R30
	LDI  R30,LOW(251)
	STD  Y+2,R30
	LDI  R30,LOW(247)
	STD  Y+3,R30
	CALL __SAVELOCR4
;	scan -> Y+4
;	row -> R17
;	col -> R16
;	cod -> R19
	LDI  R19,255
	LDI  R17,LOW(0)
_0x20055:
	CPI  R17,4
	BRSH _0x20056
; 0001 018B {
; 0001 018C PORTA=scan[row];        //se modifica doar PA0-3
	MOV  R30,R17
	LDI  R31,0
	MOVW R26,R28
	ADIW R26,4
	ADD  R26,R30
	ADC  R27,R31
	LD   R30,X
	OUT  0x2,R30
; 0001 018D delay_us(1);
	__DELAY_USB 7
; 0001 018E // col 0 - PA4,  col 1 - PA5,  col 2 - PA6,  col 3 - PA7 - inputs
; 0001 018F col=PINA>>4;
	IN   R30,0x0
	LDI  R31,0
	CALL __ASRW4
	MOV  R16,R30
; 0001 0190 if (col!=0x0F)
	CPI  R16,15
	BREQ _0x20057
; 0001 0191     {
; 0001 0192     if (col==0x0E) col=0;
	CPI  R16,14
	BRNE _0x20058
	LDI  R16,LOW(0)
; 0001 0193     if (col==0x0D) col=1;
_0x20058:
	CPI  R16,13
	BRNE _0x20059
	LDI  R16,LOW(1)
; 0001 0194     if (col==0x0B) col=2;
_0x20059:
	CPI  R16,11
	BRNE _0x2005A
	LDI  R16,LOW(2)
; 0001 0195     if (col==0x07) col=3;
_0x2005A:
	CPI  R16,7
	BRNE _0x2005B
	LDI  R16,LOW(3)
; 0001 0196     cod=4*row+col;
_0x2005B:
	MOV  R30,R17
	LSL  R30
	LSL  R30
	ADD  R30,R16
	MOV  R19,R30
; 0001 0197     break;
	RJMP _0x20056
; 0001 0198     }
; 0001 0199 }
_0x20057:
	SUBI R17,-1
	RJMP _0x20055
_0x20056:
; 0001 019A return cod;
	MOV  R30,R19
	CALL __LOADLOCR4
	ADIW R28,8
	RET
; 0001 019B }
;
;void write_LED(char a)
; 0001 019E {
_write_LED:
; 0001 019F // write PORTB bits 3-0 with a 4 bits value a3-a0
; 0001 01A0 char val;
; 0001 01A1 val=a & 0x0F;
	ST   -Y,R26
	ST   -Y,R17
;	a -> Y+1
;	val -> R17
	LDD  R30,Y+1
	ANDI R30,LOW(0xF)
	MOV  R17,R30
; 0001 01A2 PORTB=(PORTB & 0xF0) | val;
	IN   R30,0x5
	ANDI R30,LOW(0xF0)
	OR   R30,R17
	OUT  0x5,R30
; 0001 01A3 }
	RJMP _0x20A0002
;
;void write_PF(char a)
; 0001 01A6 {
_write_PF:
; 0001 01A7 // write PORTC bits 7-0 with a 8 bits value a7-a0
; 0001 01A8 PORTC = a;
	ST   -Y,R26
;	a -> Y+0
	LD   R30,Y
	OUT  0x8,R30
; 0001 01A9 }
	ADIW R28,1
	RET
;
;void build_PF_1(char a)
; 0001 01AC {
_build_PF_1:
; 0001 01AD // write x bits 7-6 with a 2 bits value a1-a0
; 0001 01AE char val;
; 0001 01AF val = a & 0x03;
	CALL SUBOPT_0x1
;	a -> Y+1
;	val -> R17
; 0001 01B0 build_PF = (build_PF & 0x3F) | (val << 6);
	ANDI R30,LOW(0x3F)
	MOV  R26,R30
	MOV  R30,R17
	SWAP R30
	ANDI R30,0xF0
	LSL  R30
	LSL  R30
	OR   R30,R26
	RJMP _0x20A0001
; 0001 01B1 }
;
;void build_PF_2(char a)
; 0001 01B4 {
_build_PF_2:
; 0001 01B5 // write x bits 5-4 with a 2 bits value a1-a0
; 0001 01B6 char val;
; 0001 01B7 val = a & 0x03;
	CALL SUBOPT_0x1
;	a -> Y+1
;	val -> R17
; 0001 01B8 build_PF = (build_PF & 0xCF) | (val << 4);
	ANDI R30,LOW(0xCF)
	MOV  R26,R30
	MOV  R30,R17
	SWAP R30
	ANDI R30,0xF0
	OR   R30,R26
	RJMP _0x20A0001
; 0001 01B9 }
;
;void build_PF_3(char a)
; 0001 01BC {
_build_PF_3:
; 0001 01BD // write x bits 3-0 with a 4 bits value a3-a0
; 0001 01BE char val;
; 0001 01BF val=a & 0x0F;
	ST   -Y,R26
	ST   -Y,R17
;	a -> Y+1
;	val -> R17
	LDD  R30,Y+1
	ANDI R30,LOW(0xF)
	MOV  R17,R30
; 0001 01C0 build_PF = (build_PF & 0xF0) | val;
	MOV  R30,R11
	ANDI R30,LOW(0xF0)
	OR   R30,R17
_0x20A0001:
	MOV  R11,R30
; 0001 01C1 }
_0x20A0002:
	LDD  R17,Y+0
	ADIW R28,2
	RET
;
;/*
;char read_LED(void)
;{
;// read PORTB bits 3-0
;char val;
;val= PINB & 0x0F;
;return val;
;}
;*/
;
;//codul cu 4 biti write, 4 biti read PF
;/*
;void write_PF(char a)
;{
;// write PORTC bits 3-0 with a 4 bits value a3-a0
;char val;
;val=a & 0x0F;
;PORTC=(PORTC & 0xF0) | val;
;}
;
;char read_PF(void)
;{
;// read PORTB bits 3-0
;char val;
;val= PINB & 0x0F;
;return val;
;}
;*/
	#ifndef __SLEEP_DEFINED__
	#define __SLEEP_DEFINED__
	.EQU __se_bit=0x01
	.EQU __sm_mask=0x0E
	.EQU __sm_powerdown=0x04
	.EQU __sm_powersave=0x06
	.EQU __sm_standby=0x0C
	.EQU __sm_ext_standby=0x0E
	.EQU __sm_adc_noise_red=0x02
	.SET power_ctrl_reg=smcr
	#endif

	.CSEG

	.CSEG

	.CSEG

	.DSEG

	.CSEG

	.CSEG

	.CSEG

	.DSEG
_rx_buffer0:
	.BYTE 0x8
_DTMF_test_LED:
	.BYTE 0x1
_stop_LED:
	.BYTE 0x1
_tx_buffer0:
	.BYTE 0x8
_tx_wr_index0:
	.BYTE 0x1
_tx_rd_index0:
	.BYTE 0x1
_tx_counter0:
	.BYTE 0x1
__seed_G102:
	.BYTE 0x4

	.CSEG
;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:2 WORDS
SUBOPT_0x0:
	CLR  R8
	MOV  R26,R11
	CALL _write_PF
	MOV  R26,R10
	JMP  _write_LED

;OPTIMIZER ADDED SUBROUTINE, CALLED 2 TIMES, CODE SIZE REDUCTION:1 WORDS
SUBOPT_0x1:
	ST   -Y,R26
	ST   -Y,R17
	LDD  R30,Y+1
	ANDI R30,LOW(0x3)
	MOV  R17,R30
	MOV  R30,R11
	RET


	.CSEG
__ANEGW1:
	NEG  R31
	NEG  R30
	SBCI R31,0
	RET

__ASRW4:
	ASR  R31
	ROR  R30
__ASRW3:
	ASR  R31
	ROR  R30
__ASRW2:
	ASR  R31
	ROR  R30
	ASR  R31
	ROR  R30
	RET

__DIVW21U:
	CLR  R0
	CLR  R1
	LDI  R25,16
__DIVW21U1:
	LSL  R26
	ROL  R27
	ROL  R0
	ROL  R1
	SUB  R0,R30
	SBC  R1,R31
	BRCC __DIVW21U2
	ADD  R0,R30
	ADC  R1,R31
	RJMP __DIVW21U3
__DIVW21U2:
	SBR  R26,1
__DIVW21U3:
	DEC  R25
	BRNE __DIVW21U1
	MOVW R30,R26
	MOVW R26,R0
	RET

__MODW21:
	CLT
	SBRS R27,7
	RJMP __MODW211
	COM  R26
	COM  R27
	ADIW R26,1
	SET
__MODW211:
	SBRC R31,7
	RCALL __ANEGW1
	RCALL __DIVW21U
	MOVW R30,R26
	BRTC __MODW212
	RCALL __ANEGW1
__MODW212:
	RET

__SAVELOCR4:
	ST   -Y,R19
__SAVELOCR3:
	ST   -Y,R18
__SAVELOCR2:
	ST   -Y,R17
	ST   -Y,R16
	RET

__LOADLOCR4:
	LDD  R19,Y+3
__LOADLOCR3:
	LDD  R18,Y+2
__LOADLOCR2:
	LDD  R17,Y+1
	LD   R16,Y
	RET

;END OF CODE MARKER
__END_OF_CODE:
