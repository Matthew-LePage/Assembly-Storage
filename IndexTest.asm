TITLE "Index Test"		(IndexTest.asm)
; Matthew LePage
INCLUDE irvine32.inc


;========================================
str_remove PROTO,
		source : BYTE,
		target : BYTE,
	indexFirst : DWORD,
	 indexLast : DWORD
;========================================

.data
	string1 BYTE 101 DUP(0)
	string2 BYTE 100 DUP(0)
	sIndex DWORD ?
	lIndex DWORD ?

	msg1 BYTE "Enter a String: ",0
	msg2 BYTE "Start Index: ",0
	msg3 BYTE "End Index: ",0
	msg4 BYTE "Result: ",0

.code
;========================================
main PROC
;========================================
	mov edx, OFFSET msg1				; Enter String
	Call WriteString
	mov edx, OFFSET string1				; Store user input correctly
	mov ecx, SIZEOF string1
	call ReadString						; EAX knows size of string typed.
	mov ebx, eax						; Store in ebx

	mov edx, OFFSET msg2				; Start Index
	Call WriteString
	Call ReadInt
	mov sIndex, eax

	mov edx, OFFSET msg3				; End Index
	Call WriteString
	Call ReadInt
	mov lIndex, eax

	mov edx, OFFSET msg4				; Result
	Call WriteString

	Invoke str_remove, ADDR string1, ADDR string2, sIndex, lIndex
	

	exit
main ENDP

;========================================
str_remove PROC,
		source : BYTE,
		target : BYTE,
	indexFirst : DWORD,
	 indexLast : DWORD
;
;========================================



	ret
str_remove ENDP
END main