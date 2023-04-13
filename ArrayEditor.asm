TITLE "Array Editor"			(ArrayEditor.asm)
; Matthew LePage
; Gives the user 5 Options, each does the following:
; 1 - Populate the Array with random numbers
; 2 - Shift the array value bits a specified number of positions
; 3 - Multiply the array with a user provided multiplier (Not Implemented)
; 4 - Print the Array
; 0 - Exit

INCLUDE Irvine32.inc

; --------------------------------------------------
printArray PROTO,
	tempArray : SDWORD,
	aLength   : DWORD
; --------------------------------------------------

.data
	errorString BYTE	"Invalid number, please try again.",0
	twoMessage  BYTE	"What would you like to shift the array by? ",0
	array		SDWORD	10 DUP(-100)
	arrayLength DWORD	?
	testing		BYTE	"Got to this point",0
	
.code
main PROC
	Call Randomize					; For any randomized parts of the code
	mov arrayLength, LENGTHOF array	; Array's length
Top:
	call options
	call ReadInt
	call CrLf
	
; --------------------------------------------------
	cmp eax, 1						; Option 1
	je OOne
	cmp eax, 2						; Option 2
	je OTwo
	cmp eax, 3						; Option 3
	je OThree
	cmp eax, 4						; Option 4
	je OFour
	cmp eax, 0						; Option 0
	je OZero
	
; --------------------------------------------------
	mov edx, OFFSET errorString		; Invalid Option
	call WriteString				; Display Error Message
	call CrLf
	call CrLf
	jmp Top							; Jump back to top
; --------------------------------------------------
OOne:
	push OFFSET array				; Pass Offset of array as a parameter
	push arrayLength				; Pass the length of array as a parameter
	call populateRandomNum			; Populates the array with random numbers
	jmp Top							; Repeat
; --------------------------------------------------
OTwo:
	call CrLf
	mov edx, OFFSET twoMessage		; "What is yo shift"
	call WriteString
	call ReadInt
	mov edx, OFFSET testing

	push OFFSET array				; First parameter (Array Offset)
	push arrayLength				; Second parameter (Array Length)
	push eax						; Third parameter (Shift amount)
	call ShiftArray
	jmp Top							; Repeat
; --------------------------------------------------
OThree:
	
	jmp Top							; Repeat
; --------------------------------------------------
OFour:
	INVOKE printArray, OFFSET array, arrayLength		; Prints the array
	jmp Top							; Repeat
; --------------------------------------------------
OZero:								; Program End

exit
main ENDP
; --------------------------------------------------

;====================================================
options PROC uses edx
;  Prints the text required before the
;  user makes a choice
;====================================================
.data
	lineOne   BYTE	"1 - Populate the Array with random numbers",0
	lineTwo   BYTE	"2 - Shift the array value bits a specified number of positions",0
	lineThree BYTE	"3 - Multiply the array with a user provided multiplier",0
	lineFour  BYTE	"4 - Print the Array",0
	lineZero  BYTE	"0 - Exit",0
	enterNum  BYTE	" = ",0

.code
	mov edx, OFFSET lineOne
	call WriteString
	call CrLf

	mov edx, OFFSET lineTwo
	call WriteString
	call CrLf

	mov edx, OFFSET lineThree
	call WriteString
	call CrLf
	
	mov edx, OFFSET lineFour
	call WriteString
	call CrLf

	mov edx, OFFSET lineZero
	call WriteString
	call CrLf
	call CrLf

	mov edx, OFFSET enterNum
	call WriteString

ret
options ENDP

;====================================================
populateRandomNum PROC
;  Option 1 of the program, randomizes numbers from -100000 to +300000
;====================================================
	push ebp						; Save ebp
	mov ebp, esp					; Save esi in ebp
	mov esi, [ebp + 12]				; Points to the OFFSET of the array
	mov ecx, [ebp + 8]				; Points to the array length

l:
	mov eax, 400001					; Randomize a number between -100k and +300k
	call RandomRange
	sub eax, 100000

	mov [esi], eax					; Store the value into the array
	add esi, TYPE DWORD				; Move to next element in array

	LOOP l

	mov esp, ebp					; Remove local variable by returning esp through ebp
	pop ebp							; Restore ebp
	ret 8
populateRandomNum ENDP

;====================================================
shiftArray PROC,
	arrayPoint : SDWORD,
	   aLength : DWORD,
		 shift : DWORD
;  Option 2 of the program, shifts numbers in array according to the user.
;====================================================
	mov ecx, aLength
	mov esi, arrayPoint
	mov ebx, shift
	cmp ebx, 0
	je ending						; Impossible to shift
	call WriteString
	jb shiL							; Shift Left
	call WriteString
	ja shiR							; Shift Right

shiL:
	lL:
		push ecx
		mov eax, [esi + TYPE DWORD]
		mov cl, BYTE PTR shift
		shld [esi], eax, cl

		add esi, TYPE DWORD

		pop ecx
		LOOP lL
	jmp ending
shiR:
	lR:
		push ecx
		mov eax, [esi + TYPE DWORD]
		mov cl, BYTE PTR shift
		shrd [esi], eax, cl

		add esi, TYPE DWORD

		pop ecx
		LOOP lR
ending:
	ret
shiftArray ENDP

;====================================================
printArray PROC uses eax ebx esi ecx edx,
	tempArray : SDWORD,
	aLength   : DWORD
;  Option 4 of the program, prints the Array
;====================================================
.data
	sqL BYTE "[" ,0
	sqR BYTE "]" ,0
	com BYTE ", ",0

.code
	mov ebx, 0
	mov ecx, aLength
	mov edx, OFFSET sqL				; The left square bracket
	call WriteString
	mov edx, OFFSET com				; Commas in the displayed array

	mov esi, tempArray

	mov eax, [esi + ebx]			; The first number
	call WriteInt					; Write the first number
	dec ecx

l:
	call WriteString
	add ebx, 4
	mov eax, [esi + ebx]
	call WriteInt

	LOOP l

	mov edx, OFFSET sqR				; The right square bracket
	call WriteString
	call CrLf						; Formatting
	call CrLf

	ret
printArray ENDP

END main