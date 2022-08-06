program baloo_editor;

{ $DEFINE GIF}

uses Dmon3B, Keyboard, Mouse, crt, useful, GIFLoad;

type tipolevel = record
  layout,bmpfondo,orient,num,need  : byte;
  p1                               : array[0..6] of byte;
  tile                             : array[0..19,0..9] of byte;
end;


var
  mouseX, mouseY       : word;                          { variables per }
  b1,b2,b3             : boolean;                       { al mouse      }
  level                : tipolevel;
  grid                 : boolean;                       { grid, tio...  }
  MODE                 : word;                          { aix¢...       }
  stile                : word;
  i,j                  : word;
  nom,dir              : string;
  f                    : file;
  pal                  : AuxPalette;
  Back                 : PtrVScreen;
  BK                   : word;
  hint                 : string;
  final                : boolean;


{ ***************************** }
{ *    CARREGAR UNA PALETA    * }
{ ***************************** }
Procedure LoadPal(filename:string; var pal: AuxPalette);
var
  f : file of AuxPalette;
begin
  Assign(f,filename);
  Reset(f);
  Read(f,Pal);
  Close(f);
end;


{ ****************** }
{ * INICIAR-HO TOT * }
{ ****************** }
Procedure Init;
var
 x,y:word;
begin
InitDM;
InitMouse;
HookKb;
InitVirtual(Back,BK);

dir := 'data\';
{$IFDEF GIF}
LoadGIF(dir+'spr.gif',SP);
{$ELSE}
LoadGIF(dir+'grf12.bal',SP);
LoadGIF(dir+'grf99.bal',BK);
LoadPal(dir+'pal01.bal',pal);
restorepalette(pal);
{$ENDIF}
HBMouse(312,0);
VBMouse(192,0);
hint := '';

grid := False;

For y := 0 to 9 do
  For x := 0 to 19 do
    level.tile[x,y] := 255;

Cls(0,IP);
Cls(0,WP);
end;

{ ********************* }
{ * FINALITZAR-HO TOT * }
{ ********************* }

Procedure Eixir;
begin
EndVirtual(Back);
FreeKb;
EndMouse;
EndDM;
end;


function IntToStr2(I: Longint): String;
var
 S: string[11];
begin
 Str(I, S);
 IntToStr2 := S;
end;



function StrToInt(S: String): byte;
var
 I      : Byte;
 Code   : integer;
begin
 Val(S, I, Code);
 StrToInt := I;
end;


procedure text(x,y:word; cadena:string; page:word);
var i,j:word;
begin
If cadena = '' then exit;
For i := 1 to length(cadena) do
  begin
  j := ord(cadena[i]);
  If j <> 32 then
    begin
    If (j > 47) and (j < 61) then j := j - 22
    else If (j > 64) and (j < 91) then j := j - 65;
    putsprite(SP,(((j) shl 3)-(j)),51,page,x+(((i-1) shl 3)-(i-1)),y,7,6);
    end;
  end;
end;




{ *************** }
{ * PINTAR MAPA * }
{ *************** }

Procedure Refresh;
var
  x,y: word;

begin

For y := 0 to 4 do
  For x := 0 to 9 do
    Putbloc(SP,53760+(level.bmpfondo shl 5),IP,32,32,x shl 5, y shl 5);

For y := 0 to 9 do
  For x := 0 to 19 do
    case level.tile[x,y] of
      253: begin
             PutSprite(SP,216,0,IP,x shl 4,y shl 4, 16, 16);
             PutSprite(SP,200,0,IP,x shl 4,y shl 4, 16, 16);
           end;
      254: PutSprite(SP,216,0,IP,x shl 4,y shl 4, 16, 16);
    else If level.tile[x,y] <> 255 then PutSprite(SP,level.tile[x,y] shl 4,57+(level.layout shl 4),IP,x shl 4,y shl 4, 16, 16);
    end;
{If grid then
For y := 1 to 9 do
  For x := 1 to 19 do
    PutPixel((x shl 4)-1,(y shl 4)-1,1,IP);}

end;


Function Get_str(x1,y1:word): string;
var
  co              : byte;
  pass            : string;
