/* -- RASM 4 -- */
@ This program will include a menu driver that serves as a text editor 
@ and saves the resulting text to a file.  There is an option to 
@ manually input a string or read it from an input file (input.txt).  
@ All additions are implemented as a linked list of strings.  The nodes 
@ can be added, deleted, or edited.
@-----------------------------------------------------------------------	

.data
	szStrBuff:	 .skip	512	@ Gives 512 bytes for string value
	szBytes:	 .skip	48	@ Gives 48 bytes for string value
	szNodes:	 .skip	48	@ Gives 48 bytes for string value
	iHead:		 .word	0	@ Initialize word to 0
	iTail:		 .word	0	@ Initialize word to 0
	iVal:		 .word	0	@ Initialize word to 0
	iBytes:		 .word	0	@ Initialize word to 0
	iNodes:		 .word	0	@ Initialize word to 0
	.balign 			4	@ Align for performance
	cCr:		 .byte	10	@ Moves the cursor down 
	.balign 			2	@ Align for performance
	szMenuTitle: .asciz	"\t\t\t\tRASM4 TEXT EDITOR\n\n"
	szMenuMem:   .asciz	"\t\tData Structure Memory Consumption: "
	szMenuBytes: .asciz	" bytes\n"
	szMenuNodes: .asciz	"\t\tNumber of nodes: "
	szMenu1:	 .asciz	"\n\n<1> View all strings\n\n"
	szMenu2:	 .asciz	"<2> Add string\n"
	szMenu2a:	 .asciz	"\t<a> from Keyboard\n"
	szMenu2b:	 .asciz	"\t<b> from File. Static file named input.txt\n\n"
	szMenu2Sub:	 .asciz "Select 1 for Keyboard, 2 for File: "
	szMenu2input:.asciz	"Please input the string: "
	szMenu3:	 .asciz	"<3> Delete string.\n\n"
	szMenuIndex: .asciz	"\tEnter index number: "
	szMenu4:	 .asciz	"<4> Edit string.\n\n"
	szMenu5:	 .asciz	"<5> String search.\n\n"
	szMenu6:	 .asciz	"<6> Save File (output.txt).\n\n"
	szMenu7:	 .asciz	"<7> Quit.\n\n"
	szSelection: .asciz	"Please enter your Main Menu selection: "
	szError:	 .asciz	"\nINCORRECT INPUT.  Please try again.\n\n"
	szBadIndex:	 .asciz	"\nINVALID INDEX. Please try again.\n\n"
	szClear:	 .asciz	"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	szMsg1:		 .asciz	"ALL STRINGS:\n"
	szMsg2:		 .asciz	"String added\n\n"
	szMsg2.2:	 .asciz	"Strings(s) added from file\n\n"
	szMsg3:		 .asciz	"String deleted\n\n"
	szMsg4:		 .asciz	"String edited.\n\n"
	szMsg5:		 .asciz	"Strings found:\n\n"
	szMsg6:		 .asciz	"File saved.\n\n"
	szMsg7:		 .asciz	"\nThanks for using our program!"
	szNameStr1:  .asciz "Name:  Adam Hurd\n"
	szNameStr2:	 .asciz "Name:  Rebecca Martin\n"
	szClass: 	 .asciz	"Class: CS 3B\n"
	szProg: 	 .asciz	"Lab:   RASM 4\n"
	szDate:		 .asciz	"Date:  TBD\n\n"
	szNewLine:	 .asciz "\n"
	
@-----------------------------------------------------------------------	

.text
	.global _start  		@ Provide program starting address to Linker

@---OUTPUT-HEADER-------------------------------------------------------	

_start: 
	@ OUTPUT HEADER
	ldr 	r0, =szNameStr1		@ DEST: Point to szNameStr1
	bl 		putstring			@ B&L: Displays string to console
	ldr 	r0, =szNameStr2		@ DEST: Point to szNameStr2
	bl 		putstring			@ B&L: Displays string to console
	ldr 	r0, =szClass		@ DEST: Point to szClass
	bl 		putstring			@ B&L: Displays string to console
	ldr 	r0, =szProg			@ DEST: Point to szProg
	bl 		putstring			@ B&L: Displays string to console
	ldr 	r0, =szDate 		@ DEST: Point to szDate
	bl 		putstring			@ B&L: Displays string to console

