unit WAVPlay;

{***************************************************************************
**                                                                        **
**            Unitat WAVPlay : Carrega i executa arxius WAV.              **
**                                                                        **
**                            by The JailDoctor                           **
**                                                                        **
** Nomes carregarÖ correctament arxius en format WAV "Windows PCM" amb    **
** 11025Hz de frequencia, 8 bit i mono.                                   **
**                                                                        **
** Bugs, polls, comentaris, alabances, cr°tiques destructives...          **
**                                                                        **
**                         jaildoctor@jazzfree.com                        **
**                                                                        **
***************************************************************************}



interface

{tupla que ens servirÖ per a enmagatzemar les dades de cada arxiu WAV}
type WaveData = record
  SoundLength : Word;
  Sample      : Pointer;
end;

{Fa que un WAV ja carregat en memïria sone}
procedure PlayWav (Voice : WaveData);

{Carrega un arxiu WAV en memïria}
procedure LoadWav (var Voice : WaveData; FileName : String);

{Descarrega de memïria un arxiu WAV especificat}
procedure UnloadWav (var Voice : WaveData);

{Inicialitza la targäta per a reproduãr s¢ digital}
Procedure InitWAV(sbPORT,sbDMA,sbIRQ : byte);

{Finalitza i allibera la memïria del buffer}
Procedure EndWAV;





implementation




uses Dos, Crt;


var
  CBuffer   : Word;    {Indicador de borrar buffer}

  DMABuffer : Pointer; {Punter al buffer del DMA}

