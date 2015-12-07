.org 800h;
JMP (ProgramStart);

; STACK OPERATIONS
	PushData:
		.word 0000h;
	StackReturn:
		.word 0000h;
	SPush:
		LDM (PushData);
		PushAddr:
		STM BFFh;
		DEC (PushAddr);
		DEC (PopAddr);
		LDM (PushData);
		JPI (StackReturn);
	SPop:
		INC (PushAddr);
		INC (PopAddr);
		PopAddr:
		LDM BFFh;
		STM (PushData);
		LDM (PushData);
		JPI (StackReturn);

; PROGRAM DATA
	Text:
		.string "Racecar";
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
		;PUSH
		 STM (PushData);
		 LDI (ReturnPoint);
		 STM (StackReturn);
		 JMP (SPush);
		  ReturnPoint:
		  LDM (PushAddr);
		  STM C01h;
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
			;POP
			 LDI (ReturnPoint2);
			 STM (StackReturn);
			 JMP (SPop);
			 ReturnPoint2:
			 STM C02h;
			 DEC (TextLength);
			 JMP (WriteLoop);
	EndLoop:
		JMP (EndLoop);