@---PRINT-MENU----------------------------------------------------------	

menu:
	ldr		r0, =szMenuTitle	@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenuMem		@ Points to message to print
	bl		putstring			@ Displays string to console
	@ CALCULATE BYTES
	ldr		r0, =iHead			@ Load address of head
	ldr		r1, =iTail			@ Load address of tail
	ldr		r2, =iNodes			@ Load address of iNodes
	ldr		r2, [r2]			@ Dereference iNodes to get list length
	bl		LL_memUsed			@ Get amount of mem used: returns to r0
	
	ldr		r1, =szBytes		@ Points to value to save to
	bl		intasc32			@ Change int to ascii value
	ldr		r0, =szBytes		@ Point to string to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenuBytes	@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenuNodes	@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =iNodes			@ Points to value to print
	ldr		r0, [r0]			@ Load value to r0
	ldr		r1, =szNodes		@ Points to value to save to
	bl		intasc32			@ Change int to ascii value
	ldr		r0, =szNodes		@ Point to string to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu1		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu2		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu2a		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu2b		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu3		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu4		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu5		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu6		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szMenu7		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szSelection	@ Points to message to print
	bl		putstring			@ Displays string to console
	
@---GET-DATA-FROM-USER-&-BRANCH-----------------------------------------

getData: 
	@ READ IN DATA
	ldr 	r0, =szStrBuff		@ DEST: Point to szStrBuff
	mov 	r1, #512			@ Max number of bytes in r1 buffer
	bl		getstring			@ B&L: Gets data from keyboard
	bl		ascint32			@ Convert answer to an int

	@ BRANCH ACCORDING TO SELECTION
	cmp		r0, #7				@ Compare to 7
	beq		end				@ End program if done
	
	cmp		r0, #1				@ If option 1, go to viewNodes
	beq		viewNodes			@ Branch to view strings

	cmp		r0, #2				@ If option 2, go to createNode
	beq		createNode			@ Branch to createNode
	
	cmp		r0, #3				@ If option 3, go to deleteNode
	beq		deleteNode			@ Branch to deleteString
	
	cmp		r0, #4				@ If option 4, go to editNode 
	beq		editNode			@ Branch to editNode
	
	cmp		r0, #5				@ If option 5, go to searchNodes
	beq		searchNodes			@ Branch to searchNodes
	
	cmp		r0, #6				@ If option 6, go to saveFile 
	beq		saveFile			@ Branch to saveFile

	@ ELSE, PRINT ERROR MESSAGE, REQUESTS NEW INPUT
	ldr		r0, =szError		@ Load error message if incorrect entry
	bl		putstring			@ Displays string to console
	ldr		r0, =szSelection	@ Clear screen
	bl		putstring			@ Displays string to console
	b		getData				@ Loops back to getData
	 
@---1-VIEW-NODES--------------------------------------------------------	

@	PRECONDITIONS:
@	R0: address of head
@	R1: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	NONE - void function

viewNodes:
	ldr		r0, =szMsg1			@ Points to message to print
	bl		putstring			@ Displays string to console

	ldr		r0, =iHead			@ Load head
	ldr		r1, =iNodes			@ Load nodes counter
	ldr		r1, [r1]			@ Load value of r2 into r2
	bl		LL_viewNodes		@ Branch to view strings

	@ END BY CLEARING SCREEN AND REPRINTING MENU
	ldr		r0, =szClear		@ Clear screen
	bl		putstring			@ Print clear option
	b		menu				@ Branch back to menu

@---2-CREATE-NODE-------------------------------------------------------	

@	PRECONDITIONS:
@ 	R0: address of data to be added (pointer)
@	R1: address of head
@	R2: address of tail
@	R3: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: Contains the number of nodes in the list (list length)
@	R1: Returns the head of the list with the node added
@	R2: Returns the tail of the list pointing to the newly added node
@	R3: Returns the current length of the list as an integer
	
