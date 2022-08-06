Unit KeyPres2;

{ Обычно клавиатура посылает символы в компьютер }
{ с максимальной скоростью 4 штуки в секунду. }
{ Чтобы игрушка не простаивала в ожидании ввода с клавиатуры }
{ нужно реализовать следующий алгоритм: }
{ 1) в начале программы допустить, что все клавиши отпущены }
{    в цикле программы: }
{ 2) считать нажатыми те клавиши, которые не отпущены }
{ 3) по аналогии считать отпущенными не нажатые }
{ Собственно этот модуль и помогает реализовать сей алгоритм: }
{ Set_Handler -> 1) }
{ New_Handler -> 2), 3) }

Interface

{ Здесь сканкоды почти всех клавиш }

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
  sAsteriks     =     $37;              { *  на цифровой клавиатуре }
  sAlt          =     $38;
  sSpace        =     $39;              { пробел }
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
  sGrayMinus    =     $4A;              { -  на цифровой клавиатуре }
  sLeft         =     $4B;
  sFive         =     $4C;              { 5  на цифровой клавиатуре }
  sRight        =     $4D;
  sGrayPlus     =     $4E;              { +  на цифровой клавиатуре }
  sEnd          =     $4F;
  sDown         =     $50;
  sPageDown     =     $51;
  sInsert       =     $52;
  sDelete       =     $53;
  sF11          =     $57;
  sF12          =     $58;

Var
  KeyMap : Array [0..$7F] of Boolean;   { Смещение-сканкод клавиши, TRUE - }
                                        { нажата сейчас, FALSE - отпущена }
  SymMap : Array [0..$7F] of Char;      { Смещение-сканкод клавиши, }
                                        { содержимое - ASCII-символы для клавиш }

Procedure Set_Handler;
{ Устанавливает новый обработчик клавиатурного прерывания, }
{ когда новый обработчик активен, то НЕВОЗМОЖНО пользоваться }
{ KeyPressed, ReadKey и Read, а также останавливать программу }
{ по Ctrl+C (Ctrl+Break) или ее отлаживать. }
{ KeyPressed и ReadKey имеют аналоги - смотри ниже }

Procedure Remove_Handler;
{ Возвращает старый обработчик клавиатурного }
{ прерывания на его законное место }

Procedure WaitForACSReleased;
{ Ждет отпускания Alt,Ctrl,Shift; используется ТОЛЬКО ПЕРЕД }
{ установкой нового обработчика клавиатурного прерывания }

Function KeyPressedNow : Boolean;
{ Возвращает TRUE если в ДАННЫЙ момент времени }
{ действительно нажата хотябы одна клавиша, иначе возвращает FALSE. }
{ Используется вместе с массивами KeyMap и SymMap }

Function KeyPressed2 : Boolean;
{ Полный аналог ф-ции KeyPressed из модуля CRT. }

Function ReadScan : Byte;
{ Аналог ф-ции ReadKey (модуль CRT). }
{ Разница в том, что эта ф-ция возвращает }
{ не символ клавиши, а ее сканкод, позволяя }
{ добраться до каждой клавиши. }
{ Используется вместе с KeyPressed2 }

Function ReadChar : Char;
{ Аналог ф-ции ReadKey (модуль CRT). }
{ Разница в том, что эта ф-ция возвращает }
{ символ клавиши без учета состояний Alt,Ctrl,Shift и Caps Lock. }
{ Если нажатая клавиша не имеет на себе символа, то возвращается }
{ нулевой символ, ни о каких расширенных кодах здесь речи быть не }
{ может. Используется вместе с KeyPressed2 }

Procedure ClearKeyboardBuf;
{ Очищает кольцевой буфер, используемый ф-циями KeyPressedNow, KeyPressed2, }
{ ReadScan и ReadChar }

Implementation

Uses DOS;

Const
  Old_Handler : Pointer = Nil;          { Сюда сохраним адрес старого обработчика }
  KeyBufSize            = 16;           { Клавиатурный буфер будет содержать }
                                        { максимум 16 сканкодов }

  Symbs : Array [sEsc..sSpace] of Char =
    #27'1234567890-='#8#9'QWERTYUIOP[]'#13#0'ASDFGHJKL;''`'#0'\'+
    'ZXCVBNM,./'#0'*'#0' ';

Var
  KeyBuf : Array [0..KeyBufSize] of Byte;       { Кольцевой клавиатурный буфер }
  BufHead,                                      { Голова буфера }
  BufTail : Word;                               { Хвост буфера }
  KeyCount : Byte;                              { Кол-во сканкодов клавиш }
                                                { в буфере }

Procedure New_Handler; Interrupt; Assembler;
{ Using assembler because we need a fast interrupt-handling routine }
Asm
  Push  AX
  Push  BX
  In    AL, 060h
  Mov   AH, AL
  And   AL, 07Fh                                { AL = Сканкод }
  LEA   BX, KeyMap
  Add   BL, AL
  AdC   BH, 0
  Test  AH, 080h
  JNZ   @released                               { Старший бит - флаг отпускания }
  Mov   Byte Ptr [BX], TRUE                     { Клавиша была нажата }
  Cmp   KeyCount, KeyBufSize
  JE    @done                                   { Буфер битком набит }
  LEA   BX, KeyBuf
  Add   BX, BufTail
  Mov   [BX], AL                                { Сохранили сканкод в KeyBuf }
  Inc   KeyCount                                { More keys avaible to read }
  Inc   BufTail                                 { Следующая позиция для сохранения }
  Cmp   BufTail, KeyBufSize
  JNE   @done
  Mov   BufTail, 0                              { Скорректировали позицию }
  Jmp   @done
@released:
  Mov   Byte Ptr [BX], FALSE                    { Клавиша была отпущена }
@done:
  Mov   AL, 020h                                { Сообщили контроллеру }
  Out   020h, AL                                { прерываний, что прерывание }
                                                { обработано }
  Pop   BX
  Pop   AX
End;

Procedure Set_Handler;
Begin
  If Old_Handler <> Nil then Exit;
  FillChar (KeyMap, $80, False);        { Изначально считаем все клавиши }
  KeyCount := 0;                        { отпущенными }
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
{ На ассемблере работает шустрее, чем на Паскале }
Asm
  Mov   AX, DS
  Mov   ES, AX
  LEA   DI, KeyMap+1                            { Начинаем с Escape }
  Mov   CX, 058h                                { Все клавиши плюс F11 и F12 }
  Mov   AL, FALSE                               { Предположили, что пусто }
  CLD
  RepE  ScaSB                                   { Сканнируем массив KeyMap }
  JE    @end                                    { Пусто }
  Mov   AL, TRUE                                { Что-то нажато }
@end:
End;

Function KeyPressed2 : Boolean;
Begin
  KeyPressed2 := KeyCount<>0                    { Буфер не пуст }
End;

Function ReadScan : Byte;
Begin
  While KeyCount=0 do;
  ReadScan := KeyBuf[BufHead];
  Inc (BufHead);                                { Смещение следующей клавиши }
  If BufHead = KeyBufSize then BufHead := 0;
  Dec (KeyCount)                                { Одну клавишу долой }
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
  { Заполнение массива символов }
  FillChar (SymMap, $80, 0);
  For I := sEsc to sSpace do
    SymMap[I] := Symbs[I];
  SymMap[sGrayMinus] := '-';
  SymMap[sGrayPlus] := '+'
End.
