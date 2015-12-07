.org 400h; Program originates in RAM location 400h
.stack BFFh; Bottom of stack

; I/O Ports
.map Display, C02h; Terminal display for output
.map Keyboard, C02h; Buffered keyboard for input
.map DisplayRow, C00h; Row in display to load data into
.map RowData, C01h; Data for row in display
.map JSRight, C00h; Joystick right value
.map JSDown, C01h; Joystick down value
.map Seconds, C06h; Seconds on real-time clock
.map Minutes, C05h; Minutes on real-time clock
.map Hours, C04h; Hours on real-time clock
.map RollLeft, C07h; Roll left
.map RollRight, C08h; Roll right
.map Buttons, C09h; Alternate function buttons
.map Cartridge, C03h; Program ROM Cartridge slot

JMP (Start); Skip over data / functions

; PROGRAM VARIABLES
	; Video buffer
	VideoBuffer:
	Video_Row0:
		.word 0000h;
	Video_Row1:
		.word 0000h;
	Video_Row2:
		.word 0000h;
	Video_Row3:
		.word 0000h;
	Video_Row4:
		.word 0000h;
	Video_Row5:
		.word 0000h;
	Video_Row6:
		.word 0000h;
	Video_Row7:
		.word 0000h;
	Video_Row8:
		.word 0000h;
	Video_Row9:
		.word 0000h;
	Video_Row10:
		.word 0000h;
	Video_Row11:
		.word 0000h;
	Video_Row12:
		.word 0000h;
	Video_Row13:
		.word 0000h;
	Video_Row14:
		.word 0000h;
	Video_Row15:
		.word 0000h;
		
	; Strings / Characters
	Prompt:
		.string "> "; Typing prompt
	Asterisk:
		.string "*"; Asterisk, for passwords
	Colon:
		.string ":"; Colon
	NewLine:
		.word 13; ASCII code for new line
	ClearScreen:
		.word 12; ASCII code for new page (blank screen)
		
	; Data buffers
	InputBuffer:
		.fill 31;
	InputLength:
		.word 0000h;
		
	; Settings
	Username:
		.string "Drew"; Username for main account
		UsernameEnd:
	Password:
		.string "1234"; Password for main account
		PasswordEnd:
		
	;Numbers
	ASCII_NumOffset:
		.word 0030h;
	SecondsVar:
		.word 0000h;
	MinutesVar:
		.word 0000h;
	HoursVar:
		.word 0000h;
	NumCommands:
		.word 0000h;
	UsernameLength:
		.word 0000h;
	PasswordLength:
		.word 0000h;
		
	; Keys
	KEY_Enter:
		.word 10; Enter key
	KEY_Backspace:
		.word 8; Backspace key
		
	; Button states
	BTN_Quit:
		.word 0001h;
	BTN_Previous:
		.word 0004h;
	BTN_Next:
		.word 0010h;
	BTN_Select:
		.word 0040h;
	BTN_Yes:
		.word 0100h;
	BTN_No:
		.word 0400h;
		
	; Command variables
	CMD_Time:
		.string "time";
	CMD_Clear:
		.string "clear";
	CMD_Halt:
		.string "halt";
	CMD_Echo:
		.string "echo";
	CMD_Load:
		.string "load";
	Commands:
		.word 0(CMD_Time), 0(CMD_Clear), 0(CMD_Halt), 0(CMD_Echo), 0(CMD_Load); Array of pointers to command string
	Functions:
		.word 0(ExecTime), 0(ExecClear), 0(ExecHalt), 0(ExecEcho), 0(Load); Array of functions to call for each command
	Lengths:
		.word 5, 6, 5, 4, 5; Array of lengths of each command string to check for

