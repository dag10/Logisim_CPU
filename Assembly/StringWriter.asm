.org 800h; 
JMP (Start);

; DATA
	; Constant 1
	One:
	.word 1;
	
	; String to write
	String:
	.string "Hello Drew!";
	.word 13;
	.string "How are you?";
	.word 3;
	
	; String length
	StringLength:
	.word 25;
	
	; String index
	StringIndex:
	.word 0;
	
; PROGRAM
Start:
	LDM (StringLength);
	STM (StringIndex);
	LoopStart:
		LDM (String);
		STM c02h;
		LDM (LoopStart);
		ADD (One);
		STM (LoopStart);
		LDM (StringIndex);
		SUB (One);
		STM (StringIndex);
		STM c01h;
		JPZ (DoneString);
		JMP (LoopStart);
		DoneString:
			LDM (LoopStart);
			SUB (StringLength);
			;ADD (One);
			STM (LoopStart);
			JMP (Start);