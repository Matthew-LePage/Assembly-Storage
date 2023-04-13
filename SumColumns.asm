TITLE "Sum of Columns"		(SumColumns.asm)
; Matthew LePage
INCLUDE irvine32.inc

;=======================================
SumOfColumnsArray PROTO,
	 arr : DWORD,
	rows : DWORD,
	cols : DWORD,
 colWork : DWORD
;=======================================

.data

NUM_ROWS = 7
NUM_COLS = 5
Array SWORD NUM_ROWS*NUM_COLS DUP (?)

pipe BYTE "|",0
comma BYTE ", ",0
inpu DWORD ?
msg1 BYTE "Please select the column to add: "

.code
;========================================
main PROC
;========================================
	Call Randomize
	
	Push NUM_ROWS				; Size 4
	Push NUM_COLS				; Size 4
	Call PopulateArray
	
	Push NUM_ROWS
	Push NUM_COLS
	Push OFFSET Array
	Call PrintArray
	
	mov edx, OFFSET msg1
	Call WriteString
	Call ReadInt
	mov inpu, eax
	INVOKE SumOfColumnsArray, ADDR Array, DWORD PTR NUM_ROWS, DWORD PTR NUM_COLS, inpu
	Call WriteInt

main ENDP
;=======================================
PopulateArray PROC
; Adds values from -125 to +125
;=======================================
	push ebp
	mov ebp, esp

	mov esi, 0								; OFFSET ROW
	mov ecx, DWORD PTR [ebp + 12]			; Number of Rows loop count

loop1:										; LOOP 1
	push ecx
	mov ecx, DWORD PTR [ebp + 8]			; Number of Columns loop
	mov edi, 0								; OFFSET COL
	
	loop2:									; LOOP 2
		mov eax, 251						; Randomizes number from -50 to +100
		Call RandomRange
		sub eax, 125
		mov Array[esi + edi], ax			; Store the value
		
		add edi, TYPE Array					; Increase edi
		loop loop2							; LOOP 2 END

	add esi, edi							; Increase esi
	pop ecx
	loop loop1								; LOOP 1 END
	
	mov esp, ebp
	pop ebp
	ret 8
PopulateArray ENDP

;=======================================
PrintArray PROC
; Displays all values
;=======================================
	push ebp
	mov ebp, esp

	mov esi, [ebp + 8]
	mov ecx, DWORD PTR [ebp + 16]

D1: ; <-------------------------------
	push ecx
	mov ecx, DWORD PTR [ebp + 12]
	mov edi, 0
	mov ebx, 0
	mov edx, OFFSET pipe						; "|"
	Call WriteString

	mov edx, OFFSET comma						; ", "
	movsx eax, SWORD PTR [esi+edi]				; Base + Index
	Call WriteInt
	add edi, TYPE SWORD
	dec ecx

	D2: ; <-------------------------------
		Call WriteString							; ", "
		movsx eax, SWORD PTR [esi + edi]			; Base + Index
		Call WriteInt

		add edi, TYPE SWORD							; Increment edi
		loop D2 ; <-------------------------------
	mov edx, OFFSET pipe							; "|"
	Call WriteString
	Call CrLf

	add esi, edi									; Increment esi
	pop ecx
	loop D1 ; <-------------------------------
	
	mov esp, ebp
	pop ebp
	ret 12
PrintArray ENDP


;=======================================
SumOfColumnsArray PROC,
		  arr : DWORD,						; OFFSET
		 rows : DWORD,
		 cols : DWORD,
	  colWork : DWORD
  LOCAL multi : DWORD
;=======================================
	mov ecx, cols							; Cols to calculate
	mov multi, 0
	mov esi, colWork

S1:
	mov edi, multi
	;add ax, arr[esi + edi * TYPE arr]
	;add multi, rows

loop S1


	ret
SumOfColumnsArray ENDP

END main