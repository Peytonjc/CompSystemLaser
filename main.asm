;
; CompProject1.asm
;
; Created: 1/7/2020 9:52:16 AM
; Author : Peyton
;



;Define names for PortB to use with LCD Functions
.INCLUDE "M328PDEF.INC"
.EQU LCD_PRT = PORTB
.EQU LCD_DDR = DDRB
.EQU LCD_PIN = PINB
.EQU LCD_RS = 0
.EQU LCD_RW = 1
.EQU LCD_EN = 2

.EQU ModeFlag = 0x600

;Set up Table for Ascii letters at location 0x300
.org 0x300
Ascii:.DB 0b01000001, 0b01000010, 0b01000011, 0b01000100, 0b01000101, 0b01000110, 0b01000111, 0b01001000, 0b01001001, 0b01001010, 0b01001011, 0b01001100, 0b01001101, 0b01001110, 0b01001111, 0b01010000, 0b01010001, 0b01010010, 0b01010011, 0b01010100, 0b01010101, 0b01010110, 0b01010111, 0b01011000, 0b01011001, 0b01011010, 0b00110000, 0b00110001, 0b00110010, 0b00110011, 0b00110100, 0b00110101, 0b00110110, 0b00110111, 0b00111000, 0b00111001
;			A			B			C			D			E			F			G			H			I			J			K			L			M			N			O			P			Q			R			S			T			U			V			W			X			Y			Z			0			1			2			3			4			5			6			7			8			9

;Set up Table for Laser Display (First one is a box)
.org 0x500
Box:.DB 0x04,	0x00,	0x00,	0x00,	0xFF,	0xFF,	0xFF,	0xFF,	0x00
;		N		X1		Y1		X2		Y2		X3		Y3		X4		Y4
.org 0x510
A:.DB	0x07,	0x02,	0x50,	0x10,	0x78,	0x1D,	0xA0,	0x2C,	0x78,	0x3B,	0x50,	0x2C,	0x78,	0x10,	0x78
.org 0x520
B:.DB	0x0A,	0x02,	0x50,	0x02,	0x79,	0x02,	0xA1,	0x2E,	0xA1,	0x3B,	0x8C,	0x2E,	0x79,	0x02,	0x79,	0x2E,	0x79,	0x3C,	0x64,	0x2E,	0x50

.org 0x570
G:.DB 0x0A, 0x3B, 0xA0, 0x03, 0xA0, 0x03, 0x50, 0x03B, 0x50, 0x3B, 0x6F, 0x21, 0x6F, 0x3B, 0x6F, 0x3B, 0x50, 0x03, 0x50, 0x03, 0xA0
.org 0x580
H:.DB 0x09, 0x03, 0x50, 0x03, 0x79, 0x03, 0xA0, 0x03, 0x79, 0x3B, 0x79, 0x3B, 0x50, 0x3B, 0x79, 0x3B, 0xA0, 0x3B, 0x79
.org 0x590
I:.DB 0x09, 0x03, 0x9F, 0x1E, 0x9F, 0x3A, 0x9F, 0x1E, 0x9F, 0x1E, 0x50, 0x3B, 0x50, 0x1E, 0x50, 0x03, 0x50, 0x3B, 0x50
.org 0x600
J:.DB 0x06, 0x28, 0xA0, 0x28, 0x50, 0x05, 0x50, 0x05, 0x65, 0x05, 0x50, 0x28, 0x50
.org 0x610
K:.DB 0x08, 0x04, 0xA0, 0x04, 0x78, 0x3A, 0xA0, 0x04, 0x78, 0x3A, 0x50, 0x04, 0x78, 0x04, 0x50, 0x04, 0x78
.org 0x620
L:.DB 0x04, 0x04, 0x9F, 0x04, 0x50, 0x3A, 0x50, 0x04, 0x50
.org 0x630
M:.DB 0x09, 0x04, 0x50, 0x14, 0xA0, 0x1E, 0x78, 0x28, 0xA1, 0x3A, 0x51, 0x28, 0xA1, 0x1E, 0x78, 0x14, 0xA0, 0x04, 0x50
.org 0x640
N:.DB 0x07, 0x04, 0x50, 0x04, 0xA0, 0x3B, 0x50, 0x3B, 0xA1, 0x3B, 0x50, 0x04, 0xA0, 0x04, 0x50
.org 0x650
O:.DB 0x05, 0x04, 0xA0, 0x04, 0x50, 0x3B, 0x50, 0x3B, 0xA0, 0x04, 0xA0


