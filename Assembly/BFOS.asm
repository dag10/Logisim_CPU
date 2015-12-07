.org 400h; Program originates in RAM location 400h
.stack BFFh; Bottom of stack

; I/O Ports
.map Display, C02h; Terminal display for output
.map Keyboard, C02h; Buffered keyboard for input

.map BFCode, 001h; BF code location

JMP (Start); Skip over data / functions


; PROGRAM VARIABLES
	BFTape:
		.fill 200;
	;BFCode:
		; Reads in 5 characters, then prints them out in reverse.
		;.string ",>,>,>,>,.<.<.<.<."

		; Should increment by 2, then decrement by 1.
		;.string "++>[<+++[-]>]<-";

		; Hello world.
		.string "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.";

		; Fibbonacci.
		;.string ">++++++++++>+>+[[+++++[>++++++++<-]>.<++++++[>--------<-]+<<<]>.>>[[-]<[>+<-]>>[<<+>+>-]<[>+<-[>+<-[>+<-[>+<-[>+<-[>+<-[>+<-[>+<-[>+<-[>[-]>+>+<<<-[>+<-]]]]]]]]]]]+>>>]<<<]"

	; BF Symbols
	BFSymbolIncrement:
		.word 002bh; '+'
	BFSymbolDecrement:
		.word 002dh; '-'
	BFSymbolMoveLeft:
		.word 003ch; '<'
	BFSymbolMoveRight:
		.word 003eh; '>'
	BFSymbolWrite:
		.word 002eh; '.'
	BFSymbolRead:
		.word 002ch; ','
	BFSymbolBracketStart:
		.word 005bh; '['
	BFSymbolBracketEnd:
		.word 005dh; ']'

	Instr_LDM:
		LDM 000h;
	Instr_STM:
		STM 000h;

	WelcomeString:
		.string "Welcome to Drew's Brainfuck engine! Enjoy!";
	EndString:
		.word 13;
		.string "Fin.";


