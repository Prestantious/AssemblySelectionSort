TITLE Program selectionSort     (selectionSort.asm)

; Author: Dominic Daprano
; Date: February 21, 2019
; Description: This program will take in an input from the user for the amount of random numbers to generate
; then will generate numbers between 100 and 999 and print them to the user, then it will sort them and
; print them again in descending order along with a value for the median. The program will use the
; system stack in order to pass parameters into methods in order to achieve this.

INCLUDE Irvine32.inc

; (insert constant definitions here)

min = 10
max = 200
lo = 100
hi = 999

.data		; (insert variable definitions here)
name1	BYTE	"Sorting Random Integers				Programmed by Dominic Daprano", 0
intro1	BYTE	"This program generates random numbers in the range [100 .. 999],", 0
intro2	BYTE	"displays the original list, sorts the list, and calculates the", 0
intro3	BYTE	"median value. Finally, it displays the list sorted in descending order.", 0

prompt1	BYTE	"Enter a number between [10, 200] for the number of random numbers you want to sort", 0
invalid	BYTE	"Invalid input", 0

median1	BYTE	"The median value is: ", 0
sorted	BYTE	"Sorted Array: ", 0
nSorted BYTE	"Unsorted Array: ", 0

list	DWORD	max		DUP(?)
total	DWORD	0
times	DWORD	0

numRand	DWORD	?

.code
main PROC	; (insert executable instructions here)
	call	Randomize			; so that random numbers are different between runs of the program

	call	intro				; prints out inroductary message

	push	OFFSET numRand			; pushes the variable that we want getData to read user input to
	call	getData				; gets the user input for the ammount of numbers that they would like to output


	push	OFFSET list
	push	numRand				; this may need to be offset to get the memory address
	call	fillArray

	push	OFFSET nsorted
	push	OFFSET list
	push	numRand
	call	displayArray			; prints out array after filling it

	push	OFFSET list
	push	numRand
	call	median				; prints out the median

	push	OFFSET list
	push	numRand
	call	sortArray

	push	OFFSET sorted
	push	OFFSET list
	push	numRand
	call	displayArray			; prints out array after sorting it

	exit					; exit to operating system
main ENDP

;
; Prints the welcome message to the user
; no pre conditions for the function call
; changes the edx register
; Post -> the welcome message is printed to the user
;
intro PROC
	mov	edx, OFFSET name1
	call	Writestring
	call	crlf
	call	crlf
	mov	edx, OFFSET intro1
	call	Writestring
	call	crlf
	mov	edx, OFFSET intro2
	call	Writestring
	call	crlf
	mov	edx, OFFSET intro3
	call	Writestring
	call	crlf

	ret
intro ENDP

;
; Gets user input for number of elements for array by using 1 parameter
; push parameter -> varible you want to put array length in (DWORD)
; changes the ebx, edx, and eax registers
; Post -> the array length is now stores in passed parameter
;
getData	PROC
	push	ebp				; save the value of ebp
	mov	ebp, esp			; ebp is now pointing at the top of the stack
	mov	ebx, [ebp + 8]			; ebp + 8 adress is moved into ebx

range:
	mov		edx, OFFSET prompt1
	call	Writestring
	call	crlf
	call	Readint				; readint stores the user input in eax
	mov	[ebx], eax			; mov eax into the ebx
	cmp	eax, min			; checks lower limit for validity of user input
	jl	message
	cmp	eax, max			; checks upper limit for validity of user input
	jg	message

	pop	ebp				; returns the correct value to ebp
	ret	4				; 4 will remove the top 4 bytes from the stack so that the pushed parameter is no longer there

message:					; mesaage will be jumped to if the input is invalid
	mov	edx, OFFSET invalid
	call	Writestring
	call	crlf
	jmp	range
getData ENDP


;
; Fills an array by using 2 parameters and the RandomRange function
; push parameter order -> OFFSET array (DWORD), array length DWORD
; changes the ecx, esi, edx, and eax registers
; Post -> the array  passed in by the stack is filled with random values
; from 100 to 999 as the bounds
;
fillArray	PROC
	push	ebp
	mov	ebp, esp
	mov	esi, [ebp + 12]
	mov	ecx, [ebp + 8]