.org 0x00 
	JMP MAIN
.org 0x02
	JMP PRESS

	MAIN:				; Initializes ports, LCD, and flags. Then goes into an infinate loop waiting for an interrupt.
		ldi r21,0x0a	; Preload binary 00001010 into r31z
		ldi r17,0x00
		sts eicra,r21	; Set eicra to 00001010 (both interrupts trigger on active low)
		ldi r21,0x03	; Preload binary 00000011 into r31
		out eimsk,r21	; Set eimsk to 00000011 (enable both interrupts)
		ldi r21,0x00	; Preload binary 00000000 into r31
		out DDRD,r21	; Set ddrd to 00000000 (all pins of portd are input pins, note you only need pins 2 and 3 for the interrupts)
		out DDRC,r21
		ldi r21,0x0c	; Preload binary 00001100 into r31
		out PORTD,r21	; Set portd to 00001100 (portd pins 2 and 3 are internally hooked to pull up resistors)
		sei				; Set enable interrupts

		LDI R21,HIGH(RAMEND)	
		OUT SPH,R21				;set up stack
		LDI R21,LOW(RAMEND)
		OUT SPL,R21

		LDI r21,0xFF;
		OUT LCD_DDR,R21			;LCD data port is output
		OUT LCD_DDR,R21			;LCD command port is output

		LDI R21, 0x00			;load 0's into R21
		OUT DDRC, R21			;output 1's to configure DDRc as "input" port
		OUT PORTC, R21			;output 1's to configure DDRc as "input" port


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
	
		
		LDI R18, 0				;Set Shift Key Flag to 0 (0 -> A-R, 1 -> S-9)
		LDI R21, 0x00
		STS ModeFlag, R21			;Set Mode Key Flag to 0 (0 -> keypad, 1 -> laser)
		LDI R28, ' '			;Initialize Character Buffer Values
		LDI R29, ' '
		LDI R23, ' '
		LDI R24, ' '

	
	HERE:
		RJMP HERE				;Stay HERE in an endless loop

	CMNDWRT:				;Function for sending commands to the display, see Table in LCD Datasheet for possible commands
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


	DATAWRT:				;Function for writing Ascii characters to LCD. Character must be stored in R16
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

	SDELAY:					;Function for short delay
		NOP
		NOP
		RET

	DELAY_100us:			;Function for 100us delay
		PUSH R17
		LDI R17,60
	DR0: CALL SDELAY
		DEC R17
		BRNE DR0
		POP R17
		RET

	DELAY_2ms:				;Function for 2ms delay
		PUSH R17
		LDI R17,20
	LDR0: CALL DELAY_100us
		DEC R17
		BRNE LDR0
		POP R17
		RET


	Press:					;Interrupt rutine. Reads buttons from PortC, Loads it to the Z register, Writes the data to the LCD, Then performs Display Shift Check
		CLI
		CALL LoadPortC
		LDI R21, 0b00010010
		CP R16, R21 ; Compare the value recieved from the keypad with R21 (it should be the value 18) and see if it is the shift key.
		BREQ ShiftKey
		LDI R21, 0b00010011
		CP R16, R21 ; Compare the value recieved from the keypad with R21 (it should be the value 19) and see if it is the mode key.
		BREQ ModeKey
		CALL LoadZRegister
		RJMP WriteBuff
