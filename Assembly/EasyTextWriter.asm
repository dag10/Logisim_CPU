.org 800h;
JMP (ProgramStart);
; DATA
	WelcomeText:
		.string "Welcome to DrewOS!";
		.word 13;
		.string "    Type some text:";
		.word 13;
		.string "> ";
		.word 0;
		
	InputBuffer:
		.data 30;
		
	ReturnChar:
		.word 13;
		
	CurrentChar:
		.word 0;

; PROGRAM
ProgramStart:
	PrintLoop:
		; Load next char
		StringIndex:
		LDM (WelcomeText);
		; If zero, stop and go onto next part
		JPZ (ReceiveLoop);
		; Display char
		STM C02h;
		; Increment char load command
		INC (StringIndex);
		; Loop again
		JMP (PrintLoop);
	ReceiveLoop:
		; Load char
		LDM C02h;
		; Back it up
		STM (CurrentChar);
		; If nothing, try again
		JPZ (ReceiveLoop);
		; If it is the return character, go on to display
		XOR (ReturnChar);
		NOT;
		JPZ (DisplayString);
		; Reload origional char
		LDM (CurrentChar);
		; Add to buffer
		BufferIndex:
		STM (InputBuffer);
		; Display char
		STM C02h;
		; Increment write command
		INC (BufferIndex);
		; Loop again
		JMP (ReceiveLoop);
	DisplayString:
		; Load next char
		DisplayStringIndex:
		LDM (InputBuffer);
		; If zero, stop and go onto next part
		JPZ (EndLoop);
		; Display char
		STM C02h;
		; Increment char load command
		INC (DisplayStringIndex);
		; Loop again
		JMP (DisplayString);
	EndLoop:
		JMP (DisplayDone);
		DoneMsg:
			.string "*";
		DisplayDone:
		LDM (DoneMsg);
		STM C02h;
		IdleLoop:
			JMP (IdleLoop);