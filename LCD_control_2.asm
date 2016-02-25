;------------------------------------------
;     ==================================
;     ==    UART�BLCD�P4x4��L����    ==
;     ==          2014/12/28          ==
;     ==        Ĭ���� 4A037052       ==
;     ==================================
;------------------------------------------
;���U����� �ӫ���ȷ|�qLCD�Ĥ@�C�̥k��C�C���ʦ̥ܳ��䰱��

;-----------------------------------------------------------------------------
;            PARAMETER DEFINE
;-----------------------------------------------------------------------------
LCD_RS  	EQU P2.1
LCD_ENABLE 	EQU P3.7
LCD_BUS		EQU P0

KEYPORT		EQU P2
KEYFLAG		EQU 20H.2
SCANCODE	EQU 33H
KEYNO		EQU 34H;;????

RXDFLAG		EQU 20H.3
;-----------------------------------------------------------------------------
;            MAIN PROGRAM
;-----------------------------------------------------------------------------
	ORG	00H
	MOV	SP,#5FH
	CALL	INITLCD
	CALL	UARTINIT
;	MOV	R0,#15

AGAIN:  MOV 	R0,#16
	CALL 	KEYIN
	JNB	KEYFLAG,AGAIN
	CALL 	TXD0
RRX:	CALL 	RXD0
	JNB 	RXDFLAG,RRX;;;�o��n��I�sRXD0������A�_�h��AGAIN���ܡA�ΨS�@���������\�A�|�ɭP�h�Ǩ⦸�H�W 8051�i�H�h�����@����ո�ƼȦs �ҥH�|�ǰƱ�����Ȧs�����
	MOV 	R3,A
;--------------------------------------------
;	MOV 	B,R0
;	MOV 	A,#1
;	CALL 	GOXY
;	MOV 	A,R3
;	MOV 	DPTR,#STR;;;;;;
;	MOVC 	A,@A+DPTR
;	CALL 	WRDR
;	MOV 	R7,#??
;	CALL 	DELAY

;	MOV 	B,R0
;	MOV 	A,#1
;	CALL 	GOXY
;	MOV 	A,#' '
;	CALL 	WRDR
;
;	MOV 	B,R0
;	MOV 	A,#1
;	CALL 	GOXY
;	MOV 	A,R3
;	MOV 	DPTR,#STR
;	MOVC 	A,@A+DPTR
;	CALL 	WRDR
;	MOV 	R7,#??
;	CALL 	DELAY

;	MOV 	B,R0
;	MOV 	A,#1
;	CALL 	GOXY
;	MOV 	A,#' '
;	CALL 	WRDR
;--------------------------------------------------
GOPRINT:	MOV 	B,R0
		MOV 	A,#1
		CALL 	GOXY
		MOV 	A,#' '
		CALL 	WRDR

		DEC 	R0

		MOV 	B,R0
		MOV 	A,#1
		CALL 	GOXY
		MOV 	A,R3
		MOV 	DPTR,#STR
		MOVC 	A,@A+DPTR
		CALL 	WRDR
		MOV 	R7,#10
		CALL 	DELAY50ms

		CJNE 	R0,#0,GOPRINT

		JMP 	AGAIN
;-----------STRING TABLE------------------------
STR:  DB 	'0123456789ABCDEF'
;-----------------------------------------------------------------------------
;           SCAN KEYBOARD
;-----------------------------------------------------------------------------
KEYIN:  PUSH 	00
  	PUSH 	01
  	MOV 	R0,#0
  	MOV 	SCANCODE,#11111110B
KEYROW: MOV 	KEYPORT,SCANCODE
  	MOV 	R7,#4
  	CALL 	DELAY
  	MOV 	A,KEYPORT
  	MOV 	R1,#4
  	SWAP 	A
