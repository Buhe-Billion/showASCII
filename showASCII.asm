;DESCRIPTION                :The program loops through characters 32 through 255
;                           :and writes a simple "ASCII chart" in a display buffer. The chart
;                           :consists of 8 lines of 32 characters, with the lines not
;                           :continuous in memory.
;
;Architecture               : X86-64
;CPU                        : Intel® Core™2 Duo CPU T6570 @ 2.10GHz × 2
;NASM                       : 2.14.02
;

SECTION .data

SYS_WRITE_CALL_VAL EQU 1
STDERR_FD          EQU 2
SYS_READ_CALL_VAL  EQU 0
STDIN_FD           EQU 0
STDOUT_FD          EQU 1
EXIT_SYSCALL       EQU 60
OK_RET_VAL         EQU 0
EOF_VAL						 EQU 0

EOL                EQU 10   ;Linux end-of-line char
FILLCHR            EQU 32   ;Default to ASCII space character
CHRTROW            EQU 2    ;Chart begins 2 lines from the top
CHRTLEN            EQU 32   ;Each chart line shows 32 chars

; This escape sequence will clear the console terminal and place the
; text cursor to the origin (1,1) on virtually all Linux consoles:

CLRHOME            DB  27,"[2J",27,"[01;01H"
CLRLEN             EQU $-CLRHOME

; We use this to display a ruler across the screen.
RULERSTRING        DB  "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
RULERLEN           EQU  $-RULERSTRING

SECTION .bss

COLS               EQU  81         ; Line length + 1 char for EOL
ROWS               EQU  25         ; Number of lines in display
VIDEOBUFFER        RESB COLS*ROWS  ; Buffer size adapts to ROWS & COLS

SECTION .text

GLOBAL _start
EXTERN CLEARTERMINAL, CLEARVID, RULER, SHOW 