createNode:
	@ PRINT SECOND SELECTION REQUEST
	ldr		r0, =szMenu2Sub		@ Points to message to print
	bl		putstring			@ Displays string to console

	@ GET DATA
	ldr 	r0, =szStrBuff		@ Address to accept input
	mov 	r1, #512			@ Max number of bytes in r1 buffer
	bl		getstring			@ B&L: Gets data from keyboard
	bl		ascint32			@ Change answer to a number

	@ COMPARE TO SELECTION
	cmp		r0, #1				@ If 1, create node from keyboard input
	beq		keyboard			@ Branch to keyboard
	cmp		r0, #2				@ If 2, create node from input file
	beq		inputFile			@ Branch to inputFile
	
	@ IF INCORRECT SELECTION, PRINT ERROR MESSAGE AND LOOP TO CREATENODE
	ldr		r0, =szError		@ Points to message to print
	bl		putstring			@ Displays string to console
	b		createNode			@ Else branch back to createNode
	
keyboard:
	@ READ IN DATA FOR KEYBOARD ENTRY
	ldr		r0, =szMenu2input	@ Print command 
	bl		putstring			@ Print clear option
	ldr		r0, =szStrBuff		@ Address to accept input
	mov		r1, #512			@ Max number of bytes in r1 buffer
	bl		getstring			@ B&L: Gets data from keyboard

	@ COPY INPUT TO DYNAMIC MEMORY
	mov		r4, r0				@ Copy input address for safekeeping
	bl		String_Length		@ Get the length of input (bytes) and put in r0
	add		r0, #1				@ Add one to string length to account for null term
	bl		malloc				@ Allocate memory and put address in r0
	mov		r1, r0				@ Copy new address to r1
	mov		r0, r4				@ Copy input back into r0
	bl		String_copy			@ Copy input string to new address (r1) 
	mov		r0, r1				@ Move copied input to r0
	
	@ LOAD REGISTERS AND CALL CREATENODE
	ldr		r1, =iHead			@ Address of head
	ldr		r2, =iTail			@ Address of tail
	ldr		r3, =iNodes			@ Number of Nodes in LL
	ldr		r3, [r3]			@ Load value to r3
	bl		LL_createNode		@ B&L to LL_createNode
	
	@ SAVE DATA AFTER CALL
	ldr		r4, =iNodes			@ Load address of pointer for # of nodes
	str		r3, [r4]			@ Stores value to pointer

	@ END BY CLEARING SCREEN AND REPRINTING MENU
	ldr		r0, =szMsg2			@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szClear		@ Clear screen
	bl		putstring			@ Print clear option
	b		menu				@ Branch back to menu

inputFile: 
@	PRECONDITIONS:
@	R1: address of head
@	R2: address of tail
@	R3: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: Contains the number of nodes in the list (list length) 

	@ LOAD REGISTERS AND CALL CREATENODE
	ldr		r1, =iHead			@ Address of head
	ldr		r2, =iTail			@ Address of tail
	ldr		r3, =iNodes			@ Number of Nodes in LL
	ldr		r3, [r3]			@ Load value to r3
	bl		LL_createNodeFF		@ B&L to LL_createNode
	ldr		r4, =iNodes			@ Address of list length in LL
	str		r0, [r4]			@ Store number in iNodes
		
	@ END BY CLEARING SCREEN AND REPRINTING MENU
	ldr		r0, =szMsg2.2		@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szClear		@ Clear screen
	bl		putstring			@ Print clear option
	b		menu				@ Branch back to menu

@---3-DELETE-NODE-------------------------------------------------------	

deleteNode:
	@ ASK FOR INDEX # AND CLEAR SCREEN
	ldr		r0, =szMenuIndex	@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr 	r0, =szStrBuff		@ Address to accept input
	mov 	r1, #512			@ Max number of bytes in r1 buffer
	bl		getstring			@ B&L: Gets data from keyboard
	bl		ascint32			@ Change answer to a number
	ldr		r1, =iVal			@ Load value to store index
	str		r0, [r1]			@ Store value in iVal

	@ ERROR-CHECK INPUT
	cmp		r0, #0				@ Compare index to 0
	ble		deleteNode_error	@ If index <= 0, goto deleteNode_error
	ldr		r3, =iNodes			@ Number of Nodes in LL
	ldr		r3, [r3]			@ Load value to r3
	cmp		r0, r3				@ Compare index and length
	bgt		deleteNode_error	@ If index > length, goto deleteNode_error
	b		deleteNode_cont		@ Else goto deleteNode_cont
	
