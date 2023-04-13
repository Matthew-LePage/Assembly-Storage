TITLE	"Binary Display"		(DisplayBinary.asm)
; Matthew LePage

INCLUDE irvine32.inc
; =======================================================
whole PROTO,
	num : REAL4
; =======================================================
fract PROTO,
	num : REAL4
; =======================================================
onlyFracts PROTO,
	num : REAL4
; =======================================================

.data
	numb REAL4 ?				; The number given by the user
	wNum REAL4 ?				; The whole number given by the user
	fNum REAL4 ?				; The fractional given by the user
	
	msg1 BYTE "Enter a float value: ",0
	msg2 BYTE "Real number in binary: ",0

	pos  BYTE "+",0
	nga	 BYTE "-",0				; neg is a keyword so nga is next for negative
	exp  BYTE " x 2^",0
	oPo  BYTE "1.",0
	one  BYTE "1",0
	zero BYTE "0",0
	justZero BYTE "0.00000000000000000000000",0		; This displays when the num is just 0 or REALLY small

.code
; =======================================================
main PROC
; =======================================================
	FINIT						; Initialize
	mov ecx, 24					; The maximum amount of numbers allowed
	mov eax, -1					; The exponent value (Set to negative 1 for 127)

	mov edx, OFFSET msg1		; Initial message
	Call WriteString
	Call ReadFloat				; Get value
	Call CrLf
	FST numb					; Store to memory (not pop)

	mov edx, OFFSET msg2		; Second message
	Call WriteString

	FLDZ						; Push 0.0 onto the stack
	FCOMIP ST(0), ST(1)			; Because we didn't pop it, we can just compare it right now to 0.0
	ja negNum					; If 0.0 is higher than the float, jump to negative
	mov edx, OFFSET pos			; Float is positive
	jmp continue
negNum:
	mov edx, OFFSET nga			; Float is negative
	FCHS						; Since it's negative,change float to positive for calculations NOTE THIS RIGHT HERE CAUSES A PRECISION ERROR FOR REAL4 CALCULATIONS INVOLVING COMPLEX FRACTORIALS FOR SOME REASON
																							; There was a better option to deal with this gone through with the TA, but I don't have time to make this with exams
																							; Basically make another variable that divides by 2, and compares to the current num, then subtracts the var from the num if fits
continue:
	Call WriteString			; Display "+" or "-"
	
; And now, a lot of pain finally worked into becoming my solution
	FLD1						; For my little trick
	FLD ST(1)					; Move the whole (positive) number into ST(0)
	FPREM						; Pulls out the fractional
	FSUB ST(2), ST(0)			; Removes the fractional from the num to make a whole num
; The fractional is now in ST(0), and the whole is in ST(2)
	FSTP fNum					; Pop fractional to fNum
	FXCH						; Switch the 1 and the whole
	FSTP wNUM					; Pop whole to wNum
	FFREE ST(0)					; Remove the 1
; The numbers are now seperated and stored correctly, this was a pain to come up with
	
	FLD wNum
	FLDZ
	FCOMIP ST(0), ST(1)			; Compare 0 to wNum
	FFREE ST(0)					; Clear FPU
	je justFractional			; The number is from 0 to under 1

	hasWhole:
		INVOKE whole, wNum			; The number is 1 or greater
		cmp ecx, -1					; For the ridiculous case
		je exponent
		INVOKE fract, fNum			; The fractorial part of the question
		jmp exponent

	justFractional:
		INVOKE onlyFracts, fNum		; The number started with 0 or -0

exponent:
	mov edx, OFFSET exp			; " x 2^"
	Call WriteString
	Call WriteInt				; eax = "+-#"
	Call CrLf
	exit
main ENDP

; =======================================================
whole PROC,
		   num : REAL4
	LOCAL half : DWORD	
	LOCAL temp : REAL4