{  VoiceData : Array [0..3] of WaveData; {Pointers to wave files}

  DMA       : Byte;    {El Canal DMA}
  IRQ       : Byte;    {El Nivell d'IRQ}
  OldIRQ    : Pointer; {Punter a les antigues rutines d'interrupci¢}

  Base      : Word;    {Adreáa base de la Sound Blaster}

{****************************************************************************
** Mira si existeix una Sound Blaster a la direcci¢ donada, torna TRUE si  **
** es troba, FALSE si no. Utilitzada en el SETUP.                          **
****************************************************************************}
function ResetDSP(Test : Word) : Boolean;
begin
  {Reseteja el DSP}
  Port[Test + $6] := 1;
  Delay(10);
  Port[Test + $6] := 0;
  Delay(10);
  {Mira si el reset ha sigut satisfactori}
  if (Port[Test + $E] and $80 = $80) and (Port[Test + $A] = $AA) then begin
    {Si s'ha trobat el DSP...}
    ResetDSP := true;
    Base := Test;
  end else
    {Si no s'ha trobat el DSP...}
    ResetDSP := false;
end;

{****************************************************************************
** Envia un byte al DSP (Digital Signal Processor) de la Sound Blaster     **
****************************************************************************}
procedure WriteDSP(Value : byte);
begin
  {Espera a que el DSP estiga preparat per a rebre dades}
  while Port[Base + $C] and $80 <> 0 do;
  {Envia el byte}
  Port[Base + $C] := value;
end;

{****************************************************************************
** Comenáa a executar-se el buffer. El controlador DMA estÖ programat amb  **
** un tamany de bloc de 32K - el buffer sencer. El DSP tÇ instruccions de  **
** executar blocs de 8K i aleshores generar una interrupci¢ (la qual permet**
** al programa borrar les parts que ja han sigut executades)               **
****************************************************************************}
procedure StartPlayBack;
var
  LinearAddress : LongInt;
  Page, OffSet  : Word;

begin
  WriteDSP($D1);             {Comando-DSP D1h - Activar speaker, necesari
                             en antigues SoundBlasters}
  WriteDSP($40);             {Comando-DSP 40h - establir la freq de sample}
  WriteDSP(165);             {Escriu la constant de temps per a 11025Hz}
  {
    La constant de temps es calcula aix°:
       (65536 - (256000000 div frequencia)) shr 8
  }

  {Converteix punter a adreáa lineal}
  LinearAddress := Seg (DMABuffer^);
  LinearAddress := LinearAddress shl 4 + Ofs (DMABuffer^);
  Page := LinearAddress shr 16;  {Calcula la pÖgina}
  OffSet := LinearAddress and $FFFF; {Calcula el offset en la pÖgina}
  Port[$0A] := 4 or DMA;     {Enmascara el canal DMA}
  Port[$0C] := 0;            {Borra el punter de byte}
  Port[$0B] := $58 or DMA;   {Estableix el mode}
  {
    El mode consisteix en lo segÅent:
    $58+x = binari 01 01 10 xx
                   |  |  |  |
                   |  |  |  +- Canal DMA
                   |  |  +---- Operador de Lectura (El DSP llig de memoria)
                   |  +------- Mode d'autoinicialitzaci¢
                   +---------- Mode de bloc
  }
  Port[DMA shl 1] := Lo(OffSet);   {Escriu el offset al controlador DMA}
  Port[DMA shl 1] := Hi(OffSet);

  case DMA of
    0 : Port[$87] := Page;             {Escriu la pagina al controlador DMA}
    1 : Port[$83] := Page;             {Escriu la pagina al controlador DMA}
    3 : Port[$82] := Page;             {Escriu la pagina al controlador DMA}
  end;

  Port[DMA shl 1 + 1] := $FF;          {Estableix el tamany de block a $7FFF = 32 Kbyte}
  Port[DMA shl 1 + 1] := $7F;

  Port[$0A] := DMA;          {Desenmascara el canal DMA}

  WriteDSP($48);             {Comando-DSP 48h - Establir tamany de bloc}
  WriteDSP($FF);             {Estableixel tamany de block a $1FFF = 8 Kbyte}
  WriteDSP($1F);
  WriteDSP($1C);             {Comando-DSP 1Ch - Comenáar execuci¢ autoinicialitzada}
end;

{****************************************************************************
** Borra una part de 8K del buffer del DMA                                 **
****************************************************************************}
procedure ClearBuffer (Buffer : Word);
begin
  {Omplir un bloc de 8K en el buffer del DMA amb 128's - silencis}
  FillChar (Mem [Seg(DMABuffer^):Ofs(DMABuffer^) + Buffer shl 13], 8192, 128);
end;

{****************************************************************************
** Executa i mescla un sample(WAV) amb el contingut del buffer del DMA     **
****************************************************************************}
procedure PlayWav (Voice : WaveData);
var
  Counter, OffSet, DMAPointer : Word;

begin
  {Llig el punter del DMA del controlador DMA}
  DMAPointer := Port [1 + DMA shl 1];
  DMAPointer := DMAPointer + Port [1 + DMA shl 1] shl 8;
  {
    DMAPointer contÇ la quantitat que falta per executar-se.
    Per tant, es convertirÖ en el offset del sample actual
  }
  DMAPointer := $7FFF - DMAPointer;

  OffSet := DMAPointer;
  for Counter := 0 to Voice.SoundLength do begin
    {Mesclar un byte}
    inc (Mem [Seg(DMABuffer^):Ofs(DMABuffer^)+OffSet],
    Mem [Seg(Voice.Sample^):Ofs(Voice.Sample^)+Counter]);
    inc(OffSet);                {Moures al proxim byte}
    OffSet := OffSet and $7FFF; {Matindre'l en el rang de 32K}
  end;
end;

{****************************************************************************
** Carrega un arxiu WAV en memoria. Aquest procediment suposa un arxiu     **
** estandard de 11025Hz, 8bit, mono. Compte! No hi ha ninguna comprobaci¢  **
** d'errors.                                                               **
****************************************************************************}
procedure LoadWav (var Voice : WaveData; FileName : String);
var
  WAVFile : File;
  OffSet : Word;

begin
  Assign (WAVFile, FileName); {Obre l'arxiu}
  Reset (WAVFile, 1);

  {Torna el tamany de l'arxiu com al tamany del s¢ menys 48 bytes per a la
   capáalera del WAV}
  Voice.SoundLength := FileSize (WAVFile) - 48;

  GetMem (Voice.Sample, Voice.SoundLength); {Asigna memoria}


{ *******  MODIFICACI‡ PER AL AROUNDERS  ******* }

{  Seek (WAVFile, 46);                       {Passa de la capáalera}

{ ********************************************** }



  {Carrega les dades del sample}
  BlockRead (WAVFile, Voice.Sample^, Voice.SoundLength + 2);

  Close (WAVFile); {Tanca l'arxiu}

  {per a cada sample, decrementa el valor del sample per a previndre un overflow}
  for OffSet := 0 to Voice.SoundLength do
    Mem [Seg(Voice.Sample^):Ofs(Voice.Sample^)+OffSet]
    := (Mem [Seg(Voice.Sample^):Ofs(Voice.Sample^)+OffSet] shr 2) - 32;
end;


{****************************************************************************
** Descarrega de la memïria un arxiu WAV, si encara no ha sigut            **
** descarregat                                                             **
****************************************************************************}
procedure UnloadWav (var Voice : WaveData);
begin
  If Voice.Sample <> nil then
    FreeMem(Voice.Sample, Voice.SoundLength); {allibera la memoria}
  Voice.Sample := nil;
end;



{****************************************************************************
** Rutina de servei de l'IRQ - Se li crida quan el DSP ha acabat d'executar**
** un bloc                                                                 **
****************************************************************************}
procedure ServiceIRQ; interrupt;
var
  Temp : Byte;

begin
  {Relevar al DSP}
  Temp := Port [Base + $E];
  {Interrupci¢ hardware de confirmaci¢}
  Port [$20] := $20;
  {Interrupci¢ en cascada de confirmaci¢ per als IRQ 2, 10 i 11}
  if IRQ in [2, 10, 11] then Port [$A0] := $20;
  {Incrementa el punter per a borrar el buffer i mantindre'l en el rang 0..3}
  CBuffer := (CBuffer + 1) and 3;
  {Borra el buffer}
  ClearBuffer (CBuffer);
end;

{****************************************************************************
** Aquest procediment asigna 32K de memïria al buffer DMA i s'asegura de   **
** que el limits de la p†gina no s'han creuat                              **
****************************************************************************}
procedure AssignBuffer;
var
  TempBuf       : Pointer; {Punter temporal}
  LinearAddress : LongInt;
  Page1, Page2  : Word;

begin
  {Asigna 32K de memïria}
  GetMem (TempBuf, 32768);

  {Calcula l'adreáa lineal}
  LinearAddress := Seg (TempBuf^);
  LinearAddress := LinearAddress shl 4 + Ofs (TempBuf^);
  {Calcula la pÖgina del principi del buffer}
  Page1 := LinearAddress shr 16;
  {Calcula la pÖgina del final del buffer}
  Page2 := (LinearAddress + 32767) shr 16;

  {Comprova si els limits d'una pÖgina s'han creuat}
  if (Page1 <> Page2) then begin
    {Si Çs aix°, asigna altra part de memïria al buffer}
    GetMem (DMABuffer, 32768);
    If TempBuf <> nil then FreeMem (TempBuf, 32768);
  end else begin
    {sin¢, utilitza la part que ja tenim asignada}
    DMABuffer := TempBuf;
  end;

  FillChar (DMABuffer^, $8000, 128); {Borra el buffer del DMA}
end;


{****************************************************************************
** Inicialitza la SoundBlaster per que comence a rebre s¢. Se li ha de     **
** passar com a parÖmetres les adreces del Port, el DMA i el IRQ.          **
** Aquestes adreces s'aconseguiran amb un programa de SETUP                **
****************************************************************************}
Procedure InitWAV(sbPORT,sbDMA,sbIRQ : byte);
begin

(*                      ** PER AL SETUP **

  {Check for Sound Blaster, address: ports 220, 230, 240, 250, 260 or 280}
  for Temp := 1 to 8 do begin
    if Temp <> 7 then
    if ResetDSP ($200 + Temp shl 4) then Break;
  end;
  if Temp = 9 then begin
    {or none at all}
    Writeln ('No S'ha trobat una SoundBlaster');
    Halt;
  end else Writeln ('SoundBlaster trobada en 2', Temp, '0h');
  {Ask for IRQ and DMA}
  Write ('Please specify DMA channel : '); Read (DMA);
  Write ('Please specify IRQ level   : '); Read (IRQ);
*)
  DMA := sbDMA;
  IRQ := sbIRQ;

  ResetDSP ($200 + sbPORT shl 4);

  {Asigna memïria al buffer del DMA}
  AssignBuffer;

  {Guarda l'antic vector de l'IRQ}
  case IRQ of
    2 : GetIntVec($71, OldIRQ);
   10 : GetIntVec($72, OldIRQ);
   11 : GetIntVec($73, OldIRQ);
  else
    GetIntVec (8 + IRQ, OldIRQ);
  end;
  {Estableix el nou vector de l'IRQ}
  case IRQ of
    2 : SetIntVec($71, Addr (ServiceIRQ));
   10 : SetIntVec($72, Addr (ServiceIRQ));
   11 : SetIntVec($73, Addr (ServiceIRQ));
  else
    SetIntVec (8 + IRQ, Addr (ServiceIRQ));
  end;
  {Activa l'IRQ}
  case IRQ of
    2 : Port[$A1] := Port[$A1] and not 2;
   10 : Port[$A1] := Port[$A1] and not 4;
   11 : Port[$A1] := Port[$A1] and not 8;
  else
    Port[$21] := Port[$21] and not (1 shl IRQ);
  end;
  if IRQ in [2, 10, 11] then Port[$21] := Port[$21] and not 4;

  {Estableix el borrat del buffer a l'ultim buffer}
  CBuffer := 3;
  {Comenáa l'execuci¢}
  StartPlayBack;
end;




{****************************************************************************
** Desinicialitza la SoundBlaster i allibera la mem¢ria asignada al buffer **
** i restableix els IRQ's                                                  **
****************************************************************************}
Procedure EndWAV;
begin
  {Para la transferäncia del DMA}
  WriteDSP ($D0);
  WriteDSP ($DA);

  {Allibera la memïria asignada al buffer de s¢}
  If DMABuffer <> nil then FreeMem (DMABuffer, 32768);

  {Allibera els vectors d'interrupci¢ utilitzats per a servir als IRQs}
  case IRQ of
    2 : SetIntVec($71, OldIRQ);
   10 : SetIntVec($72, OldIRQ);
   11 : SetIntVec($73, OldIRQ);
  else
    SetIntVec (8 + IRQ, OldIRQ);
  end;

  {Enmascara els IRQs}
  case IRQ of
    2 : Port[$A1] := Port[$A1] or 2;
   10 : Port[$A1] := Port[$A1] or 4;
   11 : Port[$A1] := Port[$A1] or 8;
  else
    Port[$21] := Port[$21] or (1 shl IRQ);
  end;
  if IRQ in [2, 10, 11] then Port[$21] := Port[$21] or 4;
end;

begin
end.