begin
co := 0;
pass := '            ';
repeat
delay(100);

If co<12 then
  case GetKey of
  keyA:begin inc(co); pass[co] := 'A'; text((x1+5)+(co*7),y1+25,'A',VGA);end;
  keyB:begin inc(co); pass[co] := 'B'; text((x1+5)+(co*7),y1+25,'B',VGA);end;
  keyC:begin inc(co); pass[co] := 'C'; text((x1+5)+(co*7),y1+25,'C',VGA);end;
  keyD:begin inc(co); pass[co] := 'D'; text((x1+5)+(co*7),y1+25,'D',VGA);end;
  keyE:begin inc(co); pass[co] := 'E'; text((x1+5)+(co*7),y1+25,'E',VGA);end;
  keyF:begin inc(co); pass[co] := 'F'; text((x1+5)+(co*7),y1+25,'F',VGA);end;
  keyG:begin inc(co); pass[co] := 'G'; text((x1+5)+(co*7),y1+25,'G',VGA);end;
  keyH:begin inc(co); pass[co] := 'H'; text((x1+5)+(co*7),y1+25,'H',VGA);end;
  keyI:begin inc(co); pass[co] := 'I'; text((x1+5)+(co*7),y1+25,'I',VGA);end;
  keyJ:begin inc(co); pass[co] := 'J'; text((x1+5)+(co*7),y1+25,'J',VGA);end;
  keyK:begin inc(co); pass[co] := 'K'; text((x1+5)+(co*7),y1+25,'K',VGA);end;
  keyL:begin inc(co); pass[co] := 'L'; text((x1+5)+(co*7),y1+25,'L',VGA);end;
  keyM:begin inc(co); pass[co] := 'M'; text((x1+5)+(co*7),y1+25,'M',VGA);end;
  keyN:begin inc(co); pass[co] := 'N'; text((x1+5)+(co*7),y1+25,'N',VGA);end;
  keyO:begin inc(co); pass[co] := 'O'; text((x1+5)+(co*7),y1+25,'O',VGA);end;
  keyP:begin inc(co); pass[co] := 'P'; text((x1+5)+(co*7),y1+25,'P',VGA);end;
  keyQ:begin inc(co); pass[co] := 'Q'; text((x1+5)+(co*7),y1+25,'Q',VGA);end;
  keyR:begin inc(co); pass[co] := 'R'; text((x1+5)+(co*7),y1+25,'R',VGA);end;
  keyS:begin inc(co); pass[co] := 'S'; text((x1+5)+(co*7),y1+25,'S',VGA);end;
  keyT:begin inc(co); pass[co] := 'T'; text((x1+5)+(co*7),y1+25,'T',VGA);end;
  keyU:begin inc(co); pass[co] := 'U'; text((x1+5)+(co*7),y1+25,'U',VGA);end;
  keyV:begin inc(co); pass[co] := 'V'; text((x1+5)+(co*7),y1+25,'V',VGA);end;
  keyW:begin inc(co); pass[co] := 'W'; text((x1+5)+(co*7),y1+25,'W',VGA);end;
  keyX:begin inc(co); pass[co] := 'X'; text((x1+5)+(co*7),y1+25,'X',VGA);end;
  keyY:begin inc(co); pass[co] := 'Y'; text((x1+5)+(co*7),y1+25,'Y',VGA);end;
  keyZ:begin inc(co); pass[co] := 'Z'; text((x1+5)+(co*7),y1+25,'Z',VGA);end;
  key1:begin inc(co); pass[co] := '1'; text((x1+5)+(co*7),y1+25,'1',VGA);end;
  key2:begin inc(co); pass[co] := '2'; text((x1+5)+(co*7),y1+25,'2',VGA);end;
  key3:begin inc(co); pass[co] := '3'; text((x1+5)+(co*7),y1+25,'3',VGA);end;
  key4:begin inc(co); pass[co] := '4'; text((x1+5)+(co*7),y1+25,'4',VGA);end;
  key5:begin inc(co); pass[co] := '5'; text((x1+5)+(co*7),y1+25,'5',VGA);end;
  key6:begin inc(co); pass[co] := '6'; text((x1+5)+(co*7),y1+25,'6',VGA);end;
  key7:begin inc(co); pass[co] := '7'; text((x1+5)+(co*7),y1+25,'7',VGA);end;
  key8:begin inc(co); pass[co] := '8'; text((x1+5)+(co*7),y1+25,'8',VGA);end;
  key9:begin inc(co); pass[co] := '9'; text((x1+5)+(co*7),y1+25,'9',VGA);end;
  key0:begin inc(co); pass[co] := '0'; text((x1+5)+(co*7),y1+25,'0',VGA);end;
  end;