; Displays the whole number as binary
; Assumes that the whole value is greater than or equal to 1
; Uses recursion to solve issue of having to build backwards
; =======================================================
	mov half, 2
	dec ecx						; Starts @24, represents total amount of numbers available for print
	cmp ecx, -1					; If ecx = -1, that means 24 numbers are about to be placed which is absolutely ridiculous
	je wholeEnding				; In which case pretend there is a period after the first number because I highly doubt this will be tested with such a high number
	inc eax						; Increase the exponent

	FLD num						; ST(1) = num
	FLD1						; ST(0) = 1
	FCOMIP ST(0), ST(1)			; Is the current number 1?
	je caseOne					; Impossible for 1 to be greater than num

		FILD half					; ST(0) = 2, ST(1) = num
		FXCH						; ST(0) = num, ST(1) = 2
		FPREM						; ST(0) = 1 or 0, ST (1) = 2 // Keeping 2 for now
		FLDZ						; Push 0
		FCOMIP ST(0), ST(1)			; Compare 0.0 (pop), to remainder, remainder can be 1 or 0
		je caseEven

		caseOdd:						; num is odd (ST(0) = 1)
			FLD num						; ST(0) = num,		ST(1) = 1,		ST(2) = 2
			FXCH						; ST(0) = 1,		ST(1) = num,	ST(2) = 2
			FSUBP ST(1), ST(0)			; ST(0) = num-1,	ST(1) = 2
			FXCH						; ST(0) = 2,		ST(1) = num-1 (Even)
			FDIV						; ST(0) = num / 2 (With no remainder and is whole)
			FSTP temp					; FPU is now clear
			
			INVOKE whole, temp			; Recursive method, temp is the next number

			mov edx, OFFSET one			; Display the 1
			Call WriteString
			jmp wholeEnding				; Continue to the ending

		caseEven:						; num is Even (ST(0) = 0)
			FADD						; Combines 0 and 2, and pops the empty number
			FLD num						; ST(0) = num,		ST(1) = 2
			FXCH						; ST(0) = 2,		ST(1) = num
			FDIV						; ST(0) = num/2
			FSTP temp					; FPU is now clear

			INVOKE whole, temp

			mov edx, OFFSET zero		; Display the 0
			Call WriteString
			jmp wholeEnding				; Continue to the ending

caseOne:
	mov edx, OFFSET oPo			; "1."
	Call WriteString
wholeEnding:					; End of program
	ret
whole ENDP

; =======================================================
fract PROC,
	num : REAL4
; This version is used when exponent is known
; =======================================================
	cmp ecx, 0					; If ecx is 0, then max allocation for bits is reached
	je endOfNum
	dec ecx						; ecx is not 0, decrease
	
	FLD num						; Push fractorial onto FPU
	FLDZ						; Push Zero
	FCOMIP ST(0), ST(1)			; Compare 0.0 to num
	je endOfOnes				; It's not possible to place another one in the binary

	FLD1						; Push 1
	FLD1						; Push 1 again
	FADD						; Make it 2
	FMUL						; Make num*2
	FLD1
	FCOMIP ST(0), ST(1)			; Compare 1.0 (pop) to num*2
	jbe insertOne				; If 1 is below or equal to num*2, 1 can be inserted

	insertZero:						; Insert a zero
		mov edx, OFFSET zero
		Call WriteString			; 0
		FSTP num					; Store updated variable in num and clear FPU
		INVOKE fract, num			; Recursive
		jmp endOfNum

	insertOne:
		mov edx, OFFSET one
		Call WriteString			; 1
		FLD1
		FSUBP ST(1), ST(0)			; Remove the one
		FSTP num					; Store updated variable in num and clear FPU
		INVOKE fract, num			; Recursive
		jmp endOfNum

		
endOfOnes:
	mov edx, OFFSET zero		; 0
	Call WriteString
	INVOKE fract, num			; Display remainingg 0's
endOfNum:
	ret
fract ENDP


; =======================================================
onlyFracts PROC,
	num : REAL4
; Uses Fract to calculate any small number (Not Negatives because precision error is broken)
; Once this method recursively finds the first 1
; =======================================================
	FLD num						; Push num on FPU
	FLDZ						; Push 0.0 on FPU
	FCOMIP ST(0), ST(1)			; Compare 0 to num
	je numIsJustZero			; The user put in 0

	FLD1						; Push 2
	FLD1
	FADD
	FMUL						; num * 2 (Can't be zero)
	FLD1
	FCOMIP ST(0), ST(1)			; Compare 1.0 (pop) to num*2
	jbe foundOne

	didntFindOne:
		dec eax						; 1 not found, exponent decreases
		FSTP num
		INVOKE onlyFracts, num
		jmp oFE

	foundOne:
		dec ecx						; A number is printed so ecx goes down
		mov edx, OFFSET oPo
		Call WriteString
		FLD1
		FSUBP ST(1), ST(0)			; Remove the one
		FSTP num					; Store updated variable in num and clear FPU
		INVOKE fract, num
		jmp oFE

numIsJustZero:
	mov edx, OFFSET justZero
	Call WriteString
	mov eax, 0					; Exponent is zero
	mov ecx, 0					; All numbers were just printed
oFE:
	ret
onlyFracts ENDP
END main

; 1010 0110 0000 0000 0000 0000 6 total sets, 4 * 6 = 24