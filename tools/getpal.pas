program GetPal;

uses crt;

type
  GIFHeader = record
    Signature : String [6];
    ScreenWidth,
    ScreenHeight : Word;
    Depth,
    Background,
    Zero : Byte;
  end;
  GIFDescriptor = record
    Separator : Char;
    ImageLeft,
    ImageTop,
    ImageWidth,
    ImageHeight : Word;
    Depth : Byte;
  end;

  RGB = record
    R,G,B: byte;
  end;

  AuxPalette = array [0..255] of RGB;

Procedure get_one(filename,balname:string);
var
  Header       : GIFHeader;
  Descriptor   : GIFDescriptor;
  GIFFile      : File;
  f            : file of AuxPalette;
  Palette      : AuxPalette;
  i            : byte;
begin
  Write('Agafant ',balname,' de ',filename);

  Assign (GIFFile, '..\dev\gif\'+filename);
  Reset (GIFFile, 1);

  Blockread (GIFFile, Header.Signature [1], sizeof (Header) - 1);

  BlockRead (GIFFile, Palette, 768);
  for i := 0 to 255 do begin
    Palette [i].r := Palette [i].r shr 2;
    Palette [i].g := Palette [i].g shr 2;
    Palette [i].b := Palette [i].b shr 2;
  end;
  Close(GIFFile);

  Assign(f,'..\data\'+balname);
  Rewrite(f);
  Write(f,Palette);
  Close(f);

  Writeln('   OK.');
end;

begin
clrscr;
Writeln('Arounders Paleta Conversor');
Writeln('===========================');
Writeln;

get_one('spr.gif'       ,       'pal01.bal');
get_one('menu.gif'      ,       'pal02.bal');
get_one('cred.gif'      ,       'pal03.bal');
get_one('thx.gif'       ,       'pal04.bal');
get_one('intros\credits.gif',   'pal05.bal');
get_one('back0.gif'     ,       'pbk00.bal');
get_one('back1.gif'     ,       'pbk01.bal');
get_one('back2.gif'     ,       'pbk02.bal');
get_one('back3.gif'     ,       'pbk03.bal');
get_one('back4.gif'     ,       'pbk04.bal');
get_one('back5.gif'     ,       'pbk05.bal');
get_one('back6.gif'     ,       'pbk06.bal');
get_one('back7.gif'     ,       'pbk07.bal');
get_one('back8.gif'     ,       'pbk08.bal');
get_one('back9.gif'     ,       'pbk09.bal');

Writeln;
Writeln('Tots els arxius procesats');

end.
