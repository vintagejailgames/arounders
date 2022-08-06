Program test;

uses crt,GIFLoad, dmon3b;

var
  p: AuxPalette;

Procedure LoadPal;
var
  i:byte;
  f:file of AuxPalette;
begin
  {$I-}
Assign(f,'pal.pal');
Reset(f);
if IOResult <> 0 then begin
  Writeln('Arxiu no trobat');
  Exit;
  end;
  {$I+}
read(f,p);
close(f);
end;



begin
InitDM;

LoadGIF('grf.grf',VGA);

loadpal;

RestorePalette(p);

repeat until keypressed;

EndDM;

end.