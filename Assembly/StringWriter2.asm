.org 800h;
JMP (ProgramStart);

; DATA
	Message:
		.string "Type something!";
		.word 13;
		.string "> ";
		.word 0;
		
; PROGRAM
ProgramStart:
	StringLoop:
		StringIndex:
		LDM (Message);
		JPZ (DisplayInput);
		STM C02h;
		INC (StringIndex);
		JMP (Message);
	DisplayInput:
		LDM C02h;
		JPZ (DisplayInput);
		STM C02h;
		JMP (DisplayInput);
	Done:
		JMP (Done);