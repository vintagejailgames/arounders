program arounders;

uses crt, dmon3b, keyboard, mouse, useful, gifload, midiplay, seq;

 { $DEFINE DEBUG}

label
  fin, INICIAR_PARTIDA, INICIAR_FASE;
const
  quiet    = 1;              { TIPOS DE MOVIMENT }
  moventse = 12;
  parant   = 2;
  cavant   = 3;
  escalant = 4;
  perforant= 5;
  escalera = 6;
  pasarela = 7;
  corda    = 8;
  descens  = 9;
  explotant= 10;

  caiguent = 11;
  aroundant= 1;

  res      = 100;

  dreta    = 0;              { ORIENTACIO }
  esquerra = 8;


type passwords = array[2..30] of string[10];    { tipus per als passwords }

type tipo_pix = record       { Cada pixel de la explosi¢ }
  x,y: word;
  xa,ya: word;
  g,c : word;
  end;

type tipo_exp = record       { Tipo per a les explosions }
  numpix: word;
  pix: array[0..50] of tipo_pix;
  count: word;
  end;

type tipo_mov = record       { Tipo per a les dades de cada moviment }
  x,y,w,h: word;
  end;

type tipo_moves = record     { Tupla per a guardar tots els moviments }
  quiet, explotant,
  moventse, cavant,
  escalant,caiguent,
  perforant,escalera,
  aroundant,parant,
  pasarela : tipo_mov;
  end;


type tipo_count = record     { Tupla per a la cantitat de moviments }
  cavant,escalant,
  perforant,escalera,
  parant,pasarela,corda : word;
  end;


type tipo_baloo = record     { Tipo per a guardar les dades de cada baloo }
  x,y: word;
  frame: tipo_mov;
  orient: word;
  mode,wannabe: word;
  j,k : word;
  goX : word;
  end;

type tipo_copo = record         { tipo per als copos de neu }
  x,y: word;
  actiu : boolean;
  end;

