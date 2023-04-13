TITLE	"Dodecahedron Maker"		(dodecahedron.asm)
; Matthew LePage

INCLUDE irvine32.inc

; =======================================================
areaCalc PROTO,
	eg : REAL4
; =======================================================
volCalc PROTO,
	eg : REAL4
; =======================================================
midRCalc PROTO,
	eg : REAL4
; =======================================================

.data
	edge REAL4 ?				; A side of the dodecahedron

	iMsg	BYTE "Please input an edge of the Dodecahedron: ",0
	msgErr	BYTE "The value given is an invalid negative, please try again.",0
	msgAr	BYTE "The area of the Dodecahedron is: ",0
	msgVo	BYTE "The volume of the Dodecahedron is: ",0
	msgMR	BYTE "The midsphere radius of the Dodecahedron is: ",0

.code
; =======================================================
main PROC
; =======================================================
	FINIT						; Initialize

startProg:						; Start of the program
	mov edx, OFFSET iMsg
	Call WriteString
	Call ReadFloat				; Edge Length Value gained from user
	
	FLDZ						; Push 0.0 on the stack
	FCOMIP ST(0), ST(1)			; Compare 0.0 to user input
	je endProg					; If 0.0 was inputted, time to end the program
	jb notNeg					; If 0.0 is below user input, user may continue
	
	mov edx, OFFSET msgErr		; User put in negative
	Call WriteString
	Call CrLf					; Formatting
	Call CrLf
	ffree ST(0)					; Free the stack of the bad number
	jmp startProg				; Return to start of program

notNeg:							; Sign was positive, so continue
	FSTP edge					; Pop out the edge length to memory, and clear the stack

	INVOKE areaCalc, edge		; Calculate Area and store in ST(0)
	mov edx, OFFSET msgAr		; Print the result
	Call WriteString
	Call WriteFloat
	Call CrLf
	ffree ST(0)					; Free the stack

	INVOKE volCalc, edge		; Calculate Volume and store in ST(0)
	mov edx, OFFSET msgVo		; Print the result
	Call  WriteString
	Call WriteFloat
	Call CrLf
	ffree ST(0)					; Free the stack

	INVOKE midRCalc, edge		; Calculate Mid
	mov edx, OFFSET msgMR
	Call WriteString
	Call WriteFloat
	Call CrLf
	ffree ST(0)					; Free the stack

	Call CrLf					; Formatting
	jmp startProg				; Program only allowed to end if user enters 0.0
	
endProg:						; End of the program, 
	ffree ST(0)
	Call ShowFPUStack
	exit
main ENDP


; =======================================================
areaCalc PROC,
	         eg : REAL4
	LOCAL three : DWORD
	LOCAL  five : DWORD
	LOCAL   two : DWORD
	LOCAL   six : DWORD
; Calculates the area of a dodecahedron
; (sqrt(3) + 6 * sqrt(5 + 2 * sqrt(5))) * 5 * eg^2
; This one moves Integers into stack and only operates on the stack
; =======================================================
	mov three, 3
	mov five, 5
	mov two, 2
	mov six, 6

	FLD eg						; edge
	FMUL eg						; edge * edge = edg^2
	FIMUL five					; 5 * eg^2	= A

	FILD three					; 3 = ST(0), A = ST(1)
	FSQRT						; sqrt 3 = B

	FILD five					; 5 = ST(0), ST(1) = B, ST(2) = A
	FSQRT						; sqrt5
	FILD two					; 2 = ST(0), sqrt5 = ST(1)
	FMUL						; 2 * sqrt(5)
	FILD five					; 5 = ST(0), 2 * sqrt5 = ST(1)
	FADD						; 5 + 2 * sqrt5
	FSQRT						; sqrt(5 + 2 * sqrt(5)) = ST(0), sqrt3 = ST(1), 5 * eg^2 = ST(2)
	FILD six					; 6
	FMUL						; 6 * sqrt(5 + 2 * sqrt(5)) = ST(0), B = ST(1), A = ST(2)
	FADD						; sqrt(3) + 6 * sqrt(5 + 2 * sqrt(5)) = ST(0), 5 * eg^2 = ST(1)

	FMUL						; (sqrt(3) + 6 * sqrt(5 + 2 * sqrt(5))) * 5 * eg^2 = ST(0)

	ret
areaCalc ENDP

; =======================================================
volCalc PROC,
				 eg : REAL4
	LOCAL fourseven : DWORD
	LOCAL  ninenine : DWORD
	LOCAL    twelve : DWORD
	LOCAL	   five : DWORD
; Calculates the volume of a dodecahedron
; (5/12) * (99 + 47 * sqrt(5)) * eg^3
; This one incorperates references to intergers
; =======================================================
	mov fourseven, 47
	mov ninenine, 99
	mov twelve, 12
	mov five, 5

	FLD eg						; eg^3
	FMUL eg
	FMUL eg

	FILD five					; 5/12
	FIDIV twelve

	FILD five					; sqrt(5)
	FSQRT
	FIMUL fourseven				; 47 * sqrt(5)
	FIADD ninenine				; 99 + 47 * sqrt(5)

	FMUL						; (5/12) * (99 + 47 * sqrt(5))

	FMUL						; (5/12) * (99 + 47 * sqrt(5)) * eg^3

	ret
volCalc ENDP

; =======================================================
midRCalc PROC,
			 eg : REAL4
	LOCAL three : DWORD
	LOCAL  four : DWORD
	LOCAL  five : DWORD
; Calculates the Midsphere Radius of a dodecahedron
; (5 + 3 * sqrt(5)) / 4 * eg
; This one is short as I can make it
; =======================================================
	mov three, 3
	mov four, 4
	mov five, 5

	FILD five					; 5 + 3 * sqrt(5)
	FSQRT
	FIMUL three
	FIADD five

	FIDIV four					; (5 + 3 * sqrt(5)) / 4

	FMUL eg						; (5 + 3 * sqrt(5)) / 4 * eg

	ret	
midRCalc ENDP

END main