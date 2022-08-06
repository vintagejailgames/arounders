unit seq;

interface

uses keyboard,dmon3b,GIFLoad,MIDIPlay;

procedure InSeq(SP:word; pal:AuxPalette; midi:byte; lev:byte);

procedure OutSeq(SP:word; pal:AuxPalette; midi:byte; lev:byte);


implementation

Procedure LoadPal(filename:string; var pal: AuxPalette);
var
  f : file of AuxPalette;
begin
  Assign(f,filename);
  Reset(f);
  Read(f,Pal);
  Close(f);
end;

Function Pause(num:word):boolean; { 250 = 1 segon (mes o menys) }
var
  i,j: word;
begin
repeat
If j < 1000 then inc(j) else
  begin
  j := 0;
  inc(i);
  end;
until (QKeyPress) or (i >= num);
If QkeyPress then Pause := False else Pause := True;
end;


procedure text(x,y:word; cadena:string; page:word);
var i,j:word;
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


Procedure InSeq(SP:word; pal:AuxPalette; midi:byte;lev:byte);
label EIXIR;
begin
LoadGIF('data\grf03.bal',SP);   { Tot açò es igual per a totes. }
blackout;                       {                               }
cls(0,VGA);                     { Nomes hi ha que canviar el    }
If midi <> 0 then               { MIDI i el GIF de baix.        }
  begin                         {                               }
  LoadMIDI('data\mus3.bal');    {                               }
  PlayMIDI;                     {                               }
  end;                          {                               }

Case lev of

1:begin   { NIVELL 1 }