var
  aigua : array[0..9] of word;  { frames de l'animació de l'aigua }
  aiguap1,aiguap2: word;        { contadors per al frame actual de l'aigua }
  moves : tipo_moves;           { posibles accions de baloo }
  baloo : array[0..20] of tipo_baloo;      { els baloos en qüestió }
  count : tipo_count;           { nombre d'accions que li queden al jugador }
  sbaloo: word;                 { baloo seleccionat }
  numbaloos : word;             { nombre de baloos actual }
  i,j,k : word;                 { variables auxiliars }
  red1,red2,green1,green2,blue1,blue2: byte; { per a la rotació de la paleta }
  mouseX,mouseY : word;         { coordenades del ratolí }
  b1,b2,b3 : boolean;           { botons del ratolí }
  OldExit: Pointer;             { Punter a l'antiga interrupció d'eixida de programa}
  password : passwords;         { Passwords de les fases }
  exp : array[0..9] of tipo_exp;{ les explosións de pixels }
  numexp : word;                { nombre actual d'explosions en pantalla }
  selected : word;              { acció seleccionada }
  final: boolean;               { s'ha acavat la fase? }
  back : PtrVScreen;            { Una pantalla virtual que hem faltava }
  BK : Word;                    { ...                                 }
  yt: word;                     { offset del text... el mantinc per compatibilitat }
  tempo : byte;                 { la velocitat dels arounders és menor que la del rellotge }

  layout, bmpfondo : word;      { layout de la fase. bmpfondo no s'utilitza }
  Initx,Inity : word;           { on comencen els baloos }
  Initnumbaloos,totalbaloos : word; { variables per al total de baloos }
  InitOrient : word;            { orientació inicial dels baloos }
  InitTime,Level : word;        { InitTime no s'utilitza. Level = nivell actual }
  Time : word;                  { temps de diferencia entre un baloo i altre }

  barrived, bneeded : word;     { baloos que han arrivat. baloos necessaris }
  EndX, EndY : word;            { on acaven els baloos (en el millor dels casos) }
  Pause : boolean;              { Estem en Pausa? }

  Pal1,pal2,pal3 : AuxPalette;  { paletes necessaries }
  starting: boolean;            { es la primera vegada que entrem al menu? }
  foc : boolean;                { aigua o foc? }

  Port, DMA, IRQ, midi : byte;  { Dades del MIDI }
  config : file of byte;        { fitxer de configuració }
  plogudax,ploguday : word;     { pa la ploguda }
  copo : array[0..20] of tipo_copo;             { pa la neu     }

  ploguda,neu : boolean;        { campanetes de Torrent, el sol fora i ploguent... o nevant }



{ ***************************** }
{ * EIXIR I ALLIBERAR MEMORIA * }
{ ***************************** }
procedure eixir; Far;             { encara que pete el joc, alliberarà la memòria }
begin
ExitProc := OldExit;    { tornem la interrupció al seu lloc }
EndVirtual(Back);       { Alliberem la p. virtual }
ClearKB;                { Borrem el buffer del teclat (per seguretat) }
FreeKB;                 { Alliberem l'interrupció del teclat }
EndMOUSE;               { Ratolí fora }
EndDM;                  { VGA i p. virtuals fora }
end;


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


{ ****************************** }
{ * FICA UNA PART D'UNA PALETA * }
{ ****************************** }
procedure PartPal(palette: AuxPalette);
var
  loop: byte;
begin
  WaitRetrace;
  for loop:= 128 to 255 do
    SetRGB(loop,palette[loop].r,palette[loop].g,palette[loop].b);
end;


{ ***************************** }
{ *    CARREGAR MAPA ACTUAL   * }
{ ***************************** }
procedure loadmap;

type tipolevel = record
  layout,bmpfondo,orient,num,need  : byte;
  p1                               : array[0..6] of byte;
  tile                             : array[0..19,0..9] of byte;
end;

var
  mylevel : tipolevel;
  i,j   : word;
  f     : file of tipolevel;
  temp  : char;
  temp2 : byte;

begin
If level = 0 then level := 1;
assign(f,'data\data.bal');
reset(f);
seek(f,level-1);
read(f,mylevel);
close(f);

layout                  := mylevel.layout;

If layout = 5 then foc := True else foc := False;

For i := 0 to 9 do
  begin
  For j := 0 to 19 do
    begin
    If mylevel.tile[j,i] < 250 then     { nombres majors de 250 reservats }
      begin
      putbloc(SP,(18240)+((layout shl 4)*320)+(mylevel.tile[j,i] shl 4),IP,16,16,j shl 4,i shl 4);
      end;
    If mylevel.tile[j,i] = 253 then begin InitX := j shl 4; InitY := i shl 4; end;
    If mylevel.tile[j,i] = 254 then begin EndX  := j shl 4; EndY  := i shl 4; end;
    end;
  end;

bmpfondo                := mylevel.bmpfondo;

InitOrient              := mylevel.orient;
totalbaloos             := mylevel.num;
bneeded                 := mylevel.need;
count.parant            := mylevel.p1[0];
count.cavant            := mylevel.p1[1];
count.escalant          := mylevel.p1[2];
count.perforant         := mylevel.p1[3];
count.escalera          := mylevel.p1[4];
count.pasarela          := mylevel.p1[5];
count.corda             := mylevel.p1[6];


  baloo[0].x := InitX; baloo[0].y := InitY+8;
  baloo[0].frame := moves.aroundant;
  baloo[0].orient := InitOrient;
  baloo[0].mode := aroundant;
  baloo[0].goX := baloo[0].x;

end;



{ ***************************** }
{ *     TEXT D'UN TIPUS       * }
{ ***************************** }
procedure text2(x,y:word; cadena:string; page:word);
var i:word;
begin
For i := 1 to length(cadena) do
  begin
  j := ord(cadena[i]);
  If j <> 32 then
    begin
    If (j > 47) and (j < 61) then j := j - 22
    else If (j > 64) and (j < 91) then j := j - 65;
    putsprite(SP,(((j) shl 3)-(j)),100,page,(x-1)+(((i-1) shl 3)-(i-1)),(y-1),7,6);
    end;              {                       ^                           ^  }
  end;                { per a eixir del pas   |                           |  }
end;


{ ***************************** }
{ *   TEXT D'UN ALTRE TIPUS   * }
{ ***************************** }
procedure text(x,y:word; cadena:string; page:word);
var i:word;
begin
For i := 1 to length(cadena) do
  begin
  j := ord(cadena[i]);
  If j <> 32 then
    begin
    If (j > 47) and (j < 61) then j := j - 22
    else If (j > 64) and (j < 91) then j := j - 65;
    putsprite(SP,(((j) shl 3)-(j)),yt,page,(x-1)+(((i-1) shl 3)-(i-1)),(y-1),7,6);
    end;              {                      ^                           ^  }
  end;                { per a eixir del pas  |                           |  }
end;




{ ***************************** }
{ *    CREAR UNA EXPLOSIà     * }
{ ***************************** }
procedure create_exp(x,y,num,c1,c2,c3:word);
var i: word;
begin
If (numexp > 9) or (numexp < 0) then exit;

exp[numexp].count := 0;
exp[numexp].numpix := num;
for i := 0 to exp[numexp].numpix -1 do
  begin
  exp[numexp].pix[i].x  := x;
  exp[numexp].pix[i].y  := y;
  exp[numexp].pix[i].xa := random(c2)-(c2 shr 1);
  exp[numexp].pix[i].ya := random(c2)-(c2 shr 1);
  exp[numexp].pix[i].g  := 1;
  exp[numexp].pix[i].c  := c1;
  end;
inc(numexp);
end;





{ ***************************** }
{ *      CREAR UN BALOO       * }
{ ***************************** }
procedure create_baloo;
begin
baloo[numbaloos].x := InitX;
baloo[numbaloos].y := InitY+8;
baloo[numbaloos].frame := moves.aroundant;
baloo[numbaloos].orient := InitOrient;
baloo[numbaloos].mode := aroundant;
baloo[numbaloos].wannabe := aroundant;
baloo[numbaloos].goX := baloo[numbaloos].x;
inc(numbaloos);
end;




{ ***************************** }
{ *     DESTRUIR UN BALOO     * }
{ ***************************** }
procedure destroy_baloo(i:word);
begin
If numbaloos > 1 then dec(numbaloos) else final := True;
If i <> numbaloos then baloo[i] := baloo[numbaloos];
If sbaloo = i then sbaloo := 0;
If sbaloo > numbaloos then sbaloo := i;
end;





{ *************************************** }
{ *     eXINTERRUPCIà DEL RELLOTGE      * }
{ *                                     * }
{ * Ac¡ es realitzen diferents tasques, * }
{ *   principalment moure cada baloo    * }
{ *   segons la seua animaci¢ actual    * }
{ *************************************** }
Procedure TimeHandler(l:longint); {far;}
var
  i,j : word;
label
  jump;
begin

If tempo <> 3 then begin inc(tempo); exit; end;
tempo := 1;


If Pause then exit;

If Initnumbaloos > 1 then
  begin
  inc(Time);
  If Time = 80 then begin create_baloo; dec(Initnumbaloos); time := 0; end;
  end;

inc(aiguap1);
inc(aiguap2);

If (not foc) and (aiguap1 = 10) then aiguap1 := 0;
If (not foc) and (aiguap2 = 10) then aiguap2 := 0;
If (foc) and (aiguap1 = 6) then aiguap1 := 0;
If (foc) and (aiguap2 = 6) then aiguap2 := 0;

If final then exit;

i := 0;
While i <> numbaloos do
begin

case baloo[i].mode of


parant:

  begin
  baloo[i].j := 0; baloo[i].k := 0;
  baloo[i].frame := moves.parant;
  end;

explotant:

  begin
  case baloo[i].k of
  5: begin
      circle(baloo[i].x+4,baloo[i].y+3,10,0,IP);
      create_exp(baloo[i].x+4,baloo[i].y+3,20,200,20,0);
      baloo[i].k := 0;
      baloo[i].j := 0;
      baloo[i].mode := quiet;
      baloo[i].wannabe := 0;
      destroy_baloo(i);
      if final then exit;
      goto jump;
     end;
  4: begin baloo[i].j := 16; baloo[i].k := 5; end;
  3: begin baloo[i].j := 8 ; baloo[i].k := 4; end;
  2: begin baloo[i].j := 16; baloo[i].k := 3; end;
  1: begin baloo[i].j := 8 ; baloo[i].k := 2; end;
  0: begin baloo[i].j := 0 ; baloo[i].k := 1; end;
  end; { del CASE }
  baloo[i].frame := moves.explotant;
  end;

aroundant:

  begin
{  If baloo[i].k > 32 then
    begin
    create_exp(baloo[i].x,baloo[i].y+4,20,200,20,0);
    destroy_baloo(i);
    if final then exit;
    goto jump;
    end;}
  baloo[i].frame := moves.aroundant;
  baloo[i].k := 0;

  If baloo[i].j = 8 then baloo[i].j := 0 else baloo[i].j := 8;

  If (baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x-1,baloo[i].y+7) <> 0) and
     (getpixel(IP,baloo[i].x-1,baloo[i].y+7) <> 68) then
    begin
    If (getpixel(IP,baloo[i].x-1,baloo[i].y+6) = 0) or
       (getpixel(IP,baloo[i].x-1,baloo[i].y+6) = 67) then
      baloo[i].y := baloo[i].y - 1
    else
      begin
      if baloo[i].wannabe = cavant then                 { PRIMER QUE CAVE }
        begin
        baloo[i].wannabe := 0;
        dec(count.cavant);
        baloo[i].mode := cavant;
        goto jump;
        end;
      If baloo[i].wannabe = escalant then               { I SINO ESCALAR }
        begin
        baloo[i].wannabe := 0;
        dec(count.escalant);
        baloo[i].mode := escalant;
        baloo[i].x := baloo[i].x - 5;
        baloo[i].k := 0;
        goto jump;
        end;
      baloo[i].orient := dreta;
      goto jump;
      end;
    end;

  If (baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+8,baloo[i].y+7) <> 0) and
     (getpixel(IP,baloo[i].x+8,baloo[i].y+7) <> 68) then
    If (getpixel(IP,baloo[i].x+8,baloo[i].y+6) = 0) or
       (getpixel(IP,baloo[i].x+8,baloo[i].y+6) = 67) then
      baloo[i].y := baloo[i].y - 1
    else
      begin
      if baloo[i].wannabe = cavant then
        begin
        baloo[i].wannabe := 0;
        dec(count.cavant);
        baloo[i].mode := cavant;
        goto jump;
        end;
      If baloo[i].wannabe = escalant then
        begin
        baloo[i].wannabe := 0;
        dec(count.escalant);
        baloo[i].mode := escalant;
        baloo[i].x := baloo[i].x + 5;
        baloo[i].k := 0;
        goto jump;
        end;
      baloo[i].orient := esquerra;
      goto jump;
      end;

  For j := 0 to numbaloos-1 do
    begin
    If (baloo[j].mode = parant) then
      begin
      If (baloo[i].orient = esquerra) and (baloo[j].x = baloo[i].x-8) and
      ((baloo[j].y = baloo[i].y) or (baloo[j].y = baloo[i].y-1) or (baloo[j].y = baloo[i].y+1)) then
        begin baloo[i].orient := dreta; goto jump; end;
      If (baloo[i].orient = dreta) and (baloo[j].x = baloo[i].x+8) and
      ((baloo[j].y = baloo[i].y) or (baloo[j].y = baloo[i].y-1) or (baloo[j].y = baloo[i].y+1)) then
        begin baloo[i].orient := esquerra; goto jump; end;
      end;
    end;

  If (baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x-1,baloo[i].y)=68) then
    begin
    baloo[i].mode := escalant;
    baloo[i].x := baloo[i].x - 5;
    baloo[i].k := 1;
    goto jump;
    end;
  If (baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+8,baloo[i].y)=68) then
    begin
    baloo[i].mode := escalant;
    baloo[i].x := baloo[i].x + 5;
    baloo[i].k := 1;
    goto jump;
    end;

  If (baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+7,baloo[i].y+8) = 0)
     and (getpixel(IP,baloo[i].x+8,baloo[i].y+8) = 0) and (baloo[i].wannabe = corda)
     and (getpixel(IP,baloo[i].x+8,baloo[i].y+9) = 0) and (getpixel(IP,baloo[i].x+8,baloo[i].y+10) = 0) then
    begin
    dec(count.corda);
    baloo[i].mode := corda;
    baloo[i].wannabe := 0;
    baloo[i].k := 1;
    end;
  If (baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x,baloo[i].y+8) = 0)
     and (getpixel(IP,baloo[i].x-1,baloo[i].y+8) = 0) and (baloo[i].wannabe = corda)
     and (getpixel(IP,baloo[i].x-1,baloo[i].y+9) = 0) and (getpixel(IP,baloo[i].x-1,baloo[i].y+10) = 0) then
    begin
    dec(count.corda);
    baloo[i].mode := corda;
    baloo[i].wannabe := 0;
    baloo[i].k := 1;
    end;

  If (getpixel(IP,baloo[i].x-1,baloo[i].y+8) = 68) and (baloo[i].orient=esquerra) then
    begin
    baloo[i].mode := descens;
    baloo[i].orient := dreta;
    baloo[i].x := baloo[i].x - 4;
    baloo[i].k := 1;
    goto jump;
    end;
  If (getpixel(IP,baloo[i].x+8,baloo[i].y+8) = 68) and (baloo[i].orient=dreta) then
    begin
    baloo[i].mode := descens;
    baloo[i].orient := esquerra;
    baloo[i].x := baloo[i].x + 4;
    baloo[i].k := 1;
    goto jump;
    end;


  If baloo[i].orient = dreta then baloo[i].x := baloo[i].x + 1;
  If baloo[i].orient = esquerra then baloo[i].x := baloo[i].x - 1;

  end;


caiguent:

  begin
  baloo[i].y := baloo[i].y + 1;
  inc(baloo[i].k);
  baloo[i].frame := moves.caiguent;
  If (getpixel(IP,baloo[i].x,baloo[i].y+8) <> 0) or (getpixel(IP,baloo[i].x+7,baloo[i].y+8) <> 0) then
    begin
    baloo[i].mode := quiet;
    If baloo[i].k > 32 then
      begin
      create_exp(baloo[i].x,baloo[i].y+4,20,200,20,0);
      destroy_baloo(i);
      if final then exit;
      goto jump;
      end;
    end;
  end;


cavant:

  begin
  baloo[i].frame := moves.cavant;
  baloo[i].k := 0;
  case baloo[i].j of
  16: baloo[i].j := 0;
  8:  baloo[i].j := 16;
  0:  baloo[i].j := 8;
  end;

  If (baloo[i].orient = esquerra) and (baloo[i].j = 16) then
    begin
    line(baloo[i].x-1,baloo[i].y,baloo[i].x-1,baloo[i].y+7,0,IP);
    create_exp(baloo[i].x-1,baloo[i].y,10,200,10,3);
    baloo[i].x := baloo[i].x - 1;
    if getpixel(IP,baloo[i].x-1,baloo[i].y+7) = 0 then
      begin
      baloo[i].mode := quiet;
      end;
    end;
  If (baloo[i].orient = dreta) and (baloo[i].j = 16) then
    begin
    line(baloo[i].x+8,baloo[i].y,baloo[i].x+8,baloo[i].y+7,0,IP);
    create_exp(baloo[i].x+8,baloo[i].y,10,200,10,3);
    baloo[i].x := baloo[i].x + 1;
    if getpixel(IP,baloo[i].x+8,baloo[i].y+7) = 0 then
      begin
      baloo[i].mode := quiet;
      end;
    end;
  end;


escalant:

  begin
  baloo[i].frame := moves.escalant;
{  baloo[i].k := 0;}
  If baloo[i].j <> 8  then baloo[i].j := 8 else baloo[i].j := 0;
  If (baloo[i].k<>0) and (baloo[i].k<8) then inc(baloo[i].k);

  baloo[i].y := baloo[i].y - 1;

If baloo[i].k = 8 then baloo[i].k := 0;
If baloo[i].k = 0 then
  if ((baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x,baloo[i].y+7) = 0)
     and (getpixel(IP,baloo[i].x+4,baloo[i].y+7)<>68))
  or
     ((baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+7,baloo[i].y+7) = 0)
     and (getpixel(IP,baloo[i].x+3,baloo[i].y+7)<>68)) then
    begin
    baloo[i].y := baloo[i].y -1;
    baloo[i].mode := quiet;
    goto jump;
    end;

  if ((baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x+6,baloo[i].y-1) <> 0)
      and (getpixel(IP,baloo[i].x+4,baloo[i].y-1) <> 68) and (getpixel(IP,baloo[i].x+4,baloo[i].y+7) <> 68))
  or
     ((baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+1,baloo[i].y-1) <> 0)
      and (getpixel(IP,baloo[i].x+3,baloo[i].y-1) <> 68) and (getpixel(IP,baloo[i].x+3,baloo[i].y+7) <> 68)) then
    begin
    If baloo[i].orient = esquerra then begin baloo[i].x := baloo[i].x + 5; baloo[i].orient := dreta; end;
    If baloo[i].orient = dreta then begin baloo[i].x := baloo[i].x - 5; baloo[i].orient := esquerra; end;
    baloo[i].mode := caiguent;
    goto jump;
    end;
  end;

