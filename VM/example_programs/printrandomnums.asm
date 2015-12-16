.org 000h; Program originates in RAM location 000h
.stack FFDh; Bottom of stack

; I/O Ports
.map Display, FFFh; Terminal display for output
.map Keyboard, FFFh; Buffered keyboard for input
.map DevURandom, FFEh; Data from /dev/urandom

JMP (Start); Skip over data / functions


; PROGRAM VARIABLES
	Instr_LDM:
		LDM 000h;
	Instr_STM:
		STM 000h;


; PROGRAM FUNCTIONS
	PrintLine:
		JMP (PrintLineInit);
			PrintLineRet:
				.word 0000h; Return address
		PrintLineInit:
			POP; Pops return address
			STM (PrintLineRet);
			CALL (Print);
		PrintLineDone:
			LDI 13;
			STM (Display); Add a new line
			JPI (PrintLineRet); Return
	Print:
		JMP (PrintInit);
			PrintRet:
				.word 0000h; Return Address
		PrintInit:
			POP; Pops return address
			STM (PrintRet);
			POP; Pops pointer to string
			ADD (Instr_LDM);
			STM (PrintLoop); Update load command to start at string
		PrintLoop:
			LDM 000h; String address to load
			JPZ (PrintDone); Return when string is done
			STM (Display); Write to display
			INC (PrintLoop); Increment string pointer
			JMP (PrintLoop); Loop again
		PrintDone:
			JPI (PrintRet); Return
	PrintNumberWithNewline:
		JMP (PrintNumberInit);
			ASCII_NumOffset:
				.word 0030h;
			PrintNumberRet:
				.word 0000h;
			PrintNumber_HexNumber:
				.word 0000h;
			PrintNumber_Places:
				.word 10000, 1000, 100, 10, 1, 0;
			PrintNumber_DigitTimes:
				.word 0000h;
			PrintNumber_PlainPlaceIndex:
				.word 2(PrintNumber_Places);
			PrintNumber_Place:
				.word 0005h;
			PrintNumber_TempChar:
				.word 0000h;
			PrintNumber_HadNonZero:
				.word 0000h;
		PrintNumberInit:
			POP; Pop return address
			STM (PrintNumberRet);
			POP; Pop hex number
			STM (PrintNumber_HexNumber);
			LDI 0;
			STM (PrintNumber_DigitTimes);
			LDM (PrintNumber_PlainPlaceIndex);
			STM (PrintNumberPlaceIndex);
			LDI 5;
			STM (PrintNumber_Place);
			LDI 000h;
			STM (PrintNumber_HadNonZero);
		PrintNumberLoop:
			LDM (PrintNumber_HexNumber);
			PrintNumberPlaceIndex:
			SUB (PrintNumber_Places);
			JPM (PrintNumberNextPlace);
			STM (PrintNumber_HexNumber);
			INC (PrintNumber_DigitTimes);
			JMP (PrintNumberLoop);
		PrintNumberNextPlace:
			LDM (PrintNumber_DigitTimes);
			;PUSH; Push digit;
			STM (PrintNumber_TempChar);
			LDM (PrintNumber_TempChar);
			ADD (PrintNumber_HadNonZero);
			JPZ (PrintNumberNextPlaceSkipDisplay);
			;LDM (PrintNumber_HadNonZero);
			LDM (PrintNumber_TempChar);
			JPZ (PrintNumberNextPlaceSkipNonZero);
			LDI FFFh;
			STM (PrintNumber_HadNonZero);
			PrintNumberNextPlaceSkipNonZero:
			LDM (PrintNumber_TempChar);
			ADD (ASCII_NumOffset);
			STM (Display);
			PrintNumberNextPlaceSkipDisplay:
			LDM (PrintNumber_HexNumber);
			;JPM (PrintNumberDone);
			;JPZ (PrintNumberDone);
			LDI 0;
			STM (PrintNumber_DigitTimes);
			INC (PrintNumberPlaceIndex);
			DEC (PrintNumber_Place);
			;JPZ (PrintNumberDisplay);
			JPZ (PrintNumberDone);
			JMP (PrintNumberLoop);
		PrintNumberDisplay:
			LDI 5;
			STM (PrintNumber_Place);
		PrintNumberDisplayLoop:
			POP;
			ADD (ASCII_NumOffset);
			STM (Display);
			DEC (PrintNumber_Place);
			JPZ (PrintNumberDone);
			JMP (PrintNumberDisplayLoop);
		PrintNumberDone:
			LDI 13;
			STM (Display); Add a new line
			JPI (PrintNumberRet); Return
	PrintRandomNumber:
		JMP (PrintRandomNumberInit);
			PrintRandomNumberRet:
				.word 0000h; Return address
			PrintRandomNumberString:
				.string "Random number: ";
		PrintRandomNumberInit:
			POP; Pop return address
			STM (PrintRandomNumberRet);
			
			LDI (PrintRandomNumberString);
			PUSH;
			CALL (Print);
			LDM (DevURandom);
			PUSH;
			CALL (PrintNumberWithNewline);
		PrintRandomNumberDone:
			JPI (PrintRandomNumberRet); Return


; PROGRAM START
	Start:
		CALL (PrintRandomNumber);
		JMP (Start);

	End:
		.word 0000h;
