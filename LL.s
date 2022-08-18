@RASM4: must use Linked Lists. Will have a menu.
@	Clear screen: a bunch of carriage returns. Create a func for this and call as many as needed
@	Must track number of nodes used
@	The 512b KbBuffer is important: temporaily store there, figure out length of mem needed,
@	and then malloc the proper amount (same input as RASM3)
@	DO NOT USE C-COMMANDS LIKE TEXTBOOK DOES
@
@	Each node (struct) will have two 4-byte pointers: one to a string, one to a Node(next):

.data	
	szStrBuff:	.skip	512							@;ADDED
	szNum:		.skip	8	
	cCr:		.byte	10	@ Moves the cursor down 
	cBuff:		.byte	1	@ Holds char for fileCreateNode ;ADDED
	.balign 			4	@ Align for performance
	filename:	.asciz	"Output.txt"
	inputFile:	.asciz	"input.txt"					@;ADDED
	szNotFound:	.asciz	"Not found.\n"
	szNoList:	.asciz	"No list to print."
	szNewLine:	.asciz	"\n"	@ Add \n to end of String_copy
	szMsg1:		.asciz	" ["						@;ADDED
	szMsg2:		.asciz	"]    \t"					@;ADDED

.text
	.extern malloc				@ External function
	.extern free				@ External function
	.global LL_viewNodes		@ Provide program starting address to Linker
	.global LL_createNode  		@ Provide program starting address to Linker
	.global LL_createNodeFF		@ Provide program starting address to Linker ;ADDED
	.global LL_deleteNode  		@ Provide program starting address to Linker
	.global LL_searchNode		@ Provide program starting address to Linker
	.global LL_saveFile			@ Provide program starting address to Linker ;MODIFIED
	.global	LL_memUsed			@ Provide program starting address to Linker 

@-------------------------------------------------------------------------------------------------------------
/* -- Subroutine: LL_viewNodes -- */
@ Purpose:  This subroutine will accept the head and tail, check to see
@ if there is a list, and if so print out the nodes.  

@	PRECONDITIONS:
@	R0: address of head
@	R1: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	NONE - void function
@ All registers are preserved as per AAPCS.

LL_viewNodes:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS required registers
	mov		r4, r0					@ Copy head to r4
	mov		r5, r1					@ Copy list length to r5
	ldr		r7, [r4]				@ Deference head to get first node
	mov		r10, #1					@ Set counter to 1 

	@ CHECK NODE LIST.  IF NO NODES EXIST, EXIT
	cmp		r5, #0					@ Check if length of list <= 0
	ldrle	r0, =szNoList			@ If length of list <= 0, load message
	blle	putstring				@ If length of list <= 0, print message
	ble		viewNodesEnd			@ If length of list <= 0, go to viewNodesEnd

	// Use list length as counter. 

viewNodes_loop:
	@ COMPARE NODES, EXIT IF AT END OF LOOP
	cmp		r10, r5					@ Compare counter to list length
	bgt		viewNodesEnd			@ Branch if counter > list length
	
	@ PRINT COUNTER STRING
	ldr		r0, =szMsg1				@ Point to "["
	bl		putstring				@ Print string
	mov		r0, r10					@ Load counter
	ldr		r1, =szNum				@ Load pointer
	bl		intasc32				@ Make counter printable
	ldr		r0, =szNum				@ Load counter
	bl		putstring				@ Print string
	ldr		r0, =szMsg2				@ Point to "]"
	bl		putstring				@ Print string	

	@ PRINT STRING