; PROGRAM FUNCTIONS
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
	Print:
		JMP (PrintInit);
			PrintRet:
				.word 0000h; Return Address
			OrigPrintLoad:
				.word 9000h; Plain load command
		PrintInit:
			POP; Pops return address
			STM (PrintRet);
			POP; Pops pointer to string
			ADD (OrigPrintLoad);
			STM (PrintLoop); Update load command to start at string
		PrintLoop:
			LDM 000h; String address to load
			JPZ (PrintDone); Return when string is done
			STM (Display); Write to display
			INC (PrintLoop); Increment string pointer
			JMP (PrintLoop); Loop again
		PrintDone:
			JPI (PrintRet); Return
	Boot:
		JMP (BootInit);
			Boot_BootMSG:
				.word 12; Clear screen
				.string "Welcome to DrewOS!";
			Boot_CommandsAddr:
				.word 0(Commands);
			Boot_UsernameAddr:
				.word 0(Username);
			Boot_PasswordAddr:
				.word 0(Password);
		BootInit:
		BootSetNumCommands:
			LDI (Functions);
			SUB (Boot_CommandsAddr);
			STM (NumCommands); Set num commands
		BootSetUsernameLength:
			LDI (UsernameEnd);
			SUB (Boot_UsernameAddr);
			SUB (One);
			STM (UsernameLength);
		BootSetPasswordLength:
			LDI (PasswordEnd);
			SUB (Boot_PasswordAddr);
			SUB (One);
			STM (PasswordLength);
		BootMessage:
			LDI (Boot_BootMSG); Load boot message
			PUSH;
			CALL (PrintLine); Print boot message
		BootDone:
			RET; Return
	Login:
		JMP (LoginInit);
			LoginRet:
				.word 0000h; Return Address
			Login_UsernameMSG:
				.string "Username: ";
			Login_PasswordMSG:
				.string "Password: ";
			Login_WelcomeMSG:
				.string "You are now logged in as ";
			Login_FailedMSG:
				.string "Incorrect username / password";
			Login_TempKeyboardInput:
				.word 0000h;
			Login_UsernameBuffer:
				.fill 11; Space for username, 10 chars max
			Login_PasswordBuffer:
				.fill 11; Space for password, 10 chars max
			Login_CurInputLength:
				.word 0000h; Num characters typed so far
		LoginInit:
			POP;
			STM (LoginRet);
			LDM (Username);
			JPZ (LoginDone);
			LDM (Password);
			JPZ (LoginDone);
		LoginUsernamePrompt:
			LDI (Login_UsernameMSG); Load login prompt
			PUSH;
			CALL (Print); Print login prompt
			LDI 0;
			STM (Login_CurInputLength);
		LoginUsernameFetchLoop:
			LDM (Keyboard);
			JPZ (LoginUsernameFetchLoop);
			STM (Login_TempKeyboardInput);
			XOR (KEY_Enter);
			JPZ (LoginPasswordPrompt); Check if enter is pressed
			LDI 10; Max chars
			SUB (Login_CurInputLength); Subtract by # typed
			JPZ (LoginUsernameFetchLoop); If user typed 10 chars, don't allow any more
			INC (Login_CurInputLength); Increment num chars
			LDM (Login_TempKeyboardInput); Reload origional char
			LoginUsernameSaveIndex:
			STM (Login_UsernameBuffer);
			INC (LoginUsernameSaveIndex);
			LDM (Login_TempKeyboardInput); Reload character
			STM (Display); Display key typed
			JMP (LoginUsernameFetchLoop);
		LoginPasswordPrompt:
			LDM (NewLine); Load a newline char
			STM (Display); Print a new line
			LDI (Login_PasswordMSG); Load login prompt
			PUSH;
			CALL (Print); Print login prompt
			LDI 0;
			STM (Login_CurInputLength);
		LoginPasswordFetchLoop:
			LDM (Keyboard);
			JPZ (LoginPasswordFetchLoop);
			STM (Login_TempKeyboardInput);
			XOR (KEY_Enter);
			JPZ (LoginCheckUsername); Check if enter is pressed
			LDI 10; Max chars
			SUB (Login_CurInputLength); Subtract by # typed
			JPZ (LoginPasswordFetchLoop); If user typed 10 chars, don't allow any more
			INC (Login_CurInputLength); Increment num chars
			LDM (Login_TempKeyboardInput); Reload origional char
			LoginPasswordSaveIndex:
			STM (Login_PasswordBuffer);
			INC (LoginPasswordSaveIndex);
			LDM (Asterisk); Load asterisk
			STM (Display); Display asterisk
			JMP (LoginPasswordFetchLoop);
		LoginCheckUsername:
			LoginCheckUsernameLoop:
				LoginCheckUsernameLoopIndex:
				LDM (Login_UsernameBuffer);
				JPZ (LoginCheckPassword);
				LoginCheckUsernameLoopIndex2:
				XOR (Username);
				JPZ (LoginCheckUsernameLoopContunue);
				JMP (LoginFailure);
				LoginCheckUsernameLoopContunue:
					INC (LoginCheckUsernameLoopIndex);
					INC (LoginCheckUsernameLoopIndex2);
					JMP (LoginCheckUsernameLoop);
		LoginCheckPassword:
			LoginCheckPasswordLoop:
				LoginCheckPasswordLoopIndex:
				LDM (Login_PasswordBuffer);
				JPZ (LoginSuccess);
				LoginCheckPasswordLoopIndex2:
				XOR (Password);
				JPZ (LoginCheckPasswordLoopContunue);
				JMP (LoginFailure);
				LoginCheckPasswordLoopContunue:
					INC (LoginCheckPasswordLoopIndex);
					INC (LoginCheckPasswordLoopIndex2);
					JMP (LoginCheckPasswordLoop);
		LoginSuccess:
			LDM (NewLine); Load a newline char
			STM (Display); Print a new line
			LDI (Login_WelcomeMSG); Load logged in message
			PUSH;
			CALL (Print); Print logged in message
			LDI (Username); Load username
			PUSH;
			CALL (PrintLine); Print username on same line as logged in message
			JMP (LoginDone); Jump to end of subroutine
		LoginFailure:
			LDM (NewLine); Load a newline char
			STM (Display); Print a new line
			LDI (Login_FailedMSG); Load failed in message
			PUSH;
			CALL (PrintLine); Print failed message
			; ERASE USERNAME BUFFER
			LDI (Login_UsernameBuffer); Load address to username buffer
			PUSH;
			LDI 10; Erase 10 spots
			PUSH;
			CALL (Erase);
			; ERASE PASSWORD BUFFER
			LDI (Login_PasswordBuffer); Load address to username buffer
			PUSH;
			LDI 10; Erase 10 spots
			PUSH;
			CALL (Erase);
			JMP (LoginUsernamePrompt); Restart login loop
		LoginDone:
			JPI (LoginRet); Return
	Erase:
		JMP (EraseInit);
			EraseRet:
				.word 0000h;
			EraseCountdown:
				.word 0000h;
			ErasePlainStore:
				.word a000h;
		EraseInit:
			POP; Pop return address
			STM (EraseRet); Save return address
			POP; Pop amount to erase
			STM (EraseCountdown);
			POP; Pop address to erase from
			ADD (ErasePlainStore); Add to plain data store command
			STM (EraseStoreIndex);
		EraseLoop:
			LDM (EraseCountdown);
			JPZ (EraseDone);
			LDI 000h; Load zero
			EraseStoreIndex:
			STM 000h;
			DEC (EraseCountdown);
			INC (EraseStoreIndex);
			JMP (EraseLoop);
		EraseDone:
			JPI (EraseRet); Return
	PrintNumber:
		JMP (PrintNumberInit);
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
			JPI (PrintNumberRet); Return
	Multiply:
		JMP (MultiplyInit);
			MultiplyRet:
				.word 0000h;
			Multiply_Number1:
				.word 0000h;
			Multiply_Number2:
				.word 0000h;
			Multiply_Product:
				.word 0000h;
		MultiplyInit:
			POP;
			STM (MultiplyRet);
			POP;
			STM (Multiply_Number1);
			POP;
			STM (Multiply_Number2);
			LDI 0;
			STM (Multiply_Product);
		MultiplyLoop:
			LDM (Multiply_Number2);
			JPZ (MultiplyDone);
			LDM (Multiply_Product);
			ADD (Multiply_Number1);
			STM (Multiply_Product);
			DEC (Multiply_Number2);
			JMP (MultiplyLoop);
		MultiplyDone:
			LDM (Multiply_Product);
			PUSH;
			JPI (MultiplyRet); Return
	PadNumber:
		JMP (PadNumberInit);
			PadNumberRet:
				.word 0000h;
			PadNumber_Number:
				.word 0000h;
			PadNumber_Padding:
				.word 0000h;
			PadNumber_Places:
				.word 10000, 1000, 100, 10, 1, 0;
			PadNumber_Place:
				.word 5;
			PadNumber_PlainSub:
				.word 2(PadNumber_Places);
		PadNumberInit:
			POP; Pop return address
			STM (PadNumberRet);
			POP; Pop padding
			STM (PadNumber_Padding);
			STM (PadNumber_Place);
			POP; Pop number
			STM (PadNumber_Number);
			LDI 5;
			SUB (PadNumber_Padding);
			STM (PadNumber_Padding);
			LDM (PadNumber_PlainSub);
			STM (PadNumberSubIndex);
			LDM (PadNumber_PlainSub);
			ADD (PadNumber_Padding);
			STM (PadNumberSubIndex);
		PadNumberLoop:
			LDM (PadNumber_Number);
			PadNumberSubIndex:
			SUB (PadNumber_Places);
			JPM (PadNumberLoopLessThan);
			JMP (PadNumberLoopContinue);
			PadNumberLoopLessThan:
				LDI 30h;
				STM (Display);
			PadNumberLoopContinue:
			INC (PadNumberSubIndex);
			DEC (PadNumber_Place);
			JPZ (PadNumberDone);
			JMP (PadNumberLoop);
		PadNumberDone:
			JPI (PadNumberRet); Return
	PrintTime:
		JMP (PrintTimeInit);
			PrintTime_Seconds:
				.word 0000h;
			PrintTime_Minutes:
				.word 0000h;
			PrintTime_Hours:
				.word 0000h;
		PrintTimeInit:
		PrintTimeGet:
			LDM (Seconds);
			STM (PrintTime_Seconds);
			LDM (Minutes);
			STM (PrintTime_Minutes);
			LDM (Hours);
			STM (PrintTime_Hours);
		PrintTimeHours:
			LDM (PrintTime_Hours); Hours
			PUSH;
			LDI 2; Padding
			PUSH;
			CALL (PadNumber);
			LDM (PrintTime_Hours); Hours
			PUSH;
			CALL (PrintNumber);
			LDM (Colon);
			STM (Display);
		PrintTimeMinutes:
			LDM (PrintTime_Minutes); Minutes
			PUSH;
			LDI 2; Padding
			PUSH;
			CALL (PadNumber);
			LDM (PrintTime_Minutes); Minutes
			PUSH;
			CALL (PrintNumber);
			LDM (Colon);
			STM (Display);
		PrintTimeSeconds:
			LDM (PrintTime_Seconds); Seconds
			PUSH;
			LDI 2; Padding
			PUSH;
			CALL (PadNumber);
			LDM (PrintTime_Seconds); Seconds
			PUSH;
			CALL (PrintNumber);
		PrintTimeDone:
			RET; Return
	FetchCommand:
		JMP (FetchCommandInit);
			FetchCommand_PlainStore:
				.word a(InputBuffer);
			FetchCommand_TempChar:
				.word 0000h;
			FetchCommand_CharsLeft:
				.word 30;
			FetchCommand_MaxChars:
				.word 30;
			FetchCommand_Two:
				.word 2;
			FetchCommand_AbortWrite:
				.word 1;
		FetchCommandInit:
			LDM (FetchCommand_PlainStore);
			STM (FetchCommandStoreIndex);
			LDM (FetchCommand_MaxChars);
			STM (FetchCommand_CharsLeft);
			LDI 0;
			STM (InputLength);
		FetchCommandPrompt:
			LDI (Prompt);
			PUSH;
			CALL (Print);
		FetchCommandInputLoop:
			LDI 1;
			STM (FetchCommand_AbortWrite);
			LDM (Keyboard);
			JPZ (FetchCommandInputLoop);
			STM (FetchCommand_TempChar);
			XOR (KEY_Enter);
			JPZ (FetchCommandDone);
			LDM (FetchCommand_TempChar);
			XOR (KEY_Backspace);
			JPZ (FetchCommandBackspace);
			JMP (FetchCommandSkipBackspace);
		FetchCommandBackspace:
			LDI 0;
			STM (FetchCommand_AbortWrite);
			LDM (FetchCommand_CharsLeft);
			XOR (FetchCommand_MaxChars);
			JPZ (FetchCommandSkipBackspace);
			LDM (FetchCommandStoreIndex);
			;SUB (FetchCommand_Two);
			SUB (One);
			STM (FetchCommandStoreIndex);
			LDM (FetchCommand_CharsLeft);
			;ADD (FetchCommand_Two);
			Add (One);
			STM (FetchCommand_CharsLeft);
			LDM (KEY_Backspace);
			STM (Display);
			DEC (InputLength);
		FetchCommandSkipBackspace:
			LDM (FetchCommand_AbortWrite);
			JPZ (FetchCommandInputLoop);
			DEC (FetchCommand_CharsLeft);
			JPZ (FetchCommandInputLoop);
			JPM (FetchCommandInputLoop);
			LDM (FetchCommand_TempChar);
			FetchCommandStoreIndex:
			STM (InputBuffer);
			STM (Display);
			INC (InputLength);
			INC (FetchCommandStoreIndex);
			JMP (FetchCommandInputLoop);
		FetchCommandDone:
			LDM (NewLine);
			STM (Display); Skip to a new line
			RET; Return
	RunCommand:
		JMP (RunCommandInit);
			RunCommandRet:
				.word 0000h;
			RunCommand_NumCommands:
				.word 1; Commands possible
			RunCommand_BlankLoad:
				.word 9000h;
			RunCommand_BlankJumpI:
				.word c000h;
			RunCommand_UnknownCommand:
				.string "Unknown command: ";
		RunCommandInit:
			POP; Pop return address
			STM (RunCommandRet);
			LDI (Commands);
			ADD (RunCommand_BlankLoad);
			STM (RunCommandCommandIndex);
			LDI (Lengths);
			ADD (RunCommand_BlankLoad);
			STM (RunCommandLengthIndex);
			LDI (Functions);
			ADD (RunCommand_BlankJumpI);
			STM (RunCommandFunctionIndex);
			LDI 1;
			LDM (NumCommands);
			STM (RunCommand_NumCommands);
		RunCommandLoop:
			RunCommandCommandIndex:
			LDM (Commands);
			PUSH; Push command pointer
			RunCommandLengthIndex:
			LDM (Lengths);
			PUSH; Push command length
			CALL (IsCommand);
			POP; Pop result
			JPZ (RunCommandExec); Command is right! We should call it
			DEC (RunCommand_NumCommands);
			JPZ (RunCommandDone);
			INC (RunCommandLengthIndex);
			INC (RunCommandFunctionIndex);
			INC (RunCommandCommandIndex);
			JMP (RunCommandLoop);
		RunCommandExec:
			LDM (RunCommandRet);
			PUSH;
			RunCommandFunctionIndex:
			JPI (Functions);
		RunCommandDone:
			LDI (RunCommand_UnknownCommand);
			PUSH;
			CALL (Print); Print unknown command message
			LDI (InputBuffer);
			PUSH;
			CALL (PrintLine); Add the command to that message
			JPI (RunCommandRet); Return
	IsCommand:
		JMP (IsCommandInit);
			IsCommandRet:
				.word 0000h;
			IsCommand_PlainLoad:
				.word 9(InputBuffer);
			IsCommand_PlainXOR:
				.word 6000h;
			IsCommand_TempChar:
				.word 0000h;
			IsCommand_CMDLength:
				.word 4;
		IsCommandInit:
			POP; Pop return address
			STM (IsCommandRet);
			POP; Pop command length
			STM (IsCommand_CMDLength);
			LDM (IsCommand_PlainLoad);
			STM (IsCommandLoadIndex);
			POP; Pop pointer to command string
			ADD (IsCommand_PlainXOR); Add to XOR command
			STM (IsCommandXORIndex);
		IsCommandLoop:
			IsCommandLoadIndex:
			LDM (InputBuffer);
			;JPZ (IsCommandDone);
			STM (IsCommand_TempChar);
			IsCommandXORIndex:
			XOR (CMD_Time);
			JPZ (IsCommandSame);
			JMP (IsCommandDone);
		IsCommandSame:
			DEC (IsCommand_CMDLength);
			JPZ (IsCommandExec);
			INC (IsCommandLoadIndex);
			INC (IsCommandXORIndex);
			JMP (IsCommandLoop);
		IsCommandExec:
			LDI 0; Load 0 (Meaning the command is correct)
			PUSH; Push
			JPI (IsCommandRet); Return
		IsCommandDone:
			LDI 1; Load 1 (Meaning the command is incorrect)
			PUSH; Push
			JPI (IsCommandRet); Return
	ExecTime:
		JMP (ExecTimePrintMessage);
			ExecTime_TimeMSG:
				.string "The current time is ";
		ExecTimePrintMessage:
			LDI (ExecTime_TimeMSG);
			PUSH;
			CALL (Print);
		ExecTimePrintTime:
			CALL (PrintTime);
			LDM (NewLine);
			STM (Display);
		ExecTimeDone:
			RET; Return
	ExecClear:
		ExecClearClearScreen:
			LDM (ClearScreen);
			STM (Display);
		ExecClearDone:
			RET; Return
	ExecHalt:
		JMP (ExecHaltInit);
			ExecHalt_HaltMSG:
				.string "HALTING";
		ExecHaltInit:
			LDI (ExecHalt_HaltMSG);
			PUSH;
			CALL (Print);
		ExecHaltHalt:
			JMP (EndLoop);
		ExecHaltDone:
			RET; Return
	ExecEcho:
		JMP (ExecEchoInit);
			ExecEcho_Offset:
				.word 5;
		ExecEchoInit:
			LDI (InputBuffer);
			ADD (ExecEcho_Offset);
			PUSH;
			CALL (PrintLine);
		ExecEchoDone:
			RET; Return
	Load:
		JMP (LoadInit);
			Load_PlainStore:
				.word a000h;
			Load_WordsLeft:
				.word 0000h;
			Load_LoadMessage:
				.string "Loading: ";
			Load_LoadMessage2:
				.string "Do not remove cartridge...";
			Load_FinishedMSG:
				.string "Safe to remove cartridge."
			Load_CurAddress:
				.word 0000h;
			Load_24:
				.word 24;
		LoadInit:
			LDI 001h;
			ADD (Load_PlainStore);
			STM (LoadStoreIndex);
			LDI 000h;
			STM (Load_CurAddress);
			STM (Cartridge);
			LDM (Cartridge); Load program size
			ADD (Load_24);
			STM (Load_WordsLeft);
			LDM (ClearScreen);
			STM (Display);
			LDI (Load_LoadMessage);
			PUSH;
			CALL (Print);
		LoadTitleLoop:
			INC (Load_CurAddress);
			STM (Cartridge);
			LDM (Cartridge);
			JPZ (LoadTitle2);
			STM (Display);
			DEC (Load_WordsLeft);
			JMP (LoadTitleLoop);
		LoadTitle2:
			LDM (NewLine);
			STM (Display);
			LDI (Load_LoadMessage2);
			PUSH;
			CALL (PrintLine);
		LoadLoop:
			INC (Load_CurAddress);
			STM (Cartridge);
			LDM (Cartridge);
			LoadStoreIndex:
			STM 001h;
			INC (LoadStoreIndex);
			DEC (Load_WordsLeft);
			JPZ (LoadFinished);
			JMP (LoadLoop);
		LoadFinished:
			LDI (Load_FinishedMSG);
			PUSH;
			CALL (PrintLine);
		LoadExec:
			LDI (LoadDone);
			PUSH;
			JMP 001h;
		LoadDone:
			RET; Return
	UpdateVideo:
		JMP (UpdateVideoInit);
			UpdateVideo_PlainLoad:
				.word 9(VideoBuffer);
			UpdateVideo_LoopsLeft:
				.word 0000h;
			UpdateVideo_VideoAddr:
				.word 0000h;
		UpdateVideoInit:
			LDM (UpdateVideo_PlainLoad);
			STM (UpdateVideoLoadIndex);
			LDI 15;
			STM (UpdateVideo_LoopsLeft);
			LDI 0;
			STM (UpdateVideo_VideoAddr);
		UpdateVideoLoop:
			LDM (UpdateVideo_VideoAddr);
			STM (DisplayRow);
			UpdateVideoLoadIndex:
			LDM (VideoBuffer);
			STM (RowData);
			INC (UpdateVideoLoadIndex);
			INC (UpdateVideo_VideoAddr);
			DEC (UpdateVideo_LoopsLeft);
			JPZ (UpdateVideoDone);
			JMP (UpdateVideoLoop);
		UpdateVideoDone:
			RET; Return
	StoreBuffer:
		JMP (StoreBufferInit);
			StoreBufferRet:
				.word 0000h;
			StoreBuffer_PlainLoad:
				.word 9000h;
			StoreBuffer_PlainStore:
				.word a(VideoBuffer);
			StoreBuffer_LoopsLeft:
				.word 16;
		StoreBufferInit:
			POP; Pop return address
			STM (StoreBufferRet);
			POP; Pop pointer to source buffer data
			ADD (StoreBuffer_PlainLoad);
			STM (StoreBufferLoadIndex);
			LDM (StoreBuffer_PlainStore);
			STM (StoreBufferStoreIndex);
			LDI 16;
			STM (StoreBuffer_LoopsLeft);
		StoreBufferLoop:
			StoreBufferLoadIndex:
			LDM 000h;
			StoreBufferStoreIndex:
			STM (VideoBuffer);
			INC (StoreBufferLoadIndex);
			INC (StoreBufferStoreIndex);
			DEC (StoreBuffer_LoopsLeft);
			JPZ (StoreBufferDone);
			JMP (StoreBufferLoop);
		StoreBufferDone:
			JPI (StoreBufferRet); Return
	PromptYesNo:
		JMP (PromptYesNoInit);
			PromptYesNoRet:
				.word 0000h;
			PromptYesNo_ButtonState:
				.word 0000h;
		PromptYesNoInit:
			POP; Pop return address
			STM (PromptYesNoRet);
			CALL (PrintLine); POINTER ALREADY IN STACK - STRING POINTER FOR MESSAGE
		PromptYesNoLoop:
			LDM (Buttons);
			STM (PromptYesNo_ButtonState);
			XOR (BTN_Yes);
			JPZ (PromptYesNoDoYes);
			LDM (PromptYesNo_ButtonState);
			XOR (BTN_No);
			JPZ (PromptYesNoDoNo);
			JMP (PromptYesNoLoop);
		PromptYesNoDoYes:
			LDI 0;
			PUSH;
			JMP (PromptYesNoDone);
		PromptYesNoDoNo:
			LDI 1;
			PUSH;
			JMP (PromptYesNoDone);
		PromptYesNoDone:
			JPI (PromptYesNoRet); Return
			
; PROGRAM START
	Start:
		CALL (Boot); Initiate system
		CALL (Login); Display login prompt and log in
	LoopStart:
		CALL (FetchCommand); Get command from input
		CALL (RunCommand); Interpret & run command
		LDI (InputBuffer);
		PUSH;
		LDM (InputLength);
		PUSH;
		CALL (Erase); Erase input buffer
		JMP (LoopStart); Loop again
	EndLoop:
		JMP (EndLoop); Loop infinitly to itself (halt)