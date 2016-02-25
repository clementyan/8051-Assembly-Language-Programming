;------------------------------------------
;     ==================================
;     ==         LCD應用控制         ==
;     ==          2014/12/29          ==
;     ==        蘇偉諺 4A037052       ==
;     ==================================
;------------------------------------------
;於LCD顯示第二列顯示'THIS IS 2ND LINE'並閃爍三次，然後由左而右依序清除



;-----------------------------------------------------------------------------
;            PARAMETER DEFINE
;-----------------------------------------------------------------------------
                LCD_ENABLE      EQU     P3.7
                LCD_RS          EQU     P2.1
                LCD_BUS         EQU     P0
;-----------------------------------------------------------------------------
;            MAIN PROGRAM
;-----------------------------------------------------------------------------
	ORG 00H
	MOV SP,#5FH

	CALL INITLCD

	MOV R5,#3
GLINT:  CALL CLRLCD;;;;;;;
	MOV R7,#20
	CALL DELAY50MS
	MOV A,#1
	MOV B,#0
	CALL GOXY
	MOV DPTR,#STR
	CALL PRTstring
	MOV R7,#20
	CALL DELAY50MS

	DJNZ R5,GLINT

	MOV R4,#16
	MOV B,#15
CLRRR:  MOV A,#1
	CALL GOXY
	MOV A,#20H
	CALL WRDR
	MOV R7,#20
	CALL DELAY50MS
	DEC B
	DJNZ R4,CLRRR

	JMP $

STR:	DB 'THIS IS 2ND LINE','$'
;-----------------------------------------------------------------------------
;           GO X LINE, Y CHAR
;-----------------------------------------------------------------------------
GOXY:	ANL     B,#00001111B
	CJNE    A,#1,CHK1
	MOV     A,B
	ADD     A,#10000000B;SETB       A.7     ORL     10000000B
	CALL    WRIR
	RET
CHK1:	MOV     A,B
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
                MOV     R7,#40;清除需延遲2ms
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
PRTSTring:      PUSH    ACC
PRTLOOP:        CLR     A
                MOVC    A,@A+DPTR
                CJNE    A,#'$',NEXT
                JMP     ENDPRT
NEXT:           CALL    WRDR
                INC     DPTR
                JMP     PRTLOOP
ENDPRT:         POP     ACC
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

END