deleteNode_error:
	@ INVALID INDEX - PRINT ERROR MESSAGE AND GET NEW INPUT
	ldr		r0, =szBadIndex		@ Points to message to print
	bl		putstring			@ Displays string to console
	b		deleteNode			@ Goto deleteNode

deleteNode_cont:
	@ SETUP
	ldr		r1, =iHead			@ Address of head
	ldr		r2, =iTail			@ Address of tail
	ldr		r3, =iNodes			@ Number of Nodes in LL
	ldr		r3, [r3]			@ Load value to r3

	bl		LL_deleteNode		@ B&L: delete the node in position #iVal
	
	@ SAVE DATA AFTER CALL
	ldr		r4, =iNodes			@ Load address of pointer for # of nodes
	str		r0, [r4]			@ Stores value to pointer
	
	@ END BY CLEARING SCREEN AND REPRINTING MENU
	ldr		r0, =szMsg3			@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szClear		@ Clear screen
	bl		putstring			@ Print clear option
	b		menu				@ Branch back to menu

@---4-EDIT-NODE---------------------------------------------------------	

editNode:
	@ ASK FOR INDEX # AND CLEAR SCREEN
	ldr		r0, =szMenuIndex	@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr 	r0, =szStrBuff		@ Address to accept input
	mov 	r1, #512			@ Max number of bytes in r1 buffer
	bl		getstring			@ B&L: Gets data from keyboard
	bl		ascint32			@ Change answer to a number
	ldr		r1, =iVal			@ Load value to store index
	str		r0, [r1]			@ Store value in iVal
	
	@ ERROR-CHECK INPUT
	cmp		r0, #0				@ Compare index to 0
	ble		editNode_error		@ If index <= 0, goto editNode_error
	ldr		r3, =iNodes			@ Number of Nodes in LL
	ldr		r3, [r3]			@ Load value to r3
	cmp		r0, r3				@ Compare index and length
	bgt		editNode_error		@ If index > length, goto editNode_error
	
	@ SETUP FOR SEARCH
	ldr		r1, =iHead			@ Address of head
	ldr		r1, [r1]			@ Deference head to get first node
	ldr		r3, =iNodes			@ Number of Nodes in LL
	ldr		r3, [r3]			@ Load value to r3	
	mov		r4, #1				@ Set counter to 1
	