BACK:	CLR R16
		SEI
		RETI

	LoadPortC:				;Function to read button presses. Adding a long delay reduces error.
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
		RET

	ShiftKey:				;Sets Shift Key flag based on what is already set. (0 -> A-R, 1 -> S-9)
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

		
	ModeKey:				;Sets Shift Key flag based on what is already set. (0 -> keypad, 1 -> lasor)
		LDS R21, ModeFlag
		CPI R21, 0x01
		BREQ HIGH2
		LDS R21, ModeFlag
		CPI R21, 0x00
		BREQ LOW2
	HIGH2:
		LDI R21, 0x00
		STS ModeFlag, R21
		JMP BACK
	LOW2:
		LDI R21, 0x01
		STS ModeFlag, R21
		CALL LASWRT				;This will be where code for the laser will start.
		JMP BACK


	LoadZRegister:			;Sets up the Z register to find the proper value from the table
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

	WriteBuff:			;Writes the value in r16 to our buffer
		MOV R21, R28
		CPI R21, ' '
		BREQ BUF1WR
		MOV R21, R29
		CPI R21, ' '
		BREQ BUF2WR
		MOV R21, R23
		CPI R21, ' '
		BREQ BUF3WR
		MOV R21, R24
		CPI R21, ' '
		BREQ BUF4WR
		JMP MOVWR
	WriteBuffHere:
		CALL delay_2ms
		JMP BACK
	BUF1WR:					;Update Buffer 1 with it's first character
		MOV R28, R16
		CALL Datawrt
		RJMP WriteBuffHere
	BUF2WR:					;Update Buffer 2 with it's first character
		MOV R29, R16
		CALL Datawrt
		RJMP WriteBuffHere
	BUF3WR:					;Update Buffer 3 with it's first character
		MOV R23, R16
		CALL Datawrt
		RJMP WriteBuffHere
	BUF4WR:					;Update Buffer 4 with it's first character
		MOV R24, R16
		CALL Datawrt
		RJMP WriteBuffHere
	MOVWR:						;Shift all the buffer values and update the display
		MOV R28, R29
		MOV R29, R23
		MOV R23, R24
		MOV R24, R16
		LDI R16,0X01			;send curser back to the far left
		CALL CMNDWRT			;call command function
		LDI R16, ' '
		CALL DATAWRT
		MOV R16, R28
		CALL DATAWRT
		MOV R16, R29
		CALL DATAWRT
		MOV R16, R23
		CALL DATAWRT
		MOV R16, R24
		CALL DATAWRT
		RJMP WriteBuffHere

	LASWRT:
		LDI R21, 0xFF
		OUT DDRC, R21
		LDI R21, 0x00		;Initialization, Port is set to all 0's
		OUT PortC, R21
		LDI R21, 0xFF		;Set PortD as output
		OUT DDRB, R21
		LDI R21, 0b00000011 ;Set X and Y -Buffer
		OUT PortC, R21
		LDI R21, 0x00		;Clear X and Y -Buffer
		OUT PortB, R21
		LDI R21, 0b00000000	;Finish setting X and Y and turn laser on
		OUT PortC, R21
		LDI R20, 0x03		;Set location counter
		LDI R25, 0x00
	LOOP:
		LDI R19, 0x00		;Initialize the step counter
		LDI R16, 0x00;
		CALL LoadARegister	;Load letter table index value
		MOV R22, R16
	LASHERE:				;Use the lasor
		LDI R21, 0x00
		CP R22, R21			;Compare the index value to 0 and draw if it isn't equal
		BRNE Draw
		LDI R21, 0x40
		ADD R25, R21
		LDI R21, 0x01
		SUB R20, R21
		LDI R21, 0x00
		CP R20, R21
		BREQ ResPos
		RJMP LOOP
	ResPos:
		LDI R20, 0x03
		LDI R25, 0x00
		RJMP LOOP
	DRAW:
		LDI R21, 0x01
		SUB R22, R21		;Decriment the index counter
		ADD R19, R21		;Increase the step counter
		MOV R16, R19		;Move the step counter into R16 to be sent to the table lookup
		CALL LoadARegister
		CALL SetX			;Set the X position
		CALL SetLas
		ADD R19, R21		;Increase the step counter
		MOV R16, R19		;Move the step counter into R16 to be sent to the table lookup
		CALL LoadARegister
		CALL SetY			;Set the Y position
		CALL SetLas
		CALL DELAY_100us
		CALL DELAY_100us
		CALL DELAY_100us
		CALL DELAY_100us
		RJMP LASHERE
		
	SetX:
		LDI R21, 0b00000001
		ADD R21, R25
		OUT PortC, R21
		;CALL DELAY_100us
		RET
	SetY:
		LDI R21, 0b00000010
		OUT PortC, R21
		;CALL DELAY_100us
		RET
	SetLas:					;Sets the position of the one of the buffers
		OUT PortB, R16
		RET

	LoadARegister:			;Sets up the Z register to find the proper value from the table
		ldi ZL, low(2*A)
		ldi ZH, high(2*A)
		add zl,r16 ; add the BCD  value to be converted to low byte of 7SEG CODE TABLE to create an offset numerically equivalent to BCD value 
		lpm r16,z ; load z into r16 from program memory from7SEG CODE TABLE using modified z register as pointer
		RET
