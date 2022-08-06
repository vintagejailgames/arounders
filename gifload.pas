{ $M 19500,0,655360}
unit GIFLoad;

interface

procedure LoadGIF (Filename : String; address:word);

implementation

type
  GIFDescriptor = record
    Separator : Char;
    ImageLeft,
    ImageTop,
    ImageWidth,
    ImageHeight : Word;
    Depth : Byte;
  end;


{This actually loads the GIF}
procedure LoadGIF (Filename : String; address:word);
var
  {For loading from the GIF file}
  Descriptor   : GIFDescriptor;
  GIFFile      : File;
  Temp         : Byte;
  BPointer     : Word;
  Buffer       : Array [0..256] of Byte;

  {Coordinates}
  X, Y,
  tlX, tlY,
  brX, brY     : Word;

  {GIF data is stored in blocks of a certain size}
  BlockSize    : Byte;

  {The string table}
  Prefix       : Array [0..4096] Of Word;
  Suffix       : Array [0..4096] Of Byte;
  OutCode      : Array [0..1024] Of Byte;
  FirstFree,
  FreeCode     : Word;

  {All the code information}
  InitCodeSize,
  CodeSize     : Byte;
  Code,
  OldCode,
  MaxCode      : Word;

  {Special codes}
  ClearCode,
  EOICode      : Word;

  {Used while reading the codes}
  BitsIn       : Byte;


{This sets one pixel on the screen}
procedure PutPixel (x, y : Word; c : Byte);
begin
  Mem [address:y shl 8 + y shl 6 + x] := c;
end;


  {Local function to read from the buffer}
  function LoadByte : Byte;
  begin
    {Read next block}
    if (BPointer = BlockSize) then begin
      {$I-}
      BlockRead (GIFFile, Buffer, BlockSize + 1);
      if IOResult <> 0 then;
      {$I+}
      BPointer := 0;
    end;
    {Return byte}
    LoadByte := Buffer [BPointer];
    inc (BPointer);
  end;

  {Local procedure to read the next code from the file}
  procedure ReadCode;
  var
    Counter : Integer;

  begin
    Code := 0;
    {Read the code, bit by bit}
    for Counter := 0 To CodeSize - 1 do begin
      {Next bit}
      inc (BitsIn);

      {Maybe, a new byte needs to be loaded with a further 8 bits}
      if (BitsIn = 9) then begin
        Temp := LoadByte;
        BitsIn := 1;
      end;

      {Add the current bit to the code}
      if ((Temp and 1) > 0) then inc (Code, 1 shl Counter);
      Temp := Temp shr 1;
    end;
  end;

  {Local procedure to draw a pixel}
  procedure NextPixel (c : Word);
  begin
    {Actually draw the pixel on screen}
    PutPixel (X, Y, c and 255);

    {Move on to next pixel}
    inc (X);

    {Or next row, if necessary}
    if (X = brX) then begin
      X := tlX;
      inc (Y);
    end;
  end;

  {Local function to output a string. Returns the first character.}
  function OutString (CurCode : Word) : Byte;
  var
    OutCount : Word;

  begin
    {If it's a single character, output that}
    if CurCode < 256 then begin
      NextPixel (CurCode);
    end else begin
      OutCount := 0;

      {Store the string, which ends up in reverse order}
      repeat
        OutCode [OutCount] := Suffix [CurCode];
        inc (OutCount);
        CurCode := Prefix [CurCode];
      until (CurCode < 256);

      {Add the last character}
      OutCode [OutCount] := CurCode;
      inc (OutCount);

      {Output all the string, in the correct order}
      repeat
        dec (OutCount);
        NextPixel (OutCode [OutCount]);
      until OutCount = 0;
    end;
    {Return 1st character}
    OutString := CurCode;
  end;

begin
  {Check whether the GIF file exists, and open it}
  {$I-}
  Assign (GIFFile, Filename);
  Reset (GIFFile, 1);
  if IOResult <> 0 then begin
    Exit;
  end;
  {$I+}

  {Load the image descriptor}
  BlockRead (GIFFile, Descriptor, sizeof (Descriptor));

  if (Descriptor.Separator <> ',') then begin
{    TextScreen;
    Writeln ('Incorrect image descriptor.');}
    Exit;
  end;

  {Get image corner coordinates}
  tlX := Descriptor.ImageLeft;
  tlY := Descriptor.ImageTop;
  brX := tlX + Descriptor.ImageWidth;
  brY := tlY + Descriptor.ImageHeight;

  {Some restrictions apply}
  if (Descriptor.Depth and 128 = 128) then begin
{    TextScreen;
    Writeln ('Local colour maps not supported');}
    Exit;
  end;
  if (Descriptor.Depth and 64 = 64) then begin
{    TextScreen;
    Writeln ('Interlaced images not supported');}
    Exit;
  end;

  {Get initial code size}
  BlockRead (GIFFile, CodeSize, 1);

  {GIF data is stored in blocks, so it's necessary to know the size}
  BlockRead (GIFFile, BlockSize, 1);

  {Start loader}
  BPointer := BlockSize;

  {Special codes used in the GIF spec}
  ClearCode        := 1 shl CodeSize;    {Code to reset}
  EOICode          := ClearCode + 1;     {End of file}

  {Initialize the string table}
  FirstFree        := ClearCode + 2;     {Strings start here}
  FreeCode         := FirstFree;         {Strings can be added here}

  {Initial size of the code and its maximum value}
  inc (CodeSize);
  InitCodeSize     := CodeSize;
  MaxCode          := 1 shl CodeSize;

  BitsIn := 8;

  {Start at top left of image}
  X := Descriptor.ImageLeft;
  Y := Descriptor.ImageTop;

  repeat
    {Read next code}
    ReadCode;

    {If it's an End-Of-Information code, stop processing}
         if Code = EOICode then break
    {If it's a clear code...}
    else if Code = ClearCode then begin
      {Clear the string table}
      FreeCode := FirstFree;

      {Set the code size to initial values}
      CodeSize := InitCodeSize;
      MaxCode  := 1 shl CodeSize;

      {The next code may be read}
      ReadCode;
      OldCode := Code;

      {Set pixel}
      NextPixel (Code);
    {Other codes}
    end else begin
      {If the code is already in the string table, it's string is displayed,
      and the old string followed by the new string's first character is
      added to the string table.}
      if (Code < FreeCode) then
        Suffix [FreeCode] := OutString (Code)
      else begin
      {If it is not already in the string table, the old string followed by
      the old string's first character is added to the string table and
      displayed.}
        Suffix [FreeCode] := OutString (OldCode);
        NextPixel (Suffix [FreeCode]);
      end;

      {Finish adding to string table}
      Prefix [FreeCode] := OldCode;
      inc (FreeCode);

      {If the code size needs to be adjusted, do so}
      if (FreeCode >= MaxCode) and (CodeSize < 12) then begin
        inc (CodeSize);
        MaxCode := MaxCode shl 1;
      end;

      {The current code is now old}
      OldCode := Code;
    end;

  until Code = EOICode;

  {Close the GIF file}
  Close (GIFFile);
end;


begin

end.