If (GetKey = keyBackSpace) and (co>0) then
  begin
  box((x1+5)+(co*7),y1+25,6,6,1,VGA);
  pass[co] := ' ';
  dec(co);
  end;


until keypress(keyEnter);

Get_Str := pass;

end;


Function Get_int(x1,y1:word; limit:byte): string;
var
  co              : byte;
  pass            : string;
begin
co := 0;
pass := '  ';
repeat
delay(100);

If co<2 then
  case GetKey of
  key1:begin inc(co); pass[co] := '1'; text((x1+5)+(co*7),y1+25,'1',VGA);end;
  key2:begin inc(co); pass[co] := '2'; text((x1+5)+(co*7),y1+25,'2',VGA);end;
  key3:begin inc(co); pass[co] := '3'; text((x1+5)+(co*7),y1+25,'3',VGA);end;
  key4:begin inc(co); pass[co] := '4'; text((x1+5)+(co*7),y1+25,'4',VGA);end;
  key5:begin inc(co); pass[co] := '5'; text((x1+5)+(co*7),y1+25,'5',VGA);end;
  key6:begin inc(co); pass[co] := '6'; text((x1+5)+(co*7),y1+25,'6',VGA);end;
  key7:begin inc(co); pass[co] := '7'; text((x1+5)+(co*7),y1+25,'7',VGA);end;
  key8:begin inc(co); pass[co] := '8'; text((x1+5)+(co*7),y1+25,'8',VGA);end;
  key9:begin inc(co); pass[co] := '9'; text((x1+5)+(co*7),y1+25,'9',VGA);end;
  key0:begin inc(co); pass[co] := '0'; text((x1+5)+(co*7),y1+25,'0',VGA);end;
  end;
If (GetKey = keyBackSpace) and (co>0) then
  begin
  box((x1+5)+(co*7),y1+25,6,6,1,VGA);
  pass[co] := ' ';
  dec(co);
  end;

until keypress(keyEnter);
If pass[2] = ' ' then begin pass[2] := pass[1]; pass[1] := '0'; end;

If (pass <> '') and (StrToInt(pass)<=limit) then Get_Int := pass else Get_Int := '0';

end;



Function ShowMessage(caption:string; tipo:integer; limit:byte): string;
var
  x1,y1,x2,y2,w,h : word;
begin
If (length(caption)*7)+6 > 120 then w := (length(caption)*7)+6 else w := 120;
h := 50;
x1 := (320-w) div 2;
y1 := ((200-h) div 2)-20;
x2 := x1+w;
y2 := y1+h;

Box(x1,y1,w,h,39,VGA);

line(x1+2,y1+2,x2-2,y1+2,1,VGA);
line(x1+2,y1+3,x2-2,y1+3,2,VGA);
line(x1+2,y1+4,x2-2,y1+4,3,VGA);
line(x1+2,y1+5,x2-2,y1+5,4,VGA);
line(x1+2,y1+6,x2-2,y1+6,5,VGA);
line(x1+2,y1+7,x2-2,y1+7,6,VGA);
line(x1+2,y1+8,x2-2,y1+8,7,VGA);

Line(x1,y1,x1,y2,53,VGA);
Line(x1,y1,x2,y1,53,VGA);
Line(x1+1,y2,x2,y2,25,VGA);
Line(x2,y1+1,x2,y2,25,VGA);
text(x1+5,y2-9,'ACEPTAR',VGA);
text(x2-59,y2-9,'CANCELAR',VGA);
Line(x1+2,y2-2,x1+55,y2-2,25,VGA);
Line(x1+55,y2-11,x1+55,y2-2,25,VGA);
Line(x1+2,y2-11,x1+2,y2-2,53,VGA);
Line(x1+2,y2-11,x1+55,y2-11,53,VGA);

