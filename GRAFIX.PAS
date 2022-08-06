Unit Grafix;
{$G+}

Interface

Type
  PFont = Pointer;                      { Тип - указатель на матричный шрифт }
  TPal = Array [0..255, 1..3] of Byte;  { Тип - палитра, хранит компоненты 256-ти }
                                        { цветов: красную, зеленую и синюю }
  THeader = Record                      { Структура заголовка VOB-файла }
    ID    : Array [1..12] of Char;      { Идентификатор }
    V, SV : Byte;                       { Версия и подверсия }
    L, H  : Word;                       { Ширина и высота }
    Mask  : Boolean;                    { Признак наличия маски }
    Pack  : Byte;                       { Признак упаковки }
    PSize,                              { Размер данных рисунка }
    MSize : Word;                       { Размер данных маски рисунка }
    Res   : Array [1..8] of Byte        { Резерв }
  End;
  TPoint = Record                       { Тип - точка. Нужен для рисования }
    X, Y : Integer                      { ломаных линий и многоугольников  }
  End;
  TPCXHeader = Record                   { Структура заголовка PCX-файла }
    Manufact,
    Ver,
    Encoding,
    BitsPerPixel : Byte;
    X1, Y1, X2, Y2,
    Hdpi, Vdpi : Word;
    ColorMap : Array [0..47] of Byte;
    Res,
    Planes : Byte;
    BytesPerLine,
    PalInfo,
    HScrSize,
    VScrSize : Word;
    Filler : Array [0..53] of Byte;
  End;

Const
  VSeg        = $A000;                  { Сегмент видео буфера }
  MaxX        = 319;
  MaxY        = 199;
  MaxColor    = 255;
  GetMaxX     = MaxX;
  GetMaxY     = MaxY;
  GetMaxColor = MaxColor;
  GrOk        = 0;                      { Нет ошибки }
  GrInit      = -1;                     { Ошибка при инициализации графики }
  GrLoadFont  = -2;                     { Ошибка при загрузке шрифта }
  GrLoadObj   = -3;                     { Ошибка при загрузке картинки }
  GrSaveObj   = -4;                     { Ошибка при записи картинки }

  Seq_Addr          = $3C4;
  CRTC_Addr         = $3D4;
  Misc_Output_Addr  = $3C2;
  Graph_Cntrl_Addr  = $3CE;

Var
  VSegA         : Word;                 { Сегмент активной видео страницы }
  GrResult      : Integer;              { Ошибка операции }
  CurFont       : PFont;                { Указатель на текущий шрифт }
  FontSize      : Word;                 { Объем текущего шрифта }
  FontX, FontY  : Byte;                 { Гориз. и верт. размеры шрифта }
  TranspColor   : Byte;                 { Цвет прозрачности спрайта }

  _Poly : Array [0..319,1..2] of Integer;       { Под рисование многоуг-ков }
                                                {                  и сдвиги }
  _LeftTable,
  _RightTable : Array [0..199,0..2] of Integer; { Под текстурную заливку }


Function IsVGA : Boolean;
{ Возвращает TRUE, если в системе установлена VGA-карта }

Procedure InitGraph;
{ Инициализирует графику; состояние в переменной GrResult }

Procedure CloseGraph;
{ Закрывает графику (устанавливает цвеиной текстовый режим 80x25) }

Procedure ClearScreen (C : Byte);
{ Очищает экран цветом C; на активной странице }

Procedure Border (C : Byte);
{ Устанавливает цвет C рамки экрана }

Procedure PutPixel (X, Y : Word; C : Byte);
{ Рисует точку в позиции (X,Y) цветом C; на активной странице }

Function GetPixel (X, Y : Word) : Byte;
{ Возвращет цвет точки в позиции (X,Y); а/с }

Procedure LineH (X, Y, L : Word; C : Byte);
{ Рисует горизонтальную линию от точки (X,Y) длины L цветом C; a/c }

Procedure LineV (X, Y, H : Word; C : Byte);
{ Рисует вертикальную линию от точки (X,Y) высоты H цветом C; a/c }

Procedure Line (X1, Y1, X2, Y2 : Word; C : Byte);
{ Рисует линию, соединяющую точки (X1,Y1) и (X2,Y2), цветом C; a/c }

Procedure Box (X, Y, L, H : Word; C : Byte; Fill : Boolean);
{ Рисует прямоугольник от точки (X,Y) длины L и высоты H цветом C,
  если Fill = True, то прямоугольник закрашивается тем же цветом; а/с }

Procedure Circle (X, Y, R : Word; C : Byte; Fill : Boolean);
{ Рисует окружность цвета C с центром в точке (X,Y) радиуса R;
  если Fill = True, то окружность закрашивается тем же цветом; а/с }

Procedure Fill (X, Y : Word; C : Byte);
{ Перекрашивает одноцветную область, в которую попала точка (X,Y),
  в новый цвет - C; требует 120 тыс. байт с копейками свободной
  памяти в куче; то жутко тормозящая процедура; а/с }

Procedure DrawPoly (Num : Word; PolyPoints : Array of TPoint; C : Byte);
{ Рисует ломаную цвета C по ее Num вершинам в PolyPoints; а/с }

Procedure DrawPoly2 (Num : Word; PolyPoints : Array of TPoint; C : Byte);
{ Рисует замкнутую ломаную цвета C по ее Num вершинам в
  PolyPoints; а/с }

Procedure FillPoly (Num : Word; PolyPoints : Array of TPoint; C : Byte);
{ Рисует сплошной многоугольник цвета C по его Num вершинам в
  PolyPoints; а/с }

Procedure FillPolyPat (Num : Word; PolyPoints : Array of TPoint;
                                                L, H : Word; Var Pat);
{ Заполняет многоугольник с Num вершинами в PolyPoints одинаковыми
  прямоугольниками (размер LxH точек), изображение которых хранится
  в L*H-байтном массиве Pat; а/с }

Procedure LoadFont (Name : String; Var PF : PFont; Var Size : Word);
{ Загружает матричный шрифт с дисковым именем Name, резервируя память
  для PF, в Size возвращается объем зарезервированной памяти;
  состояние в переменной GrResult }

Procedure SetFont (PF : PFont);
{ Устанавливает текущий шрифт, по указателю на него PF }

Procedure WriteC (X, Y : Word; B, T : Byte; C : Char);
{ Отображает символ C в позиции (X,Y), цветом T на фоне B;
  если B = T, то фон не изменяется; а/с }

Procedure WriteS (X, Y : Word; B, T : Byte; S : String);
{ Аналогично процедуре WriteC отображает строку S; а/с }

Procedure ReadS (X, Y : Word; B, T : Byte; Var S : String; N : Byte);
{ Считывает (изменяет) с клавиатуры строку S максимальной длины N,
  одновременно производится ее отображение на экране, условия
  отображения такие же как и в процедуре WriteC; примеч.: по клавише
  ESC ввод заканчивается с возвращением пустой строки; а/с }

Function ImageSize (L, H : Word) : Word;
{ Возвращает объем требуемой памяти для сохранения в ней
  прямоугольного участка изображения размером L x H }

Procedure GetImage (X, Y, L, H : Word; Var BitMap);
{ Сохраняет в переменной BitMap прямоугольный участок изображения
  из позиции (X,Y) размером L x H; а/с }

Procedure GetClippedImage (X, Y : Integer; L, H : Word; Var BitMap);
{ Делает то же, что и GetImage, с той лишь разницей, что картинка не
  обязательно должна полностью умещаться на экране, что было необходимо
  для правильной работы GetImage }

Procedure PutImage (X, Y : Word; Var BitMap);
{ Восстанавливает из переменной BitMap прямоугольный участок
  изображения в позицию (X,Y); а/с }

Procedure PutTranspImage (X, Y : Word; Var BitMap);
{ Восстанавливает из переменной BitMap "прозрачный" прямоугольный
  участок изображения в позицию (X,Y); цвет прозрачности хранится
  в TranspColor; а/с }

Procedure PutImagePart (X, Y : Word; Var BitMap; PX, PY, PL, PH : Word);
{ Отображает прямоугольную часть от картинки BitMap в позицию (X,Y) на
  экране; (PX,PY) - левый верхний угол прямоугольника в картинке, PL и
  PH задают размер прямоугольника; а/с }

Procedure PutTranspImagePart (X, Y : Word; Var BitMap; PX, PY, PL, PH : Word);
{ Отображает прямоугольную часть от "прозрачной" картинки BitMap в
  позицию (X,Y) на экране; (PX,PY) - левый верхний угол прямоугольника
  в картинке, PL и PH задают размер прямоугольника; а/с }

Procedure PutClippedImage (X, Y : Integer; Var BitMap);
{ Делает то же, что и PutImage, с той лишь разницей, что картинка не
  обязательно должна полностью умещаться на экране, что было необходимо
  для правильной работы PutImage }

Procedure PutTranspClippedImage (X, Y : Integer; Var BitMap);
{ Делает то же, что и PutImage, с той лишь разницей, что "прозрачная"
  картинка не обязательно должна полностью умещаться на экране,
  что было необходимо для правильной работы PutImage }

Procedure PutClippedImagePart (X, Y : Integer; Var BitMap; PX, PY, PL, PH : Word);
{ Делает то же, что и PutImagePart, с той лишь разницей, что
  картинка не обязательно должна полностью умещаться на экране,
  что было необходимо для правильной работы PutImagePart }

Procedure PutTranspClippedImagePart (X, Y : Integer; Var BitMap; PX, PY, PL, PH : Word);
{ Делает то же, что и PutTranspImagePart, с той лишь разницей, что
  "прозрачная" картинка не обязательно должна полностью умещаться на
  экране, что было необходимо для правильной работы PutTranspImagePart }