LoadGIF('data\seq11.bal',VGA);
fadein(pal);
SetRGB(54,0,63,0);
text(140,20,'AU A LA JAIL<',VGA);
If not pause(500) then goto EIXIR;
LoadGIF('data\seq11.bal',VGA);
SetRGB(54,63,0,0);
text(50,10,'ESPEREU< NO SABEU ELS',VGA);
text(50,20,'PERILLS QUE HI HAN<',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq12.bal',VGA);
fadein(pal);
SetRGB(54,63,0,0);
text(10,0,'TINDREU QUE ENFRONTARVOS;;;',VGA);
If not pause(500) then goto EIXIR;
LoadGIF('data\seq12.bal',VGA);
text(10,0,'TINDREU QUE ENFRONTARVOS;;;',VGA);
text(10,10,'ALS 4 PSICOPATES DE LA EUI<',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq13.bal',VGA);
fadein(pal);
SetRGB(54,0,63,0);
text(70,10,'BAH< PSICOPATES A MI;;;',VGA);
text(70,20,'XAVAL JO TREBALLE A TELEFONICA',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq14.bal',VGA);
fadein(pal);
SetRGB(54,63,63,63);
text(10,0,'PERO NOMES EIXIR;;;',VGA);
If not pause(500) then goto EIXIR;
LoadGIF('data\seq14.bal',VGA);
SetRGB(54,0,63,0);
text(40,20,'I ESTE KAPOLL',VGA);
text(40,30,'DE QUE SE RIU;;;',VGA);
If not pause(1000) then goto EIXIR;
LoadGIF('data\seq14.bal',VGA);
SetRGB(54,0,0,63);
text(100,30,'SOC EL JOCKER',VGA);
text(100,40,'I SI NO SUPEREU;;;',VGA);
If not pause(1000) then goto EIXIR;
LoadGIF('data\seq14.bal',VGA);
text(80,30,'ELS MEUS MAPES US ADORMIRE',VGA);
text(80,40,'AMB UNA PRACTICA DE TAL<<',VGA);
If not pause(1250) then goto EIXIR;
goto EIXIR;
end;

6:begin   { NIVELL 6 }

LoadGIF('data\seq21.bal',VGA);  {                               }
fadein(pal);
SetRGB(54,0,63,0);
text(160,20,'VENIU< CREC QUE HE',VGA);
text(160,30,'TROBAT LA JAIL<',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq22.bal',VGA);
fadein(pal);
SetRGB(54,0,63,63);
text(10,20,'QUE ALGORISMES FEU ACI;;;',VGA);
If not pause(500) then goto EIXIR;
LoadGIF('data\seq22.bal',VGA);
text(10,20,'ARA TINDREU QUE SUPERAR',VGA);
text(10,30,'5 MAPES AMB COST EXPONENCIAL<',VGA);
If not pause(1500) then goto EIXIR;
goto EIXIR;
end;

11:begin   { NIVELL 11 }

LoadGIF('data\seq31.bal',VGA);  {                               }
fadein(pal);
SetRGB(54,63,0,0);
text(160,70,'ENANOS DE MERDA<',VGA);
text(160,80,'MAI APROVAREU TCO<',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq32.bal',VGA);
fadein(pal);
SetRGB(54,0,63,0);
text(10,20,'MALEIT SIGA< ET VAIG',VGA);
text(10,30,'A FER UN SALVAPANTALLES<',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq31.bal',VGA);
fadein(pal);
SetRGB(54,63,0,0);
text(160,70,'QUE POR QUE HEM DONA<',VGA);
If not pause(500) then goto EIXIR;
LoadGIF('data\seq31.bal',VGA);
text(160,70,'QUE POR QUE HEM DONA<',VGA);
text(160,80,'SUPEREU ELS MEUS MAPES<',VGA);
If not pause(1500) then goto EIXIR;
goto EIXIR;
end;

16:begin   { NIVELL 16 }

LoadGIF('data\seq41.bal',VGA);  {                               }
fadein(pal);
SetRGB(54,0,63,0);
text(160,140,'MMMM;;; CADA VEGADA',VGA);
text(160,150,'EN QUEDEM MENOS;;;',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq42.bal',VGA);
fadein(pal);
SetRGB(54,63,0,0);
text(30,30,'VEIG DOBLE< VEIG TRIPLE<',VGA);
If not pause(500) then goto EIXIR;
LoadGIF('data\seq42.bal',VGA);
text(30,30,'ES EL MOMENT DELS MEUS',VGA);
text(30,40,'MAPES :BALOO:;;;',VGA);
If not pause(1000) then goto EIXIR;
LoadGIF('data\seq42.bal',VGA);
text(30,30,'QUE NO ELS SUPERA',VGA);
text(30,40,'QUASI QUASI NINGU',VGA);
If not pause(1500) then goto EIXIR;
goto EIXIR;
end;

21:begin   { NIVELL 21 }

LoadGIF('data\seq51.bal',VGA);  {                               }
fadein(pal);
SetRGB(54,0,63,0);
text(60,40,':JA HEM ARRIVAT',VGA);
text(60,50,'A LA JAIL<<<:',VGA);
If not pause(1000) then goto EIXIR;
fadeout;
LoadGIF('data\seq52.bal',VGA);
fadein(pal);
SetRGB(54,63,0,0);
text(30,30,'ASI QUE TODOS USAIS',VGA);
text(30,40,'EL MISMO LOGIN;;;',VGA);
If not pause(750) then goto EIXIR;
LoadGIF('data\seq52.bal',VGA);
text(30,30,'OS VOY A DAR YO MP3<',VGA);
If not pause(500) then goto EIXIR;
LoadGIF('data\seq52.bal',VGA);
text(30,30,'O ME COMPRAIS UNA PRECIOSA',VGA);
text(30,40,'CHAQUETA DE CUERO O NADA DE NADA',VGA);
If not pause(1500) then goto EIXIR;
goto EIXIR;
end;

26:begin   { NIVELL 26 }

LoadGIF('data\seq61.bal',VGA);  {                               }
fadein(pal);
SetRGB(54,63,63,63);
text(160,20,'HI HA ALGU MES A QUI',VGA);
text(160,30,'ET TENS QUE ENFRONTAR<',VGA);
If not pause(1500) then goto EIXIR;
goto EIXIR;
end;

end;
EIXIR:
fadeout;
end;

Procedure OutSeq(SP:word; pal:AuxPalette; midi:byte; lev:byte);
label EIXIR;
begin

If lev <> 30 then
  begin
  LoadGIF('data\grf03.bal',SP);   { Tot açò es igual per a totes. }
  blackout;                       {                               }
  cls(0,VGA);                     { Nomes hi ha que canviar el    }
  If midi <> 0 then               { MIDI i el GIF de baix.        }
    begin                         {                               }
    LoadMIDI('data\mus3.bal');    {                               }
    PlayMIDI;                     {                               }
    end;                          {                               }
  If lev = 5  then LoadGIF('data\seq01.bal',VGA);  {                               }
  If lev = 10 then LoadGIF('data\seq02.bal',VGA);  {                               }
  If lev = 15 then LoadGIF('data\seq03.bal',VGA);  {                               }
  If lev = 20 then LoadGIF('data\seq04.bal',VGA);  {                               }
  If lev = 25 then LoadGIF('data\seq05.bal',VGA);  {                               }
  fadein(pal);
  If not pause(1500) then goto EIXIR;
  end
else

begin
LoadGIF('data\grf03.bal',SP);   { Tot açò es igual per a totes. }
blackout;                       {                               }
cls(0,VGA);                     { Nomes hi ha que canviar el    }
If midi <> 0 then               { MIDI i el GIF de baix.        }
  begin                         {                               }
  LoadMIDI('data\mus3.bal');    {                               }
  PlayMIDI;                     {                               }
  end;                          {                               }
LoadGIF('data\seq71.bal',VGA);
fadein(pal);
SetRGB(54,0,63,0);
text(10,10,'QUI DIMONIS ERES<<<',VGA);
pause(750);
LoadGIF('data\seq72.bal',VGA);
pause(250);
LoadGIF('data\seq72.bal',VGA);
SetRGB(54,0,63,0);
text(10,10,'DOCTOR BACTERIOL<<',VGA);
pause(500);
LoadGIF('data\seq72.bal',VGA);
text(10,10,'PERO JO PENSAVA QUE TU',VGA);
text(10,20,'ME AJUDARIES;;;',VGA);
pause(1000);
LoadGIF('data\seq72.bal',VGA);
SetRGB(54,63,0,0);
text(150,10,'I TE HE AJUDAT;',VGA);
text(150,20,'ARA JA NOMES QUEDES TU',VGA);
pause(1000);
LoadGIF('data\seq72.bal',VGA);
text(150,10,'EL ORIGINAL;AIXI HE',VGA);
text(150,20,'ARREGLAT EL QUE VAIG FER',VGA);
pause(1000);
fadeout;
LoadGIF('data\seq73.bal',VGA);
fadein(pal);
SetRGB(54,63,63,63);
text(40,20,'PERO POTSER NO ESTA',VGA);
text(40,30,'SOLUCIONAT DEL TOT;;;',VGA);
pause(2000);
fadeout;

LoadPal('data\pal05.bal',pal);

LoadGIF('data\seq74.bal',VGA);
fadein(pal);
SetRGB(54,63,63,63);
text(170,120,'UN JOC DE',VGA);
text(170,130,'JAILDOCTOR GAMES',VGA);
pause(1000);
LoadGIF('data\seq74.bal',VGA);
text(170,100,'PROGRAMADOR',VGA);
text(170,110,'GRAFICS',VGA);
text(170,120,'MUSICA',VGA);
text(170,130,'GUIO',VGA);
text(170,150,' RAIMON ZAMORA',VGA);
text(170,160,' :THE JAILDOCTOR:',VGA);
pause(1500);
LoadGIF('data\seq74.bal',VGA);
text(170,100,'GRACIES A',VGA);
text(170,110,' JAILDESSIGNER',VGA);
text(170,120,' DIEGO VALOR',VGA);
text(170,130,' JAILGAMER',VGA);
text(170,140,' MASTERJAIL',VGA);
text(170,150,'  I EL SEU GERMA',VGA);
text(170,160,' JAILWEBMASTER',VGA);
text(170,170,' I A TOTS ELS JAILERS',VGA);
pause(1500);
LoadGIF('data\seq74.bal',VGA);
text(170,110,'GRACIES ESPECIALMENT',VGA);
text(170,120,' AL JAILAROUNDER PER',VGA);
text(170,130,' CEDIR LA SEUA IMATGE',VGA);
pause(1250);
LoadGIF('data\seq74.bal',VGA);
text(170,120,'AQUEST ES UN',VGA);
text(170,130,'JAILGAME',VGA);
pause(1000);
LoadGIF('data\seq74.bal',VGA);
text(170,130,'FINS LA PROXIMA;',VGA);
pause(1000);

end;

EIXIR:
fadeout;


end;


begin
end
.