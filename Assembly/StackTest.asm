.org 800h;
JMP (ProgramStart);

; PROGRAM DATA
	Text:
		.string "Drew";
		.word 0;
	
	TextLength:
		.word 0;

; PROGRAM START
ProgramStart:
	TextLoopStart:
		TextPointer:
		LDM (Text);
		JPZ (WriteStack);
		STM C02h;
		PUSH;
		INC (TextPointer);
		INC (TextLength);
		JMP (TextLoopStart);
	WriteStack:
		LDI 13;
		STM C02h;
		STM C02h;
		WriteLoop:
			LDM (TextLength);
			JPZ (EndLoop);
			POP;
			STM C02h;
			DEC (TextLength);
			JMP (WriteLoop);
	EndLoop:
		JMP (EndLoop);