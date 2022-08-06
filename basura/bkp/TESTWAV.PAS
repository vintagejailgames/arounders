program testWAV;

uses WAVPlay, crt;

var
  sample : array[1..2] of WaveData;
  key: char;

begin

InitWAV(2,1,5);

LoadWAV(sample[1],'adios.wav');
LoadWAV(sample[2],'taladre.wav');

clrscr;

Writeln('WAVPlay - by The JailDoctor');
Writeln('===========================');
Writeln;
Writeln('Pulsa la tecla "1" per a escoltar un arounder');
Writeln('Pulsa la tecla "2" per a escoltar un taladre');
Writeln('ESC per a eixir...');

  repeat
    if KeyPressed then
      Key := Readkey
    else
      Key := Chr(0);

    if Key = '1' then PlayWAV (sample[1]);
    if Key = '2' then PlayWAV (sample[2]);

  until Key = Chr(27);


UnLoadWAV(sample[1]);
UnLoadWAV(sample[2]);

EndWAV;

end.