Line(x2-62,y2-2,x2-2,y2-2,25,VGA);
Line(x2-2,y2-11,x2-2,y2-2,25,VGA);
Line(x2-62,y2-11,x2-62,y2-2,53,VGA);
Line(x2-62,y2-11,x2-2,y2-11,53,VGA);

{text(x1+3,y1+2,'AROUNDED V05',VGA);}
PutSprite(BK,0,16,VGA,x1+4,y1+3,52,6);

text(x1+2,y1+12,caption,VGA);

If tipo = 2 then
  begin
  delay(300);
  repeat until (keypress(keyEnter)) or (keypress(keyEsc));
  ShowMessage := 'NO';
  If keypress(keyEnter) then ShowMessage := 'OK';
  exit;
  end;

Box(x1+3,y1+25,w-6,7,1,VGA);

If tipo = 0 then ShowMessage := Get_Int(x1,y1,limit);
If tipo = 1 then ShowMessage := Get_Str(x1,y1);

end;



{ ***************** }
{ *   PRINCIPAL   * }
{ ***************** }

begin
Init;
Refresh;
Final := False;
showMessage('BENVINGUT AL AROUNDED',2,0);

repeat

Getmouse(mouseX,mouseY,b1,b2,b3);


    If b1 then
      begin
      If mouseY < 160 then
        begin
        level.tile[mouseX shr 4, mouseY shr 4] := stile;
{        refresh;}
        end;
      If (mouseY > 169) and (mouseY < 187) then
        begin
        stile := mouseX shr 4;
        end;
      end;

    If b3 then
      begin
      If mouseY < 160 then
        begin
        level.tile[mouseX shr 4, mouseY shr 4] := 255;
        end;
      end;

    If keypress(keyI) then
      begin
      level.tile[mouseX shr 4, mouseY shr 4] := 253;
      end;

    If keypress(keyE) then
      begin
      level.tile[mouseX shr 4, mouseY shr 4] := 254;
      end;

    If keypress(keyL) then
      begin
      level.layout   := StrToInt(showMessage('LAYOUT A UTILITZAR',0,5));
      delay(100);
      end;

    If keypress(keyF) then
      begin
      level.bmpfondo := StrToInt(showMessage('FONDO A UTILITZAR',0,5));
      delay(100);
      end;


If keypress(keyT) then
  begin
  level.num      := StrToInt(showMessage('NUMERO TOTAL DE BALOOS',0,99));
  delay(100);
  end;

If keypress(keyN) then
  begin
  level.need     := StrToInt(showMessage('NUMERO NECESSARI DE BALOOS',0,99));
  delay(100);
  end;

If keypress(keyO) then
  begin
  level.orient   := StrToInt(showMessage('ORIENTACIO',0,8));
  delay(100);
  end;

If keypress(key0) then
  begin
  level.p1[0]    := StrToInt(showMessage('NUMERO DE ACCIONS :PARAR:',0,99));
  delay(100);
  end;

If keypress(key1) then
  begin
  level.p1[1]    := StrToInt(showMessage('NUMERO DE ACCIONS :CAVAR:',0,99));
  delay(100);
  end;

If keypress(key2) then
  begin
  level.p1[2]    := StrToInt(showMessage('NUMERO DE ACCIONS :ESCALAR:',0,99));
  delay(100);
  end;

If keypress(key3) then
  begin
  level.p1[3]    := StrToInt(showMessage('NUMERO DE ACCIONS :PERFORAR:',0,99));
  delay(100);
  end;

If keypress(key4) then
  begin
  level.p1[4]    := StrToInt(showMessage('NUMERO DE ACCIONS :ESCALERA:',0,99));
  delay(100);
  end;

If keypress(key5) then
  begin
  level.p1[5]    := StrToInt(showMessage('NUMERO DE ACCIONS :PASARELA:',0,99));
  delay(100);
  end;

