;
; CompProject1.asm
;
; Created: 1/7/2020 9:52:16 AM
; Author : Peyton
;




.INCLUDE "M328PDEF.INC"
.EQU LCD_PRT = PORTB
.EQU LCD_DDR = DDRB
.EQU LCD_PIN = PINB
.EQU LCD_RS = 0
.EQU LCD_RW = 1
.EQU LCD_EN = 2

.org 0x300
Ascii:.DB 0b01000001, 0b01000010, 0b01000011, 0b01000100, 0b01000101, 0b01000110, 0b01000111, 0b01001000, 0b01001001, 0b01001010, 0b01001011, 0b01001100, 0b01001101, 0b01001110, 0b01001111, 0b01010000, 0b01010001, 0b01010010, 0b01010011, 0b01010100, 0b01010101, 0b01010110, 0b01010111, 0b01011000, 0b01011001, 0b01011010, 0b00110000, 0b00110001, 0b00110010, 0b00110011, 0b00110100, 0b00110101, 0b00110110, 0b00110111, 0b00111000, 0b00111001
;			A			B			C			D			E			F			G			H			I			J			K			L			M			N			O			P			Q			R			S			T			U			V			W			X			Y			Z			0			1			2			3			4			5			6			7			8			9


.org 0x00 
	JMP MAIN
.org 0x02
	JMP PRESS

MAIN:	
		ldi r31,0x0a	; Preload binary 00001010 into r31z
		ldi r17,0x00
		sts eicra,r31	; Set eicra to 00001010 (both interrupts trigger on active low)
		ldi r31,0x03	; Preload binary 00000011 into r31
		out eimsk,r31	; Set eimsk to 00000011 (enable both interrupts)
		ldi r31,0x00	; Preload binary 00000000 into r31
		out DDRD,r31	; Set ddrd to 00000000 (all pins of portd are input pins, note you only need pins 2 and 3 for the interrupts)
		out DDRC,r31
		ldi r31,0x0c	; Preload binary 00001100 into r31
		//ldi r31,0x00
		out PORTD,r31	; Set portd to 00001100 (portd pins 2 and 3 are internally hooked to pull up resistors)
		sei		; Set enable interrupts

		LDI R21,HIGH(RAMEND)	
		OUT SPH,R21				;set up stack
		LDI R21,LOW(RAMEND)
		OUT SPL,R21

		LDI r21,0xFF;
		OUT LCD_DDR,R21			;LCD data port is output
		OUT LCD_DDR,R21			;LCD command port is output

		LDI R16, 0x00 ; load 0's into R16
		OUT DDRC, R16 ; output 1's to configure DDRc as "input" port
		OUT PORTC, R16 ; output 1's to configure DDRc as "input" port


		LDI R16,0X33			;init .LCD for 4-bit data
		CALL CMNDWRT			;call command function
		CALL DELAY_2ms			;init. hold
		LDI R16,0X32			;init. LCD for 4-bit data
		CALL CMNDWRT			;call command function
		CALL DELAY_2ms			;init. hold
		LDI R16,0X28			;init. LCD 2 lines, 5x7 matrix
		CALL CMNDWRT			;call command function
		CALL DELAY_2ms			;init. hold
		LDI R16,0X0E			;display on, cursor on
		CALL CMNDWRT			;call command function
		LDI R16,0X01			;clear LCD
		CALL CMNDWRT			;call command function
		CALL DELAY_2ms			;delay 2 ms for clear LCD
		LDI R16,0X06			;shift curser right
		CALL CMNDWRT			;call command function
	
		/*LDI R16,'F'				;display letter 'H'
		CALL DATAWRT			;call data write function
		LDI R16,' '				;display letter 'i'
		CALL DATAWRT			;call data write function*/

		LDI R18, 0
		LDI R20, 0
		/*ldi r19, 0x00
		CALL LoadZRegister
		ldi ZL, low(2*Ascii)
		ldi ZH, high(2*Ascii)
		ldi r29,0x01
		add zl,r29 ; add the BCD  value to be converted to low byte of 7SEG CODE TABLE to create an offset numerically equivalent to BCD value 
		lpm r18,z ; load z into r18 from program memory from7SEG CODE TABLE using modified z register as pointer
		MOV R16,r18
		CALL DATAWRT*/
	
	HERE:
		JMP HERE			;stay here

	CMNDWRT:
		MOV R27,R16
		ANDI R27,0XF0
		IN R26,LCD_PRT
		ANDI R26,0X0F
		OR R26,R27
		OUT Lcd_PRT,R26		;LCD data port = R16
		CBI LCD_PRT,LCD_RS	;RS = 0 for command
		CBI LCD_PRT,LCD_RW	;RW = 0 for write
		SBI LCD_PRT,LCD_EN	;EN = 1 for high pulse
		CALL SDELAY			;make a wide EN pulse
		CBI LCD_PRT,LCD_EN	;EN=0 for H-to-L pulse

		CALL DELAY_100us	;make a wide EN pulse

		MOV R27,R16
		SWAP R27
		ANDI R27,0XF0
		IN R26,LCD_PRT
		ANDI R26,0X0F
		OR R26,R27
		OUT LCD_PRT,R26		;LCD data port = R16
		SBI LCD_PRT,LCD_EN	;EN = 1 for high pulse
		CALL SDELAY			;make a wide EN pulse
		CBI LCD_PRT,LCD_EN	;EN = 0 for H-to-L pulse

		CALL DELAY_100us	;wait 100 us
		RET


	DATAWRT:
		MOV R27,R16
		ANDI R27,0XF0
		IN R26,LCD_PRT
		ANDI R26,0X0F
		OR R26,R27
		OUT Lcd_PRT,R26		;LCD data port = R16
		SBI LCD_PRT,LCD_RS	;RS = 1 for data
		CBI LCD_PRT,LCD_RW	;RW = 0 for write
		SBI LCD_PRT,LCD_EN	;EN = 1 for high pulse
		CALL SDELAY			;make a wide EN pulse
		CBI LCD_PRT,LCD_EN	;EN = 0 for H-to-L pulse

		MOV R27,R16
		SWAP R27
		ANDI R27,0XF0
		IN R26,LCD_PRT
		ANDI R26,0X0F
		OR R26,R27
		OUT Lcd_PRT,R26		;LCD data port = R16
		SBI LCD_PRT,LCD_EN	;EN = 1 for high pulse
		CALL SDELAY			;make a wide EN pulse
		CBI LCD_PRT,LCD_EN	;EN = 0 for H-to-L pulse

		CALL DELAY_100us	;wait 100 us
		RET

	SDELAY:
		NOP
		NOP
		RET

	DELAY_100us:
		PUSH R17
		LDI R17,60
	DR0: CALL SDELAY
		DEC R17
		BRNE DR0
		POP R17
		RET


	DELAY_2ms:
		PUSH R17
		LDI R17,20
	LDR0: CALL DELAY_100us
		DEC R17
		BRNE LDR0
		POP R17
		RET
	Press:
		CLI
		CALL LoadPortC
		CALL LoadZRegister
		CALL DataWrt
		LDI R16, 0x01
		ADD R20, R16
		CALL ShiftDisplayCheck