descens:

  begin
  baloo[i].frame := moves.escalant;
{  baloo[i].k := 0;}
  If baloo[i].j <> 8  then baloo[i].j := 8 else baloo[i].j := 0;
{  If baloo[i].k = 0 then putpixel(baloo[i].x+2,baloo[i].y+7,68,IP);}
  baloo[i].y := baloo[i].y + 1;

  { SI FENT CORDA, MIRA SI S'HA ARRIVAT A TERRA }
  { SI BAIXANT CORDA, MIRA SI QUEDA CORDA }

  if ((baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x+4,baloo[i].y+8) <> 68)) or
     ((baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+3,baloo[i].y+8) <> 68)) then
    begin
    baloo[i].y := baloo[i].y +1;
    baloo[i].mode := quiet;
    If baloo[i].orient = esquerra then baloo[i].orient := dreta else baloo[i].orient := esquerra;
    goto jump;
    end;

{  if ((baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x+6,baloo[i].y-1) <> 0)) or
     ((baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+1,baloo[i].y-1) <> 0)) then
    begin
    If baloo[i].orient = esquerra then begin baloo[i].x := baloo[i].x + 5; baloo[i].orient := dreta; end;
    If baloo[i].orient = dreta then begin baloo[i].x := baloo[i].x - 5; baloo[i].orient := esquerra; end;
    baloo[i].mode := caiguent;
    goto jump;
    end;}
  end;

corda:

  begin
  baloo[i].frame := moves.escalera;
  baloo[i].wannabe := 0;
  case baloo[i].j of
  24: baloo[i].k := baloo[i].k + 1;
  16: baloo[i].j := 24;
  8:  baloo[i].j := 16;
  0:  baloo[i].j := 8;
  end;

  If (baloo[i].orient = dreta) and (baloo[i].j = 24) then
    begin
    If getpixel(IP,baloo[i].x+8,baloo[i].y+8+baloo[i].k+3)<>0 then
      begin
      baloo[i].mode := quiet;
      baloo[i].k := 0; baloo[i].j := 0;
      goto jump;
      end
    else
      begin
      putpixel(baloo[i].x+8,baloo[i].y+7+baloo[i].k,68,IP);
      end;
    end;
  If (baloo[i].orient = esquerra) and (baloo[i].j = 24) then
    begin
    If getpixel(IP,baloo[i].x-1,baloo[i].y+8+baloo[i].k+3)<>0 then
      begin
      baloo[i].mode := quiet;
      baloo[i].k := 0; baloo[i].j := 0;
      goto jump;
      end
    else
      begin
      putpixel(baloo[i].x-1,baloo[i].y+7+baloo[i].k,68,IP);
      end;
    end;

  end;