@mov		r1, r7					@ Move data pointer to r1 ;DELETE
@ldr		r1, [r1]				@ Dereference for address ;DELETE
@mov		r0, r1					@ Move address to r0
	mov		r0, r7					@ Move data pointer to r1
	ldr		r0, [r0]				@ Dereference for address ;NO LONGER NEEDED W/ CHANGE TO CREATE NODE
	bl		putstring				@ Print string

	@ SET UP POINTER FOR LOOP
	ldr		r7, [r7, #4]			@ Load node.next into r4 (advance pointer)
	
	@ DROP DOWN A LINE & INCREMENT COUNTER
	ldr 	r0, =cCr				@ Move cursor down a line	
	bl 		putch
	add		r10, #1					@ Increment counter
	b		viewNodes_loop			@ Branch to beginning of loop
	
viewNodesEnd:
	pop 	{r4-r8, r10, r11, LR}	@ Pop AAPCS required registers to stack to save them
	bx 		lr						@ Return to calling program


@-------------------------------------------------------------------------------------------------------------
/* -- Subroutine: LL_createNode -- */
@ Purpose:  This subroutine will accept three pointers: data/input, head, and tail. It will create a node for the data
@ and either create a new list if none exists or will add it to the end of the preexisting list. Head and tail are
@ adjusted to point to the front and rear of the list, respectively. The length of the list is updated for each node
@ added.

@	PRECONDITIONS:
@ 	R0: address of data to be added (pointer) ;now szStrBuff
@	R1: address of head
@	R2: address of tail
@	R3: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: Contains the number of nodes in the list (list length) ;Nothing passed to this
@	R1: Returns the head of the list with the node added
@	R2: Returns the tail of the list pointing to the newly added node
@	R3: Returns the current length of the list as an integer
@ All registers are preserved as per AAPCS.

LL_createNode:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS required registers
	mov		r4, r0					@ Copy argument address into r4 ;now szStrBuff
	mov		r5, r1					@ Copy head to r5
	mov		r6, r2					@ Copy tail to r6
	mov		r10, r3					@ Copy list length to r10

	@ ALLOCATE MEMORY
	mov		r0, #8					@ Set r0 to 8 for malloc
	bl 		malloc					@ Allocate 8 bytes for node
	mov 	r1, #0					@ Set r1 to 0

	@ SAVE DATA IN THE NEW NODE
	str 	r4, [r0]				@ node.data = address of argument
	str 	r1, [r0, #4]			@ node.next = null
	mov		r8, r0					@ Move dynamic mem address to r8

	@ INCREMENT NODE COUNTER
	add		r10, #1					@ Increment r10 by 1

	@ ASSIGN TAIL TO LAST NODE
	mov 	r1, r6					@ load address of tail into r1
	ldr		r7, [r1]				@ Save current last node address to r7
	str		r8, [r1]				@ Update tail to new node
	mov		r6, r1					@ Move tail address to r6

	@ CHECK FOR EMPTY LIST AND ADJUST POINTERS
	mov		r2, r5					@ Load address of head
	ldr 	r2, [r2]				@ Deference head
	cmp		r2, #0					@ Check if head is pointing to null (empty list)
	streq	r8, [r5]				@ If (*head == null), point head to new node (create list)
	strne	r8, [r7, #4]			@ Else point second-to-last node to new end node (extend list)
			
	@ END
	mov		r1, r5					@ Load address of head into r1
	mov		r2, r6					@ Load address of tail into r2
	mov		r3, r10					@ Copy updated list length to r3
	pop 	{r4-r8, r10, r11, LR}	@ Pop AAPCS required registers to stack to save them
	bx 		lr						@ Return to calling program

@-------------------------------------------------------------------------------------------------------------
/* -- Subroutine: LL_createNodeFF -- */
@ Purpose:  This subroutine will accept head and tail, create a node 
@ from a hardcoded file, call create node, and read byte by byte from 
@ the input file until it hits 0 characters read. It will then close 
@ the input file and end program.

@	PRECONDITIONS:
@	R1: address of head
@	R2: address of tail
@	R3: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: Contains the number of nodes in the list (list length) 
@ All registers are preserved as per AAPCS.

LL_createNodeFF:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS required registers
	mov		r4, r0					@ Copy argument address into r4; not used
	mov		r5, r1					@ Copy head to r5
	mov		r6, r2					@ Copy tail to r6
	mov		r10, r3					@ Copy list length to r10

	@ OPEN READ-FROM FILE ; NEED TO ERROR CHECK IF NO FILE??
	MOV 	R7, #5					@ r7 = #5 : Open file code
	LDR 	R0, =inputFile  		@ Open the inputFile to be read from "input.txt"
	MOV 	R1, #00        			@ R1 = #00 : "read only"
	SVC 	0
	@ R0 contains the "int fileHandle"
	MOV 	R4, R0    				@ Temporarily store fileHandle

	@ INITIALIZE COUNTER
	mov		r11, #0					@ Initialize counter to 0
	
createNodeFFloop:	
	@ READ INPUTFILE	
	MOV 	R7, #3    				@ R7 = #3 means "to read"
	MOV  	R0, R4   				@ Move the fileHandle back into R0
	ldr		r1, =cBuff				@ Load address of address to store char
	MOV 	R2, #1   				@ # of bytes to be read
	SVC  	0        				@ Do the thing.
	mov		r7, r0					@ Store result to r7

	@ LOAD STRING BUFFER
	ldr		r8, =cBuff			@ Load pointer to char from inputFile
	ldrb	r8, [r8]			@ Dereference to get byte
	
	@ COMPARE FOR END OF STRING, BRANCH TO CREATE NODE IF SO
	cmp		r8, #0xa			@ Compare r8 to 10 (\n = 10 = 0x0a)	
	ldreq	r9, =szStrBuff		@ Load pointer to string buffer
	moveq	r1, #0				@ Load 0 to r1
	streqb	r1, [r9, r11]		@ Load 0 in replace of \n  
	beq		fileCreateNode		@ IF r0 == 10, branch to create a node

	@ COMPARE FOR END OF FILE, BRANCH TO CREATE NODE IF SO
	cmp		r7, #0				@ Compare r7 (bytes read) to 0
	beq		fileCreateNode		@ If 0, branch to final create node

	@ ELSE STORE BYTE, COMPARE FOR END OF FILE 
	ldr		r9, =szStrBuff		@ Load pointer to string buffer
	strb	r8, [r9, r11]		@ Load character into string buffer
	
	@ INCREMENT COUNTER, & LOOP FOR NEXT CHAR
	add		r11, #1				@ Increment counter
	b		createNodeFFloop	@ Loop back to get next line/node
 
	@ CREATE NODE & LOOP
fileCreateNode:
	@ ADD 0 TO END OF STRING 
	add		r11, #1				@ Increment counter
	mov		r8, #0				@ Load r8 with 0
	ldr		r0, =szStrBuff		@ Load pointer to string buffer
	strb	r8, [r0, r11]		@ Load character into string buffer
	
	@ COPY INPUT TO DYNAMIC MEMORY 
	bl		String_Length		@ Get the length of input (bytes) and put in r0
	add		r0, #1				@ Add one for string end 0
	bl		malloc				@ Allocate memory and put address in r0
	mov		r1, r0				@ Copy new address to r1
	ldr		r0, =szStrBuff		@ Copy input back into r0
	bl		String_copy			@ Copy input string to new address (r1) 
	mov		r0, r1				@ Move copied input to r0

	mov		r1, r5				@ Load head
	mov		r2, r6				@ Load tail
	mov		r3, r10				@ Load list length
	bl		LL_createNode		@ Branch to create Node
	mov		r10, r3				@ Move list length to r10

	@ CLEAR STRING BUFFER
	mov		r2, #0				@ Setup counter
	mov		r3, #0				@ Setup clearing value
clearAddVarR1: 
	cmp		r2, #512			@ Compare counter to strBuff length
	bgt		continueFF			@ If counter > StrBuff, end
	ldr		r0, =szStrBuff		@ Load address of string pointer
	strb	r3, [r0, r2]		@ Else, store 0 in next byte
	add		r2, #1				@ Increment counter
	b		clearAddVarR1		@ Loop again

continueFF:
	@ COMPARE FOR END OF FILE & END IF SO
	cmp		r7, #0				@ Compare r0 to 0
	beq		endCreateFF			@ If 0, branch to close file & end
	
	@ ELSE RESET COUNTER, LOOP
	mov		r11, #0				@ Reset counter to null
	b		createNodeFFloop	@ Continue to loop

endCreateFF:
	@ R0 contains the "int fileHandle"
	mov		r0, r4	@ Close the file
	MOV 	R7, #6  @ R7 = #6 means "to close the file"
	SVC 	0       @ Do the thing
	
endFF:
	mov		r0, r10					@ Load number of nodes made
	pop 	{r4-r8, r10, r11, LR}	@ Pop AAPCS required registers to stack to save them
	bx 		lr						@ Return to calling program

@-------------------------------------------------------------------------------------------------------------
/* -- Subroutine: LL_deleteNode -- */
@ Purpose:  This subroutine will delete a node at an index if it exists. If an invalid index is given,
@ the subroutine will return a -1. List length is updated following deletion.

@	PRECONDITIONS:
@ 	R0: node index to be deleted
@	R1: address of head
@	R2: address of tail
@	R3: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: Contains the number of nodes in the list (list length)
@	R1: Returns the head of the list with the node added
@	R2: Returns the tail of the list pointing to the newly added node
@ All registers are preserved as per AAPCS.

LL_deleteNode:
	@ SETUP
	push 	{r4-r11, LR}			@ push AAPCS required registers
	mov		r4, r0					@ Copy argument address into r4
	mov		r5, r1					@ Copy head to r5
	mov		r6, r2					@ Copy tail to r6
	mov		r10, r3					@ Copy list length to r10
	mov		r3, #0					@ Set counter to 0
	ldr		r0, [r5]				@ Deference head into r0
	mov		r9, r0					@ Copy first node address into r9

deleteNode_loop:
	@ SEARCH LIST FOR NODE TO BE DELETED
	add		r3, #1					@ Increment counter
	
	@ CHECK IF NODE FOUND
	cmp		r4, r3					@ Check if counter == node index
	beq		deleteNode_cont			@ If counter == node index, goto deleteNode_cont
	
	@ CHECK IF END OF LIST REACHED
	cmp		r3, r10					@ Check if counter > list length
	bgt		deleteNode_err			@ If counter > length, goto deleteNode_err
	
	@ LOAD NEXT NODE ADDRESS
	mov		r9, r0					@ Copy current node into r9
	ldr		r0, [r0, #4]			@ Load node.next into r0
	b		deleteNode_loop			@ Goto deleteNode_loop
	
deleteNode_err:
	mov		r3, #-1					@ Set r3 to -1 on indicate invalid indexOf_1_end
	b 		deleteNode_end			@ goto deleteNode_end

deleteNode_cont:
	@ DECREMENT LIST LENGTH
	sub		r10, #1					@ Length = Length - 1
	
	@ PRESERVE LINKS
	mov		r7, r0					@ Copy node to be deleted into r7
	ldr		r8, [r7, #4]			@ Copy node.next into r8
	
	@ DELETE DATA AND NODE
	ldr		r0, [r7]				@ Copy node.data into r0
	bl		free					@ Delete node.data
	mov		r0, r7					@ Copy node address into r0
	bl		free					@ Delete node
	
	@ RE-LINK LIST IF NEEDED
	cmp		r9, #0					@ Check if there is an index-1
	strne	r8, [r9, #4]			@ If there is an index-1, store node index+1 into it
	
	@ CHECK HEAD
	mov		r0, r5					@ Load head address into r0
	ldr		r0, [r0]				@ Deference head
	cmp		r0, #0					@ Check if head == null
	streq	r8, [r5]				@ If head == null, store index+1  into head
	
	@ CHECK TAIL
	mov		r0, r6					@ Load tail address into r0
	ldr		r0, [r0]				@ Deference tail
	cmp		r0, #0					@ Check if tail == null
				@cmpeq	r9, #0					@ If tail == null, check if index-1 exists
	streq	r9, [r6]				@ If tail == null, point tail to index-1

deleteNode_end:
	mov		r1, r5					@ Load address of head into r1
	mov		r2, r6					@ Load address of tail into r2
	mov		r0, r10					@ Copy updated list length to r0
	pop 	{r4-r11, LR}			@ Pop AAPCS required registers to stack to save them
	bx 		lr						@ Return to calling program

@-------------------------------------------------------------------------------------------------------------
/* -- Subroutine: LL_searchNode -- */
@ Purpose:  This subroutine will iterate through a list and return the contents
@ of the found node. INPUT MUST ERROR-CHECKED to avoid out-of-bounds errors.

@	PRECONDITIONS:
@ 	R0: Contains search string
@	R1: Contains address of node pointer (pointed to by head)
@	R2: Contains length of list
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: Contains address of node.data

@ All registers are preserved as per AAPCS.

LL_searchNode:
	@ SETUP
	push 	{r4-r11, LR}			@ push AAPCS required registers
	mov		r4, r0					@ Copy argument (search string) into r4 
	mov		r5, r1					@ Copy argument (node.data) into r5 
	mov		r6, r2					@ Copy argument (length list) to r6
	bl		String_toUpperCase		@ Change r0 (search string) to upper case
	mov		r7, #1					@ Set r7 to 1 (counter)

searchNode_loop:
@ COPY NEW NODE 
@ldr		r0, [r5]				@ Dereference node to get node.data into r0
@ldr		r1, =szStrBuff			@ Load address of string buffer for copying
	
	@ CLEAR STRING BUFFER
	mov		r2, #0				@ Setup counter
	mov		r3, #0				@ Setup clearing value
clearAddVarR2: 
	cmp		r2, #512			@ Compare counter to strBuff length
	bgt		searchNode_loop_upper			@ Goto searchNode_loop_upper
	ldr		r0, =szStrBuff		@ Load address of string pointer
	strb	r3, [r0, r2]		@ Else, store 0 in next byte
	add		r2, #1				@ Increment counter
	b		clearAddVarR2		@ Loop again
	
	@ CONVERT STRING TO SEARCH TO UPPER CASE
searchNode_loop_upper:
	ldr		r0, [r5]				@ Dereference node to get node.data into r0
	ldr		r1, =szStrBuff			@ Load address of string buffer for copying
	bl		String_copy				@ Copy node.data for toUpperCase
	mov		r0, r1					@ Copy copied string address from r1 to r0
	bl		String_toUpperCase		@ Change node.data to uppercase
	mov		r1, r4					@ Load search string into r1
	
	@ COMPARE STRINGS
	bl		String_indexOf_3 @; r0/r1 - string pointers. Change to uppercase first. r0 has index where found
	
	@ CHECK FOR MATCH
	cmp		r0, #0					@ Compare r0 (return index) to 0
	blt		searchNode_loop_inc		@ If return index < 0, goto searchNode_loop_inc
	
	@ PRINT MATCHING NODE
	ldr		r0, [r5]				@ Dereference node to get node.data into r0 
	bl		putstring				@ Print found node to console
	ldr		r0, =szNewLine			@ Load address of newline
	bl		putstring				@ Print newline to console

searchNode_loop_inc:
	@ INCREMENT COUNTER AND CHECK FOR END OF LIST
	add		r7, #1					@ Increment counter
	cmp		r7, r6					@ Compare counter to length
	bgt		searchNode_end			@ If counter > length, goto searchNode_end
	
	@ LOAD NEXT NODE
	ldr		r5, [r5, #4]			@ Load node.next into r5
	b		searchNode_loop			@ Goto searchNode_loop
	
		@beq		searchNode_end			@ If counter == index, goto searchNode_end
		@add		r3, #1					@ Else increment counter
		@ldr		r2, [r2, #4]			@ Load node.next into r2
		@ldr		r1, [r2]				@ Dereference to load node.data into r1
		@b		searchNode_loop			@ Goto searchNode_loop
	
	
@searchNode_NF:
	@ldr 	r0, =szNotFound			@ Load message
	@bl		putstring				@ Print message to console
	@b		searchNode_end			@ goto searchNode_end

searchNode_end:
	mov		r0, r5					@ Load node.data (string pointer) into r0
	pop 	{r4-r11, LR}			@ Pop AAPCS required registers to stack to save them
	bx 		lr						@ Return to calling program


@-------------------------------------------------------------------------------------------------------------
/* -- Subroutine: LL_saveFile -- */
@ Purpose:  This subroutine will save the nodes created to an output
@ file.    

@	PRECONDITIONS:
@	R0: address of head
@	R1: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	NONE - void function
@ All registers are preserved as per AAPCS.

LL_saveFile:
	@ SETUP
	push 	{r4-r8, r10, r11, LR}	@ push AAPCS required registers
	mov		r4, r0					@ Copy head to r4
	mov		r5, r1					@ Copy list length to r5
	ldr		r6, [r4]				@ Deference head to get first node
	mov		r10, #1					@ Set counter to 1 

	@ CHECK NODE LIST.  IF NO NODES EXIST, EXIT
	cmp		r5, #0					@ Check if length of list <= 0
	ldrle	r0, =szNoList			@ If length of list <= 0, load message
	blle	putstring				@ If length of list <= 0, print message
	ble		saveEnd					@ If length of list <= 0, go to saveEnd

	@ OPEN FILE "Output.txt"
	LDR 	R0, =filename  			@ R0 contains the file descriptor
	MOV 	R7, #5         			@ R7 = #5 means "to open" (the file specified in R0)
	MOV		R1, #01101     			@ R1 = #01101 : #01 "write only" 
	@ | 0100 "create if it isn't there" | 01000 "Truncate existing file"
	MOV 	R2, #0777      			@ R2 contains the linux permissions (chmod)
	SVC 	0              			@ Do the thing.
	@ R0 contains the "int fileHandle" returned from opening the file
	mov		r8, r0					@ Store address of int fileHandle

	// Use list length as counter. 

saveFile_loop:
	@ COMPARE NODES, EXIT IF AT END OF LOOP
	cmp		r10, r5					@ Compare counter to list length
	bgt		saveFileEnd				@ Branch if counter > list length

	@ SET UP FOR SAVE 
	mov		r1, r6					@ Move data pointer to r1
	ldr		r1, [r1]				@ Dereference for address
	mov		r11, r1					@ Move address to r11 to preserve location ;MAY NOT NEED (done bc string_length may modify)
	mov		r0, r1					@ Load address of string to count
	bl		String_Length			@ Link to count bytes to be written
	mov		r2, r0					@ Move string count t r2 for save node
	
	@ SAVE NODE
	MOV 	R7, #4         			@ R7 = #4 means "to write"
	mov		r0, r8					@ Reinstate int fileHandle
	mov 	r1, r11  				@ R1 is the string to be written to the file  ;NAY NOT NEED
	SVC 	0             			@ Do the thing.
	
	@ SAVE NEW LINE STRING
	cmp		r10, r5					@ Compare counter to list length
	beq		saveFileEnd				@ If at end of file, branch & don't add newline
	mov		r0, r8					@ Reinstate int fileHandle  
	MOV R7, #4         				@ R7 = #4 means "to write"
	LDR R1, =szNewLine				@ R1 is the string to be written to the file
	MOV R2, #1        				@ This specifies the # of bytes to be written
	SVC 0              				@ Do the thing.

	@ SET UP POINTER FOR LOOP
	ldr		r6, [r6, #4]			@ Load node.next into r6 (advance pointer)
	
	@ INCREMENT COUNTER & STORE FILE NEXT LOCATION TO r8
	add		r10, #1					@ Increment counter
	b		saveFile_loop			@ Branch to beginning of loop

saveFileEnd:
	mov		r0, r8					@ R0 contains the "int fileHandle"
	MOV 	R7, #6  				@ R7 = #6 means "to close the file"
	SVC 	0       				@ Do the thing
saveEnd:
	pop 	{r4-r8, r10, r11, LR}	@ Pop AAPCS required registers to stack to save them
	bx 		lr						@ Return to calling program
	
@-------------------------------------------------------------------------------------------------------------
/* -- Subroutine: LL_memUsed -- */
@ Purpose:  This subroutine will calculate the total memory in bytes consumed by the linked list

@	PRECONDITIONS:
@	R0: address of head
@   R1: address of tail
@	R2: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: The amount of bytes consumed by the list
@ All registers are preserved as per AAPCS.

LL_memUsed:
	push 	{r4-r11, LR}			@ push AAPCS required registers
	@ CHECK FOR EMPTY LIST
	cmp		r2, #0					@ Check if list length == 0
	moveq	r8, #0					@ If list length == 0, set amount to 0
	beq		LL_memUsed_end			@ If list length == 0, goto LL_memUsed_end
	
	@ SETUP
	mov		r4, r0					@ Move head to r4
	mov		r5, r1					@ Move tail to r5
	mov		r6,	r2					@ Move list length to r6
	mov		r7, #1					@ Set index to 1
	mov		r8, #0					@ Set amount counter to 0
	
	@ COUNT MEM ALLOC FOR HEAD/TAIL
	add		r8, #8					@ Add 8 bytes for the head and tail
	ldr		r4, [r4]				@ Dereference head to get first node

LL_memUsed_loop:	
	@ LOOP THROUGH LIST ASSESSING EACH NODE
	cmp		r7, r6					@ Check if index > length
	bgt		LL_memUsed_end			@ If index > length, goto LL_memUsed_end
	add		r8, #8					@ Add 8 bytes for the node itself to amount
	ldr		r0, [r4]				@ Dereference node.data into r0
	bl		String_Length			@ Get length of string in chars (bytes)
	add		r8, r0					@ Add string_length to amount
	add		r8, #1					@ Add one byte for null terminator
	ldr		r4, [r4, #4]			@ Load node.next into r4 (advance pointer) ;ADDED
	add		r7, #1					@ Increment index
	b		LL_memUsed_loop			@ Goto LL_memUsed_loop

LL_memUsed_end:
	mov		r0, r8					@ Move amount to r0
	pop 	{r4-r11, LR}			@ Pop AAPCS required registers to stack to save them
	bx 		lr						@ Return to calling program

@---TRUE-END--------------------------------------------------------------------------------------------------
	.end
