@-----------------------------------------------------------------------	
/* -- Subroutines String1 -- */
@ Purpose:  This set of functions will perform various tasks as listed 
@ below in the .text section.  They will modify or check strings passed
@ in from registers, and return their answers in r0 and/or r1.  
@-----------------------------------------------------------------------	

.data
	szBuff:		.skip	512		@ String buffer
	szBuffer:	.skip	512		@ Holds string data
	sPtr:		.word	0		@ String pointer
	szReturn:	.asciz	"\n"	@ Add \n to end of String_copy_2

@-----------------------------------------------------------------------	

.text						@ Subroutine entry point
	.global String_Length
	.global String_equals	
	.global String_equalsIgnoreCase
	.extern malloc
	.extern free
	.global String_copy
	.global String_copy_2
	.global String_substring_1
	.global String_substring_2
	.global String_charAt
	.global String_startsWith_1
	.global String_startsWith_2
	.global String_endsWith
	.global String_indexOf_1	@ provide program starting address to Linker
	.global String_indexOf_2	@ provide program starting address to Linker
	.global String_indexOf_3	@ provide program starting address to Linker
	.global String_lastIndexOf_1	@ provide program starting address to Linker
	.global String_lastIndexOf_2	@ provide program starting address to Linker
	.global String_lastIndexOf_3 	@ provide program starting address to Linker
	.global String_concat	  	@ provide program starting address to Linker
	.global String_replace		@ provide program starting address to Linker
	.global	String_toLowerCase	@ provide program starting address to Linker
	.global	String_toUpperCase	@ provide program starting address to Linker

@-----------------------------------------------------------------------	
/* -- Subroutine String_Length -- */
@ Purpose:  This subroutine will accept the address of a string and 
@ count the characters in the string, excluding the NULL character and 
@ returning that value as an int (word) in the r0 register.