Procedure LoadObject (Name : String; Var PBitMap : Pointer; Var Size : Word);
{ Загружает прямоугольную картинку с дисковым именем Name,
  резервируя память для PBitMap, в Size возвращается объем
  зарезервированной памяти; возможно последующее отображение
  с помощью всяких PutImage'й }

Procedure LoadPCX256 (Name : String; Var PBitMap : Pointer; Var Size : Word;
                      Var Pal : TPal);
{ Загружает прямоугольную 256 цветную PCX-картинку с дисковым именем
  Name, резервируя память для PBitMap, в Size возвращается объем
  зарезервированной памяти; возможно последующее отображение
  с помощью всех PutImage'й, кроме PutImageM }

Procedure SavePCX256 (Name : String; X, Y, L, H : Word);
{ Записывает в файл с именем Name прямоугольный участок изображения
  с активной страницы в формате PCX; (X,Y) и LxH - координаты и
  размеры участка изображения на странице }

Procedure PutImageM (X, Y : Word; Var BitMap);
{ Восстанавливает из переменной BitMap прямоугольный участок
  изображения, имеющего маску, в позицию (X,Y); вначале на экран
  накладывается по AND маска, затем накладывается по XOR сама
  картинка, - это для того, чтобы изображение на экране не
  выглядело чем-то на фоне непонятной прямоугольной тени
  (иными словами, чтобы не затирался полностью фон картинки); а/с }

Procedure SetActivePage (PageSeg : Word);
{ Переключает активную страницу, куда будет выводится графическая
  информация, точнее переключает сегмент памяти этой страницы,
  примеч.: под страницу должна быть зарезервирована память объемом
  64000 байт, а чтобы переключиться на отображаемую страницу,
  достаточно указать PageSeg равным VSeg ($A000) }

Procedure DisplayPage (PageSeg : Word);
{ Отображает активную страницу по ее сегменту PageSeg на экран }

Procedure DisplayBox (PageSeg, X, Y, L, H : Word);
{ Отображает прямоугольный участок активной страницы по ее
  сегменту памяти и параметрам участка: (X,Y) и LxH }

Procedure WaitRetrace;
{ Дожидается момента возврата луча из правого нижнего угла электронно- }
{ лучевой трубки в левый верхний. Графические манипуляции в этот момент}
{ не будут вызывати мелькания на экране. В этот момент удобно менять   }
{ палитру; восстанавливать фоновое изображение под спрайтом и          }
{ рисовать другой спрайт в этой позиции или тот что был, но в          }
{ другой позиции.                                                      }

Procedure GetCRGB (C : Byte; Var R, G, B : Byte);
{ Возвращает содержание красной, зеленой и синей компонент для
  цвета C в текущей палитре }

Procedure SetCRGB (C : Byte; R, G, B : Byte);
{ Устанавливает содержание красной, зеленой и синей компонент для
  цвета C в текущей палитре }

Procedure GetPal (Var Pal);
{ Возвращает в Pal текущую палитру }

Procedure SetPal (Var Pal);
{ Устанавливает палитру Pal текущей }

Procedure FadeUp (Pal : TPal);
{ Плавно "проявляет" текущую палитру до палитры Pal }

Procedure FadeDown;
{ Плавно "гасит" текущую палитру }

Procedure BlackOutPut;
{ Обнуляет текущую палитру, делая ее черной }

Procedure TextureMapPoly (X1,Y1, X2,Y2, X3,Y3, X4,Y4, L, H : Integer;
                                                             PicSeg : Word);
{ Заливает четыреугольник с заданными координатами текстурой;
  PicSeg - сегмент адреса текстуры, размещенной в куче (при
  помощи GetMem или New), LxH - размер текстуры; примечание:
  первая координата соответствует левому верхнему углу текстуры,
  координаты располагаются по часовой стрелке }

Procedure TextureMapPoly2 (X1,Y1, X2,Y2, X3,Y3, X4,Y4, L, H : Integer;
                                                   N : Byte; PicSeg : Word);
{ Выполняет то же, что и процедура TextureMapPoly, но с той }  { N: ┌─┬─┐ }
{ разницей, что в L и H указываются размеры четверти текстуры }   { │0│1│ }
{ (половины ширины и высоты текстуры), а в N - номер четверти }   { ├─┼─┤ }
{ текстуры. Нужно это для изображения близких к глазу трех-   }   { │2│3│ }
{ мерных объектов, которые выглядят просто ужасно при исполь- }   { └─┴─┘ }
{ зовании TextureMapPoly. }

Procedure DisplayOff;
{ "Выключает" дисплей - он становится черным (графический режим) }

Procedure DisplayOn;
{ "Включает" дисплей - изображение появляется вновь (графический режим) }

Implementation

Uses
  CRT, Packer;

Function IsVGA : Boolean; Assembler;
Asm
  Mov   AX, 1A00h
  Int   10h
  Cmp   AL, 1Ah
  JNE   @@NotVGA
  Cmp   BL, 7
  JE    @@VGA
  Cmp   BL, 8
  JE    @@VGA
@@NotVGA:
  Mov   AL, 0
  Jmp   @@Quit
@@VGA:
  Mov   AL, 1
@@Quit:
End;

Procedure InitGraph; Assembler;
Asm
  Mov   AX, 013H
  Int   010H
  Mov   AH, 00FH
  Int   010H
  Cmp   AL, 013H
  JNE   @1
  Mov   GrResult, GrOk
  Jmp   @2
@1:
  Mov   GrResult, GrInit
@2:
End;

Procedure CloseGraph; Assembler;
Asm
  Mov   AX, 003H
  Int   010H
End;

Procedure ClearScreen (C : Byte); Assembler;
Asm
  Mov   AX, VSegA
  Mov   ES, AX
  Xor   DI, DI
  CLD
  Mov   AL, C
  Mov   AH, AL
  Mov   CX, 32000
  Rep   STOSW
End;

Procedure Border (C : Byte); Assembler;
Asm
  Mov   AX, 01001H
  Mov   BH, C
  Int   010H
End;

Procedure PutPixel (X, Y : Word; C : Byte); Assembler;
Asm
  Mov   AX, VSegA
  Mov   ES, AX
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AL, C
  STOSB
End;

Function GetPixel (X, Y : Word) : Byte; Assembler;
Asm
  Mov   AX, VSegA
  Mov   ES, AX
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AL, ES:[DI]
End;

Procedure LineH (X, Y, L : Word; C : Byte); Assembler;
Asm
  Mov   AX, VSegA
  Mov   ES, AX
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AL, C
  Mov   CX, L
  CLD
  Rep   STOSB
End;

Procedure LineV (X, Y, H : Word; C : Byte); Assembler;
Asm
  Mov   AX, VSegA
  Mov   ES, AX
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AL, C
  Mov   CX, H
  CLD
@1:
  STOSB
  Add   DI, 319
  Loop  @1
End;

Function Sgn (I : Integer) : Integer; Assembler;
Asm
  Mov   AX, I
  Or    AX, AX
  JZ    @end
  ShL   AX, 1
  JC    @1
  Mov   AX, 1
  Jmp   @end
@1:
  Mov   AX, -1
@end:
End;

Function _Abs (I : Integer) : Integer; Assembler;
Asm
  Mov   AX, I
  Test  AX, 8000h
  JZ    @end
  Neg   AX
@end:
End;

Procedure Line (X1, Y1, X2, Y2 : Word; C : Byte);
Var
  SX, SY, M, N,
  DX1, DY1, DX2, DY2 : Integer;
Begin
  SX := X2-X1;
  SY := Y2-Y1;
  DX1 := Sgn (SX);
  DY1 := Sgn (SY);
  M := _Abs (SX);
  N := _Abs (SY);
  DX2 := DX1;
  DY2 := 0;
  If M < N then
    Begin
      M := _Abs (SY);
      N := _Abs (SX);
      DX2 := 0;
      DY2 := DY1
    End;
  Asm
    Mov   AX, VSegA
    Mov   ES, AX
    Mov   DI, X1
    Mov   BX, Y1
    ShL   BX, 6
    Add   DI, BX
    ShL   BX, 2
    Add   DI, BX                                { ES:DI = ^ на первую точку }

    Mov   AX, DY1
    Test  AX, 8000h
    JZ    @lb0
    Neg   AX
    ShL   AX, 6
    Mov   BX, AX
    ShL   AX, 2
    Add   BX, AX
    Neg   BX
    Jmp   @lb1
@lb0:
    ShL   AX, 6
    Mov   BX, AX
    ShL   AX, 2
    Add   BX, AX
@lb1:
    Add   BX, DX1

    Mov   AX, DY2
    Test  AX, 8000h
    JZ    @lb2
    Neg   AX
    ShL   AX, 6
    Mov   DX, AX
    ShL   AX, 2
    Add   DX, AX
    Neg   DX
    Jmp   @lb3
@lb2:
    ShL   AX, 6
    Mov   DX, AX
    ShL   AX, 2
    Add   DX, AX
@lb3:
    Add   DX, DX2

    Mov   AL, C
    Xor   SI, SI
    Mov   CX, M
    Inc   CX
@cycle:
    Mov   ES:[DI], AL
    Add   SI, N
    Cmp   SI, M
    JC    @cl1
    Sub   SI, M
    Add   DI, BX                                { + Смещение след. элемента }
    Loop  @cycle
    Jmp   @end
@cl1:
    Add   DI, DX                                { + Смещение след. точки }
    Loop  @cycle
@end:
  End
End;

Procedure Box (X, Y, L, H : Word; C : Byte; Fill : Boolean);
Begin
  If L or H = 0 then Exit;
  If not Fill then
    Begin
      LineH (X, Y, L, C);
      LineH (X, Y+H-1, L, C);
      LineV (X, Y, H, C);
      LineV (X+L-1, Y, H, C)
    End
  Else
    Asm
      Mov   AX, VSegA
      Mov   ES, AX
      Mov   DI, X
      Mov   BX, Y
      ShL   BX, 6
      Add   DI, BX
      ShL   BX, 2
      Add   DI, BX
      CLD
      Mov   BX, L
      Mov   DX, H
      Mov   AL, C
@1:
      Push  DI
      Mov   CX, BX
      Rep   STOSB
      Pop   DI
      Add   DI, 320
      Dec   DX
      JNZ   @1
    End
End;

Function SqrWN (X : Word) : Byte; Assembler; { Yi+1 = (Yi + X/Yi) / 2 }
{ Возвращает корень, квадрат которого является ближайшим к аргумету }
Asm
  Mov   CX, X
  Push  BP
  Mov   BP, 1
  Mov   BX, CX
  JCXZ  @end2
  Cmp   CX, 0FFFFH
  JNE   @cycle
  Mov   BX, 0FFH
  Jmp   @end2
@cycle:
  Xor   DX, DX
  Mov   AX, CX
  Div   BX
  Add   AX, BX
  Shr   AX, 1
  Mov   DI, SI
  Mov   SI, BX
  Mov   BX, AX
  Inc   BP
  Cmp   BX, SI
  JE    @end
  Cmp   BP, 3
  JC    @cycle
  Cmp   BX, DI
  JNE   @cycle
  Cmp   SI, BX
  JNC   @end
  Mov   BX, SI
@end:
  Mov   AX, BX
  Mul   BX
  Sub   AX, CX
  Neg   AX
  Inc   AX
  Mov   SI, AX                  { разница аргумента и квадрата корня }
  Inc   BX
  Mov   AX, BX
  Mul   BX
  Sub   AX, CX                  { разница арг. и квадрата увеличенного корня }
  Cmp   AX, SI
  JC    @end2
  Dec   BX
@end2:
  Pop   BP
  Mov   AX, BX
End;

Procedure Circle (X, Y, R : Word; C : Byte; Fill : Boolean);
Var
  A, B : Word;
begin
  If R = 0 then Exit;
  If not Fill then
    For A := 0 to R do
      Begin
        B := SqrWN(Sqr(R)-Sqr(A));
        PutPixel (X-A, Y-B, C);
        PutPixel (X+A, Y-B, C);
        PutPixel (X-A, Y+B, C);
        PutPixel (X+A, Y+B, C);
        PutPixel (X-B, Y-A, C);
        PutPixel (X-B, Y+A, C);
        PutPixel (X+B, Y-A, C);
        PutPixel (X+B, Y+A, C)
      End
  Else
    For A := 0 to R do
      Begin
        B := SqrWN(Sqr(R)-Sqr(A));
        LineH (X-B, Y-A, 1+B shl 1, C);
        LineH (X-B, Y+A, 1+B shl 1, C)
      End
End;

Procedure Fill (X, Y : Word; C : Byte);
Var
  P1, P2     : Pointer;
  Sg1, Sg2, P,
  ZX, ZY, ZP : Word;
  CO         : Byte;
Begin
  GetMem (P1, 64000);
  GetMem (P2, 64000);
  Sg1 := Seg(P1^);
  Sg2 := Seg(P2^);
Asm
  Mov   AX, VSegA
  Mov   ES, AX
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AL, ES:[DI]
  Cmp   AL, C
  JE    @end
  Mov   CO, AL
  Mov   ZP, 0
  Mov   AX, X
  Mov   ZX, AX
  Mov   AX, Y
  Mov   ZY, AX
@cycle:
  Mov   AX, VSegA
  Mov   ES, AX
  Mov   DI, ZX
  Mov   BX, ZY
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   P, DI
  Mov   AL, C
  Mov   ES:[DI], AL

  Mov   AX, ZX
  Or    AX, AX
  JZ    @l2
  Mov   AL, ES:[DI-1]
  Cmp   AL, CO
  JNE   @l2
  Dec   DI
  Push  ES
  Mov   AX, Sg1
  Mov   BX, ZP
  Cmp   BX, 32000
  JC    @l1
  Mov   AX, Sg2
  Sub   BX, 32000
@l1:
  Mov   ES, AX
  Shl   BX, 1
  Mov   ES:[BX], DI
  Inc   ZP
  Pop   ES
  Inc   DI
@l2:
  Mov   AX, ZX
  Cmp   AX, 319
  JNC   @r2
  Mov   AL, ES:[DI+1]
  Cmp   AL, CO
  JNE   @r2
  Inc   DI
  Push  ES
  Mov   AX, Sg1
  Mov   BX, ZP
  Cmp   BX, 32000
  JC    @r1
  Mov   AX, Sg2
  Sub   BX, 32000
@r1:
  Mov   ES, AX
  Shl   BX, 1
  Mov   ES:[BX], DI
  Inc   ZP
  Pop   ES
  Dec   DI
@r2:
  Mov   AX, ZY
  Or    AX, AX
  JZ    @u2
  Mov   AL, ES:[DI-320]
  Cmp   AL, CO
  JNE   @u2
  Sub   DI, 320
  Push  ES
  Mov   AX, Sg1
  Mov   BX, ZP
  Cmp   BX, 32000
  JC    @u1
  Mov   AX, Sg2
  Sub   BX, 32000
@u1:
  Mov   ES, AX
  Shl   BX, 1
  Mov   ES:[BX], DI
  Inc   ZP
  Pop   ES
  Add   DI, 320
@u2:
  Mov   AX, ZY
  Cmp   AX, 199
  JNC   @d2
  Mov   AL, ES:[DI+320]
  Cmp   AL, CO
  JNE   @d2
  Add   DI, 320
  Push  ES
  Mov   AX, Sg1
  Mov   BX, ZP
  Cmp   BX, 32000
  JC    @d1
  Mov   AX, Sg2
  Sub   BX, 32000
@d1:
  Mov   ES, AX
  Shl   BX, 1
  Mov   ES:[BX], DI
  Inc   ZP
  Pop   ES
  Sub   DI, 320
@d2:
  Mov   BX, ZP
  Or    BX, BX
  JZ    @end
  Dec   BX
  Mov   ZP, BX
  Mov   AX, Sg1
  Cmp   BX, 32000
  JC    @p1
  Mov   AX, Sg2
  Sub   BX, 32000
@p1:
  Mov   ES, AX
  Shl   BX, 1
  Mov   AX, ES:[BX]
  Mov   P, AX

  Mov   AX, P
  Xor   DX, DX
  Mov   BX, 320
  Div   BX
  Mov   ZY, AX
  Mov   ZX, DX
  Jmp   @cycle
@end:
End;
  FreeMem (P2, 64000);
  FreeMem (P1, 64000)
End;

Procedure DrawPoly (Num : Word; PolyPoints : Array of TPoint; C : Byte);
Var I : Word;
Begin
  If Num > 1 then
    For I := 0 to Num-2 do Begin
      Line (PolyPoints[I].X, PolyPoints[I].Y,
            PolyPoints[I+1].X, PolyPoints[I+1].Y, C)
    End
End;

Procedure DrawPoly2 (Num : Word; PolyPoints : Array of TPoint; C : Byte);
Var I : Word;
Begin
  If Num > 0 then Begin
    For I := 0 to Num-2 do Begin
      Line (PolyPoints[I].X, PolyPoints[I].Y,
            PolyPoints[I+1].X, PolyPoints[I+1].Y, C)
    End;
    Line (PolyPoints[Num-1].X, PolyPoints[Num-1].Y,
          PolyPoints[0].X, PolyPoints[0].Y, C)
  End
End;

Procedure FillPoly (Num : Word; PolyPoints : Array of TPoint; C : Byte);
Var I, Y, Ymin, Ymax : Integer;
  Procedure DoSide (X1, Y1, X2, Y2 : Integer);
  Var
    Temp, I, X, Y,
    SX, SY, M, N,
    DX1, DY1, DX2, DY2 : Integer;
  Begin
    SX := X2-X1; SY := Y2-Y1;
    DX1 := Sgn(SX); DY1 := Sgn(SY);
    M := _Abs(SX); N := _Abs(SY);
    DX2 := DX1; DY2 := 0;
    If M < N then Begin
      M := _Abs(SY); N := _Abs(SX);
      DX2 := 0; DY2 := DY1
    End;
    X := X1; Y := Y1;
    Temp := 0;
    For I := 0 to M do Begin
      If (Y >= 0) and (Y <= 199) then Begin
        If X < _Poly[Y,1] then _Poly[Y,1] := X;
        If X > _Poly[Y,2] then _Poly[Y,2] := X
      End;
      Inc (Temp, N);
      If Temp < M then Begin
        Inc (X, DX2); Inc (Y, DY2)
      End
      Else Begin
        Dec (Temp, M);
        Inc (X, DX1); Inc (Y, DY1)
      End
    End
  End;
Begin
  If Num < 3 then Exit;
  Ymin := PolyPoints[0].Y; Ymax := Ymin;
  For I := 0 to Num-1 do Begin
    If PolyPoints[I].Y < Ymin then Ymin := PolyPoints[I].Y;
    If PolyPoints[I].Y > Ymax then Ymax := PolyPoints[I].Y
  End;
  If (Ymin > 199) or (Ymax < 0) then Exit;
  If Ymin < 0 then Ymin := 0; If Ymax > 199 then Ymax := 199;
  For Y := Ymin to Ymax do Begin
    _Poly[Y,1] := 320; _Poly[Y,2] := -1
  End;
  For I := 0 to Num-2 do
    DoSide (PolyPoints[I].X, PolyPoints[I].Y,
            PolyPoints[I+1].X, PolyPoints[I+1].Y);
  DoSide (PolyPoints[Num-1].X, PolyPoints[Num-1].Y,
          PolyPoints[0].X, PolyPoints[0].Y);
  For Y := Ymin to Ymax do Begin
    If _Poly[Y,1] < 0 then _Poly[Y,1] := 0;
    If _Poly[Y,2] > 319 then _Poly[Y,2] := 319;
    LineH (_Poly[Y,1], Y, _Poly[Y,2]-_Poly[Y,1]+1, C)
  End
End;

Procedure FillPolyPat (Num : Word; PolyPoints : Array of TPoint;
                                                L, H : Word; Var Pat);
Var
  I, X, Y, Ymin, Ymax : Integer;
  PA : Array [0..63999] of byte absolute Pat;
  Procedure DoSide (X1, Y1, X2, Y2 : Integer);
  Var
    Temp, I, X, Y,
    SX, SY, M, N,
    DX1, DY1, DX2, DY2 : Integer;
  Begin
    SX := X2-X1; SY := Y2-Y1;
    DX1 := Sgn(SX); DY1 := Sgn(SY);
    M := _Abs(SX); N := _Abs(SY);
    DX2 := DX1; DY2 := 0;
    If M < N then Begin
      M := _Abs(SY); N := _Abs(SX);
      DX2 := 0; DY2 := DY1
    End;
    X := X1; Y := Y1;
    Temp := 0;
    For I := 0 to M do Begin
      If (Y >= 0) and (Y <= 199) then Begin
        If X < _Poly[Y,1] then _Poly[Y,1] := X;
        If X > _Poly[Y,2] then _Poly[Y,2] := X
      End;
      Inc (Temp, N);
      If Temp < M then Begin
        Inc (X, DX2); Inc (Y, DY2)
      End
      Else Begin
        Dec (Temp, M);
        Inc (X, DX1); Inc (Y, DY1)
      End
    End
  End;
Begin
  If Num < 3 then Exit;
  Ymin := PolyPoints[0].Y; Ymax := Ymin;
  For I := 0 to Num-1 do Begin
    If PolyPoints[I].Y < Ymin then Ymin := PolyPoints[I].Y;
    If PolyPoints[I].Y > Ymax then Ymax := PolyPoints[I].Y
  End;
  If (Ymin > 199) or (Ymax < 0) then Exit;
  If Ymin < 0 then Ymin := 0; If Ymax > 199 then Ymax := 199;
  For Y := Ymin to Ymax do Begin
    _Poly[Y,1] := 320; _Poly[Y,2] := -1
  End;
  For I := 0 to Num-2 do
    DoSide (PolyPoints[I].X, PolyPoints[I].Y,
            PolyPoints[I+1].X, PolyPoints[I+1].Y);
  DoSide (PolyPoints[Num-1].X, PolyPoints[Num-1].Y,
          PolyPoints[0].X, PolyPoints[0].Y);
  For Y := Ymin to Ymax do Begin
    If _Poly[Y,1] < 0 then _Poly[Y,1] := 0;
    If _Poly[Y,2] > 319 then _Poly[Y,2] := 319;
    I := L * (Y mod H);
    For X := _Poly[Y,1] to _Poly[Y,2] do
      PutPixel (X, Y, PA[I + (X mod 8)])
  End
End;

Procedure LoadFont (Name : String; Var PF : PFont; Var Size : Word);
Var
  F : File;
Label
  LErr;
Begin
  PF := nil;
  Assign (F, Name);
  {$i-}
  Reset (F, 1);
  {$i+}
  If IOResult <> 0 then
    Begin
LErr:
      If PF <> nil then
        FreeMem (PF, Size);
      PF := nil;
      Size := 0;
      GrResult := GrLoadFont;
      Exit
    End;
  {$i-} Size := FileSize(F); {$i+}
  If IOResult <> 0 then Goto LErr;
  GetMem (PF, Size);
  {$i-} BlockRead (F, PF^, Size); {$i+}
  If IOResult <> 0 then Goto LErr;
  {$i-} Close (F); {$i+}
  If IOResult <> 0 then Goto LErr;
  GrResult := GrOk
End;

Procedure SetFont (PF : PFont);
Begin
  FontX := Lo(Word(PF^));
  FontY := Hi(Word(PF^));
  CurFont := PF
End;

Procedure WriteC (X, Y : Word; B, T : Byte; C : Char); Assembler;
Asm
  Push  BP
  Push  DS
  Mov   AX, Word Ptr CurFont+2
  Mov   ES, AX
  Mov   DI, Word Ptr CurFont            { ES:DI - Font Addr }
  Mov   CX, AX
  Or    CX, DI
  JZ    @End                            { ES:DI - nil }
  Add   DI, 2
  Xor   AH, AH
  Mov   AL, C
  Shl   AX, 1
  Shl   AX, 1
  Shl   AX, 1
  Add   DI, AX                          { ES:DI - Char Addr }
  Mov   AH, FontY
  Mov   AL, FontX                       { Char size -> stack }
  Push  AX
  Mov   AX, VSegA
  Mov   DS, AX
  Mov   AX, Y
  Mov   BX, 320
  Mul   BX
  Add   AX, X
  Mov   BX, AX                          { DS:BX - Screen Addr }
  Mov   DH, B
  Mov   DL, T                           { DX - Colors Back & Text }
  Mov   AX, SP
  Mov   BP, AX
  Mov   CH, SS:[BP+1]
@1:
  Mov   CL, SS:[BP]
  Push  BX
  Mov   AL, ES:[DI]
@2:
  Mov   AH, DL
  Shl   AL, 1
  JC    @Put
  Cmp   DH, DL
  JE    @NoPut
  Mov   AH, DH
@Put:
  Mov   DS:[BX], AH
@NoPut:
  Inc   BX
  Dec   CL
  JNZ   @2
  Inc   DI
  Pop   BX
  Add   BX, 320
  Dec   CH
  JNZ   @1
  Pop   AX
@End:
  Pop   DS
  Pop   BP
End;

Procedure WriteS (X, Y : Word; B, T : Byte; S : String);
Var
  N  : Byte;
Begin
  If S = '' then Exit;
  For N := 1 to Length(S) do
    Begin
      WriteC (X, Y, B, T, S[N]);
      Inc (X, FontX)
    End
End;

Procedure ReadS (X, Y : Word; B, T : Byte; Var S : String; N : Byte);
Const
  CM = 20;
Var
  C : Char;
  P : Byte;
  Cnt : Byte;
Begin
  Box (X, Y, N*FontX, FontY, B, True);
  WriteS (X, Y, B, T, S);
  P := Length(S);
  If P < N then
    WriteC (X+P*FontX, Y, B, T, '_');
  Cnt := 0;
  Repeat
    If KeyPressed then C := ReadKey
    Else C := #$FF;
    If C = #0 then
      Begin
        ReadKey;
        C := #$FF
      End;
    If C = #27 then
      Begin
        S := '';
        Break
      End;
    If C = #13 then Break;
    If (C = #8) and (P > 0) then
      Begin
        Dec (S[0]);
        If P < N then
          WriteC (X+P*FontX, Y, B, T, ' ');
        Dec (P);
        WriteC (X+P*FontX, Y, B, T, '_');
        Continue
      End;
    If (C in [#32..#254]) and (P < N) then
      Begin
        S := S + C;
        WriteC (X+P*FontX, Y, B, T, C);
        Inc (P);
        If P < N then
          WriteC (X+P*FontX, Y, B, T, '_')
      End;
      Delay (20);
      Inc (Cnt);
      If Cnt = CM then Cnt := 0;
      If P < N then
        If Cnt < CM div 2 then
          WriteC (X+P*FontX, Y, B, T, '_')
        Else
          WriteC (X+P*FontX, Y, B, T, ' ')
  Until False
End;

Function ImageSize (L, H : Word) : Word;
Begin
  ImageSize := 4+L*H
End;

Procedure GetImage (X, Y, L, H : Word; Var BitMap); Assembler;
Asm
  Push  DS
  Mov   AX, H
  Push  AX
  Mov   DX, L
  LES   DI, BitMap                      { ES:DI - Memory Addr (BitMap^) }
  Mov   SI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   SI, BX
  ShL   BX, 2
  Add   SI, BX
  Mov   AX, VSegA
  Mov   DS, AX                          { DS:SI - Screen Addr }
  Mov   ES:[DI], DX
  Pop   AX
  Mov   ES:[DI+2], AX                   { L & H -> BitMap }
  Add   DI, 4
  CLD
  Shr   DX, 1
  JC    @2                              { If L is ODD }
@1:
  Mov   BX, SI
  Mov   CX, DX
  Rep   MovSW
  Mov   SI, BX
  Add   SI, 320
  Dec   AX
  JNZ   @1
  Pop   DS
  Jmp   @end
@2:
  Mov   BX, SI
  Mov   CX, DX
  MovSB
  Rep   MovSW
  Mov   SI, BX
  Add   SI, 320
  Dec   AX
  JNZ   @2
  Pop   DS
@end:
End;

Procedure GetImagePart (X, Y, L, H : Word; Var BitMap; PX, PY, PL, PH : Word); Assembler;
Asm
  Push  DS
  Push  BP
  Mov   SI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   SI, BX
  ShL   BX, 2
  Add   SI, BX
  Mov   AX, VSegA
  Mov   DS, AX                          { DS:SI - Screen Addr }

  LES   DI, BitMap                      { ES:DI - ^BitMap }
  Mov   AX, L
  Mov   Word Ptr ES:[DI], AX
  Mov   AX, H
  Mov   Word Ptr ES:[DI+2], AX

  Mov   AX, PY
  Mul   L                               { DX:AX - vertical offset in image }
  Add   AX, 4
  Add   AX, PX

  Mov   DX, PL                          { Output length }
  Mov   BX, PH                          { Output height }
  Mov   BP, L                           { Image length }

  Add   DI, AX                          { ES:DI - correct starting addr }

  CLD
  Shr   DX, 1
  JC    @2
@1:
  Mov   AX, SI
  Mov   CX, DX
  Push  DI
  Rep   MovSW
  Pop   DI
  Add   DI, BP
  Mov   SI, AX
  Add   SI, 320
  Dec   BX
  JNZ   @1
  Jmp   @end
@2:
  Mov   AX, SI
  Mov   CX, DX
  Push  DI
  Rep   MovSW
  MovSB
  Pop   DI
  Add   DI, BP
  Mov   SI, AX
  Add   SI, 320
  Dec   BX
  JNZ   @2
@end:
  Pop   BP
  Pop   DS
End;

Procedure GetClippedImage (X, Y : Integer; L, H : Word; Var BitMap);
Var
  Dims : Array [0..1] of Word absolute BitMap; {Dims[0]=Length;Dims[1]=Height}
  RX, RY, RL, RH, IX, IY : Integer;
Begin
  If (X > 319) or (Y > 199) then Exit;          { Image is out of screen }
  RX := X; RY := Y;                             { Start X & Y at screen }
  RL := L; RH := H;                             { Length & Height at begining }
  IX := 0; IY := 0;                             { IX & IY - coos in image to }
                                                { start drawin it (at begining) }
  If RX < 0 then Begin
    Inc (RL, RX);                               { Output length corrected }
    Dec (IX, RX);                               { IX corrected }
    RX := 0                                     { Screen X corrected }
  End;
  If RY < 0 then Begin
    Inc (RH, RY);                               { Output height corrected }
    Dec (IY, RY);                               { IY corrected }
    RY := 0                                     { Screen Y corrected }
  End;
  If (RL <= 0) or (RH <= 0) then Exit;          { Image is out of screen }
  If RX+RL > 320 then RL := 320-RX;             { Last correct in a length }
  If RY+RH > 200 then RH := 200-RY;             { Last correct in a height }
  GetImagePart (RX, RY, L, H, BitMap, IX, IY, RL, RH) { Drawing clipped image... }
End;

Procedure PutImage (X, Y : Word; Var BitMap); Assembler;
Asm
  Push  DS
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AX, VSegA
  Mov   ES, AX                          { ES:DI - Screen Addr }
  LDS   SI, BitMap                      { DS:SI - BitMap }
  Mov   DX, DS:[SI]                     { L }
  Mov   BX, DS:[SI+2]                   { H }
  Add   SI, 4
  CLD
  Shr   DX, 1
  JC    @2
@1:
  Mov   AX, DI
  Mov   CX, DX
  Rep   MovSW
  Mov   DI, AX
  Add   DI, 320
  Dec   BX
  JNZ   @1
  Pop   DS
  Jmp   @end
@2:
  Mov   AX, DI
  Mov   CX, DX
  Rep   MovSW
  MovSB
  Mov   DI, AX
  Add   DI, 320
  Dec   BX
  JNZ   @2
  Pop   DS
@end:
End;

Procedure PutTranspImage (X, Y : Word; Var BitMap); Assembler;
Asm
  Push  DS
  Push  BP
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AX, VSegA
  Mov   ES, AX                          { ES:DI - Screen Addr }
  Mov   AH, TranspColor
  LDS   SI, BitMap                      { DS:SI - BitMap }
  Mov   DX, DS:[SI]                     { L }
  Mov   BX, DS:[SI+2]                   { H }
  Add   SI, 4
  CLD
@cycle:
  Mov   BP, DI
  Mov   CX, DX
@cyc:
  LODSB
  Cmp   AL, AH
  JE    @transp
  STOSB
  Jmp   @norm
@transp:
  Inc   DI
@norm:
  Loop  @cyc
  Mov   DI, BP
  Add   DI, 320
  Dec   BX
  JNZ   @cycle
  Pop   BP
  Pop   DS
End;

Procedure PutImagePart (X, Y : Word; Var BitMap; PX, PY, PL, PH : Word); Assembler;
Asm
  Push  DS
  Push  BP
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AX, VSegA
  Mov   ES, AX                          { ES:DI - Screen Addr }
  LDS   SI, BitMap                      { DS:SI - ^BitMap }
  Mov   AX, PY
  Mul   Word Ptr DS:[SI]                { DX:AX - vertical offset in image }
  Add   AX, 4
  Add   AX, PX
  Mov   DX, PL                          { Output length }
  Mov   BX, PH                          { Output height }
  Mov   BP, DS:[SI]                     { Image length }
  Add   SI, AX                          { DS:SI - correct starting addr }
  CLD
  Shr   DX, 1
  JC    @2
@1:
  Mov   AX, DI
  Mov   CX, DX
  Push  SI
  Rep   MovSW
  Pop   SI
  Add   SI, BP
  Mov   DI, AX
  Add   DI, 320
  Dec   BX
  JNZ   @1
  Jmp   @end
@2:
  Mov   AX, DI
  Mov   CX, DX
  Push  SI
  Rep   MovSW
  MovSB
  Pop   SI
  Add   SI, BP
  Mov   DI, AX
  Add   DI, 320
  Dec   BX
  JNZ   @2
@end:
  Pop   BP
  Pop   DS
End;

Procedure PutTranspImagePart (X, Y : Word; Var BitMap; PX, PY, PL, PH : Word); Assembler;
Asm
  Push  DS
  Push  BP
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AX, VSegA
  Mov   ES, AX                          { ES:DI - Screen Addr }
  Push  Word Ptr TranspColor
  LDS   SI, BitMap                      { DS:SI - ^BitMap }
  Mov   AX, PY
  Mul   Word Ptr DS:[SI]                { DX:AX - vertical offset in image }
  Add   AX, 4
  Add   AX, PX
  Mov   DX, PL                          { Output length }
  Mov   BX, PH                          { Output height }
  Mov   BP, DS:[SI]                     { Image length }
  Add   SI, AX                          { DS:SI - correct starting addr }
  CLD
  Pop   AX
@cycle:
  Push  DI
  Mov   CX, DX
  Push  SI
@cyc:
  LODSB
  Cmp   AL, AH
  JE    @transp
  STOSB
  Jmp   @norm
@transp:
  Inc   DI
@norm:
  Loop  @cyc
  Pop   SI
  Add   SI, BP
  Pop   DI
  Add   DI, 320
  Dec   BX
  JNZ   @cycle
  Pop   BP
  Pop   DS
End;

Procedure PutClippedImage (X, Y : Integer; Var BitMap);
Var
  Dims : Array [0..1] of Word absolute BitMap; {Dims[0]=Length;Dims[1]=Height}
  RX, RY, RL, RH, IX, IY : Integer;
Begin
  If (X > 319) or (Y > 199) then Exit;          { Image is out of screen }
  RX := X; RY := Y;                             { Start X & Y at screen }
  RL := Dims[0]; RH := Dims[1];                 { Length & Height at begining }
  IX := 0; IY := 0;                             { IX & IY - coos in image to }
                                                { start drawin it (at begining) }
  If RX < 0 then Begin
    Inc (RL, RX);                               { Output length corrected }
    Dec (IX, RX);                               { IX corrected }
    RX := 0                                     { Screen X corrected }
  End;
  If RY < 0 then Begin
    Inc (RH, RY);                               { Output height corrected }
    Dec (IY, RY);                               { IY corrected }
    RY := 0                                     { Screen Y corrected }
  End;
  If (RL <= 0) or (RH <= 0) then Exit;          { Image is out of screen }
  If RX+RL > 320 then RL := 320-RX;             { Last correct in a length }
  If RY+RH > 200 then RH := 200-RY;             { Last correct in a height }
  PutImagePart (RX, RY, BitMap, IX, IY, RL, RH) { Drawing clipped image... }
End;

Procedure PutTranspClippedImage (X, Y : Integer; Var BitMap);
Var
  Dims : Array [0..1] of Word absolute BitMap; {Dims[0]=Length;Dims[1]=Height}
  RX, RY, RL, RH, IX, IY : Integer;
Begin
  If (X > 319) or (Y > 199) then Exit;          { Image is out of screen }
  RX := X; RY := Y;                             { Start X & Y at screen }
  RL := Dims[0]; RH := Dims[1];                 { Length & Height at begining }
  IX := 0; IY := 0;                             { IX & IY - coos in image to }
                                                { start drawin it (at begining) }
  If RX < 0 then Begin
    Inc (RL, RX);                               { Output length corrected }
    Dec (IX, RX);                               { IX corrected }
    RX := 0                                     { Screen X corrected }
  End;
  If RY < 0 then Begin
    Inc (RH, RY);                               { Output height corrected }
    Dec (IY, RY);                               { IY corrected }
    RY := 0                                     { Screen Y corrected }
  End;
  If (RL <= 0) or (RH <= 0) then Exit;          { Image is out of screen }
  If RX+RL > 320 then RL := 320-RX;             { Last correct in a length }
  If RY+RH > 200 then RH := 200-RY;             { Last correct in a height }
  PutTranspImagePart (RX, RY, BitMap, IX, IY, RL, RH) { Drawing clipped image... }
End;

Procedure PutClippedImagePart (X, Y : Integer; Var BitMap; PX, PY, PL, PH : Word);
Var
  Dims : Array [0..1] of Word absolute BitMap; {Dims[0]=Length;Dims[1]=Height}
  RX, RY, RL, RH, IX, IY : Integer;
Begin
  If (X > 319) or (Y > 199) then Exit;          { Image is out of screen }
  RX := X; RY := Y;                             { Start X & Y at screen }
  RL := PL; RH := PH;                           { Length & Height at begining }
  IX := PX; IY := PY;                           { IX & IY - coos in image to }
                                                { start drawin it (at begining) }
  If RX < 0 then Begin
    Inc (RL, RX);                               { Output length corrected }
    Dec (IX, RX);                               { IX corrected }
    RX := 0                                     { Screen X corrected }
  End;
  If RY < 0 then Begin
    Inc (RH, RY);                               { Output height corrected }
    Dec (IY, RY);                               { IY corrected }
    RY := 0                                     { Screen Y corrected }
  End;
  If (RL <= 0) or (RH <= 0) then Exit;          { Image is out of screen }
  If RX+RL > 320 then RL := 320-RX;             { Last correct in a length }
  If RY+RH > 200 then RH := 200-RY;             { Last correct in a height }
  PutImagePart (RX, RY, BitMap, IX, IY, RL, RH) { Drawing clipped image... }
End;

Procedure PutTranspClippedImagePart (X, Y : Integer; Var BitMap; PX, PY, PL, PH : Word);
Var
  Dims : Array [0..1] of Word absolute BitMap; {Dims[0]=Length;Dims[1]=Height}
  RX, RY, RL, RH, IX, IY : Integer;
Begin
  If (X > 319) or (Y > 199) then Exit;          { Image is out of screen }
  RX := X; RY := Y;                             { Start X & Y at screen }
  RL := PL; RH := PH;                           { Length & Height at begining }
  IX := PX; IY := PY;                           { IX & IY - coos in image to }
                                                { start drawin it (at begining) }
  If RX < 0 then Begin
    Inc (RL, RX);                               { Output length corrected }
    Dec (IX, RX);                               { IX corrected }
    RX := 0                                     { Screen X corrected }
  End;
  If RY < 0 then Begin
    Inc (RH, RY);                               { Output height corrected }
    Dec (IY, RY);                               { IY corrected }
    RY := 0                                     { Screen Y corrected }
  End;
  If (RL <= 0) or (RH <= 0) then Exit;          { Image is out of screen }
  If RX+RL > 320 then RL := 320-RX;             { Last correct in a length }
  If RY+RH > 200 then RH := 200-RY;             { Last correct in a height }
  PutTranspImagePart (RX, RY, BitMap, IX, IY, RL, RH) { Drawing clipped image... }
End;

Procedure LoadObject (Name : String; Var PBitMap : Pointer; Var Size : Word);
Const
  ID : Array [1..12] of Char = 'EGO''S FILE. ';
Var
  F : File;
  H : THeader;
  I : Byte;
  P : Pointer;
  SF: Word;
Label
  LErr;
Begin
  PBitMap := nil;
  Assign (F, Name);
  {$i-}
  Reset (F, 1);
  {$i+}
  If IOResult <> 0 then
    Begin
LErr:
      If PBitMap <> nil then
        FreeMem (PBitMap, Size);
      PBitMap := nil;
      Size := 0;
      GrResult := GrLoadObj;
      Exit
    End;
  {$i-} BlockRead (F, H, SizeOf(H)); {$i+}
  If IOResult <> 0 then Goto LErr;
  For I := 1 to 12 do
    If H.ID[I] <> ID[I] then Goto LErr;
  Case H.Pack of
    $00, $FF:
      Begin
        Size := (Ord(H.Mask)+1)*H.L*H.H+4;
        GetMem (PBitMap, Size);
        Word(PBitMap^) := H.L;
        PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)+2);
        Word(PBitMap^) := H.H;
        PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)+2);
        {$i-} BlockRead (F, PBitMap^, Size-4); {$i+}
        PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)-4);
        If IOResult <> 0 then Goto LErr;
        {$i-} Close (F); {$i+}
        If IOResult <> 0 then Goto LErr;
      End;
    $01:
      Begin
        {$I-} SF := FileSize(F)-32; {$I+}
        If IOResult <> 0 then Goto LErr;
        Size := (Ord(H.Mask)+1)*H.L*H.H+4;
        GetMem (PBitMap, Size);
        GetMem (P, SF);
        {$I-} BlockRead (F, P^, SF); {$I+}
        If IOResult <> 0 then
          Begin FreeMem (P, SF); Goto LErr End;
        {$I-} Close (F); {$I+}
        If IOResult <> 0 then
          Begin FreeMem (P, SF); Goto LErr End;
        Word(PBitMap^) := H.L;
        PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)+2);
        Word(PBitMap^) := H.H;
        PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)+2);
        UnPack (P^, PBitMap^, H.PSize);
        If H.Mask then
          Begin
            P := Ptr(Seg(P^), Ofs(P^)+H.PSize);
            PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)+H.L*H.H);
            UnPack (P^, PBitMap^, H.MSize);
            PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)-H.L*H.H);
            P := Ptr(Seg(P^), Ofs(P^)-H.PSize)
          End;
        PBitMap := Ptr(Seg(PBitMap^), Ofs(PBitMap^)-4);
        FreeMem (P, SF)
      End;
  End;
  GrResult := GrOk
