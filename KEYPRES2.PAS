Unit KeyPres2;

{ ???筮 ?????????? ???뫠?? ᨬ???? ? ????????? }
{ ? ???ᨬ??쭮? ᪮?????? 4 ??㪨 ? ᥪ㭤?. }
{ ?⮡? ????誠 ?? ????⠨???? ? ???????? ????? ? ?????????? }
{ ?㦭? ॠ???????? ᫥???騩 ????????: }
{ 1) ? ??砫? ?ணࠬ?? ?????????, ??? ??? ??????? ????饭? }
{    ? 横?? ?ணࠬ??: }
{ 2) ??????? ?????묨 ?? ???????, ??????? ?? ????饭? }
{ 3) ?? ???????? ??????? ????饭?묨 ?? ??????? }
{ ????⢥??? ???? ?????? ? ???????? ॠ???????? ᥩ ????????: }
{ Set_Handler -> 1) }
{ New_Handler -> 2), 3) }

Interface

{ ????? ᪠????? ????? ???? ?????? }

Const
  sEsc          =       1;
  s1            =       2;
  s2            =       3;
  s3            =       4;
  s4            =       5;
  s5            =       6;
  s6            =       7;
  s7            =       8;
  s8            =       9;
  s9            =     $0A;
  s0            =     $0B;
  sMinus        =     $0C;              { - _ }
  sEqual        =     $0D;              { = + }
  sBackSpace    =     $0E;
  sTab          =     $0F;
  sQ            =     $10;
  sW            =     $11;
  sE            =     $12;
  sR            =     $13;
  sT            =     $14;
  sY            =     $15;
  sU            =     $16;
  sI            =     $17;
  sO            =     $18;
  sP            =     $19;
  sLBraket      =     $1A;             (* [ { *)
  sRBraket      =     $1B;             (* ] } *)
  sEnter        =     $1C;
  sCtrl         =     $1D;
  sA            =     $1E;
  sS            =     $1F;
  sD            =     $20;
  sF            =     $21;
  sG            =     $22;
  sH            =     $23;
  sJ            =     $24;
  sK            =     $25;
  sL            =     $26;
  sSemicolon    =     $27;              { ; :  }
  sQuote        =     $28;              { ' "  }
  sApostrophe   =     $29;              { ` ~  }
  sLShift       =     $2A;
  sSlash        =     $2B;              { \ |  }
  sZ            =     $2C;
  sX            =     $2D;
  sC            =     $2E;
  sV            =     $2F;
  sB            =     $30;
  sN            =     $31;
  sM            =     $32;
  sComma        =     $33;              { , <  }
  sPoint        =     $34;              { . >  }
  sBackSlash    =     $35;              { / ?  }
  sRShift       =     $36;
  sAsteriks     =     $37;              { *  ?? ???஢?? ?????????? }
  sAlt          =     $38;
  sSpace        =     $39;              { ?஡?? }
  sCapsLock     =     $3A;
  sF1           =     $3B;
  sF2           =     $3C;
  sF3           =     $3D;
  sF4           =     $3E;
  sF5           =     $3F;
  sF6           =     $40;
  sF7           =     $41;
  sF8           =     $42;
  sF9           =     $43;
  sF10          =     $44;
  sNumLock      =     $45;
  sScrollLock   =     $46;
  sHome         =     $47;
  sUp           =     $48;
  sPageUp       =     $49;
  sGrayMinus    =     $4A;              { -  ?? ???஢?? ?????????? }
  sLeft         =     $4B;
  sFive         =     $4C;              { 5  ?? ???஢?? ?????????? }
  sRight        =     $4D;
  sGrayPlus     =     $4E;              { +  ?? ???஢?? ?????????? }
  sEnd          =     $4F;
  sDown         =     $50;
  sPageDown     =     $51;
  sInsert       =     $52;
  sDelete       =     $53;
  sF11          =     $57;
  sF12          =     $58;

Var
  KeyMap : Array [0..$7F] of Boolean;   { ???饭??-᪠???? ???????, TRUE - }
                                        { ?????? ᥩ???, FALSE - ????饭? }
  SymMap : Array [0..$7F] of Char;      { ???饭??-᪠???? ???????, }
                                        { ᮤ?ন??? - ASCII-ᨬ???? ??? ?????? }

Procedure Set_Handler;
{ ??⠭???????? ????? ??ࠡ??稪 ????????୮?? ????뢠???, }
{ ????? ????? ??ࠡ??稪 ??⨢??, ?? ?????????? ???짮?????? }
{ KeyPressed, ReadKey ? Read, ? ⠪?? ??⠭???????? ?ணࠬ?? }
{ ?? Ctrl+C (Ctrl+Break) ??? ?? ?⫠??????. }
{ KeyPressed ? ReadKey ????? ??????? - ᬮ??? ???? }

Procedure Remove_Handler;
{ ??????頥? ?????? ??ࠡ??稪 ????????୮?? }
{ ????뢠??? ?? ??? ???????? ????? }

Procedure WaitForACSReleased;
{ ???? ????᪠??? Alt,Ctrl,Shift; ?ᯮ???????? ?????? ????? }
{ ??⠭????? ?????? ??ࠡ??稪? ????????୮?? ????뢠??? }

Function KeyPressedNow : Boolean;
{ ??????頥? TRUE ?᫨ ? ?????? ?????? ?६??? }
{ ????⢨⥫쭮 ?????? ?????? ???? ???????, ????? ??????頥? FALSE. }
{ ?ᯮ???????? ?????? ? ???ᨢ??? KeyMap ? SymMap }

Function KeyPressed2 : Boolean;
{ ?????? ?????? ?-樨 KeyPressed ?? ?????? CRT. }

Function ReadScan : Byte;
{ ?????? ?-樨 ReadKey (?????? CRT). }
{ ??????? ? ⮬, ??? ??? ?-??? ??????頥? }
{ ?? ᨬ??? ???????, ? ?? ᪠????, ???????? }
{ ????????? ?? ?????? ???????. }
{ ?ᯮ???????? ?????? ? KeyPressed2 }

Function ReadChar : Char;
{ ?????? ?-樨 ReadKey (?????? CRT). }
{ ??????? ? ⮬, ??? ??? ?-??? ??????頥? }
{ ᨬ??? ??????? ??? ????? ?????ﭨ? Alt,Ctrl,Shift ? Caps Lock. }
{ ?᫨ ??????? ??????? ?? ????? ?? ᥡ? ᨬ????, ?? ??????頥??? }
{ ?㫥??? ᨬ???, ?? ? ????? ?????७??? ????? ????? ???? ???? ?? }
{ ?????. ?ᯮ???????? ?????? ? KeyPressed2 }

Procedure ClearKeyboardBuf;
{ ???頥? ????楢?? ?????, ?ᯮ???㥬?? ?-??ﬨ KeyPressedNow, KeyPressed2, }
{ ReadScan ? ReadChar }

Implementation

Uses DOS;

Const
  Old_Handler : Pointer = Nil;          { ? ???࠭?? ????? ???ண? ??ࠡ??稪? }
  KeyBufSize            = 16;           { ???????????? ????? ?㤥? ᮤ?ঠ?? }
                                        { ???ᨬ?? 16 ᪠?????? }

  Symbs : Array [sEsc..sSpace] of Char =
    #27'1234567890-='#8#9'QWERTYUIOP[]'#13#0'ASDFGHJKL;''`'#0'\'+
    'ZXCVBNM,./'#0'*'#0' ';

Var
  KeyBuf : Array [0..KeyBufSize] of Byte;       { ????楢?? ???????????? ????? }
  BufHead,                                      { ?????? ?????? }
  BufTail : Word;                               { ????? ?????? }
  KeyCount : Byte;                              { ???-?? ᪠?????? ?????? }
                                                { ? ?????? }

Procedure New_Handler; Interrupt; Assembler;
{ Using assembler because we need a fast interrupt-handling routine }
Asm
  Push  AX
  Push  BX
  In    AL, 060h
  Mov   AH, AL
  And   AL, 07Fh                                { AL = ??????? }
  LEA   BX, KeyMap
  Add   BL, AL
  AdC   BH, 0
  Test  AH, 080h
  JNZ   @released                               { ????訩 ??? - 䫠? ????᪠??? }
  Mov   Byte Ptr [BX], TRUE                     { ??????? ?뫠 ?????? }
  Cmp   KeyCount, KeyBufSize
  JE    @done                                   { ????? ??⪮? ????? }
  LEA   BX, KeyBuf
  Add   BX, BufTail
  Mov   [BX], AL                                { ???࠭??? ᪠???? ? KeyBuf }
  Inc   KeyCount                                { More keys avaible to read }
  Inc   BufTail                                 { ????????? ??????? ??? ???࠭???? }
  Cmp   BufTail, KeyBufSize
  JNE   @done
  Mov   BufTail, 0                              { ????४??஢??? ??????? }
  Jmp   @done
@released:
  Mov   Byte Ptr [BX], FALSE                    { ??????? ?뫠 ????饭? }
@done:
  Mov   AL, 020h                                { ????騫? ????஫???? }
  Out   020h, AL                                { ????뢠???, ??? ????뢠??? }
                                                { ??ࠡ?⠭? }
  Pop   BX
  Pop   AX
End;

Procedure Set_Handler;
Begin
  If Old_Handler <> Nil then Exit;
  FillChar (KeyMap, $80, False);        { ????砫쭮 ???⠥? ??? ??????? }
  KeyCount := 0;                        { ????饭?묨 }
  BufHead := 0;                         { -//- }
  BufTail := 0;                         { -//- }
  GetIntVec (9, Old_Handler);
  SetIntVec (9, @New_Handler)
End;

Procedure Remove_Handler;
Begin
  If Old_Handler = Nil then Exit;
  SetIntVec (9, Old_Handler);
  Old_Handler := Nil
End;

Procedure WaitForACSReleased;
Begin
  While Mem[$40:$17] and $0F <> 0 do
End;

Function KeyPressedNow : Boolean; Assembler;
{ ?? ??ᥬ????? ࠡ?⠥? ????॥, 祬 ?? ??᪠?? }
Asm
  Mov   AX, DS
  Mov   ES, AX
  LEA   DI, KeyMap+1                            { ??稭??? ? Escape }
  Mov   CX, 058h                                { ??? ??????? ???? F11 ? F12 }
  Mov   AL, FALSE                               { ?।????????, ??? ????? }
  CLD
  RepE  ScaSB                                   { ???????㥬 ???ᨢ KeyMap }
  JE    @end                                    { ????? }
  Mov   AL, TRUE                                { ???-?? ?????? }
@end:
End;

Function KeyPressed2 : Boolean;
Begin
  KeyPressed2 := KeyCount<>0                    { ????? ?? ???? }
End;

Function ReadScan : Byte;
Begin
  While KeyCount=0 do;
  ReadScan := KeyBuf[BufHead];
  Inc (BufHead);                                { ???饭?? ᫥???饩 ??????? }
  If BufHead = KeyBufSize then BufHead := 0;
  Dec (KeyCount)                                { ???? ??????? ????? }
End;

Function ReadChar : Char;
Begin
  ReadChar := SymMap[ReadScan]
End;

Procedure ClearKeyboardBuf;
Begin
  Asm PushF; CLI End;
  BufHead := BufTail;
  KeyCount := 0;
  Asm PopF End
End;

Var I : Byte;

Begin
  { ?????????? ???ᨢ? ᨬ????? }
  FillChar (SymMap, $80, 0);
  For I := sEsc to sSpace do
    SymMap[I] := Symbs[I];
  SymMap[sGrayMinus] := '-';
  SymMap[sGrayPlus] := '+'
End.
