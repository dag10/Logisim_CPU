.org 000h;
.stack 7FFh;
.map Display, C00h;

JMP (Start);
	PrintLine:
		JMP (PrintLineInit);
			PrintLineRet:
				.word 0000h; Return Address
			OrigPrintLineLoad:
				.word 9000h; Plain load command
			OrigPrintLineJump:
				.word b000h; Plain jump command
		PrintLineInit:
			POP; Pops return address
			STM (PrintLineRet);
			POP; Pops pointer to string
			ADD (OrigPrintLineLoad);
			STM (PrintLineLoop); Update load command to start at string
		PrintLineLoop:
			LDM 000h; String address to load
			JPZ (PrintLineDone); Return when string is done
			STM (Display); Write to display
			INC (PrintLineLoop); Increment string pointer
			JMP (PrintLineLoop); Loop again
		PrintLineDone:
			LDI 13;
			STM (Display); Add a new line
			JPI (PrintLineRet); Return
	String:
		.string "Hello World!";
	Start:
		LDI (String);
		PUSH;
		CALL (PrintLine);
		JMP (Start);