@ 	R0: Points to first byte of string to count
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Number of characters in the string (doesn't include NULL).
@ All registers are preserved as per AAPCS.

	.global String_Length	@ Subroutine entry point
	 
String_Length:
	push 	{r4-r11, LR} 	@ Preserve working register contents

	@ INITIALIZE COUNTER TO 0
	mov		r2, #0		 	@ Initialize counter to 0

loopStrLen:
	@ CHECK: IF STRING IS ZERO, END IF 0
	ldrb	r1, [r0, r2]	@ Load specified byte (from counter) of string
	cmp		r1, #0			@ Compare to 0, end if it's zero
	beq		endSub			@ Branch to end of program if 0
	
	@ ELSE - INCREMENT COUNTER & LOOP
	add		r2, #1			@ Increment counter by one
	b		loopStrLen		@ Continue looping

endSub:
	mov		r0, r2			@ Load value in r2 into r0
	pop		{r4-r11, LR}	@ Restore working register contents
	bx		LR				@ Return from subroutine

@-----------------------------------------------------------------------	
/* -- Subroutine: String_equals -- */
@ Purpose:  This subroutine will compare two string lengths, and if the 
@ string lengths aren't equal, it will return 0. If they match, it will 
@ then increment through each character in the same locations and 
@ return 0 if they aren't equal. If it gets to the end of both strings 
@ and all are equal, it returns 1.

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string
@	R1: Points to first byte of second string 
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns 0 for false, 1 for true.
@ All registers are preserved as per AAPCS.

String_equals:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS

	@ CALL STRING_LENGTH & SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	bl		String_Length	@ B&L: to String_Length subroutine
	mov		r4, r0			@ Move answer to r4
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses
	
	@ CALL STRING_LENGTH & SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	mov		r0, r1			@ Move address of second string to r0
	bl		String_Length	@ B&L: to String_Length subroutine
	mov		r5, r0			@ Move answer to r5
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses
	
	@ COMPARE STRING LENGTHS, END IF NOT EQUAL
	cmp		r4, r5			@ Compare string lengths
	movne	r6, #0			@ If not equal, load 0 value
	bne		endEqual		@ If not equal, branch to end
	
	@ INITIALIZE COUNTER TO 0
	mov		r2, #0	    	@ Initialize counter to 0

loopStrEq:

	@ CHECK: IF FIRST STRING IS DONE, END
	ldrb	r4, [r0, r2]	@ Load specified byte (from counter) of string
	cmp		r4, #0			@ Compare to 0, end if it's zero
	moveq	r6, #1			@ If reaching end of string, load 1 and end
	beq		endEqual		@ Branch to end of program if 0
	
	@ LOAD SECOND STRING BYTE, COMPARE AND END IF NOT EQUAL
	ldrb	r5, [r1, r2]	@ Load specified byte (from counter) of string
	cmp		r4, r5			@ Compare bytes of both strings
	movne	r6, #0			@ If not equal, load 0 value
	bne		endEqual		@ If not equal, branch to end
	
	@ ELSE- INCREMENT COUNTER AND LOOP
	add		r2, #1			@ Increment counter
	b		loopStrEq		@ Continue looping

endEqual:
	mov		r0, r6			@ Load value in r2 into r0
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine

@-----------------------------------------------------------------------	
/* -- Subroutine: String_equalsIgnoreCase -- */
@ Purpose:  This subroutine will compare two string lengths, and if the 
@ string lengths aren't equal, it will return 0. If they match, it will 
@ then increment through each character in the same locations and return 0
@ if they aren't equal. If it encounters a capital letter, it will 
@ change the character to a lower case letter before comparing.  
@ If it gets to the end of both strings and all are equal, it returns 1.

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string
@	R1: Points to first byte of second string 
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns 0 for false, 1 for true.
@ All registers are preserved as per AAPCS.

String_equalsIgnoreCase:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS

	@ CALL STRING_LENGTH & SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	bl		String_Length	@ B&L: to String_Length subroutine
	mov		r4, r0			@ Move answer to r4
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses
	
	@ CALL STRING_LENGTH & SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	mov		r0, r1			@ Move address of second string to r0
	bl		String_Length	@ B&L: to String_Length subroutine
	mov		r5, r0			@ Move answer to r5
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses

	@ COMPARE STRINGS, END IF NOT EQUAL
	cmp		r4, r5			@ Compare string lengths
	movne	r6, #0			@ If not equal, load 0 value
	bne		endEqualIC		@ If not equal, branch to end
	
	@ ELSE- INITIALIZE COUNTER TO 0
	mov		r2, #0	    	@ Initialize counter to 0

loopStrEqIC:

	@ CHECK: IF FIRST STRING IS DONE, END
	ldrb	r4, [r0, r2]	@ Load specified byte (from counter) of string
	cmp		r4, #0			@ Compare to 0, end if it's zero
	moveq	r6, #1			@ If reaching end of string, load 1 and end
	beq		endEqualIC		@ Branch to end of program if 0
	
	@ ELSE- CHECK IF LOWERCASE, IF NOT CHANGE
	cmp		r4, #0x61		@ Compare to hex 0x61
	addlt	r4, #0x20		@ If < 0x61, add 0x20 making it lower case
	
	@ LOAD SECOND STRING, CHECK IF LOWER CASE & CHANGE IF NOT
	ldrb	r5, [r1, r2]	@ Load specified byte (from counter) of string
	cmp		r5, #0x61		@ Compare to hex 0x61
	addlt	r5, #0x20		@ If < 0x61, add 0x20 making it lower case
	
	@ COMPARE BOTH BYTES, END IF NOT EQUAL
	cmp		r4, r5			@ Compare bytes of both strings
	movne	r6, #0			@ If not equal, load 0 value
	bne		endEqualIC		@ If not equal, branch to end
	
	@ ELSE CONTINUE LOOPING
	add		r2, #1			@ Increment counter
	b		loopStrEqIC		@ Continue looping

endEqualIC:
	mov		r0, r6			@ Load value in r2 into r0
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine

@-----------------------------------------------------------------------	
/* -- Subroutine: String_copy -- */
@ Purpose:  This subroutine will dynamically create a new pointer with
@ the same number of bytes as the string passed in to copy.  It will 
@ then copy the original string to a new string, passing back the value
@ both in r0 and to the specified pointer passed by reference in r1.  

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string to be copied.
@	R1: Points to string pointer address from main.
@ 	LR: Contains the return address.

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns address for new string.
@	R1: Returns value saved to string pointer address from main.
@ All registers are preserved as per AAPCS.

String_copy:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS

	@ PRESERVE REGISTER ADDRESS CONTENTS DURING FUNCTION
	mov		r5, r0			@ Move original string pointer to r5
	mov		r8, r1			@ Move new string pointer address from main
	
	@ CALL STRING_LENGTH & SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	bl		String_Length	@ B&L: to String_Length subroutine
	add		r0, #1			@ Add one to counter	;ADDED/REMOVED
	mov		r4, r0			@ Move answer to r4
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses
	
@ ALLOCATE MEMORY TO A NEW POINTER WITH MALLOC ;REMOVED
@add		r4, #1			@ Add one for the null pointer
@mov		r0, r4			@ Move number of bytes in r4 to r0
@bl		malloc			@ r0 now has the address with number of bytes
@ldr		r6, =szBuff		@ Load new pointer
@str		r0, [r6]		@ Store address in r0 to r6 (szBuff)
@bl		free			@ Deallocate memory
 
	@ INITIALIZE COUNTER
	mov		r2, #0			@ Initialize counter to zero
	mov		r3, #0			@ Value to store remaining spaces to zero;now used for null @ end of string
	 
loopStrCopy:

	@ CHECK: IF STRINGS ARE EQUAL, END IF 0
	cmp		r2, r4			@ Compare counter to string length, end if ==
@	strgeb	r3, [r8, r3]	@ If ==, add null to end			; ADDED TO END WITH NULL!!!!!!!!
	bge		endStrCopy		@ If r2 >= r4, end ;ADDED
@bge		clearAddVarR1	@ If r2 >= r4, clear r1's remaining string 		;REMOVED

	@ ELSE: COPY STRING TO NEW STRING VARIABLE AND R1
	ldrb	r7, [r5, r2]	@ Load specified byte (from counter) of string
@ldr		r0, =szBuff		@ Loads dynamic address to r0;REMOVED
@strb	r7, [r0, r2]	@ Store copied byte in specified location to r0;REMOVED
	strb	r7, [r8, r2]	@ Store byte into r8, increment one byte

	add		r2, #1			@ Increment counter
	b		loopStrCopy		@ Continue looping

@ CLEAR REMAINING VALUES IN ADDRESS PASSED FROM MAIN;REMOVED
@clearAddVarR1: 
@ldrb	r7, [r8, r2]	@ Load next byte of address
@cmp		r7, #0			@ Compare to 0
@beq		endStrCopy		@ If 0, end
@strb	r3, [r8, r2]	@ Else, store 0 in next byte
@add		r2, #1			@ Increment counter
@b		clearAddVarR1	@ Loop again

endStrCopy: 
@ldr		r0, =szBuff		@ Load dynamic value into r0;REMOVED
@ldr		r0, [r0] ;REMOVED
	mov		r1, r8			@ Load value to referenced pointer 
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine


@-----------------------------------------------------------------------	
/* -- Subroutine: String_substring_1 -- */
@ Purpose:  This subroutine will create a new string consisting of 
@ characters from a substring of the passed substring starting with 
@ beginIndex and ending with endIndex.  

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string to be copied
@	R1: Points to string pointer address from main
@	R2: Beginning index
@	R3: Ending index
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns address for new string.
@	R1: Returns value saved to string pointer address from main.
@ All registers are preserved as per AAPCS.

String_substring_1:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS

	@ PRESERVE REGISTER ADDRESS CONTENTS DURING FUNCTION
	mov		r5,  r0			@ Move original string pointer to r5
	mov		r8,  r1			@ Move string pointer address from main to r8
	mov		r9,  r2			@ Move beginning index
	mov		r10, r3			@ Move end index

	@ CHECK FOR BLANK STRING
	ldrb	r11, [r0, #0]	@ Load first byte of full string to be read
	cmp		r11, #0			@ Verify pointer isn't null
	moveq	r0, #-1			@ If it is, load 0
	beq		endSubStr1		@ Then end

	@ CHECK FOR VALID INDICIES
	cmp		r2, #0			@ Compare r1 to 0
	movlt	r0, #-1			@ If it's negative, load -1
	blt		endSubStr1		@ Then end
	cmp		r3, #0			@ Compare r3 to 0
	movlt	r0, #-1			@ If it's negative, load -1
	movlt	r1, #-1			@ If it's negative, load -1
	blt		endSubStr1		@ Then end
	cmp		r3, r2			@ Compare r3-r2
	movlt	r0, #-1			@ If it's negative, load -1
	movlt	r1, #-1			@ If it's negative, load -1
	blt		endSubStr1		@ Then end

	@ ALLOCATE MEMORY TO A NEW POINTER WITH MALLOC
	sub		r0, r3, r2		@ Find new string length
	add		r0, #1			@ Add one for the null pointer
	bl		malloc			@ r0 now has the address with number of bytes
	ldr		r6, =szBuff		@ Load new pointer
	str		r0, [r6]		@ Store address in r0 to r6 (szBuff)
	bl		free			@ Deallocate memory
	
	@ COPY TO NEW STRING
	mov		r2, #0			@ Initialize to 0
	
loopSubStr1:	
	cmp		r9, r10			@ Compare beginning index with end index
	bge		clearAddVar		@ If r2 >= r3, clear r1's remaining string 
	
	ldrb	r7, [r5, r9]	@ Load specified byte (from counter) of string
	ldr		r0, =szBuff		@ Loads address pointed to by r0
	strb	r7, [r0, r2]	@ Store byte into r0, increment one byte
	strb	r7, [r8, r2]	@ Store byte into r8, increment one byte

	add		r9, #1			@ Increment 1st counter
	add		r2, #1			@ Increment 2nd counter
	b		loopSubStr1		@ Continue looping

	@ CLEAR REMAINING VALUES IN ADDRESS PASSED FROM MAIN
	mov		r3, #0			@ Value to store remaining spaces to zero
	
clearAddVar:
	ldrb	r7, [r8, r2]	@ Load next byte of address
	cmp		r7, #0			@ Compare to 0
	beq		endSubStr1		@ If 0, end
	strb	r3, [r8, r2]	@ Else, store 0 in next byte
	add		r2, #1			@ Increment counter
	b		clearAddVar		@ Loop again

endSubStr1:
	ldr		r0, =szBuff		@ Load value in r5 into r0
	mov		r1, r8			@ Load value to referenced pointer
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine

@-----------------------------------------------------------------------	
/* -- Subroutine: String_substring_2 -- */
@ Purpose:  This subroutine will create a new string consisting of 
@ characters from a substring of the passed substring starting with 
@ beginIndex to the end of the original string.  

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string to be copied.
@	R1: Beginning index.
@ 	LR: Contains the return address.

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns address for new string.
@ All registers are preserved as per AAPCS.

String_substring_2:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS

	@ CHECK FOR BLANK STRING
	ldrb	r5, [r0, #0]	@ Load first byte of full string to be read
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r0, #-1			@ If it is, load 0
	beq		endSubStr2		@ Then end

	@ CHECK FOR VALID INDEX
	cmp		r1, #0			@ Compare r1 to 0
	movlt	r0, #-1			@ If it's negative, load 0
	blt		endSubStr2		@ Then end

	@ CALL STRING COPY TO COPY STRING
	add		r0, r1			@ Move r0 to correct byte specified 
	ldr		r1, =szBuff		@ Load address for return variable
	bl		String_copy		@ Call String_copy
	
endSubStr2:
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine

@-----------------------------------------------------------------------	
/* -- Subroutine: String_charAt -- */
@ Purpose:  This subroutine will verify there isn't a blank string, 
@ check for a valid index, and return the character in the indicated
@ position.  If the request is impossible to fulfill, the method returns 0.  

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string to be read.
@	R1: Index of character to be found.
@ 	LR: Contains the return address.

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns character at index, or 0 if not possible.
@ All registers are preserved as per AAPCS.

String_charAt:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS
	
	@ CHECK FOR BLANK STRING
	ldrb	r5, [r0, #0]	@ Load first byte of full string to be read
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r0, #0			@ If it is, load 0
	beq		endCharAt

	@ CHECK FOR VALID INDEX
	cmp		r1, #0			@ Compare r1 to 0
	movlt	r0, #0			@ If it's negative, load 0
	blt		endCharAt		@ Then end

	@ CALL STRING_LENGTH & SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	bl		String_Length	@ B&L: to String_Length subroutine
	mov		r4, r0			@ Move answer to r4
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses
	
	@ CHECK TO VERIFY INDEX IS WITHIN STRING SIZE
	cmp		r4, r1			@ Compare index to string length
	movlt	r0, #0			@ If index is <= string length, load 0
	blt		endCharAt		@ Then end	
	
	@ STORE CHARACTER AT SPECIFIED LOCATION
	ldrb	r7, [r0, r1]	@ Load byte at specified r1 location
	ldr		r0, =szBuff		@ Load szBuff
	str		r7, [r0]		@ Load byte into szBuff
	
endCharAt:
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine

@-----------------------------------------------------------------------	
/* -- Subroutine: String_startsWith_1 -- */
@ Purpose:  This subroutine will verify that the substring, starting 
@ from the specified offset index, exists within string.
@ It returns 0 for false, 1 for true.  

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string to be read.
@	R1: Index of starting point to search.
@	R2: Points to first byte of string to search for.
@ 	LR: Contains the return address.

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns 0 if false, 1 if true.
@ All registers are preserved as per AAPCS.

String_startsWith_1:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS
	
	@ CHECK FOR VALID INDEX
	cmp		r1, #0			@ Compare r1 to 0
	movlt	r0, #0			@ If it's negative, load 0
	blt		endStartsWith1	@ Then end

	@ CHECK FOR BLANK STRINGS
	ldrb	r5, [r0, #0]	@ Load first byte of full string to be read
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r6, #0			@ If it is, load 0
	beq		endStartsWith1	@ Then branch to end
	ldrb	r5, [r2, #0]	@ Load first byte of comparison string 
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r6, #0			@ If it is, load 0
	beq		endStartsWith1	@ Then branch to end
		
	@ INITIALIZE COUNTER 
	mov		r3, #0			@ Initialize counter to 0

loopStartsWith1:

	@ LOAD COMPARISON STRING AT INDEX, END IF STRING IS DONE
	ldrb	r5, [r2, r3]	@ Load specified byte (from counter) of string
	cmp		r5, #0			@ Compare to 0, end if it's zero
	moveq	r6, #1			@ If reaching end of string, load 1 and end
	beq		endStartsWith1	@ Branch to end of program if 0
	
	@ LOAD FIRST STRING AT INDEX
	ldrb	r4, [r0, r1]	@ Load specified byte (from counter) of string
	cmp		r4, r5			@ Compare bytes of both strings
	movne	r6, #0			@ If not equal, load 0 value
	bne		endStartsWith1	@ If not equal, branch to end
	
	@ ELSE- INCREMENT COUNTER AND LOOP
	add		r3, #1			@ Increment 1st counter
	add		r1, #1			@ Increment 2nd counter
	b		loopStartsWith1	@ Continue looping

endStartsWith1:
	mov		r0, r6			@ Load value in r6 into r0
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine

	
@-----------------------------------------------------------------------	
/* -- Subroutine: String_startsWith_2 -- */
@ Purpose:  This subroutine will verify that the substring begins with
@ the specified prefix.  It returns 0 for false, 1 for true.  
	
@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string to be read.
@	R1: Points to first byte of string to search for.
@ 	LR: Contains the return address.

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns 0 if false, 1 if true.
@ All registers are preserved as per AAPCS.

String_startsWith_2:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS
	
	@ CHECK FOR BLANK STRINGS
	ldrb	r5, [r0, #0]	@ Load first byte of full string to be read
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r6, #0			@ If it is, load 0
	beq		endStartsWith2	@ Then branch to end
	ldrb	r5, [r1, #0]	@ Load first byte of comparison string 
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r6, #0			@ If it is, load 0
	beq		endStartsWith2	@ Then branch to end
		
	@ INITIALIZE COUNTER 
	mov		r3, #0			@ Initialize counter to 0

loopStartsWith2:

	@ LOAD COMPARISON STRING AT INDEX, END IF STRING IS DONE
	ldrb	r5, [r1, r3]	@ Load specified byte (from counter) of string
	cmp		r5, #0			@ Compare to 0, end if it's zero
	moveq	r6, #1			@ If reaching end of string, load 1 and end
	beq		endStartsWith2	@ Branch to end of program if 0
	
	@ LOAD FIRST STRING AT INDEX
	ldrb	r4, [r0, r3]	@ Load specified byte (from counter) of string
	cmp		r4, r5			@ Compare bytes of both strings
	movne	r6, #0			@ If not equal, load 0 value
	bne		endStartsWith2	@ If not equal, branch to end
	
	@ ELSE- INCREMENT COUNTER AND LOOP
	add		r3, #1			@ Increment 1st counter
	b		loopStartsWith2	@ Continue looping

endStartsWith2:
	mov		r0, r6			@ Load value in r6 into r0
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine
	
@-----------------------------------------------------------------------	
/* -- Subroutine: String_endsWith -- */
@ Purpose:  This subroutine will verify that the substring end with
@ the specified postfix.  It returns 0 for false, 1 for true.  

@	PRECONDITIONS: 
@ 	R0: Points to first byte of first string to be read.
@	R1: Points to first byte of string to search for.
@ 	LR: Contains the return address.

@ 	POSTCONDITIONS/Returned register contents: 
@ 	R0: Returns 0 if false, 1 if true.
@ All registers are preserved as per AAPCS.

String_endsWith:

	push 	{r4-r11, LR}  	@ Preserve register contents per AAPCS
	
	@ CHECK FOR BLANK STRINGS
	ldrb	r5, [r0, #0]	@ Load first byte of full string to be read
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r6, #0			@ If it is, load 0
	beq		endEndsWith		@ Branch to end
	ldrb	r5, [r1, #0]	@ Load first byte of comparison string 
	cmp		r5, #0			@ Verify pointer isn't null
	moveq	r6, #0			@ If it is, load 0
	beq		endEndsWith		@ Branch to end
		
	@ CALL STRING_LENGTH FOR STRING TO BE READ, SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	bl		String_Length	@ B&L: to String_Length subroutine
	mov		r4, r0			@ Move answer to r4
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses
	
	@ CALL STRING_LENGTH FOR COMPARISON STRING, SAVE TO A REGISTER
	push	{r0, r1}		@ Push r0 and r1 to preserve addresses
	mov		r0, r1			@ Move address of second string to r0
	bl		String_Length	@ B&L: to String_Length subroutine
	mov		r5, r0			@ Move answer to r5
	pop		{r0, r1}		@ Pop r0 and r1 to preserve addresses
		
	@ INITIALIZE COUNTER 
	mov		r3, #0			@ Initialize counter to 0

loopEndsWith:

	@ LOAD COMPARISON STRING AT INDEX, END IF STRING IS DONE
	ldrb	r5, [r1, r5]	@ Load specified byte (from counter) of string
	cmp		r5, #0			@ Compare to 0, end if it's zero
	moveq	r6, #1			@ If reaching end of string, load 1 and end
	beq		endEndsWith		@ Branch to end of program if 0
	
	@ LOAD FIRST STRING AT INDEX
	ldrb	r4, [r0, r4]	@ Load specified byte (from counter) of string
	cmp		r4, r5			@ Compare bytes of both strings
	movne	r6, #0			@ If not equal, load 0 value
	bne		endEndsWith		@ If not equal, branch to end
	
	@ ELSE- INCREMENT COUNTER AND LOOP
	sub		r5, #1			@ Increment 1st counter
	sub		r4, #1			@ Increment 2nd counter
	b		loopEndsWith	@ Continue looping

endEndsWith:
	mov		r0, r6			@ Load value in r6 into r0
	pop		{r4-r11, LR} 	@ Restore working register contents
	bx		LR				@ Return from subroutine
		
@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_indexOf_1 -- */
@ Purpose:  This subroutine will search the string for the character. If found, the index
@ of that character is returned. If NOT found, -1 is returned.
@ 	R0: Points to a null-terminated string
@	R1: Contains a character byte
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the index where key was found or -1
@ All registers are preserved as per AAPCS.

String_indexOf_1:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r2, #0				@ Set r2 to 0 (index)
	mov	r4, r0				@ Copy string address to r4
	ldrb	r0, [r0]		@ Load string[0] into r0

indexOf_1_loop:	
	@ COMPARE STRING[i] AND CHAR
	cmp	r0, r1				@ Check if the char in the string matches the char arg
	moveq	r0, r2			@ If equal, move index to r0
	beq	indexOf_1_end		@ If equal, goto indexOf_1_end; char found

	@ ELSE IF: CHECK FOR END OF STRING
	cmp	r0, #0				@ Check for null terminator
	moveq	r0, #-1			@ If equal, index = -1
	beq	indexOf_1_end		@ If equal, goto end; end of string

	@ ELSE: GO TO STRING[i+1]
	add	r2, #1				@ Increment index
	ldrb	r0, [r4, r2]	@ Load string[i+1] into r0
	b	indexOf_1_loop		@ Goto indexOf_1_loop

indexOf_1_end:
	pop 	{r4-r8, r10, r11, LR}	@ Pop AAPCS required registers to stack to save them
	bx 	lr					@ Return to calling program 

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_indexOf_2 -- */
@ Purpose:  This subroutine will search the string for the character offset by an integer value. 
@ If found, the index of that character is returned. If NOT found, -1 is returned.
@ 	R0: Points to a null-terminated string
@	R1: Contains a character byte
@	R2: Contains an integer (inital offset)
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the index where key was found or -1
@ All registers are preserved as per AAPCS.


String_indexOf_2:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r4, r0				@ Copy string address to r4
	ldrb	r0, [r0, r2]	@ Load string[offset] into r0
	b	indexOf_2_loop		@ Goto indexOf_2_loop 

indexOf_2_loop:	
	@ COMPARE STRING[i] AND CHAR
	cmp	r0, r1				@ Check if the char in the string matches the char arg
	moveq	r0, r2			@ If equal, move index to r0
	beq	indexOf_2_end		@ If equal, goto indexOf_2_end; char found

	@ ELSE IF: CHECK FOR END OF STRING
	cmp	r0, #0				@ Check for null terminator
	moveq	r0, #-1			@ If equal, index = -1
	beq	indexOf_2_end		@ If equal, goto indexOf_2_end; end of string

	@ ELSE: GO TO STRING[i+1]
	add	r2, #1				@ Increment index
	ldrb	r0, [r4, r2]	@ Load string[i+1] into r0
	b	indexOf_2_loop		@ Goto indexOf_2_loop

indexOf_2_end:
	pop 	{r4-r8, r10, r11, LR}	@ Pop AAPCS required registers to stack to save them
	bx 	lr					@ Return to calling program


@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_indexOf_3 -- */
@ Purpose:  This subroutine will search the string for a substring. If found, the first index of 
@ the substring is returned. If NOT found, -1 is returned.
@ 	R0: Points to a null-terminated string
@	R1: Points to a null-terminated string (substring)
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the first index where key was found or -1
@ All registers are preserved as per AAPCS.

String_indexOf_3:
	@ SETUP ADDRESSES AND INDICIES
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r4, r0				@ Copy string address to r4
	mov	r5, r1				@ Copy substr address to r5
	mov	r6, #0				@ Set string index to 0
	mov	r7, #0				@ Set substr index to 0
	mov	r8, #0				@ Set search index to 0

	@ LOAD INITIAL CHARACTERS
	ldrb	r0, [r4, r6]	@ Load string[i] into r0
	ldrb	r1, [r5, r7]	@ Load substr[i] into r1

indexOf_3_outer_loop:
	@ CHECK FOR END OF STRING
	cmp	r0, #0					@ Compare character to 00
	moveq	r0, r8				@ If equal, copy search index to r0
	beq	indexOf_3_end			@ If equal, goto indexOf_3_end

	@ COMPARE FIRST CHARACTER OF SUBSTRING
	cmp	r0, r1					@ Check string[i] == substr[i]
	moveq	r8, r6				@ If equal, set start of substr ident index
	beq	indexOf_3_inner_loop	@ If equal, goto indexOf_3_inner_loop

	@ ELSE GO TO NEXT STRING CHARACTER
	add	r6, #1					@ Increment string index
	ldrb	r0, [r4, r6]		@ Load string[i] into r0
	cmp	r0, #0					@ Check string[i+1] == 00
	moveq	r0, #-1				@ If equal, set r0 to -1 (not found)
	beq	indexOf_3_end			@ If equal, goto indexOf_3_end
	b	indexOf_3_outer_loop	@ Goto indexOf_3_outer_loop

indexOf_3_inner_loop:
	@ COMPARE STRING CHARACTERS
	cmp	r0, r1					@ Check string[i] == substr[i]
	movne	r7, #0				@ If NOT equal, reset substr index to 0
	ldrneb	r1, [r5, r7]		@ Reload first char of substr
	bne	indexOf_3_outer_loop	@ If NOT equal, goto indexOf_3_outer_loop

	@ GET NEXT STRING CHAR AND CHECK FOR END OF STRING
	add	r6, #1					@ Increment string index
	ldrb	r0, [r4, r6]		@ Load string[i] into r0
			@cmp	r0, #0				@ Check string[i+1] == 00
			@moveq	r0, #-1			@ If equal, set r0 to -1 (not found)
			@beq	indexOf_3_end		@ If equal, goto indexOf_3_end

	@ GET NEXT SUBSTRING CHAR AND CHECK FOR END OF SUBSTRING
	add	r7, #1					@ Increment substr index
	ldrb	r1, [r5, r7]		@ Load substr[i] into r1
	cmp	r1, #0					@ Check substr[i] == 00
	beq	indexOf_3_continue		@ If equal, goto indexOf_3_continue
	b	indexOf_3_inner_loop	@ Goto indexOf_3_inner_loop

indexOf_3_continue:
	mov 	r0, r8			@ Move starting index to r0

indexOf_3_end:
	pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	bx	lr					@ Return to calling program

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_lastIndexOf_1 -- */
@ Purpose:  This subroutine will search the string in reverse for a character. 
@ If found, the first index of the char is returned. If NOT found, -1 is returned.
@ 	R0: Points to a null-terminated string
@	R1: Contains a character byte
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the last index where key was found or -1
@ All registers are preserved as per AAPCS.

String_lastIndexOf_1:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r4, r0				@ Copy string address to r4
	mov	r5, r1				@ Copy char arg to r5

	@ GET LENGTH-1 (LAST INDEX) OF STRING
	bl	String_Length		@ Get length of string and store in r0
	sub	r0, #1				@ Decrement length to account for zero-indexing
	mov	r2, r0				@ Set r2 (index) to string length

lastIndexOf_1_loop:
	@ COMPARE CHARACTERS
	ldrb	r0, [r4, r2]	@ Load string[i] into r0
	cmp	r0, r5				@ Compare string[i] with char arg
	moveq	r0, r2			@ If equal, move index to r0
	beq	lastIndexOf_1_end	@ If equal, goto lastIndexOf_1_end (FOUND)
	
	@ ELSE GO TO STRING[i-1]
	sub	r2, #1				@ Decrement index
	cmp	r2, #-1				@ Compare index to -1
	moveq	r0, r2			@ If equal, move index to r0
	beq	lastIndexOf_1_end	@ If equal, goto lastIndexOf_1_end (END OF STRING/NOT FOUND)
	b	lastIndexOf_1_loop	@ Goto lastIndexOf_1_loop

lastIndexOf_1_end:
	pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	bx	lr			@ Return to calling program

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_lastIndexOf_2 -- */
@ Purpose:  This subroutine will search the string in reverse from an offset for a character. 
@ If found, the first index of the char is returned. If NOT found, -1 is returned.
@ 	R0: Points to a null-terminated string
@	R1: Contains a character byte
@	R2: Contains an integer (inital offset)
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the last index where key was found or -1
@ All registers are preserved as per AAPCS.

String_lastIndexOf_2:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r4, r0				@ Copy string address to r4
	mov	r5, r1				@ Copy char arg to r5
	bl	String_Length		@ Get length of string and store in r0
	sub	r0, #1				@ Decrement length to account for zero-indexing

lastIndexOf_2_loop:
	@ COMPARE CHARACTERS
	ldrb	r0, [r4, r2]	@ Load string[i] into r0
	cmp	r0, r5				@ Compare string[i] with char arg
	moveq	r0, r2			@ If equal, move index to r0
	beq	lastIndexOf_2_end	@ If equal, goto lastIndexOf_2_end (FOUND)
	
	@ ELSE GO TO STRING[i-1]
	sub	r2, #1				@ Decrement index
	cmp	r2, #-1				@ Compare index to -1
	moveq	r0, r2			@ If equal, move index to r0
	beq	lastIndexOf_2_end	@ If equal, goto lastIndexOf_2_end (END OF STRING/NOT FOUND)
	b	lastIndexOf_2_loop	@ Goto lastIndexOf_2_loop

lastIndexOf_2_end:
	pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	bx	lr			@ Return to calling program

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_lastIndexOf_3 -- */
@ Purpose:  This subroutine will search the string in reverse for a substring. 
@ If found, the first index of the char is returned. If NOT found, -1 is returned.
@ 	R0: Points to a null-terminated string
@	R1: Points to a null-terminated string (substring)
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the last index where the key was found or -1
@ All registers are preserved as per AAPCS.

String_lastIndexOf_3:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r4, r0				@ Copy string address to r4
	mov	r5, r1				@ Copy substr address to r5

	@ SET BOTH INDICIES TO END OF RESPECTIVE STRINGS
	bl	String_Length		@ Get string's length into r0
	sub	r0, #1				@ Decrement string lengt to account for zero-index
	mov	r6, r0				@ Copy string index into r6		

	mov	r0, r5				@ Move substr address to r0
	bl	String_Length		@ Get substr length into r0
	sub	r0, #1				@ Decrement substr length to account for zero-index
	mov	r7, r0				@ Copy substr index to r7 
	mov	r8, r0				@ Copy substr index to r8 for reinitialization

	@ LOAD LAST LETTER OF EACH STRING
	ldrb	r0, [r4, r6]	@ Load string[length - 1] into r0
	ldrb	r1, [r5, r7]	@ Load substr[length - 1] into r1

lastIndexOf_3_outer_loop:
	@ CHECK: IF STRING INDEX == -1, SUBSTRING NOT FOUND
	cmp	r6, #-1				@ Check for reverse end of string (index == -1)
	moveq	r0, r6			@ If equal, Copy index to r0
	beq	lastIndexOf_3_end	@ If equal, Goto lastIndexOf_3_end

	@ ELSE IF FIRST LETTER OF SUBSTRING FOUND IN STRING
	cmp	r0, r1				@ Check string[i] == substr[i]
	beq	lastIndexOf_3_inner_loop@ Goto indexOf_3_inner_loop

	@ ELSE DECREMENT STRING INDEX AND CONTINUE SEARCH
	sub	r6, #1				@ Decrement string index
	ldrb	r0, [r4, r6]	@ Load string[i] into r0
	b	lastIndexOf_3_outer_loop	@ Goto indexOf_3_outer_loop

lastIndexOf_3_inner_loop:
	@ CHECK: IF STRING CHAR DOES NOT EQUAL SUBSTR CHAR
	cmp	r0, r1				@ Check string[i] == substr[i]
	
	@ NO MATCH FOUND: RESET SUBSTR INDEX AND GO TO OUTER LOOP
	movne	r7, r8			@ If not equal, reset substr index to substr (length - 1)
	bne	lastIndexOf_3_outer_loop 	@ If not equal, goto indexOf_3_outer_loop

	@ INCREMENT STRING INDEX AND CHECK FOR END OF STRING
	sub	r6, #1				@ Decrement string index
	cmp	r6, #-1				@ Check string index == 0
	moveq	r0, #-1			@ If equal, set r0 to -1 (not found)
	beq	lastIndexOf_3_end	@ If equal, goto end

	@ DECREMENT SUBSTR INDEX AND CHECK FOR END OF SUBSTR
	sub	r7, #1				@ Decrement substr index
	cmp	r7, #-1				@ Check substr index == -1
	addeq	r6, #1			@ If equal, add one to string index to compensate answer
	moveq	r0, r6			@ If equal, move string index to r0
	beq	lastIndexOf_3_end	@ If equal, goto lastIndexOf_3_end

	@ ELSE LOAD NEXT CHARACTERS
	ldrb	r0, [r4, r6]	@ Load string[i] into r0
	ldrb	r1, [r5, r7]	@ Load substr[i] into r1
	b	lastIndexOf_3_inner_loop@ Goto indexOf_3_inner_loop

lastIndexOf_3_end:
	pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	bx	lr			@ Return to calling program

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_concat -- */
@ Purpose:  This subroutine will concatenate two strings and return the new string
@ 	R0: Points to a null-terminated string (string1)
@	R1: Points to a null-terminated string (string2)
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the concatenated string
@ All registers are preserved as per AAPCS.

String_concat:
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	@ SETUP ADDRESSES
	mov	r4, r0				@ Copy string1 address to r4
	mov	r5, r1				@ Copy string2 address to r5
	
	@ GET STRINGS 1 AND 2 LENGTHS
	bl	String_Length		@ Get length of string1
	mov	r7, r0				@ Move length to r7
	mov	r2, r0				@ Copy length to r2
	mov	r0, r5				@ Move String2 address to r0
	bl	String_Length		@ Get length of string2
	add	r7, r0				@ length = s1_length + s2_length
	add	r7, #1				@ Add 1 to length to account for null term
	
	@ ALLOCATE MEMORY FOR NEW STRING
	mov	r0, r7				@ Copy length to r0
	bl 	malloc				@ Allocate length number of bytes: new_string
	ldr	r8, =sPtr			@ Load address of string pointer into r8
	str	r0, [r8]			@ Store dyn. mem. addres in pointer
	bl	free				@ Deallocate dynamic memory

	@ SETUP FOR COPYING
	mov	r1, r4				@ Move address of string1 to r1 for copying
	mov	r2, r8				@ Move address of new_string pointer to r2
	ldr 	r2, [r2]		@ Load address pointed to by szBuffer
	ldrb	r0, [r1]		@ Load first char of string1
	mov	r6, #0				@ String2 index
	mov	r3, #0				@ new_string index	

concat_loop_1:
	@ CHECK FOR END OF STRING
	ldrb	r0, [r1, r3]	@ Load string[i] into r0
	cmp	r0, #0				@ Check string1[i] == 00
	beq	concat_continue		@ If equal, goto concat_continue
	
	@ COPY CHARACTERS
	strb	r0, [r2, r3]	@ Store string[i] into new_string[i]
	add	r3, #1				@ Increment index
	b	concat_loop_1		@ Goto concat_loop_1
	
concat_continue:
	mov	r1, r5				@ Load address of string2 into r1
	ldrb	r0, [r1]		@ Load first char of string2
	
concat_loop_2:
	@ CHECK FOR END OF STRING
	ldrb	r0, [r1, r6]	@ Load string2[i] into r0
	cmp	r0, #0				@ Check string2[i] == 00
	beq	concat_finish		@ If equal, goto concat_finish
	
	@ COPY CHARACTERS
	strb	r0, [r2, r3]	@ Store string2[i] into new_string
	add	r6, #1				@ Increment string2 index
	add	r3, #1				@ Increment new_string index
	b	concat_loop_2		@ Goto concat_loop_2

concat_finish:
	@ ADD A NULL TERMINATOR
	add	r3, #1				@ Increment index
	mov	r0, #0				@ Load ASCII value for NULLTERM
	strb	r0, [r2, r3]	@ Store NULLTERM into new_string
	mov	r0, r2				@ Load pointer of new_string into r2
	
	@ END CALL
	pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	bx	lr					@ Return to calling program

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_replace -- */
@ Purpose:  This subroutine will create a new string and replace all chars matching the char argument
@ 	R0: Points to a null-terminated string
@	R1: Contains a character byte (oldChar)
@	R2: Contains a character byte (newChar)
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the new string with replaced chars
@ All registers are preserved as per AAPCS.

String_replace:	
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r4, r0				@ Copy string address to r4
	mov	r5, r1				@ Copy oldchar to r5
	mov	r6, r2				@ Copy newChar to r6
	mov 	r3, #0			@ Set r3 (index) to 0
	ldrb	r0, [r0]		@ Load string[0] into r0

	@ ALLOCATE MEMORY FOR NEW STRING
	mov	r0, r7				@ Copy length to r0
	bl 	malloc				@ Allocate length number of bytes: new_string
	ldr	r8, =szBuffer		@ Load address of szBuffer into r8
	str	r0, [r8]			@ Store dyn. mem. addres in szBuffer
	bl	free				@ Deallocate dynamic memory

	@ SETUP FOR COPYING STRING
	mov	r1, r4				@ Move address of string to r1 for copying
	ldr	r2, =szBuffer		@ Move address of new_string into r2 for copy-receipt
	ldrb	r0, [r1]		@ Load first char of string
	mov	r3, #0				@ new_string index	

replace_loop:
	@ CHECK FOR END OF STRING
	ldrb	r0, [r1, r3]	@ Load string[i] into r0
	cmp	r0, #0				@ Check for null term
	beq	replace_end			@ If equal, goto replace_end

	@ COMPARE AND COPY CHARACTERS
	cmp	r0, r5				@ Check if oldChar == newChar
	streqb	r6, [r2, r3]	@ If equal, store newChar into new_string
	strneb	r0, [r2, r3]	@ If not equal, store string[i] into new_string
	add	r3, #1				@ Increment index
	b	replace_loop		@ Goto replace_loop

replace_end:
	@ ADD NULL TERM
	add	r3, #1				@ Increment index
	mov	r0, #0				@ Set r0 to 0 (null term)
	strb	r0, [r2, r3]	@ Amend new_string with null terminator
	mov	r0, r2				@ Move new_String address to r0
	
	@ END CALL
	pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	bx	lr					@ Return to calling program

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_toUpperCase -- */
@ Purpose:  This subroutine will convert all lowercase chars to uppercase
@ 	R0: Points to a null-terminated string
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the new string will replaced chars
@ All registers are preserved as per AAPCS.

String_toUpperCase:
	@ SETUP
	push 	{r4-r11, LR}		@ push AAPCS-required registers to stack to save them
	mov		r1, #0				@ Set r1 (index) to 0
	mov		r2, r0				@ Copy string address to r2

	@ CHECK FOR END OF STRING
	cmp		r0, #0				@ Check if string[i] == 00
	beq		toUpperCase_end		@ If equal, goto toUpperCase_end

toUpperCase_loop:
	ldrb	r0, [r2, r1]		@ load string[i] into r0
	cmp		r0, #0				@ Check for null term
	beq		toUpperCase_end		@ If equal, goto toUpperCase_end
	
	@ CHECK IF CHAR HAS ASCII VALUE LOWER THAN 'a'
	cmp		r0, #97				@ (r0 - 97)
	addlt		r1, #1				@ index++
	blt		toUpperCase_loop	@ If (r0 < 'a'), goto toUpperCase_loop

	@ CHECK IF CHAR HAS ASCII VALUE HIGHER THAN 'z'
	cmp		r0, #122			@ Check if char is greater than 'z'
	addgt		r1, #1				@ index++
	bgt		toUpperCase_loop	@ If greater than, goto toUpperCase_loop

	@ CONVERT CHARACTER
	sub		r0, #32				@ string[i] = string[i] - 32
				@sub		r1, #1				@ index--
	strb	r0, [r2, r1]		@ Store converted character (r0) into string[i]
	add		r1, #1				@ index++
	
	b		toUpperCase_loop	@ Else goto toUpperCase_loop

toUpperCase_end:
	mov		r0, r2				@ move string address to r0
	pop 	{r4-r11, LR}		@ pop AAPCS-required registers off of stack to restore them
	bx		lr					@ Return to calling program

@--------------------------------------------------------------------------------------------------------------
/* -- Subroutine: String_toLowerCase -- */
@ Purpose:  This subroutine will convert all uppercase chars to lowercase
@ 	R0: Points to a null-terminated string
@ 	LR: Contains the return address

@ Returned register contents:
@ 	R0: Returns the new string will replaced chars
@ All registers are preserved as per AAPCS.

String_toLowerCase: 
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS-required registers to stack to save them
	mov	r1, #0				@ Set r1 (index) to 0
	mov	r2, r0				@ Copy string address to r2

	@ LOAD FIRST CHAR
	ldrb	r0, [r0]		@ Load string[0] into r0
	cmp	r0, #0				@ Check for null term
	moveq	r0, r2			@ If equal, move string address to r0
	beq	toLowerCase_end		@ If equal, goto toLowerCase_end

toLowerCase_loop:
	@ CHECK IF CHAR HAS ASCII VALUE LOWER THAN 'A'
	cmp	r0, #65				@ Check if char is less than 'A'
	addlt	r1, #1			@ If less than, increment index
	ldrltb	r0, [r2, r1]	@ If less than, load string[i] into r0
	blt	toLowerCase_loop	@ If less than, goto toLowerCase_loop

	@ CHECK IF CHAR HAS ASCII VALUE HIGHER THAN 'Z'
	cmp	r0, #90				@ Check if char is greater than 'Z'
	addgt	r1, #1			@ If greater than, increment index
	ldrgtb	r0, [r2, r1]	@ If greater than, load string[i] into r0
	bgt	toLowerCase_loop	@ If greater than, goto toLowerCase_loop

	@ CONVERT CHAR
	add	r0, #32				@ string[i] = string[i] + 32
	strb	r0, [r2, r1]	@ Store converted character (r0) into string[i]

	@ GET NEXT CHAR
	add	r1, #1				@ Increment index
	ldrb	r0, [r2, r1]	@ Load string[i] into r0
	cmp	r0, #0				@ Check for null term
	moveq	r0, r2			@ If equal, move string address to r0	
	beq	toLowerCase_end		@ If equal, goto toLowerCase_end
	b	toLowerCase_loop	@ Else goto toLowerCase_loop

toLowerCase_end:
	pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	bx	lr					@ Return to calling program

	/* END */
	@end:
	@pop 	{r4-r8, r10, r11, LR}	@ pop AAPCS-required registers off of stack to restore them
	@bx	lr					@ Return to calling program

@---TRUE-END------------------------------------------------------------	
	.end
