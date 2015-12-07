.org 800h; 
JMP (WriteString);

; DATA
	; Constant 1
	One:
	.word 1;
	
	; String to write
	String:
	.string "It's over...";
	.word 13;
	.string "NINE-THOUSAND!!!!!!";
	.word 3;
	
	; String length
	StringLength:
	.word 34;
	
	; String index
	StringIndex:
	.word 0;
	
; PROGRAM
Start:
	GetLoop:
		; DO CODE TO GET STRING AND LOAD IT INTO A BUFFER HERE
WriteString:
	LDM (StringLength);
	STM (StringIndex);
	WriteLoop:
		LDM (String);
		STM c02h;
		LDM (WriteLoop);
		ADD (One);
		STM (WriteLoop);
		LDM (StringIndex);
		SUB (One);
		STM (StringIndex);
		JPZ (DoneString);
		JMP (WriteLoop);
		DoneString:
			LDM (WriteLoop);
			SUB (StringLength);
			STM (WriteLoop);
			JMP (WriteString);