editNode_search:
	@ SEARCH FOR NODE
	cmp		r4, r0				@ Compare counter to search index
	beq		editNode_cont		@ If counter == index, goto editNode_cont
	add		r4, #1				@ Increment counter
	ldr		r1, [r1, #4]		@ Load node.next into r2
	b		editNode_search		@ Goto editNode_search
	
editNode_cont:
	mov		r6, r1				@ Load node address into r6
	
	@ READ IN DATA FOR KEYBOARD ENTRY
	ldr		r0, =szMenu2input	@ Print command 
	bl		putstring			@ Print clear option
	ldr		r0, =szStrBuff		@ Address to accept input
	mov		r1, #512			@ Max number of bytes in r1 buffer
	bl		getstring			@ B&L: Gets data from keyboard

	@ COPY INPUT TO DYNAMIC MEMORY
	mov		r4, r0				@ Copy input address for safekeeping
	bl		String_Length		@ Get the length of input (bytes) and put in r0
	bl		malloc				@ Allocate memory and put address in r0
	mov		r1, r0				@ Copy new address to r1
	mov		r0, r4				@ Copy input back into r0
	bl		String_copy			@ Copy input string to new address (r1) 
	mov		r4, r1				@ Move copied input to r4
	
	@ REMOVE OLD STRING AND INSERT NEW STRING
	ldr		r0, [r6]			@ Dereference node.data into r0
	bl		free				@ Deallocate old string
	str		r4, [r6]			@ Store new string ptr into node.data
	b		editNode_end		@ Goto editNode_end

editNode_error:
	@ INVALID INDEX - PRINT ERROR MESSAGE AND GET NEW INPUT
	ldr		r0, =szBadIndex		@ Points to message to print
	bl		putstring			@ Displays string to console
	b		editNode			@ Goto editNode

editNode_end:
	@ END BY CLEARING SCREEN AND REPRINTING MENU
	ldr		r0, =szMsg4			@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szClear		@ Clear screen
	bl		putstring			@ Print clear option
	b		menu				@ Branch back to menu

@---5-SEARCH-NODE-------------------------------------------------------	

@	PRECONDITIONS:
@ 	R0: address of string to search for (pointer)
@	R1: address of head
@	R2: address of tail
@	R3: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	R0: Contains the node number where found or -1 if not found.
@	R1: Returns the head of the list with the node added
@	R2: Returns the tail of the list pointing to the newly added node
@			//R3: Returns the current length of the list as an integer

searchNodes:
	@ GET SEARCH STRING
	ldr		r0, =szMenu2input	@ Print command 
	bl		putstring			@ Print clear option
	
	@ CLEAR STRING BUFFER
	mov		r2, #0				@ Setup counter
	mov		r3, #0				@ Setup clearing value
clearAddVarR2: 
	cmp		r2, #512			@ Compare counter to strBuff length
	bgt		searchNode_input	@ Goto searchNode_input
	ldr		r0, =szStrBuff		@ Load address of string pointer
	strb	r3, [r0, r2]		@ Else, store 0 in next byte
	add		r2, #1				@ Increment counter
	b		clearAddVarR2		@ Loop again
	
searchNode_input:
	ldr		r0, =szStrBuff		@ Address to accept input
	mov		r1, #512			@ Max number of bytes in r1 buffer
	bl		getstring			@ B&L: Gets data from keyboard
	mov		r4, r0				@ Copy input to r4 for safekeeping
	ldr		r0, =szMsg5			@ Load address of szMsg5
	bl		putstring			@ Print szMsg5 to console
	mov		r0, r4				@ Copy input back from r4
	
	@ SETUP FOR SEARCH
	ldr		r1, =iHead			@ Address of head
	ldr		r1, [r1]			@ Dereference to get first node address
	ldr		r2, =iNodes			@ Number of Nodes in LL
	ldr		r2, [r2]			@ Load value to r2	

	@ COMMIT SEARCH
	bl		LL_searchNode		@ Branch to LL_searchNode
	
	@ PRINT FOUND NODE
	@mov		r4, r0				@ Move found string pointer to r4
	@ldr		r0, =szMsg5			@ Points to message to print
	@bl		putstring			@ Displays string to console
	@mov		r0, r4				@ Move string pointer back to r0
	@bl		putstring			@ Print found node

	@ END BY CLEARING SCREEN AND REPRINTING MENU
	ldr		r0, =szClear		@ Clear screen
	bl		putstring			@ Print clear option
	b		menu				@ Branch back to menu

@---6-SAVE-FILE---------------------------------------------------------	
@	PRECONDITIONS:
@	R0: address of head
@	R1: length of list (integer)
@ 	LR: Contains the return address

@ 	POSTCONDITIONS/Returned register contents:
@ 	NONE - void function
@ All registers are preserved as per AAPCS.

saveFile:
	ldr		r0, =iHead			@ Load head
	ldr		r1, =iNodes			@ Load nodes counter
	ldr		r1, [r1]			@ Load value of r2 into r2
	bl		LL_saveFile			@ Branch to LL_safeFile

	@ END BY CLEARING SCREEN AND REPRINTING MENU
	ldr		r0, =szMsg6			@ Points to message to print
	bl		putstring			@ Displays string to console
	ldr		r0, =szClear		@ Clear screen
	bl		putstring			@ Print clear option
	b		menu				@ Branch back to menu

@---7-END-PROGRAM-------------------------------------------------------

end: 	
	ldr		r0, =szMsg7		@ Load message 7
	bl		putstring		@ Print message
	ldr 	r0, =cCr		@ Move cursor down a line
	bl 	putch
	ldr 	r0, =cCr		@ Move cursor down a line
	bl 	putch
	mov 	r0, #0			@ Exit Status code set to 0 indicates "normal completion"
	mov 	r7, #1			@ Service command code (1) will terminate this program
	svc 	0			@ Issue Linux command to terminate program

	.end