If keypress(key6) then
  begin
  level.p1[6]    := StrToInt(showMessage('NUMERO DE ACCIONS :CORDA:',0,99));
  delay(100);
  end;

If keypress(keyD) then
  begin
       dir := showMessage('NOU DIRECTORI',1,0);
       If dir <> '' then
         begin
         dir := dir + '\';
         {$I-}
         Assign(f,dir+'grf12.bal');
         reset(f);
         close(f);
         {$I+}
         If IOResult <> 0 then
           showMessage('DIRECTORI INCORRECTE',2,0)
         else
           begin
           LoadGIF(dir+'grf12.bal',SP);
           LoadPal(dir+'pal01.pal',pal);
           restorepalette(pal);
           end;
         end;
  end;

If keypress(keyB) then
  begin
       For i := 0 to 9 do
         For j := 0 to 19 do
           level.tile[j,i] := 255;
       level.layout := 0;
       level.bmpfondo := 0;
       level.orient := 0;
       level.num := 0;
       level.need := 0;
       For i := 0 to 6 do level.p1[i] := 0;
  end;

If keypress(keyC) then
  begin
       {$I-}
       nom := IntToStr2(StrToInt(showMessage('NUMERO DE MAPA A CARREGAR',0,30)));
       Assign(f,dir + '..\dev\lev\level'+ nom + '.lev');
       reset(f,sizeof(level));
       {$I+}
       If IOResult <> 0 then
         showMessage('EL ARXIU NO EXISTEIX',2,0)
       else
         begin
         blockread(f,level,1);
         close(f);
         end;
  end;

If keypress(keyS) then
  begin
       nom := IntToStr2(StrToInt(showMessage('NUMERO DE MAPA A GUARDAR',0,30)));
       if nom <> '' then
         begin
         Assign(f,dir + '..\dev\lev\level'+ nom + '.lev');
         rewrite(f,sizeof(level));
         blockwrite(f,level,1);
         close(f);
         end;
  end;


refresh;
flip(IP,WP);


If keypress(keyTab) then
  begin
  putbloc(SP,5120,WP,320,35,0,165);
  text(7,188,'XX',WP);
  text(23,188,inttostr(level.p1[0]),WP);
  text(39,188,inttostr(level.p1[1]),WP);
  text(55,188,inttostr(level.p1[2]),WP);
  text(71,188,inttostr(level.p1[3]),WP);
  text(87,188,inttostr(level.p1[4]),WP);
  text(103,188,inttostr(level.p1[5]),WP);
  text(119,188,inttostr(level.p1[6]),WP);
  text(135,188,'XX',WP);
  text(151,188,'XX',WP);
  If level.orient = 0 then text(224,170,'ORIENT  DRETA',WP);
  If level.orient = 8 then text(224,170,'ORIENT  ESQUE',WP);
  text(224,182,'TOTAL      '+inttostr(level.num),WP);
  text(224,188,'NECESSARIS '+inttostr(level.need),WP);
  end
else
  begin
  putbloc(SP,18240+((level.layout shl 4)*320),WP,320,16,0,168);
  rectangle((stile shl 4)-1,167,(stile shl 4)+16,184,49,WP);
  putbloc(BK,0,WP,320,16,0,184);
  text(5,160,hint,WP);
  text(259,188,'LEVEL'+IntToStr2(StrToInt(nom)),WP);
  end;

If (mouseY > 167) and (mouseY < 184) then
  rectangle(((mouseX shr 4)shl 4)-1,(((mouseY-10) shr 4)shl 4)+7,
           ((mouseX shr 4)shl 4)+16,(((mouseY-10) shr 4)shl 4)+24,160,WP);
If mouseY < 160 then
  rectangle(((mouseX shr 4)shl 4)-1,((mouseY shr 4)shl 4)-1,((mouseX shr 4)shl 4)+16,((mouseY shr 4)shl 4)+16,160,WP);