End;

Procedure LoadPCX256 (Name : String; Var PBitMap : Pointer; Var Size : Word;
                      Var Pal : TPal);
Var
  Hd : TPCXHeader;
  F : File;
  L, H : Word;
  PFBuf, Temp : Pointer;
  Sz : Word;
Label LErr;
Begin
  GrResult := GrOk;
  Temp := nil;
  Assign (F, Name);
  {$I-} Reset (F, 1); {$I+}
  If IOResult <> 0 then Begin
LErr:
    If Temp <> nil then FreeMem (Temp, Size);
    GrResult := GrLoadObj;
    PBitMap := nil;
    Size := 0;
    Exit
  End;
  {$I-} BlockRead (F, Hd, 128); {$I+}           { Load header }
  If IOResult <> 0 then Goto LErr;
  If (Hd.BitsPerPixel <> 8) or (Hd.Planes <> 1) then Goto LErr;
  L := Hd.X2 - Hd.X1 + 1;
  H := Hd.Y2 - Hd.Y1 + 1;
  Size := 4 + L*H;
  If Size > 64004 then Goto LErr;               { If not in the range }
  GetMem (Temp, Size);                          { Allocate memory for unpacked bitmap }
  {$I-} Seek (F, FileSize(F)-768); {$I+}
  If IOResult <> 0 then Goto LErr;
  {$I-} BlockRead (F, Pal, 768); {$I+}          { Load palette part }
  If IOResult <> 0 then Goto LErr;
  {$I-} Seek (F, 128); {$I+}
  If IOResult <> 0 then Goto LErr;
  Sz := FileSize(F)-896;
  GetMem (PFBuf, Sz);                           { Allocate memory for file buffer }
  {$I-} BlockRead (F, PFBuf^, Sz); {$I+}        { Load picture body }
  If IOResult <> 0 then Begin
    FreeMem (PFBuf, Sz);
    Goto LErr
  End;
  {$I-} Close (F); {$I+}
  If IOResult <> 0 then Begin
    FreeMem (PFBuf, Sz);
    Goto LErr
  End;
  Asm
    Push  DS
    Mov   SI, Word Ptr Pal;
    Mov   DI, SI
    Mov   AX, Word Ptr Pal+2;
    Mov   DS, AX
    Mov   ES, AX
    Mov   CX, 768
    CLD