perforant:

  begin
  baloo[i].frame := moves.perforant;
  baloo[i].k := 0;
  If baloo[i].j <> 8  then baloo[i].j := 8 else baloo[i].j := 0;

  If (baloo[i].j = 8) then
    begin
    line(baloo[i].x,baloo[i].y+8,baloo[i].x+7,baloo[i].y+8,0,IP);
    create_exp(baloo[i].x+4,baloo[i].y+8,10,200,10,3);
    baloo[i].y := baloo[i].y + 1;
    if (getpixel(IP,baloo[i].x,baloo[i].y+8) = 0) and (getpixel(IP,baloo[i].x+7,baloo[i].y+8) = 0) and
       (getpixel(IP,baloo[i].x+3,baloo[i].y+8) = 0) and (getpixel(IP,baloo[i].x+4,baloo[i].y+8) = 0) then
      begin
      baloo[i].mode := quiet;
      end;
    end;
  end;


escalera:

  begin
  baloo[i].frame := moves.escalera;
  baloo[i].k := 0;
  case baloo[i].j of
  24: baloo[i].j := 0;
  16: baloo[i].j := 24;
  8:  baloo[i].j := 16;
  0:  baloo[i].j := 8;
  end;

  If count.escalera = 0 then baloo[i].mode := quiet;

  If (baloo[i].j = 0) and
     ( ((getpixel(IP,baloo[i].x,baloo[i].y-1) <> 0) or (getpixel(IP,baloo[i].x+7,baloo[i].y-1) <> 0) ) or
     ((baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x-1,baloo[i].y+7) <> 0)) or
     ((baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+8,baloo[i].y+7) <> 0)) ) then
    begin
    baloo[i].mode := quiet;
    end;

  If (baloo[i].orient = dreta) and (baloo[i].j = 24) then
    begin
    dec(count.escalera);
    line(baloo[i].x+6,baloo[i].y+7,baloo[i].x+8,baloo[i].y+7,67,IP);
    baloo[i].x := baloo[i].x + 1; baloo[i].y := baloo[i].y - 1;
    end;
  If (baloo[i].orient = esquerra) and (baloo[i].j = 24) then
    begin
    dec(count.escalera);
    line(baloo[i].x-1,baloo[i].y+7,baloo[i].x+1,baloo[i].y+7,67,IP);
    baloo[i].x := baloo[i].x - 1; baloo[i].y := baloo[i].y - 1;
    end;
  end;


pasarela:

  begin
  baloo[i].frame := moves.pasarela;
  baloo[i].k := 0;
  case baloo[i].j of
  24: baloo[i].j := 0;
  16: baloo[i].j := 24;
  8:  baloo[i].j := 16;
  0:  baloo[i].j := 8;
  end;

  If count.pasarela = 0 then baloo[i].mode := quiet;

  If (baloo[i].j = 0) and
     ( ((getpixel(IP,baloo[i].x,baloo[i].y-1) <> 0) or (getpixel(IP,baloo[i].x+7,baloo[i].y-1) <> 0) ) or
     ((baloo[i].orient = esquerra) and (getpixel(IP,baloo[i].x-1,baloo[i].y+7) <> 0)) or
     ((baloo[i].orient = dreta) and (getpixel(IP,baloo[i].x+8,baloo[i].y+7) <> 0)) ) then
    begin
    baloo[i].mode := quiet;
    end;

  If (baloo[i].orient = dreta) and (baloo[i].j = 24) then
    begin
    dec(count.pasarela);
    line(baloo[i].x+6,baloo[i].y+8,baloo[i].x+8,baloo[i].y+8,67,IP);
    baloo[i].x := baloo[i].x + 2;
    end;
  If (baloo[i].orient = esquerra) and (baloo[i].j = 24) then
    begin
    dec(count.pasarela);
    line(baloo[i].x-1,baloo[i].y+8,baloo[i].x+1,baloo[i].y+8,67,IP);
    baloo[i].x := baloo[i].x - 2;
    end;
  end;


end; { final del CASE }

jump:

inc(i);
end; { final del WHILE }

end;



