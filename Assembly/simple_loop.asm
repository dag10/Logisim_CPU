.org 800h; 
JMP (Start);

; DATA
	; Constant 1
	One:
	.word 1;
	
	; Number of times left to loop (will fetch value for this from port 1, and count down)
	Loops:
	.word 0;
	
; PROGRAM
Start:
	FetchTimes:
		LDM c00h;
		STM (Loops);
		LoopStart:
			JPZ (FetchTimes);
			LDM (Loops);
			STM c00h;
			SUB (One);
			STM (Loops);
			JMP (LoopStart);