@loop:
    LODSB
    Shr   AL, 2                                 { Normalizing palette }
    STOSB
    Loop  @loop
    Pop   DS
  End;
  Asm
    Push  DS
    Push  BP
    LES   DI, Temp                      { ES:DI = ^ unpacking buffer }
    CLD
    Mov   AX, L                         { Picture length stored to memory }
    STOSW
    Push  AX                            { Local constant L }
    Mov   AX, H
    STOSW                               { Picture height stored to memory }
    Mov   BX, H
    Push  Hd.BytesPerLine               { Local constant Hd.BytesPerLine }
    LDS   SI, PFBuf                     { DS:SI = ^ file buffer with packed pic }
    Mov   BP, SP                        { Pointer to the local constants }
    Xor   CH, CH                        { Hi byte of repeat counter,always 0 }
    Xor   DX, DX                        { Written pixels counter }
@cyc:
    LODSB
    Cmp   AL, 0C0h
    JNC   @repeat                       { If need to repeat pixel }
    Cmp   DX, SS:[BP+2]
    JNC   @1                            { If run off the line }
    STOSB                               { Writing if all right }
@1:
    Inc   DX
    Jmp   @next
@repeat:
    And   AL, 3Fh
    Mov   CL, AL                        { CX = repeat count }
    Add   DX, CX
    LODSB                               { AL = repeated pixel (color) }
    Cmp   DX, SS:[BP+2]
    JG    @2                            { If run off the line }
    Rep   STOSB                         { Writing if all right }
    Jmp   @next