{ ******************************** }
{ * PROCEDIMENT D'INICIALITZACIà * }
{ * DE MEMORIA, MODE GRAFIC, ETC.* }
{ ******************************** }
Procedure Start;
var
 i,j: integer;
 f : file of passwords;
begin
Port := 255;
DMA  := 255;
IRQ  := 255;
midi := 0;

{$I-}
assign(config,'around.cfg');
reset(config);
close(config);
{$I+}
If IOResult <> 0 then
  begin
  clrscr;
  Writeln('Arxiu de configuraci¢ "around.cfg" no trobat.');
  Writeln('Deus executar "Setup.exe" abans de jugar.');
  halt;
  end;
assign(config,'around.cfg');
reset(config);
read(config,Port);
read(config,DMA);
read(config,IRQ);
read(config,midi);
close(config);

Randomize;
OldExit := ExitProc;
ExitProc := @Eixir;
Starting := True;
randomize;
InitDM;
HookKB;
initMOUSE;
InitVirtual(Back,BK);
{InitVirtual(World,WL);}

HBMouse(313,0);
VBMouse(192,0);
numexp := 0;

assign(f,'data\offsets.bal');
reset(f);
read(f,password);
close(f);

For i := 2 to 30 do
  for j := 1 to 10 do
    password[i][j] := chr( ord(password[i][j])-100 -j);

IF midi = 1 then SetGM;
IF midi = 2 then SetFM;

end;





{ ******************************** }
{ * PROCEDIMENT D'INICIALITZACIà * }
{ * DE VARIABLES, MAPA i JOC.    * }
{ ******************************** }
Procedure Init_Game;
var
   i,j : integer;
   s : string;
begin
moves.quiet.x := 0;
moves.quiet.y := 0;
moves.quiet.w := 8;
moves.quiet.h := 8;

moves.caiguent.x := 88;
moves.caiguent.y := 0;
moves.caiguent.w := 8;
moves.caiguent.h := 8;

moves.explotant.x := 0;
moves.explotant.y := 0;
moves.explotant.w := 8;
moves.explotant.h := 8;

moves.moventse.x := 24;
moves.moventse.y := 0;
moves.moventse.w := 8;
moves.moventse.h := 8;

moves.cavant.x := 48;
moves.cavant.y := 0;
moves.cavant.w := 8;
moves.cavant.h := 8;

moves.parant.x := 16;
moves.parant.y := 0;
moves.parant.w := 8;
moves.parant.h := 8;

moves.escalant.x := 72;
moves.escalant.y := 0;
moves.escalant.w := 8;
moves.escalant.h := 8;

moves.perforant.x := 96;
moves.perforant.y := 0;
moves.perforant.w := 8;
moves.perforant.h := 8;

moves.escalera.x := 112;
moves.escalera.y := 0;
moves.escalera.w := 8;
moves.escalera.h := 8;

moves.aroundant.x := 24;
moves.aroundant.y := 0;
moves.aroundant.w := 8;
moves.aroundant.h := 8;

moves.pasarela.x := 112;
moves.pasarela.y := 0;
moves.pasarela.w := 8;
moves.pasarela.h := 8;

For i := 0 to 20 do
  begin
  copo[i].x := 0;
  copo[i].y := 0;
  copo[i].actiu := False;
  end;

LoadGIF('data\grf12.bal',SP);
cls(0,IP);
cls(0,BK);

{level := 24;}

loadmap;

{neu := True;}

plogudax := 219; ploguday := 0;

If level = 1 then InSeq(SP,pal2,midi,1);
If level = 6 then InSeq(SP,pal2,midi,6);
If level = 11 then InSeq(SP,pal2,midi,11);
If level = 16 then InSeq(SP,pal2,midi,16);
If level = 21 then InSeq(SP,pal2,midi,21);
If level = 26 then InSeq(SP,pal2,midi,26);

LoadGIF('data\grf12.bal',SP);
RestorePalette(pal1);

If foc then
  begin
  aigua[0] := 96;
  aigua[1] := 112;
  aigua[2] := 128;
  aigua[3] := 144;
  aigua[4] := 160;
  aigua[5] := 176;
  aiguap1 := 0; aiguap2 := 3;
  end
else
  begin
  aigua[0] := 0;
  aigua[1] := 16;
  aigua[2] := 32;
  aigua[3] := 16;
  aigua[4] := 0;
  aigua[5] := 48;
  aigua[6] := 64;
  aigua[7] := 80;
  aigua[8] := 64;
  aigua[9] := 48;
  aiguap1 := 0; aiguap2 := 5;
  end;

{cls(0,WP);}
cls(0,VGA);
delay(50);
clearKB;
Final := False;

LoadGIF('data\grf11.bal',BK);
blackout;
text(130,60,'NIVELL '+inttostr(level),BK);
text(80,100,inttostr(totalbaloos)+' AROUNDERS DISPONIBLES',BK);
text(80,110,inttostr(bneeded)+' AROUNDERS NECESSARIS',BK);
flip(BK,VGA);
fadein(pal1);
repeat until QKeyPress;
fadeout;
cls(0,VGA);
cls(0,BK);
restorepalette(pal1);

{For i := 0 to 9 do
  For j := 0 to 4 do
    Putbloc(SP,53760+(bmpfondo shl 5),BK,32,32,i shl 5, j shl 5);}


s := 'data\bkg'+inttostr((level-1) mod 10)+'.bal';
LoadGIF(s,BK);
s := 'data\pbk'+inttostr((level-1) mod 10)+'.bal';
LoadPal(s,pal3);

selected := moventse;

numbaloos := 1; sbaloo := 0;

Initnumbaloos := totalbaloos;
barrived := 0;

For i := 0 to InitNumBaloos do
  baloo[i].k := 0;

Pause := False;

tempo := 1;

end;





{ ************************************* }
{ * VORE I ACTUALITZAR LES EXPLOSIONS * }
{ ************************************* }
procedure show_exp;
var c1,c2: word;
begin
c1 := 0;

while c1 <> numexp do
  begin
  For c2 := 0 to exp[c1].numpix-1 do
    begin
    exp[c1].pix[c2].x  := exp[c1].pix[c2].x  + exp[c1].pix[c2].xa;
    exp[c1].pix[c2].ya := exp[c1].pix[c2].ya + exp[c1].pix[c2].g;
    exp[c1].pix[c2].y  := exp[c1].pix[c2].y  + exp[c1].pix[c2].ya;
    If (exp[c1].pix[c2].x > 0) and (exp[c1].pix[c2].x < 319) and
       (exp[c1].pix[c2].y > 0) and (exp[c1].pix[c2].y < 199) then
         putpixel(exp[c1].pix[c2].x,exp[c1].pix[c2].y,exp[c1].pix[c2].c,WP);
    end;
  inc(exp[c1].count);

  inc(c1);

  If exp[c1-1].count = 20 then
    begin
    dec(numexp);
    dec(c1);
    If (c1) <> numexp then
      begin
      exp[c1] := exp[numexp];
      end;

    end;
  end;

end;





{ ************************************* }
{ * VORE I ACTUALITZAR LES EXPLOSIONS * }
{ * SENSE TORNAR AL JOC(PER AL FINAL) * }
{ ************************************* }
procedure show_exp_modal;
var c1,c2: word;
begin

Repeat
c1 := 0;

while c1 <> numexp do
  begin
  For c2 := 0 to exp[c1].numpix-1 do
    begin
    exp[c1].pix[c2].x  := exp[c1].pix[c2].x  + exp[c1].pix[c2].xa;
    exp[c1].pix[c2].ya := exp[c1].pix[c2].ya + exp[c1].pix[c2].g;
    exp[c1].pix[c2].y  := exp[c1].pix[c2].y  + exp[c1].pix[c2].ya;
    If (exp[c1].pix[c2].x > 0) and (exp[c1].pix[c2].x < 319) and
       (exp[c1].pix[c2].y > 0) and (exp[c1].pix[c2].y < 199) then
         putpixel(exp[c1].pix[c2].x,exp[c1].pix[c2].y,exp[c1].pix[c2].c,VGA);
    end;
  inc(exp[c1].count);
  inc(c1);
  If exp[c1-1].count = 20 then
    begin
    dec(numexp);
    dec(c1);
    If (c1) <> numexp then
      begin
      exp[c1] := exp[numexp];
      end;
    end;
  end;
until numexp = 0;
end;






{ ********************************** }
{ * CALCUL DE POSICIONS DEL RATOLÖ * }
{ ********************************** }
Procedure Calcul;
begin

getmouse(mouseX,mouseY,b1,b2,b3);

if (b1) then
  begin
  If mouseY > 170 then
    begin
    selected := moventse;

{PARANT}
    If (mouseX > 20) and (mouseX < 36) and (count.parant > 0) and (baloo[sbaloo].mode <> parant) then
      begin
      dec(count.parant);
      baloo[sbaloo].mode := parant;
      baloo[sbaloo].orient := esquerra;
      baloo[sbaloo].frame := moves.parant;
      end;

{CAVANT}
    If (mouseX > 36) and (mouseX < 52) and (count.cavant > 0) and (baloo[sbaloo].mode <> cavant) then
      baloo[sbaloo].wannabe := cavant;

{ESCALANT}
    If (mouseX > 52) and (mouseX < 68) and (count.escalant > 0) and (baloo[sbaloo].mode <> escalant) then
      baloo[sbaloo].wannabe := escalant;

{PERFORANT}
    If (mouseX > 68) and (mouseX < 84) and (count.perforant > 0) and (baloo[sbaloo].mode <> perforant) then
      begin
      If (getpixel(IP,baloo[sbaloo].x,baloo[sbaloo].y+8) <> 0) or
         (getpixel(IP,baloo[sbaloo].x+7,baloo[sbaloo].y+8) <> 0) then
        begin
        baloo[sbaloo].mode := perforant;
        dec(count.perforant);
        end;
      end;

{ESCALERA}
    If (mouseX > 84) and (mouseX < 100) and (count.escalera > 0) and (baloo[sbaloo].mode <> escalera) then
      begin
      IF
       (
        (baloo[sbaloo].orient = esquerra) and (getpixel(IP,baloo[sbaloo].x-1,baloo[sbaloo].y+7) = 0) and
        ((getpixel(IP,baloo[sbaloo].x,baloo[sbaloo].y-1) = 0) {and (getpixel(IP,baloo[sbaloo].x+7,baloo[sbaloo].y-1) = 0)} )
       )
      OR
       (
        (baloo[sbaloo].orient = dreta) and (getpixel(IP,baloo[sbaloo].x+8,baloo[sbaloo].y+7) = 0) and
        ({(getpixel(IP,baloo[sbaloo].x,baloo[sbaloo].y-1) = 0) and} (getpixel(IP,baloo[sbaloo].x+7,baloo[sbaloo].y-1) = 0) )
       )
      THEN baloo[sbaloo].mode := escalera;
      end;
    {100-116 116-132 132-148}

{PASARELA}
    If (mouseX > 100) and (mouseX < 116) and (count.pasarela > 0) and (baloo[sbaloo].mode <> pasarela) then
      begin
      IF
       (
        (baloo[sbaloo].orient = esquerra) and (getpixel(IP,baloo[sbaloo].x-1,baloo[sbaloo].y+7) = 0) {and}
        {((getpixel(IP,baloo[sbaloo].x,baloo[sbaloo].y-1) = 0) and (getpixel(IP,baloo[sbaloo].x+7,baloo[sbaloo].y-1) = 0) )}
       )
      OR
       (
        (baloo[sbaloo].orient = dreta) and (getpixel(IP,baloo[sbaloo].x+8,baloo[sbaloo].y+7) = 0) {and}
        {((getpixel(IP,baloo[sbaloo].x,baloo[sbaloo].y-1) = 0) and (getpixel(IP,baloo[sbaloo].x+7,baloo[sbaloo].y-1) = 0) )}
       )
      THEN baloo[sbaloo].mode := pasarela;
      end;

{CORDA}
    If (mouseX > 116) and (mouseX < 132) and (count.corda > 0) then
      begin
      baloo[sbaloo].wannabe := corda;
      end;

{EXPLOTANT}
    If (mouseX > 132) and (mouseX < 148) then
      begin
      baloo[sbaloo].mode := explotant;
      baloo[sbaloo].j := 0; baloo[sbaloo].k := 0;
      baloo[sbaloo].orient := dreta;
      end;

{SUICIDI COLECTIU}
    If (mouseX > 148) and (mouseX < 164) then
      begin
      For i := 0 to numbaloos-1 do
        begin
        baloo[i].mode := explotant;
        baloo[i].j := 0; baloo[i].k := 0;
        baloo[i].orient := dreta;
        end;
      end;

    end
  else
  begin

  For i := 0 to numbaloos-1 do
    begin
    If (baloo[i].x <= mouseX) and (baloo[i].x+7 >= mouseX) and
       (baloo[i].y <= mouseY) and (baloo[i].y+7 >= mouseY) then
       sbaloo := i;
    end;

  If (baloo[sbaloo].mode = quiet) and (baloo[sbaloo].mode <> caiguent) then
    begin


    If selected = moventse then
      begin
      If mouseX < baloo[sbaloo].x then
          baloo[sbaloo].orient := esquerra;
      If mouseX > baloo[sbaloo].x then
          baloo[sbaloo].orient := dreta;
      end;


    If selected = aroundant then
      begin
      If mouseX < baloo[sbaloo].x then
        If (getpixel(IP,baloo[sbaloo].x-1,baloo[sbaloo].y+7) = 0) or
           ((getpixel(IP,baloo[sbaloo].x-1,baloo[sbaloo].y+7) <> 0) and
           ((getpixel(IP,baloo[sbaloo].x-1,baloo[sbaloo].y+6) = 0) or
           (getpixel(IP,baloo[sbaloo].x-1,baloo[sbaloo].y+8) = 0))) then
          begin
          baloo[sbaloo].mode := aroundant;
          baloo[sbaloo].orient := esquerra;
          end;

      If mouseX > baloo[sbaloo].x then
        If (getpixel(IP,baloo[sbaloo].x+8,baloo[sbaloo].y+7) = 0) or
           ((getpixel(IP,baloo[sbaloo].x+8,baloo[sbaloo].y+7) <> 0) and
           ((getpixel(IP,baloo[sbaloo].x+8,baloo[sbaloo].y+6) = 0) or
           (getpixel(IP,baloo[sbaloo].x+8,baloo[sbaloo].y+8) = 0))) then
          begin
          baloo[sbaloo].mode := aroundant;
          baloo[sbaloo].orient := dreta;
          end;
      end;


      selected := moventse;

    end; { de "si est… quiet i no est… caiguent" }
  end; { de "si no est… en la barra" }
  end; { del bucle principal }

If (b3) and (baloo[sbaloo].mode <> caiguent) then
  begin
  baloo[sbaloo].mode := quiet;
  baloo[sbaloo].wannabe := 0;
  baloo[sbaloo].k := 0;
  baloo[sbaloo].j := 0;
  end;

For i := 0 to numbaloos-1 do
  If (getpixel(IP,baloo[i].x,baloo[i].y+8) = 0) and (getpixel(IP,baloo[i].x+2,baloo[i].y+8) = 0) and
     (getpixel(IP,baloo[i].x+4,baloo[i].y+8) = 0) and (getpixel(IP,baloo[i].x+7,baloo[i].y+8) = 0) and
     (baloo[i].mode <> caiguent) and (baloo[i].mode <> explotant) and (baloo[i].mode <> descens)
     and (baloo[i].mode <> escalant) then
    begin
    If ((getpixel(IP,baloo[i].x,baloo[i].y+9) <> 0) or (getpixel(IP,baloo[i].x+2,baloo[i].y+9) <> 0) or
       (getpixel(IP,baloo[i].x+4,baloo[i].y+9) <> 0) or (getpixel(IP,baloo[i].x+7,baloo[i].y+9) <> 0)) and
       (baloo[i].mode <> caiguent) then
         baloo[i].y := baloo[i].y + 1
    else
      begin
      baloo[i].mode := caiguent;
      baloo[i].j := 0;
      end;
    end;

For i := 0 to numbaloos -1 do
  begin
  If (baloo[i].y > 150) or (baloo[i].y < 2) or (baloo[i].x < 2) or (baloo[i].x > 316) then
    begin
    create_exp(baloo[i].x,baloo[i].y+4,20,200,20,0);
    destroy_baloo(i);
    end;
  If (baloo[i].y = EndY+8) and (baloo[i].x = EndX) then
    begin

    inc(barrived);
    destroy_baloo(i);
    end;
  end;

end;






{ ****************************** }
{ *     DEMANA EL PASSWORD     * }
{ ****************************** }
Procedure GetPassWord;
var
  co : word;
  pass : string;
  ctt : word;
  lastkey : byte;
begin
yt := 51;
LoadGIF('data\grf12.bal',SP);
LoadGIF('data\grf11.bal',BK);
blackout;
text(95,80,'ESCRIU EL PASSWORD',BK);
flip(BK,VGA);
fadein(pal1);

pass := '          ';
co := 0;

repeat
{If getKey <> lastkey then
begin}
  case GetKey of
  keyA:begin inc(co); pass[co] := 'A'; end;
  keyB:begin inc(co); pass[co] := 'B'; end;
  keyC:begin inc(co); pass[co] := 'C'; end;
  keyD:begin inc(co); pass[co] := 'D'; end;
  keyE:begin inc(co); pass[co] := 'E'; end;
  keyF:begin inc(co); pass[co] := 'F'; end;
  keyG:begin inc(co); pass[co] := 'G'; end;
  keyH:begin inc(co); pass[co] := 'H'; end;
  keyI:begin inc(co); pass[co] := 'I'; end;
  keyJ:begin inc(co); pass[co] := 'J'; end;
  keyK:begin inc(co); pass[co] := 'K'; end;
  keyL:begin inc(co); pass[co] := 'L'; end;
  keyM:begin inc(co); pass[co] := 'M'; end;
  keyN:begin inc(co); pass[co] := 'N'; end;
  keyO:begin inc(co); pass[co] := 'O'; end;
  keyP:begin inc(co); pass[co] := 'P'; end;
  keyQ:begin inc(co); pass[co] := 'Q'; end;
  keyR:begin inc(co); pass[co] := 'R'; end;
  keyS:begin inc(co); pass[co] := 'S'; end;
  keyT:begin inc(co); pass[co] := 'T'; end;
  keyU:begin inc(co); pass[co] := 'U'; end;
  keyV:begin inc(co); pass[co] := 'V'; end;
  keyW:begin inc(co); pass[co] := 'W'; end;
  keyX:begin inc(co); pass[co] := 'X'; end;
  keyY:begin inc(co); pass[co] := 'Y'; end;
  keyZ:begin inc(co); pass[co] := 'Z'; end;
  key1:begin inc(co); pass[co] := '1'; end;
  key2:begin inc(co); pass[co] := '2'; end;
  key3:begin inc(co); pass[co] := '3'; end;
  key4:begin inc(co); pass[co] := '4'; end;
  key5:begin inc(co); pass[co] := '5'; end;
  key6:begin inc(co); pass[co] := '6'; end;
  key7:begin inc(co); pass[co] := '7'; end;
  key8:begin inc(co); pass[co] := '8'; end;
  key9:begin inc(co); pass[co] := '9'; end;
  key0:begin inc(co); pass[co] := '0'; end;
  keyBackSpace:begin pass[co] := ' '; dec(co); end;
  end;
{end;}
If QKeypress then begin delay(100); end;

waitretrace;
flip(BK,VGA);
text(123,140,pass,VGA);
{if (ctt<100) and (ctt>0) then inc(ctt) else begin ctt := 0; lastkey := keyArrowUp; end;}
until co >= 10;

fadeout;
cls(0,VGA);
cls(0,BK);
restorepalette(pal1);

i := 1;
level := 1;
repeat
  inc(i);
  If pass = password[i] then level := i;
until (i = 30) or (level <> 1);
end;





{ *********************** }
{ *     PRESENTACIà     * }
{ *********************** }

Procedure Presentacio;
label MENU,continuar;
var
  co : word;
  ok : word;
begin
yt := 95;

cls(0,WP);
LoadGIF('data\grf03.bal',SP);
blackout;

{$IFDEF DEBUG}
starting := False;
LoadPal('data\pal01.bal',pal1);
LoadPal('data\pal02.bal',pal2);
{$ENDIF}

If starting then starting := False else
  begin
  If midi <> 0 then
    begin
    LoadMIDI('data\mus3.bal');
    PlayMIDI;
    end;
  goto continuar;
  end;

LoadPal('data\pal03.bal',pal1);
LoadPal('data\pal04.bal',pal2);

LoadGIF('data\grf01.bal',BK);

flip(BK,VGA);
If midi <> 0 then
  begin
  LoadMIDI('data\mus1.bal');
  PlayMIDI;
  end;
fadein(pal1);
delay(4000);
fadeout;
delay(2000);
If midi <> 0 then
  begin
  StopMIDI;
  UnloadMIDI;
  end;


cls(0,VGA);
LoadGIF('data\grf02.bal',BK);
blackout;
flip(BK,VGA);
If midi <> 0 then
  begin
  LoadMIDI('data\mus2.bal');
  PlayMIDI;
  end;
fadein(pal2);
delay(4000);
fadeout;
delay(2000);
If midi <> 0 then
  begin
  StopMIDI;
  UnloadMIDI;
  end;

LoadPal('data\pal01.bal',pal1);
LoadPal('data\pal02.bal',pal2);

cls(0,VGA);
LoadGIF('data\grf04.bal',BK);
blackout;
flip(BK,VGA);
If midi <> 0 then
  begin
  LoadMIDI('data\mus3.bal');
  PlayMIDI;
  end;
fadein(pal2);
SetRGB(54,63,63,63);
text2(40,150,'8 DEL MATI',VGA);
if QKeyPress Then goto continuar;
delay(1000);
text2(40,157,'LABORATORI DE FFI',VGA);
if QKeyPress Then goto continuar;
delay(4000);
fadeout;
cls(0,VGA);

{SeqIntro(BK,SP,WP);}

LoadGIF('data\grf05.bal',BK);
blackout;
flip(BK,VGA);
if QKeyPress Then goto continuar;
fadein(pal2);
SetRGB(54,63,63,63);
text2(40,173,'EL PROFESOR BACTERIOL ESTA',VGA);
text2(40,180,'PREPARANT EL SEU NOU INVENT;;;',VGA);
if QKeyPress Then goto continuar;
delay(4000);
fadeout;
cls(0,VGA);
LoadGIF('data\grf06.bal',BK);
blackout;
flip(BK,VGA);
if QKeyPress Then goto continuar;
fadein(pal2);
SetRGB(54,63,0,0);
text2(120,20,':COGEMOL EL INDIVIDUOL',VGA);
text2(120,27,'Y PULSANDOL EL BOTOL;;;',VGA);
if QKeyPress Then goto continuar;
delay(4000);
flip(BK,VGA);
text2(120,20,';;;CONSEGUIMOL VARIOL',VGA);
text2(120,27,'INDIVIDUOL;;;:',VGA);
if QKeyPress Then goto continuar;
delay(4000);
fadeout;
cls(0,VGA);
LoadGIF('data\grf07.bal',BK);
blackout;
flip(BK,VGA);
if QKeyPress Then goto continuar;
fadein(pal2);
SetRGB(54,63,63,63);
text2(80,180,'PERO ALGUN DESAPRENSIU;;;',VGA);
if QKeyPress Then goto continuar;
delay(4000);
flip(BK,VGA);
SetRGB(54,0,63,0);
text2(110,40,':EY< ME ANE A FERME',VGA);
text2(110,47,'UN CORTAET;;;:',VGA);
if QKeyPress Then goto continuar;
delay(4000);
fadeout;
cls(0,VGA);
LoadGIF('data\grf08.bal',BK);
blackout;
flip(BK,VGA);
if QKeyPress Then goto continuar;
fadein(pal2);
SetRGB(54,63,63,63);
text2(125,155,'ERA BALOO<<<',VGA);
if QKeyPress Then goto continuar;
delay(2000);
text2(125,162,'I HA ENXUFAT LA MAQUINA<',VGA);
if QKeyPress Then goto continuar;
delay(4000);
fadeout;
cls(0,VGA);
LoadGIF('data\grf09.bal',BK);
blackout;
flip(BK,VGA);
if QKeyPress Then goto continuar;
fadein(pal2);
SetRGB(54,63,0,0);
text2(110,10,':LA CAGAMOL<<<',VGA);
text2(110,17,'AHORAL QUE HAGOL<:',VGA);
if QKeyPress Then goto continuar;
delay(8000);
fadeout;

if QKeyPress Then goto continuar;
delay(2000);

continuar:

cls(0,VGA);
cls(0,WP);
LoadGIF('data\grf10.bal',BK);
Blackout;
flip(BK,VGA);
fadein(pal2);

MENU:

ok := 0;
setmouse(157,132);
repeat
  If midi <> 0 then If not playing then PlayMIDI;
  getmouse(mouseX,mouseY,b1,b2,b3);
  cls(0,WP);
  flip(BK,WP);
{  putbloc(SP,320*8,WP,180,37,70,i-37);
  text(140,130,'JUGAR',WP);
  text(130,140,'PASSWORD',WP);}
  putsprite(SP,24,0,WP,mouseX,mouseY,8,8);
  WAITRETRACE;
  flip(WP,VGA);
  If b1 then
    begin
    If (mouseX >= 199) and (mouseX < 266) and (mouseY >= 103) and (mouseY < 125) then
      begin ok := 1; level := 1; end;
    If (mouseX >= 176) and (mouseX < 290) and (mouseY >= 126) and (mouseY < 145) then
      ok := 2;
    If (mouseX >= 204) and (mouseX < 262) and (mouseY >= 149) and (mouseY < 167) then
      begin fadeout; If midi <> 0 then begin StopMIDI; UnLoadMIDI; end; halt; end;
    end;

until {$IFDEF DEBUG} (Qkeypress) or {$ENDIF} (ok<>0);

fadeout;cls(0,VGA);

If ok <> 2 then exit;

GetPassWord;

end;





{  *************************  }
{ *************************** }
{ *************************** }
{ ***                     *** }
{ ***      PRINCIPAL      *** }
{ ***                     *** }
{ *************************** }
{ *************************** }
{  *************************  }
begin
start;

INICIAR_PARTIDA:

Presentacio;

INICIAR_FASE:

yt := 51;

Time := 0;

Init_Game;
{baloo.j := 0;}

If midi <> 0 then
  begin
  StopMIDI;
  UnloadMIDI;
  If (level mod 5) = 0 then LoadMIDI('data\mus6.bal') else LoadMIDI('data\mus4.bal');
  PlayMIDI;
  end;
PartPal(pal3);

repeat

If (not Pause) then TimeHandler(ClockTicks);

If midi <> 0 then If not playing then PlayMIDI;

If (not Pause) and (numbaloos > 0) then Calcul;

If final then goto fin;

If keypress(keyP) then
  begin
  If Pause = False then
    begin
    Pause := True;
    clearKB;
    delay(50);
    clearKB;
    end
  else
    begin
    Pause := False;
    clearKB;
    delay(50);
    clearKB;
    end;
  end;

If (not Pause) and (keypress(keyESC)) then
  begin
  clearKB;
  text(97,93,'PULSA S PER A EIXIR',VGA);
  Repeat Until QKeypress;
  If keyPress(keyS) then Final := True;
  delay(50);
  clearKB;
  end;

{$IFDEF DEBUG}
If keypress(keyA) then begin barrived := bneeded; Final := True; end;
{$ENDIF}

flip(BK,WP);
putsprite(IP,0,0,WP,0,0,320,200);

putbloc(SP,216,WP,16,16,InitX,InitY);
putbloc(SP,216,WP,16,16,EndX,EndY);

show_exp;

For i := 0 to numbaloos-1 do
  putsprite(SP,baloo[i].frame.x+baloo[i].j,baloo[i].frame.y+baloo[i].orient,WP,
  baloo[i].x,baloo[i].y,baloo[i].frame.w,baloo[i].frame.h);


For i := 0 to 9 do
  begin
{  putbloc(SP,37120+aigua[aiguap1],WP,16,16,i shl 5,152);
  putbloc(SP,37120+aigua[aiguap2],WP,16,16,(i shl 5)+16,152);}

  putsprite(SP,aigua[aiguap1],153,WP,i shl 5,150,16,15);
  putsprite(SP,aigua[aiguap2],153,WP,(i shl 5)+16,150,16,15);
  end;


putsprite(SP,150,0,WP,baloo[sbaloo].x-3,baloo[sbaloo].y-3,14,14);

If (not Pause) and (tempo = 2) then
  begin
  GetRGB(64,red1,green1,blue1);
  GetRGB(65,red2,green2,blue2);
  SetRGB(64,red2,green2,blue2);
  GetRGB(66,red2,green2,blue2);
  SetRGB(66,red1,green1,blue1);
  SetRGB(65,red2,green2,blue2);
  end;

putbloc(SP,5120,WP,320,35,0,165);

{putbloc(SP,5120,WP,128,16,0,170);
putbloc(SP,15360,WP,320,5,0,165);
putbloc(SP,15360,WP,320,5,0,195);}

if baloo[sbaloo].wannabe <> 0 then putsprite(SP,200,0,WP,((baloo[sbaloo].wannabe-1) shl 4)+5,170,16,16)
else If baloo[sbaloo].mode > 6 then putsprite(SP,200,0,WP,5,170,16,16)
else putsprite(SP,200,0,WP,((baloo[sbaloo].mode-1) shl 4)+5,170,16,16);

text(188,188,inttostr(level),WP);
text(224,171,'ACTIUS     '+inttostr(numbaloos),WP);
text(224,177,'TOTAL      '+inttostr(totalbaloos),WP);
text(224,183,'NECESSARIS '+inttostr(bneeded),WP);
text(224,189,'ARRIVATS   '+inttostr(barrived),WP);

text(7,188,'XX',WP);
text(23,188,inttostr(count.parant),WP);
text(39,188,inttostr(count.cavant),WP);
text(55,188,inttostr(count.escalant),WP);
text(71,188,inttostr(count.perforant),WP);
text(87,188,inttostr(count.escalera),WP);
text(103,188,inttostr(count.pasarela),WP);
text(119,188,inttostr(count.corda),WP);
text(135,188,'XX',WP);
text(151,188,'XX',WP);

If ploguda then                                                             { efecte de ploguda }
  begin
  If plogudax <= 0 then plogudax := 319 else dec(plogudax,2);
  If ploguday >= 160 then ploguday := 0 else inc(ploguday,2);
  for i := 0 to 10 do
    for j := 0 to 6 do
      begin
      putpixel(( plogudax+(i*32)  )mod 320,(ploguday+(j*32)  )mod 160,41,WP);
      putpixel(( plogudax+(i*32)+1)mod 320,(ploguday+(j*32)-1)mod 160,41,WP);
      end;
  end;

If neu then
  begin
  If Random(10) = 5 then
    begin
    i := 0;
    repeat
      If not copo[i].actiu then
        begin
        copo[i].x := Random(320);
        copo[i].y := 0;
        copo[i].actiu := True;
        i := 20;
        end;
      inc(i);
    until i = 21;
    end;
  For i := 0 to 20 do
    begin
    If copo[i].actiu then
      begin
      inc(copo[i].y);
      If copo[i].y = 160 then copo[i].actiu := False;
      If getpixel(IP,copo[i].x,copo[i].y+1) <> 0 then
        begin
        putpixel(copo[i].x,copo[i].y,45,IP);
        copo[i].actiu := False;
        end;
      putpixel(copo[i].x,copo[i].y,45,WP);
      end;
    end;
  end;


If Pause then
  begin
  text(147,93,'PAUSA',WP);
  getmouse(mouseX,mouseY,b1,b2,b3);
  end;

putsprite(SP,8,8,WP,mouseX,mouseY,8,8);


waitretrace;
flip(WP,VGA);
cls(0,WP);

fin:

until (Final) {or (keypress(KeyEsc))};

{Timer_Done;}
show_exp_modal;
fadeout;

cls(0,VGA);
cls(0,WP);

If midi <> 0 then
  begin
  StopMIDI;
  UnloadMIDI;
  end;

If barrived >= bneeded then
begin
ClearKb;

If level=5  then OutSeq(SP, pal2, midi,5);
If level=10 then OutSeq(SP, pal2, midi,10);
If level=15 then OutSeq(SP, pal2, midi,15);
If level=20 then OutSeq(SP, pal2, midi,20);
If level=25 then OutSeq(SP, pal2, midi,25);
{If level=30 then OutSeq30(SP, pal2, midi);}

If level <> 30 then
  begin
  If midi <> 0 then
    begin
    LoadMIDI('data\mus5.bal');
    PlayMIDI;
    end;
  LoadGIF('data\grf03.bal',SP);
  LoadGIF('data\grf13.bal',BK);
  yt := 95;
  inc(level);
  Blackout;
  flip(BK,VGA);
  fadein(pal2);
  SetRGB(54,63,0,0);
  text2(173,145,password[level],VGA);
  repeat
    If midi <> 0 then If not playing then PlayMIDI;
  until QKeyPress;
  fadeout; cls(0,VGA);
  If midi <> 0 then
    begin
    StopMIDI;
    UnloadMIDI;
    end;
  goto INICIAR_FASE;
  end
else OutSeq(SP, pal2, midi,30);

end

else
begin
If midi <> 0 then
  begin
  LoadMIDI('data\mus5.bal');
  PlayMIDI;
  end;

LoadGIF('data\grf03.bal',SP);
LoadGIF('data\grf14.bal',BK);
Blackout;
flip(BK,VGA);
fadein(pal2);


setmouse(157,132);
repeat
  If midi <> 0 then If not playing then PlayMIDI;
  getmouse(mouseX,mouseY,b1,b2,b3);
  cls(0,WP);
  flip(BK,WP);
  putsprite(SP,24,0,WP,mouseX,mouseY,8,8);
  WAITRETRACE;
  flip(WP,VGA);

  If b1 then
    begin
    If (mouseX >= 101) and (mouseX < 209) and (mouseY >= 52) and (mouseY < 70) then
      begin
      fadeout; cls(0,VGA);
      If midi <> 0 then
        begin
        StopMIDI;
        UnloadMIDI;
        end;
      goto INICIAR_FASE;
      end;
    If (mouseX >= 124) and (mouseX < 187) and (mouseY >= 73) and (mouseY < 93) then
      begin
      fadeout; cls(0,VGA);
      If midi <> 0 then
        begin
        StopMIDI;
        UnloadMIDI;
        end;
      goto INICIAR_PARTIDA;
      end;
    If (mouseX >= 127) and (mouseX < 185) and (mouseY >= 96) and (mouseY < 114) then
      begin
      fadeout;
      If midi <> 0 then
        begin
        StopMIDI;
        UnloadMIDI;
        end;
      halt;
      end;
    end;

until not Final;

end;


StopMIDI;
UnloadMIDI;

end.