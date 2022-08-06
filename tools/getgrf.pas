program GetGrf;

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


Procedure get_one(filename, balname:string);
var
  Header       : GIFHeader;
  Descriptor   : GIFDescriptor;
  GIFFile,f    : File;
  Palette      : AuxPalette;
  i            : byte;
begin

Write('Convertint ',filename,' en ',balname);

  Assign (GIFFile, '..\dev\gif\'+filename);
  Reset (GIFFile, 1);

  Blockread (GIFFile, Header.Signature [1], sizeof (Header) - 1);

  BlockRead (GIFFile, Palette, 768);
  for i := 0 to 255 do begin
    Palette [i].r := Palette [i].r shr 2;
    Palette [i].g := Palette [i].g shr 2;
    Palette [i].b := Palette [i].b shr 2;
  end;

  Assign(f,'..\data\'+balname);
  Rewrite(f,1);

repeat
  BlockRead(GIFFile,i,1);
  BlockWrite(f,i,1);
until EOF(GIFFile);

Close(GIFFile);

Close(f);

Writeln('   OK.');

end;

begin
clrscr;
Writeln('Arounders Grafics Conversor');
Writeln('===========================');
Writeln;

get_one('cred.gif'      ,       'grf01.bal');
get_one('thx.gif'       ,       'grf02.bal');
get_one('titles.gif'    ,       'grf03.bal');
get_one('scene1.gif'    ,       'grf04.bal');
get_one('scene2.gif'    ,       'grf05.bal');
get_one('scene3.gif'    ,       'grf06.bal');
get_one('scene4.gif'    ,       'grf07.bal');
get_one('scene5.gif'    ,       'grf08.bal');
get_one('scene6.gif'    ,       'grf09.bal');
get_one('menu.gif'      ,       'grf10.bal');
get_one('fase.gif'      ,       'grf11.bal');
get_one('spr.gif'       ,       'grf12.bal');
get_one('guay.gif'      ,       'grf13.bal');
get_one('mort.gif'      ,       'grf14.bal');
get_one('editor.gif'    ,       'grf99.bal');
get_one('back0.gif'     ,       'bkg00.bal');
get_one('back1.gif'     ,       'bkg01.bal');
get_one('back2.gif'     ,       'bkg02.bal');
get_one('back3.gif'     ,       'bkg03.bal');
get_one('back4.gif'     ,       'bkg04.bal');
get_one('back5.gif'     ,       'bkg05.bal');
get_one('back6.gif'     ,       'bkg06.bal');
get_one('back7.gif'     ,       'bkg07.bal');
get_one('back8.gif'     ,       'bkg08.bal');
get_one('back9.gif'     ,       'bkg09.bal');
get_one('intros\i1s1.gif'      ,       'seq11.bal');
get_one('intros\i1s2.gif'      ,       'seq12.bal');
get_one('intros\i1s3.gif'      ,       'seq13.bal');
get_one('intros\i1s4.gif'      ,       'seq14.bal');
get_one('intros\i2s1.gif'      ,       'seq21.bal');
get_one('intros\i2s2.gif'      ,       'seq22.bal');
get_one('intros\i3s1.gif'      ,       'seq31.bal');
get_one('intros\i3s2.gif'      ,       'seq32.bal');
get_one('intros\i4s1.gif'      ,       'seq41.bal');
get_one('intros\i4s2.gif'      ,       'seq42.bal');
get_one('intros\i5s1.gif'      ,       'seq51.bal');
get_one('intros\i5s2.gif'      ,       'seq52.bal');
get_one('intros\i6s1.gif'      ,       'seq61.bal');
get_one('intros\o1s1.gif'      ,       'seq01.bal');
get_one('intros\o2s1.gif'      ,       'seq02.bal');
get_one('intros\o3s1.gif'      ,       'seq03.bal');
get_one('intros\o4s1.gif'      ,       'seq04.bal');
get_one('intros\o5s1.gif'      ,       'seq05.bal');
get_one('intros\f1.gif'        ,       'seq71.bal');
get_one('intros\f2.gif'        ,       'seq72.bal');
get_one('intros\f3.gif'        ,       'seq73.bal');
get_one('intros\credits.gif'   ,       'seq74.bal');

Writeln;
Writeln('Tots els arxius procesats');

end.