BACK:	CLR R16
		SEI
		JMP HERE

	LoadPortC:
		LDI R16,0X00
		OUT DDRC,R16
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		CALL Delay_2ms
		IN R16,PINC
		LDI R19, 0b00011111
		AND R16,R19
		LDI R21, 0b00010010
		CP R16, R21 ; Compare the value recieved from the keypad with R21 (it should be the value 18) and see if it is the shift key.
		BREQ ShiftKey
		RET

	LoadZRegister:
		/*ldi r19, 0x00
		ldi ZL, low(2*Ascii)
		ldi ZH, high(2*Ascii)
		add zl,r19 ; add the BCD  value to be converted to low byte of 7SEG CODE TABLE to create an offset numerically equivalent to BCD value 
		lpm r19,z ; load z into r17 from program memory from7SEG CODE TABLE using modified z register as pointer
		ret*/
		ldi ZL, low(2*Ascii)
		ldi ZH, high(2*Ascii)
		LDI R21,0
		LDI R22,18
		CPSE R18,R21
		add r16, R22
		add zl,r16 ; add the BCD  value to be converted to low byte of 7SEG CODE TABLE to create an offset numerically equivalent to BCD value 
		lpm r16,z ; load z into r16 from program memory from7SEG CODE TABLE using modified z register as pointer
		CALL delay_2ms
		RET

	ShiftKey:
		LDI R21, 1
		CP R18, R21
		BREQ HIGH1
		LDI R21, 0
		CP R18, R21
		BREQ LOW1
	HIGH1:
		ldi R18, 0
		JMP BACK
	LOW1:
		ldi R18, 1
		JMP BACK

	ShiftDisplayCheck:
		ldi R19, 0x05
		CP R20, R19
		BRSH DisplayShift
		RET	
	DisplayShift:
		LDI R16,0x02			;go home
		CALL CMNDWRT
		LDI R16,' '		
		CALL DATAWRT			;write blank space
		LDI R16,0X18			;shift display left
		CALL CMNDWRT			;call command function
		LDI R16,0X84			;send curser back to the right
		CALL CMNDWRT			;call command function
		RET