@2:
    Add   CX, SS:[BP+2]
    Sub   CX, DX                        { CX = corrected repeat count }
    Rep   STOSB
@next:
    Cmp   DX, SS:[BP]
    JNE   @cyc                          { Line isn't done }
    Xor   DX, DX
    Dec   BX
    JNZ   @cyc                          { Going to the next line }
    Add   SP, 4                         { Remove local constants from stack }
    Pop   BP                            { Restore original BP }
    Pop   DS                            { Restore original DS }
  End;
  FreeMem (PFBuf, Sz);                  { Deallocating file buffer }
  PBitMap := Temp                       { Returning address of our bitmap }
End;

Procedure SavePCX256 (Name : String; X, Y, L, H : Word);
Const
  Z : Byte = 12;
Var
  F : File;
  Hd : TPCXHeader;
  Pal,
  Buf : Array [0..767] of Byte;
  J, Cnt,
  Len : Word;
  Rep, B : Byte;
  PLeft, P : ^Byte;
Label
  LErr;
Begin
  FillChar (Hd, SizeOf(Hd), 0);
  Hd.X1 := 0; Hd.Y1 := 0; Hd.X2 := L-1; Hd.Y2 := H-1;
  Hd.Manufact := 10; Hd.Ver := 5; Hd.Encoding := 1;
  Hd.BitsPerPixel := 8; Hd.Planes := 1; Hd.PalInfo := 1;
  Hd.BytesPerLine := L + (L and 1);
  Assign (F, Name);
  {$I-} Rewrite (F, 1); {$I+}
  If IOResult <> 0 then Begin
LErr:
    GrResult := GrSaveObj;
    Exit
  End;
  {$I-} BlockWrite (F, Hd, SizeOf(Hd)); {$I+}
  If IOResult <> 0 then Begin
    {$I-} Close (F); {$I+}
    Goto LErr
  End;
  PLeft := Ptr (VSegA, Y*320+X);
  For J := 0 to H-1 do Begin
    Cnt := 0;
    Len := 0;
    P := PLeft;
    Repeat
      B := P^; Inc (Word(P)); Inc (Cnt);
      Rep := 1;
      While (B = P^) and (Rep < 63) and (Cnt < L) do Begin
        Inc (Rep);
        Inc (Cnt);
        Inc (Word(P))
      End;
      If Rep > 1 then Begin
        Buf[Len] := $C0 or Rep;
        Buf[Len+1] := B;
        Inc (Len, 2)
      End
      Else Begin
        If B >= $C0 then Begin
          Buf[Len] := $C1; Inc (Len)
        End;
        Buf[Len] := B;
        Inc (Len)
      End
    Until Cnt = L;
    Buf[Len] := 0;
    {$I-} BlockWrite (F, Buf, Len + (L and 1)); {$I+}
    If IOResult <> 0 then Begin
      {$I-} Close (F); {$I+}
      Goto LErr
    End;
    Inc (Word(PLeft), 320)
  End;
  BlockWrite (F, Z, 1);
  GetPal (Pal);
  For J := 0 to 767 do Pal[J] := Pal[J] shl 2;
  BlockWrite (F, Pal, 768);
  Close (F)
End;

Procedure PutImageM (X, Y : Word; Var BitMap); Assembler;
Asm
  Push  DS
  Push  BP
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX
  Mov   AX, VSegA
  Mov   ES, AX                          { ES:DI - Screen Addr }
  LDS   SI, BitMap                      { DS:SI - BitMap }
  Mov   AX, DS:[SI]                     { L }
  Mov   BX, DS:[SI+2]                   { H }
  Mul   BX
  Mov   BP, AX                          { BP = L*H }
  Mov   DX, DS:[SI]                     { L }
  Add   SI, 4
  CLD
@1:
  Push  DI
  Mov   CX, DX
@2:
  Mov   AL, ES:[DI]
  And   AL, DS:[SI+BP]
  Xor   AL, DS:[SI]
  STOSB
  Inc   SI
  Loop  @2
  Pop   DI
  Add   DI, 320
  Dec   BX
  JNZ   @1
  Pop   BP
  Pop   DS
End;

Procedure SetActivePage (PageSeg : Word);
Begin
  VSegA := PageSeg
End;

Procedure DisplayPage (PageSeg : Word); Assembler;
Asm
  Push  DS
  Mov   AX, SegA000
  Mov   ES, AX
  Xor   DI, DI
  Mov   AX, PageSeg
  Mov   DS, AX
  Mov   SI, DI
  CLD
  Mov   CX, 16000
  db $66
  Rep   MovSW
  Pop   DS
End;

Procedure DisplayBox (PageSeg, X, Y, L, H : Word); Assembler;
Asm
  Push  DS
  Mov   AX, SegA000
  Mov   ES, AX
  Mov   DI, X
  Mov   BX, Y
  ShL   BX, 6
  Add   DI, BX
  ShL   BX, 2
  Add   DI, BX                          { ES:DI - Screen Addr }
  Mov   BX, H                           { H }
  Mov   DX, L                           { L }
  Mov   AX, PageSeg
  Mov   SI, DI                          { DI - Offset in Page }
  Mov   DS, AX                          { DS:SI - Addr in Page }
  CLD
  Shr   DX, 1
  JC    @2                              { If L is ODD }
@1:
  Mov   CX, DX
  Push  SI
  Rep   MovSW
  Pop   SI
  Add   SI, 320
  Mov   DI, SI
  Dec   BX
  JNZ   @1
  Pop   DS
  Jmp   @end
@2:
  Mov   CX, DX
  Push  SI
  MovSB
  Rep   MovSW
  Pop   SI
  Add   SI, 320
  Mov   DI, SI
  Dec   BX
  JNZ   @2
  Pop   DS
@end:
End;

Procedure WaitRetrace; Assembler;
  { This waits until you are in a Verticle Retrace ... this means that all
    screen manipulation you do only appears on screen in the next verticle
    retrace ... this removes most of the "fuzz" that you see on the screen
    when changing the pallette. It unfortunately slows down your program
    by "synching" your program with your monitor card ... it does mean
    that the program will run at almost the same speed on different
    speeds of computers which have similar monitors. In our SilkyDemo,
    we used a WaitRetrace, and it therefore runs at the same (fairly
    fast) speed when Turbo is on or off. }

Label
  L1, L2;
Asm
    Mov DX, 3DAH
L1:
    In AL,DX
    And AL,08H
    JNZ L1
L2:
    In AL,DX
    And AL,08H
    JZ  L2
End;

Procedure GetCRGB (C : Byte; Var R, G, B : Byte);
Begin
  Port[$3C7] := C;
  R := Port[$3C9];
  G := Port[$3C9];
  B := Port[$3C9]
End;

Procedure SetCRGB (C : Byte; R, G, B : Byte);
Begin
  Port[$3C8] := C;
  Port[$3C9] := R;
  Port[$3C9] := G;
  Port[$3C9] := B
End;

Procedure GetPal (Var Pal); Assembler;
Asm
  LES   DI, Pal
  Mov   CX, 768
  CLD
  Mov   DX, 3C7h
  Xor   AL, AL
  Out   DX, AL
  Inc   DX
  Inc   DX
  Rep   InSB
End;

Procedure SetPal (Var Pal); Assembler;
Asm
  Mov   BX, DS
  LDS   SI, Pal
  Mov   CX, 768
  CLD
  Mov   DX, 3C8h
  Xor   AL, AL
  Out   DX, AL
  Inc   DX
  Rep   OutSB
  Mov   DS, BX
End;

Procedure FadeUp (Pal : TPal);
Var
  Cnt, C,
  R, G, B : Byte;
Begin
  For Cnt := 0 to 63 do
    Begin
      WaitRetrace;
      For C := 0 to 255 do
        Begin
          GetCRGB (C, R, G, B);
          If 64-Cnt <= Pal[C,1]-R then
            Inc (R);
          If 64-Cnt <= Pal[C,2]-G then
            Inc (G);
          If 64-Cnt <= Pal[C,3]-B then
            Inc (B);
          SetCRGB (C, R, G, B)
        End
    End
End;

Procedure FadeDown;
Var
  Cnt, C,
  R, G, B : Byte;
Begin
  For Cnt := 0 to 63 do
    Begin
      WaitRetrace;
      For C := 0 to 255 do
        Begin
          GetCRGB (C, R, G, B);
          If R > 0 then Dec (R);
          If G > 0 then Dec (G);
          If B > 0 then Dec (B);
          SetCRGB (C, R, G, B)
        End
    End
End;

Procedure BlackOutPut;
Var C : Byte;
Begin
  For C := 0 to 255 do
    SetCRGB (C, 0, 0, 0)
End;

Procedure TextureMapPoly (X1,Y1, X2,Y2, X3,Y3, X4,Y4, L, H : Integer;
                                                             PicSeg : Word);

Procedure ScanLeftSide (X1,X2,Ytop,LH:Integer;Side:Byte);
{ Scan in our needed variables ... X on the left, texturmap X, texturemap Y }
Var
  Y, X, PX, PY, DPX, DPY,
  SX, SY, M, N, DX1, DY1, DX2, DY2, I, T, Xm, Yt : Integer;
Begin
{  SX := X2-X1; SY := LH;}                      { !!! }
  SX := X1-X2; SY := -LH;                       { !!! }
  DX1 := Sgn(SX); DY1 := Sgn(SY);
  M := _Abs(SX); N := _Abs(SY);
  DX2 := DX1; DY2 := 0;
  If M < N then Begin
    M := _Abs(SY); N := _Abs(SX);
    DX2 := 0; DY2 := DY1
  End;
  LH := LH + 1;
  If Side = 1 then Begin
    PX := (L-1) shl 7;
    PY := 0;
    DPX:= (-(L-1) shl 7) div LH;
    DPY := 0;
  End;
  If Side = 2 then Begin
    PX := (L-1) shl 7;
    PY := (H-1) shl 7;
    DPX := 0;
    DPY := (-(H-1) shl 7) div LH;
  End;
  If Side = 3 then Begin
    PX := 0;
    PY := (H-1) shl 7;
    DPX := (L-1) shl 7 div LH;
    DPY := 0;
  End;
  If Side = 4 then Begin
    PX := 0;
    PY := 0;
    DPX := 0;
    DPY := (H-1) shl 7 div LH;
  End;
{  X := X1; Y := Ytop;}                         { !!! }
  X := X2; Y := Ytop+LH-1;                      { !!! }
  Yt := Y; Xm := X;
  T := 0;
  For I := 0 to M do Begin
    If Y = Yt then Begin
      If Xm > X then Xm := X
    End
    Else Begin
      If (Yt >= 0) and (Yt <= 199) then
        _LeftTable[Yt,0] := Xm;
      Yt := Y; Xm := X
    End;
    Inc (T, N);
    If T < M then Begin
      Inc (X, DX2); Inc (Y, DY2)
    End
    Else Begin
      Dec (T, M);
      Inc (X, DX1); Inc (Y, DY1)
    End;
  End;
  If (Yt >= 0) and (Yt <= 199) then
    _LeftTable[Yt,0] := Xm;
  For Y := 0 to LH-1 do Begin
    If (Ytop+Y >= 0) and (Ytop+Y <= 199) then Begin
      _LeftTable[Ytop+Y,1] := PX shr 7;
      _LeftTable[Ytop+Y,2] := PY shr 7
    End;
    PX := PX + DPX;
    PY := PY + DPY
  End
End;

Procedure ScanRightSide (X1, X2, Ytop, LH : Integer; Side : Byte);
{ Scan in our needed variables ... X on the right, texturmap X, texturemap Y }
Var
  Y, X, PX, PY, DPX, DPY,
  SX, SY, M, N, DX1, DY1, DX2, DY2, I, T, Xm, Yt : Integer;
Begin
  SX := X2-X1; SY := LH;
  DX1 := Sgn(SX); DY1 := Sgn(SY);
  M := _Abs(SX); N := _Abs(SY);
  DX2 := DX1; DY2 := 0;
  If M < N then Begin
    M := _Abs(SY); N := _Abs(SX);
    DX2 := 0; DY2 := DY1
  End;
  LH := LH + 1;
  If Side = 1 then Begin
    PX := 0;
    PY := 0;
    DPX := (L-1) shl 7 div LH;
    DPY := 0;
  End;
  If Side = 2 then Begin
    PX := (L-1) shl 7;
    PY := 0;
    DPX := 0;
    DPY := (H-1) shl 7 div LH;
  End;
  If Side = 3 then Begin
    PX := (L-1) shl 7;
    PY := (H-1) shl 7;
    DPX := (-(L-1)) shl 7 div LH;
    DPY := 0;
  End;
  If Side = 4 then Begin
    PX := 0;
    PY := (H-1) shl 7;
    DPX := 0;
    DPY := (-(H-1)) shl 7 div LH;
  End;
  X := X1; Y := Ytop;
  Yt := Y; Xm := X;
  T := 0;
  For I := 0 to M do Begin
    If Y = Yt then Begin
      If Xm < X then Xm := X
    End
    Else Begin
      If (Yt >= 0) and (Yt <= 199) then
        _RightTable[Yt,0] := Xm;
      Yt := Y; Xm := X
    End;
    Inc (T, N);
    If T < M then Begin
      Inc (X, DX2); Inc (Y, DY2)
    End
    Else Begin
      Dec (T, M);
      Inc (X, DX1); Inc (Y, DY1)
    End;
  End;
  If (Yt >= 0) and (Yt <= 199) then
    _RightTable[Yt,0] := Xm;
  For Y := 0 to LH-1 do Begin
    If (Ytop+Y >= 0) and (Ytop+Y <= 199) then Begin
      _RightTable[Ytop+Y,1] := PX shr 7;
      _RightTable[Ytop+Y,2] := PY shr 7
    End;
    PX := PX + DPX;
    PY := PY + DPY
  End
End;

Var
  Ymin, Ymax,
  PX1, PY1, PX2, PY2,
  XL, XR, X, Y, LW,
  DPX, DPY : Integer;

Label LC;

Begin
  Ymin := Y1; Ymax := Y1;

  If Y1 < Ymin then Ymin := Y1;
  If Y1 > Ymax then Ymax := Y1;
  If Y2 < Ymin then Ymin := Y2;
  If Y2 > Ymax then Ymax := Y2;
  If Y3 < Ymin then Ymin := Y3;
  If Y3 > Ymax then Ymax := Y3;
  If Y4 < Ymin then Ymin := Y4;
  If Y4 > Ymax then Ymax := Y4;

  If Ymax-Ymin < 2 then Exit;
  If (Ymin > 199) or (Ymax < 0) then Exit;

  If Y2 < Y1 then ScanLeftSide (X2, X1, Y2, Y1-Y2, 1)
  Else ScanRightSide (X1, X2, Y1, Y2-Y1, 1);
  { If point2.Y is above point1.Y, Point1 to Point2 is on the "left",
    and our leftside array must be altered }

  If Y3 < Y2 then ScanLeftSide (X3, X2, Y3, Y2-Y3, 2)
  Else ScanRightSide (X2, X3, Y2, Y3-Y2, 2);

  If Y4 < Y3 then ScanLeftSide (X4, X3, Y4, Y3-Y4, 3)
  Else ScanRightSide (X3, X4, Y3, Y4-Y3, 3);

  If Y1 < Y4 then ScanLeftSide (X1, X4, Y1, Y4-Y1, 4)
  Else ScanRightSide (X4, X1, Y4, Y1-Y4, 4);

  { This uses the tables we have created to actually draw the texture }

  If Ymin < 0 then Ymin:=0;
  If Ymax > 199 then Ymax:=199;
  For Y := Ymin to Ymax do Begin
    XL := _LeftTable[Y,0];          { X Starting position }
    PX1 := _LeftTable[Y,1] shl 7;   { Texture X at start  }
    PY1 := _LeftTable[Y,2] shl 7;   { Texture Y at stary  }
    XR := _RightTable[Y,0];         { X Ending position   }
    PX2 := _RightTable[Y,1] shl 7;  { Texture X at End    }
    PY2 := _RightTable[Y,2] shl 7;  { Texture Y at End    }
    LW := XR-XL;                    { Width of line }
    If LW <= 0 then Goto LC;
    DPX := (PX2-PX1) div LW;
    DPY := (PY2-PY1) div LW;
    While XL < 0 do Begin
      PX1 := PX1 + DPX;
      PY1 := PY1 + DPY;
      Inc (XL);
      Dec (LW); If LW < 0 then Goto LC
    End;
    While XR > 319 do Begin
      Dec (XR);
      Dec (LW); If LW < 0 then Goto LC
    End;
    Asm
      Push  DS
      Mov   AX, VSegA
      Mov   ES, AX
      Mov   DI, XL
      Mov   BX, Y
      ShL   BX, 6
      Add   DI, BX
      ShL   BX, 2
      Add   DI, BX                              { ES:DI - Screen start addr }
      Mov   AX, PicSeg
      Mov   DS, AX
      Mov   CX, LW
      Inc   CX                                  { Line length }
      Mov   BX, PX1                             { Texture X }
      Mov   DX, PY1                             { Texture Y }
      CLD
@cyc:
      Mov   SI, BX
      Shr   SI, 7
      Push  DX
      Shr   DX, 7
      Mov   AX, L
      Mul   DX
      Add   SI, AX                              { DS:SI - Addres in texture }
      Pop   DX
      MOVSB                                     { Copy pixel:texture->screen }
      Add   BX, DPX                             { PX1 = PX1 + DPX }
      Add   DX, DPY                             { PY1 = PY1 + DPY }
      Loop  @cyc
      Pop   DS
    End;
LC:
  End;
End;

Procedure TextureMapPoly2 (X1,Y1, X2,Y2, X3,Y3, X4,Y4, L, H : Integer;
                                                   N : Byte; PicSeg : Word);

Procedure ScanLeftSide (X1,X2,Ytop,LH:Integer;Side:Byte);
{ Scan in our needed variables ... X on the left, texturmap X, texturemap Y }
Var
  Y, X, PX, PY, DPX, DPY,
  SX, SY, M, N, DX1, DY1, DX2, DY2, I, T, Xm, Yt : Integer;
Begin
{  SX := X2-X1; SY := LH;}                      { !!! }
  SX := X1-X2; SY := -LH;                       { !!! }
  DX1 := Sgn(SX); DY1 := Sgn(SY);
  M := _Abs(SX); N := _Abs(SY);
  DX2 := DX1; DY2 := 0;
  If M < N then Begin
    M := _Abs(SY); N := _Abs(SX);
    DX2 := 0; DY2 := DY1
  End;
  LH := LH + 1;
  If Side = 1 then Begin
    PX := (L-1) shl 7;
    PY := 0;
    DPX:= (-(L-1) shl 7) div LH;
    DPY := 0;
  End;
  If Side = 2 then Begin
    PX := (L-1) shl 7;
    PY := (H-1) shl 7;
    DPX := 0;
    DPY := (-(H-1) shl 7) div LH;
  End;
  If Side = 3 then Begin
    PX := 0;
    PY := (H-1) shl 7;
    DPX := (L-1) shl 7 div LH;
    DPY := 0;
  End;
  If Side = 4 then Begin
    PX := 0;
    PY := 0;
    DPX := 0;
    DPY := (H-1) shl 7 div LH;
  End;
{  X := X1; Y := Ytop;}                         { !!! }
  X := X2; Y := Ytop+LH-1;                      { !!! }
  Yt := Y; Xm := X;
  T := 0;
  For I := 0 to M do Begin
    If Y = Yt then Begin
      If Xm > X then Xm := X
    End
    Else Begin
      If (Yt >= 0) and (Yt <= 199) then
        _LeftTable[Yt,0] := Xm;
      Yt := Y; Xm := X
    End;
    Inc (T, N);
    If T < M then Begin
      Inc (X, DX2); Inc (Y, DY2)
    End
    Else Begin
      Dec (T, M);
      Inc (X, DX1); Inc (Y, DY1)
    End;
  End;
  If (Yt >= 0) and (Yt <= 199) then
    _LeftTable[Yt,0] := Xm;
  For Y := 0 to LH-1 do Begin
    If (Ytop+Y >= 0) and (Ytop+Y <= 199) then Begin
      _LeftTable[Ytop+Y,1] := PX shr 7;
      _LeftTable[Ytop+Y,2] := PY shr 7
    End;
    PX := PX + DPX;
    PY := PY + DPY
  End
End;

Procedure ScanRightSide (X1, X2, Ytop, LH : Integer; Side : Byte);
{ Scan in our needed variables ... X on the right, texturmap X, texturemap Y }
Var
  Y, X, PX, PY, DPX, DPY,
  SX, SY, M, N, DX1, DY1, DX2, DY2, I, T, Xm, Yt : Integer;
Begin
  SX := X2-X1; SY := LH;
  DX1 := Sgn(SX); DY1 := Sgn(SY);
  M := _Abs(SX); N := _Abs(SY);
  DX2 := DX1; DY2 := 0;
  If M < N then Begin
    M := _Abs(SY); N := _Abs(SX);
    DX2 := 0; DY2 := DY1
  End;
  LH := LH + 1;
  If Side = 1 then Begin
    PX := 0;
    PY := 0;
    DPX := (L-1) shl 7 div LH;
    DPY := 0;
  End;
  If Side = 2 then Begin
    PX := (L-1) shl 7;
    PY := 0;
    DPX := 0;
    DPY := (H-1) shl 7 div LH;
  End;
  If Side = 3 then Begin
    PX := (L-1) shl 7;
    PY := (H-1) shl 7;
    DPX := (-(L-1)) shl 7 div LH;
    DPY := 0;
  End;
  If Side = 4 then Begin
    PX := 0;
    PY := (H-1) shl 7;
    DPX := 0;
    DPY := (-(H-1)) shl 7 div LH;
  End;
  X := X1; Y := Ytop;
  Yt := Y; Xm := X;
  T := 0;
  For I := 0 to M do Begin
    If Y = Yt then Begin
      If Xm < X then Xm := X
    End
    Else Begin
      If (Yt >= 0) and (Yt <= 199) then
        _RightTable[Yt,0] := Xm;
      Yt := Y; Xm := X
    End;
    Inc (T, N);
    If T < M then Begin
      Inc (X, DX2); Inc (Y, DY2)
    End
    Else Begin
      Dec (T, M);
      Inc (X, DX1); Inc (Y, DY1)
    End;
  End;
  If (Yt >= 0) and (Yt <= 199) then
    _RightTable[Yt,0] := Xm;
  For Y := 0 to LH-1 do Begin
    If (Ytop+Y >= 0) and (Ytop+Y <= 199) then Begin
      _RightTable[Ytop+Y,1] := PX shr 7;
      _RightTable[Ytop+Y,2] := PY shr 7
    End;
    PX := PX + DPX;
    PY := PY + DPY
  End
End;

Var
  Ymin, Ymax,
  PX1, PY1, PX2, PY2,
  XL, XR, X, Y, LW,
  DPX, DPY : Integer;

Label LC;

Begin
  Ymin := Y1; Ymax := Y1;

  If Y1 < Ymin then Ymin := Y1;
  If Y1 > Ymax then Ymax := Y1;
  If Y2 < Ymin then Ymin := Y2;
  If Y2 > Ymax then Ymax := Y2;
  If Y3 < Ymin then Ymin := Y3;
  If Y3 > Ymax then Ymax := Y3;
  If Y4 < Ymin then Ymin := Y4;
  If Y4 > Ymax then Ymax := Y4;

  If Ymax-Ymin < 2 then Exit;
  If (Ymin > 199) or (Ymax < 0) then Exit;

  If Y2 < Y1 then ScanLeftSide (X2, X1, Y2, Y1-Y2, 1)
  Else ScanRightSide (X1, X2, Y1, Y2-Y1, 1);
  { If point2.Y is above point1.Y, Point1 to Point2 is on the "left",
    and our leftside array must be altered }

  If Y3 < Y2 then ScanLeftSide (X3, X2, Y3, Y2-Y3, 2)
  Else ScanRightSide (X2, X3, Y2, Y3-Y2, 2);

  If Y4 < Y3 then ScanLeftSide (X4, X3, Y4, Y3-Y4, 3)
  Else ScanRightSide (X3, X4, Y3, Y4-Y3, 3);

  If Y1 < Y4 then ScanLeftSide (X1, X4, Y1, Y4-Y1, 4)
  Else ScanRightSide (X4, X1, Y4, Y1-Y4, 4);

  { This uses the tables we have created to actually draw the texture }

  If Ymin < 0 then Ymin:=0;
  If Ymax > 199 then Ymax:=199;
  For Y := Ymin to Ymax do Begin
    XL := _LeftTable[Y,0];          { X Starting position }
    PX1 := _LeftTable[Y,1] shl 7;   { Texture X at start  }
    PY1 := _LeftTable[Y,2] shl 7;   { Texture Y at stary  }
    XR := _RightTable[Y,0];         { X Ending position   }
    PX2 := _RightTable[Y,1] shl 7;  { Texture X at End    }
    PY2 := _RightTable[Y,2] shl 7;  { Texture Y at End    }
    LW := XR-XL;                    { Width of line }
    If LW <= 0 then Goto LC;
    DPX := (PX2-PX1) div LW;
    DPY := (PY2-PY1) div LW;
    While XL < 0 do Begin
      PX1 := PX1 + DPX;
      PY1 := PY1 + DPY;
      Inc (XL);
      Dec (LW); If LW < 0 then Goto LC
    End;
    While XR > 319 do Begin
      Dec (XR);
      Dec (LW); If LW < 0 then Goto LC
    End;
    Inc (PX1, (L * (N and 1)) shl 7);
    Inc (PY1, (H * (N shr 1)) shl 7);
    Asm
      Push  DS
      Mov   AX, VSegA
      Mov   ES, AX
      Mov   DI, XL
      Mov   BX, Y
      ShL   BX, 6
      Add   DI, BX
      ShL   BX, 2
      Add   DI, BX                              { ES:DI - Screen start addr }
      Mov   AX, PicSeg
      Mov   DS, AX
      Mov   CX, LW
      Inc   CX                                  { Line length }
      Mov   BX, PX1                             { Texture X }
      Mov   DX, PY1                             { Texture Y }
      CLD
@cyc:
      Mov   SI, BX
      Shr   SI, 7
      Push  DX
      Shr   DX, 7
      Mov   AX, L
      Mul   DX
      Shl   AX, 1
      Add   SI, AX                              { DS:SI - Addres in texture }
      Pop   DX
      MOVSB                                     { Copy pixel:texture->screen }
      Add   BX, DPX                             { PX1 = PX1 + DPX }
      Add   DX, DPY                             { PY1 = PY1 + DPY }
      Loop  @cyc
      Pop   DS
    End;
LC:
  End;
End;

Procedure DisplayOff; Assembler;
Asm
  CLI
  Mov   DX, Seq_Addr
  Mov   AL, 1
  Out   DX, AL
  Inc   DX
  In    AL, DX
  Or    AL, 20h
  Mov   AH, AL
  Mov   AL, 1
  Dec   DX
  Out   DX, AX
  STI
End;

Procedure DisplayOn; Assembler;
Asm
  CLI
  Mov   DX, Seq_Addr
  Mov   AL, 1
  Out   DX, AL
  Inc   DX
  In    AL, DX
  And   AL, 0DFh
  Mov   AH, AL
  Mov   AL, 1
  Dec   DX
  Out   DX, AX
  STI
End;

Begin
  GrResult := GrOk;
  CurFont := nil;
  FontX := 0;
  FontY := 0;
  VSegA := SegA000;
  TranspColor := Black
End.