If (mouseY > 183) then
  begin
  case (mousex shr 4) of
  0: hint := 'NOU MAPA';
  1: hint := 'CARREGAR MAPA';
  2: hint := 'GUARDAR MAPA';
  3: hint := 'CANVIAR DIRECTORI';
  4: hint := 'PARAR';
  5: hint := 'CAVAR';
  6: hint := 'ESCALAR';
  7: hint := 'PERFORAR';
  8: hint := 'ESCALERA';
  9: hint := 'PASARELA';
 10: hint := 'CORDA';
 11: hint := 'ORIENTACIO';
 12: hint := 'BALOOS TOTALS';
 13: hint := 'BALOOS NECESSARIS';
 14: hint := 'LAYOUT';
 15: hint := 'FONDO';
  end;
  If b1 then
    begin
    case (mousex shr 4) of
    0: begin
       For i := 0 to 9 do
         For j := 0 to 19 do
           level.tile[j,i] := 255;
       level.layout := 0;
       level.bmpfondo := 0;
       level.orient := 0;
       level.num := 0;
       level.need := 0;
       For i := 0 to 6 do level.p1[i] := 0;
       end;
    1: begin
       {$I-}
       nom := IntToStr2(StrToInt(showMessage('NUMERO DE MAPA A CARREGAR',0,30)));
       Assign(f,dir + '..\dev\lev\level'+ nom + '.lev');
       reset(f,sizeof(level));
       {$I+}
       If IOResult <> 0 then
         showMessage('EL ARXIU NO EXISTEIX',2,0)
       else
         begin
         blockread(f,level,1);
         close(f);
         end;
       end;
    2: begin
       nom := IntToStr2(StrToInt(showMessage('NUMERO DE MAPA A GUARDAR',0,30)));
       if nom <> '' then
         begin
         Assign(f,dir + '..\dev\lev\level'+ nom + '.lev');
         rewrite(f,sizeof(level));
         blockwrite(f,level,1);
         close(f);
         end;
       end;
    3: begin
       dir := showMessage('NOU DIRECTORI',1,0);
       If dir <> '' then
         begin
         dir := dir + '\';
         {$I-}
         Assign(f,dir+'grf12.bal');
         reset(f);
         close(f);
         {$I+}
         If IOResult <> 0 then
           showMessage('DIRECTORI INCORRECTE',2,0)
         else
           begin
           LoadGIF(dir+'grf12.bal',SP);
           LoadPal(dir+'pal01.pal',pal);
           restorepalette(pal);
           end;
         end;
       end;
    4: level.p1[0]    := StrToInt(showMessage('NUMERO DE ACCIONS :PARAR:',0,99));
    5: level.p1[1]    := StrToInt(showMessage('NUMERO DE ACCIONS :CAVAR:',0,99));
    6: level.p1[2]    := StrToInt(showMessage('NUMERO DE ACCIONS :ESCALAR:',0,99));
    7: level.p1[3]    := StrToInt(showMessage('NUMERO DE ACCIONS :PERFORAR:',0,99));
    8: level.p1[4]    := StrToInt(showMessage('NUMERO DE ACCIONS :ESCALERA:',0,99));
    9: level.p1[5]    := StrToInt(showMessage('NUMERO DE ACCIONS :PASARELA:',0,99));
   10: level.p1[6]    := StrToInt(showMessage('NUMERO DE ACCIONS :CORDA:',0,99));
   11: level.orient   := StrToInt(showMessage('ORIENTACIO',0,8));
   12: level.num      := StrToInt(showMessage('NUMERO TOTAL DE BALOOS',0,99));
   13: level.need     := StrToInt(showMessage('NUMERO NECESSARI DE BALOOS',0,99));
   14: level.layout   := StrToInt(showMessage('LAYOUT A UTILITZAR',0,5));
   15: level.bmpfondo := StrToInt(showMessage('FONDO A UTILITZAR',0,5));
    end;
    end;
  end
else
  hint := '';
putsprite(SP,8,8,WP,mouseX,mouseY,8,8);
flip(WP,VGA);

If keypress(keyESC) then
  If showMessage('ESTAS SEGUR',2,0) = 'OK' then Final:=True else delay(300);

until Final;


Eixir;
end.