again:
	mov	eax, hi
	sub	eax, lo
	inc	eax				; gets the correct value for the bounds of eax
	call	RandomRange			; gets a random number bound by eax
	add	eax, lo
	mov	[esi], eax			; esi accesses the element in the array
	add	esi, 4

	loop	again

	pop	ebp				; restore the ebp register
	ret	8				; removes the values that were put on the top of the stack
fillArray	ENDP


;
; Finds the median value of an array by using 2 parameters
; push parameter order -> OFFSET array (DWORD), array length DWORD
; changes the ecx, esi, ebx, edx, and eax registers
; Post -> the median of the array is printed out
;
median	PROC					; random values need to change each time
	push	ebp
	mov	ebp, esp
	mov	esi, [ebp + 12]
	mov	ecx, [ebp + 8]
doIt:
	mov	eax, [esi]
	add	eax, total			; adds the value in eax to total
	mov	total, eax			; stores the new total in total
	add	esi, 4
	loop	doIt

	call	crlf
	call	crlf
	mov	edx, OFFSET median1		; prints out median message
	call	Writestring
	mov	edx, 0
	mov	eax, total
	mov	ecx, [ebp + 8]			; moves divisor to ecx
	DIV	ecx				; stores quotient in eax
	call	WriteDec			; displays quotient
	call	crlf
	call	crlf

	pop	ebp
	ret	8

median	ENDP

;
; Selection sorts an array using 2 parameters
; push parameter order -> OFFSET array (DWORD), array length DWORD
; changes the ecx, esi, ebx, edx, and eax registers
; Post -> array is sorted from greatest to least
;
sortArray PROC
	push	ebp
	mov	ebp, esp
	mov	esi, [ebp + 12]
	mov	ecx, [ebp + 8]
	XOR	edx, edx			; since theedx register may hav been used for Writestring before

outer:						; go through the array
	push	ecx
	mov	eax, [esi]			; eax stores the element in the array that you are trying to sort
	mov	ebx, [esi]
	push	esi				; puts esi on the stack so the location for the outer loop can be saved also
	dec	ecx
	ADD	esi, 4				; gets the next element in the array
inner:
	cmp	[esi], eax
	jg	setter				; if the number is greater set the new eax as the biggest value
back:
	ADD	esi, 4
	loop	inner				; increments inner loop ecx

; exchange the parts of the loop

	mov	[edx], ebx			; swap performed
	pop	esi				; restore esi
	mov	ebx, esi			; esi saved to temp value so that it isnt change for the loop
	mov	[ebx], eax			; other swap performed

	ADD	esi, 4				; add 4 tto get next element for outer loop
	pop	ecx				; restore ecx for outer loop
	cmp	ecx, 2
	JE	done
	loop	outer

done:
	pop	ebp				; restore the ebp register
	ret	8
setter:						; i = j
	mov	edx, esi
	mov	eax, [esi]			; stores the location in eax (i)

	jmp	back
sortArray ENDP

;
; Prints out an array using 3 parameters
; push parameter order -> OFFSET message string (DWORD), OFFSET array, array length DWORD
; changes the ecx, esi, edx, and eax registers
; Post -> array is displayed in lines of 10 and esp is pointing to the same value as before the function call
;
displayArray	PROC
	push	ebp
	mov	ebp, esp
	mov	edx, [ebp + 16]			; message now in edx
	mov	esi, [ebp + 12]			; array pointer
	mov	ecx, [ebp + 8]			; array length
	call	Writestring			; prints out meessage from edx
	call	crlf
more:
	inc	times				; times stores how many were printed on a line
	mov	eax, [esi]			; moves value at esi array location to ax
	call	Writedec
	mov	al, tab
	call	Writechar
	add	esi, 4				; adds 4 to esi to access the next element in the Dword array

	XOR	edx, edx
	mov	eax, times
	mov	ebx, 10				; puts 10 in to be divisor
	DIV	ebx				; divides, times prime by 10
	cmp	edx, 0				; if remainder is 0, 10 have been printed so there needs to be a new line
	JE	newline
back:
	loop	more

	mov	times, 0
	pop	ebp				; restore the ebp register
	ret	8

newLine:
	call	crlf
	JMP	back
displayArray	ENDP

END main