; BRACKET STACK
	BracketStackTop:
		.fill 99;
	BracketStackBottom:
		.fill 1;
	BracketRet:
		.word 0000h;
	BracketPush:
		POP; Pops return address
		STM (BracketRet);
		POP; Pops bracket value
		BracketPushSTM:
		STM (BracketStackBottom); This operand will be modified.
		DEC (BracketPushSTM);
		DEC (BracketPopLDM);
		JPI (BracketRet);
	BracketPop:
		POP; Pops return address
		STM (BracketRet);
		INC (BracketPushSTM);
		INC (BracketPopLDM);
		BracketPopLDM:
		LDM (BracketStackBottom); This operand will be modified.
		PUSH;
		JPI (BracketRet);


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
	ReadBF:
		JMP (ReadBFInit);
			Prompt:
				.string "bf> ";
			ReadBFRet:
				.word 0000h;
			ReadBFValue:
				.word 0000h;
			ReadBFNewline:
				.word 10;
			ReadBFBackspace:
				.word 8;
			ReadBFCodeAddress:
				.word 0000h;

		ReadBFInit:
			POP; Pop return address
			STM (ReadBFRet);

			LDI (Prompt);
			PUSH;
			CALL (Print);

			LDI (BFCode);
			ADD (Instr_STM);
			STM (ReadBFSTM);
			STM (ReadBFSTMNull);

		ReadBFLoop:
			LDM (Keyboard);
			JPZ (ReadBFLoop);

			STM (ReadBFValue);

			; TEMPORARY:
			;PUSH;
			;LDI 13;
			;STM (Display);
			;CALL (PrintNumberWithNewline);
			;LDM (ReadBFValue);

			XOR (ReadBFBackspace);
			JPZ (ReadBFErase);

			LDM (ReadBFValue);
			XOR (ReadBFNewline);
			JPZ (ReadBFDone);

			LDM (ReadBFValue);
			STM (Display);
			ReadBFSTM:
			STM 000h; This operand will be modified.
			INC (ReadBFSTM);
			INC (ReadBFSTMNull);
			JMP (ReadBFLoop);

		ReadBFErase:
			LDI (BFCode);
			STM (ReadBFCodeAddress);

			LDM (ReadBFSTM);
			SUB (Instr_STM);
			SUB (ReadBFCodeAddress);
			SUB (One);
			JPM (ReadBFLoop);

			DEC (ReadBFSTM);
			DEC (ReadBFSTMNull);
			LDM (ReadBFBackspace);
			STM (Display);
			JMP (ReadBFLoop);

		ReadBFDone:
			LDI 0;
			ReadBFSTMNull:
			STM 000h; This operand will be modified.
			JPI (ReadBFRet); Return
	ExecuteBF:
		JMP (ExecuteBFInit);
			ExecuteBFRet:
				.word 0000h;
			ExecuteBFTapeReadWriteRet:
				.word 0000h;
			ExecuteBFTapeValue:
				.word 0000h;
			ExecuteBFSymbol:
				.word 0000h;
			ExecuteBFTempAddress:
				.word 0000h;
			ExecuteBFBracketDepth:
				.word 0000h;
		ExecuteBFReadTape:
			ExecuteBFReadTapeLDM:
			LDM (BFTape); This operand will be modified.
			STM (ExecuteBFTapeValue);
			JPI (ExecuteBFTapeReadWriteRet);
		ExecuteBFWriteTape:
			LDM (ExecuteBFTapeValue);
			ExecuteBFWriteTapeSTM:
			STM (BFTape); This operand will be modified.
			JPI (ExecuteBFTapeReadWriteRet);
		ExecuteBFInit:
			POP; Pop return address
			STM (ExecuteBFRet)

			LDI (BFTape);
			ADD (Instr_LDM);
			STM (ExecuteBFReadTapeLDM);

			LDI (BFTape);
			ADD (Instr_STM);
			STM (ExecuteBFWriteTapeSTM);

			LDI (BFCode);
			ADD (Instr_LDM);
			STM (ExecuteBFLDM);

			JMP (ExecuteBFLoop);
		ExecuteBFLoopNext:
			INC (ExecuteBFLDM);
		ExecuteBFLoop:
			; Load current BF symbol
			ExecuteBFLDM:
			LDM (BFCode); This operand will be modified.
			STM (ExecuteBFSymbol);

			; Branch to execute instruction
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolIncrement);
			JPZ (ExecuteBFIncrement);
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolDecrement);
			JPZ (ExecuteBFDecrement);
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolMoveLeft);
			JPZ (ExecuteBFMoveLeft);
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolMoveRight);
			JPZ (ExecuteBFMoveRight);
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolWrite);
			JPZ (ExecuteBFWrite);
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolRead);
			JPZ (ExecuteBFRead);
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolBracketStart);
			JPZ (ExecuteBFBracketStart);
			LDM (ExecuteBFSymbol);
			XOR (BFSymbolBracketEnd);
			JPZ (ExecuteBFBracketEnd);

			; If symbol is null, finish
			LDM (ExecuteBFSymbol);
			JPZ (ExecuteBFDone);

			; Otherwise, skip symbol
			JMP (ExecuteBFLoopNext);

		ExecuteBFIncrement:
			LDI (ExecuteBFIncrementContinue);
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFReadTape);
			ExecuteBFIncrementContinue:

			INC (ExecuteBFTapeValue);

			LDI (ExecuteBFLoopNext); Loop after writing
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFWriteTape);

		ExecuteBFDecrement:
			LDI (ExecuteBFDecrementContinue);
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFReadTape);
			ExecuteBFDecrementContinue:

			DEC (ExecuteBFTapeValue);

			LDI (ExecuteBFLoopNext); Loop after writing
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFWriteTape);

		ExecuteBFMoveLeft:
			DEC (ExecuteBFReadTapeLDM);
			DEC (ExecuteBFWriteTapeSTM);

			JMP (ExecuteBFLoopNext);

		ExecuteBFMoveRight:
			INC (ExecuteBFReadTapeLDM);
			INC (ExecuteBFWriteTapeSTM);

			JMP (ExecuteBFLoopNext);

		ExecuteBFWrite:
			LDI (ExecuteBFWriteContinue);
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFReadTape);
			ExecuteBFWriteContinue:

			LDM (ExecuteBFTapeValue);
			STM (Display);

			JMP (ExecuteBFLoopNext);

		ExecuteBFRead:
			ExecuteBFReadLoop:
			LDM (Keyboard);
			JPZ (ExecuteBFReadLoop);

			STM (ExecuteBFTapeValue);

			LDI (ExecuteBFLoopNext); Loop after writing
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFWriteTape);

		ExecuteBFBracketStart:
			LDI (ExecuteBFBracketStartContinue);
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFReadTape);
			ExecuteBFBracketStartContinue:

			JPZ (ExecuteBFMoveToClosingBracket);

			LDM (ExecuteBFLDM);
			SUB (Instr_LDM);
			ADD (One);
			PUSH;
			CALL (BracketPush);

			JMP (ExecuteBFLoopNext);

		ExecuteBFBracketEnd:
			CALL (BracketPop);
			POP;
			STM (ExecuteBFTempAddress);

			LDI (ExecuteBFBracketEndContinue);
			STM (ExecuteBFTapeReadWriteRet);
			JMP (ExecuteBFReadTape);
			ExecuteBFBracketEndContinue:

			JPZ (ExecuteBFLoopNext);

			LDM (ExecuteBFTempAddress);
			PUSH;
			CALL (BracketPush);

			LDM (ExecuteBFTempAddress);
			ADD (Instr_LDM);
			STM (ExecuteBFLDM);

			JMP (ExecuteBFLoop);

		ExecuteBFMoveToClosingBracket:
			LDI 1;
			STM (ExecuteBFBracketDepth);

			LDM (ExecuteBFLDM);
			STM (ExecuteBFScanLDM);

		ExecuteBFMoveToClosingBracketLoop:
			INC (ExecuteBFScanLDM);

			ExecuteBFScanLDM:
			LDM 0000; This operand will be modified.
			STM (ExecuteBFSymbol);

			XOR (BFSymbolBracketStart);
			JPZ (ExecuteBFMoveToClosingBracketLoopBracketStart);

			LDM (ExecuteBFSymbol);
			XOR (BFSymbolBracketEnd);
			JPZ (ExecuteBFMoveToClosingBracketLoopBracketEnd);

			JMP (ExecuteBFMoveToClosingBracketLoop);

		ExecuteBFMoveToClosingBracketLoopBracketStart:
			INC (ExecuteBFBracketDepth);
			JMP (ExecuteBFMoveToClosingBracketLoop);

		ExecuteBFMoveToClosingBracketLoopBracketEnd:
			DEC (ExecuteBFBracketDepth);
			LDM (ExecuteBFBracketDepth);
			JPZ (ExecuteBFMoveToClosingBracketLoopDone);
			JMP (ExecuteBFMoveToClosingBracketLoop);

		ExecuteBFMoveToClosingBracketLoopDone:
			LDM (ExecuteBFScanLDM);
			STM (ExecuteBFLDM);

			JMP (ExecuteBFLoopNext);

		ExecuteBFDone:
			JPI (ExecuteBFRet); Return


; PROGRAM START
	Start:
		JMP (ExecuteInteractiveBF);
		;JMP (ExecuteStoredBF);

	ExecuteInteractiveBF:
		LDI (WelcomeString);
		PUSH;
		CALL (PrintLine);
		LDI 13;
		STM (Display);

	InteractiveLoop:
		CALL (ReadBF);
		LDI 13;
		STM (Display); Print newline
		CALL (ExecuteBF);
		LDI 13;
		STM (Display); Print newline
		JMP (InteractiveLoop);

	ExecuteStoredBF:
		CALL (ExecuteBF);
		LDI 13;
		STM (Display); Print newline
		LDI (EndString);
		PUSH;
		CALL (PrintLine);

	EndLoop:
		JMP (EndLoop); Loop infinitly to itself (halt).
