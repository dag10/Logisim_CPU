.org 800h; 
JMP (Start);

; DATA
	; Constant 1
	One:
	.word 1;
	
	; Number of times left to loop (will fetch value for this from port 1, and count down)
	Loops:
	.word 0;
	
	; Number of loops left in sub-loop
	SubLoops:
	.word 0;
	
	; Number of subloops to do (setting)
	NumSubLoops:
	.word 30;
	
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
			LDM (NumSubLoops);
			STM (SubLoops);
			SubLoop:
				JPZ (LoopStart);
				LDM (SubLoops);
				SUB (One);
				STM (SubLoops);