KCOL:  	RRC 	A
  	JNC 	KEYPRESSED
  	INC 	R0
  	DJNZ 	R1,KCOL
  	MOV 	A,SCANCODE
  	RL 	A
  	MOV 	SCANCODE,A
  	JNB 	ACC.4,NOKEY;;;;;;;;;;;;;;;;;;;;
  	JMP 	KEYROW
NOKEY:  CLR 	KEYFLAG
  	JMP 	KEYEND
KEYPRESSED: MOV A,R0
  	SETB 	KEYFLAG
KEYEND: POP 	01
  	POP 	00
  	RET
;-----------------------------------------------------------------------------
;           GO X LINE, Y CHAR
;-----------------------------------------------------------------------------
GOXY:  	ANL     B,#00001111B
  	CJNE    A,#1,CHK1
  	MOV     A,B
  	ADD     A,#10000000B;SETB       A.7     ORL     10000000B
  	CALL    WRIR
  	RET
CHK1:  	MOV     A,B
  	ADD     A,#11000000B
  	CALL    WRIR
  	RET
;-----------------------------------------------------------------------------
;            INITIAL LCD
;-----------------------------------------------------------------------------
INITLCD:        MOV     A,#38H
                CALL    WRIR
                MOV     A,#0DH
                CALL    WRIR
                MOV     A,#06H
                CALL    WRIR
CLRLCD:         MOV     A,#01H
                CALL    WRIR
                MOV     R7,#40;�M���ݩ���2ms
                CALL    DELAY
                RET
;-------------------------------------------------------------------------------
;          DELAY TIME=R7*0.05mS
;-------------------------------------------------------------------------------
DELAY:          MOV     TMOD,#00100001B
DLOOP:          MOV     TH0,#HIGH(65536-50)
                MOV     TL0,#LOW(65536-50)
                SETB    TR0
                JNB     TF0,$
                CLR     TR0
                CLR     TF0
                DJNZ    R7,DLOOP
                RET
;-------------------------------------------------------------------------------
;          DELAY TIME=R7*50mS
;-------------------------------------------------------------------------------
DELAY50ms:
DLOOP1:         MOV     TH0,#HIGH(65536-50000)
                MOV     TL0,#LOW(65536-50000)
                SETB    TR0
                JNB     TF0,$
                CLR     TR0
                CLR     TF0
                DJNZ    R7,DLOOP1
                RET
;-----------------------------------------------------------------------------
;     WRITE CONTROL WORD TO INSTRUCTION REGISTER
;-----------------------------------------------------------------------------
WRIR:           SETB    LCD_ENABLE
                CLR     LCD_RS
                MOV     LCD_BUS,A
                CLR     LCD_ENABLE
                MOV     R7,#1
                CALL    DELAY
                RET
;-----------------------------------------------------------------------------
;           WRITE DATA TO DATA REGISTER
;-----------------------------------------------------------------------------
WRDR:           SETB    LCD_ENABLE
                SETB    LCD_RS
                MOV     LCD_BUS,A
                CLR     LCD_ENABLE
                MOV     R7,#1
                CALL    DELAY
                RET

RXD0:  		JNB 	RI,RXDRET
  		MOV 	A,SBUF
  		CLR 	RI
  		SETB 	RXDFLAG
  		RET
RXDRET:  	CLR 	RXDFLAG
  		RET

TXD0:		CLR 	TI
  		MOV 	SBUF,A
  		JNB 	TI,$
  		CLR 	TI
  		RET
;------------------------------------------------------------------------------
;           INITIAL UART,Timer1,Timer0
;12MHz:   Timer1,TH1
;-----------------------------------------------------------------------------
UARTINIT:       MOV     SCON,#01010000B         ;UART:MODE 1
                MOV     TMOD,#00100001B         ;Timer1:MODE 2, Timer0:MODE 1
  		MOV 	PCON,#10000000B  ;(SMOD=1)
                MOV     TH1,#255                ;Baud Rate=62500 bits/sec
                SETB    TR1                     ;START Timer1
;               CLR     TR0
;               CLR     TF0
                CLR     RI
                CLR     TI
                RET

  		END