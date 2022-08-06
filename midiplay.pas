{****************************************************************************
** Background MIDI unit                                                    **
**  by Steven H Don                                                        **
*****************************************************************************
** The file FM.DAT is necessary to play through Sound Blaster/compatible   **
*****************************************************************************
** Unit for playing MIDI files in the background through either an FM      **
** sound card, such as the Sound Blaster (any version) or a General MIDI   **
** device, such as the Roland cards or a Gravis UltraSound using MegaEM.   **
** It does not implement all of the MIDI effects and asynchronous files    **
** are not supported. It works with most files I have, however. As you can **
** see from the size of the file, as well as the complexity of the code,   **
** MIDI is no easy stuff. This file should be useful though.               **
**                                                                         **
** For questions, feel free to e-mail me.                                  **
**                                                                         **
**    shd@earthling.net                                                    **
**    http://shd.cjb.net                                                   **
**                                                                         **
** Arranged by The JailDoctor.                                             **
**                                                                         **
**    Now General Midi initializes by itself & other fixes.                **
**                                                                         **
**    e-mail me if you vols to jaildoctor@jazzfree.com                     **
**                                                                         **
*****************************************************************************}
unit MIDIPlay;

interface

var
  ClockTicks : longint;

{
  Functions available to the calling program are:
    LoadMIDI   : loads the MIDI file into memory.
                   Expects a filename including .MID extension
                   Returns TRUE if successful
    UnloadMIDI : unloads the MIDI file and fress the memory.
    PlayMIDI   : starts MIDI playback
    StopMIDI   : stops MIDI playback
    SetGM      : sets the playback device to General MIDI.
    SetFM      : sets the playback device to the FM synthesizer
    SetVol     : sets the playback volume, from 0..255
    Playing    : returns FALSE when the MIDI file has ended
}

function LoadMidi (FileName : String) : Boolean;
procedure UnloadMIDI;
procedure PlayMIDI;
procedure StopMIDI;
procedure SetVol (NewVol : Byte);
function SetFM : Boolean;
function SetGM : Boolean;
function Playing : Boolean;

implementation

uses DOS, Crt;

const
  {At compile time, allow for 64 tracks, increase if necessary (this requires
  more memory)}
  MaxTracks = 64;
  {Used to distinguish between General MIDI devices and FM synthesizers}
  None = 0; FM = 1; GM = 2;
  {Used to activate tremolo and vibrato amplification}
  AM = 1; VIB = 0; ByteBD : Byte = AM shl 7 or VIB shl 6 or $20;

type
  {Almost 64K of memory to hold the data for each individual track}
  SixtyFour = Array [0..65534] of Byte;

  {The MIDI File's header}
  FileHeaderType = record
{    MTHd : LongInt; {6468544Dh = "MTHd"}
    HeaderSize : LongInt;
    FileFormat, NumberOfTracks, TicksPerQNote : Word;
  end;

  {The header of a track}
  TrackHeaderType = record
    MTrk : LongInt; {6468544Dh = "MTrd"}
    TrackSize : LongInt;
  end;

{Variables for reading the MIDI file}
var
  {How many tracks are there in the file}
  NumberOfTracks : Byte;
  {This is used to determine whether a track needs attention}
  WaitingFor : Array [1..MaxTracks] of LongInt;
  {Stores the actual MIDI data}
  TrackData : Array [1..MaxTracks] of ^SixtyFour;
  {Stores the byte length of each track}
  TrackSize : Array [1..MaxTracks] of Word;
  {Which byte is to be read next}
  NextBytePtr : Array [1..MaxTracks] of Word;
  {Stores the last MIDI command sent, this is necessary for "running" mode}
  LastCommand : Array [1..MaxTracks] of Byte;

  {This stores a pointer to the original timer handler}
  BIOSTimerHandler : procedure;
  {This is used for counting the clock ticks}
  TicksPerQNote : LongInt;
  TickCounter, MIDICounter : LongInt;
  {This is used in case Windows is active}
  WinTick : LongInt;
  Windows : Boolean;

{Variables and constants necessary for playing the MIDI file through an FM
based sound card such as Sound Blaster}
const
  {Addresses of the operators used to form voice data}
  OpAdr : Array [0..8] of Byte = (0, 1, 2, 8, 9, 10, 16, 17, 18);
  {F numbers - to form a specific note}
  FNr : Array [0..127] of Word = (86,91,96,102,108,114,121,128,136,144,
                                 153,162,172,182,192,204,108,114,121,
                                 128,136,144,153,162,172,182,192,204,
                                 216,229,242,257,136,144,153,162,172,
                                 182,192,204,216,229,242,257,272,288,
                                 306,324,172,182,192,204,216,229,242,
                                 257,272,288,306,324,343,363,385,408,
                                 216,229,242,257,272,288,306,324,343,
                                 363,385,408,432,458,485,514,272,288,
                                 306,324,343,363,385,408,432,458,485,
                                 514,544,577,611,647,343,363,385,408,
                                 432,458,485,514,544,577,611,647,686,
                                 726,770,816,432,458,485,514,544,577,
                                 611,647,686,726,770,816,864,916,970,1023);
  {Some operators are reserved for percussion. They are at the end of the
  SB's operators which means they're in the middle of the SB Pro's. The main
  program doesn't take this into account so this is used to convert from
  virtual voice number to real voice number}
  RealVoice : Array [0..14] of Byte = (0, 1, 2, 3, 4, 5, 9, 10,
                                       11, 12, 13, 14, 15, 16, 17);

var
  {There is a total of 15 melodic channels available of the SB Pro, hence the 14}
  InUse : Array [0..14] of Boolean;
  Activated : Array [0..17] of LongInt;
  MIDILink,
  NoteNumber,
  NoteVelocity : Array [0..14] of Byte;
  NoteOffData : Array [0..17, 0..1] of Byte;
  {This stores which instrument is currently in use on a MIDI channel}
  Instrument : Array [0..15] of Byte;
  {This stores the FM instrument definitions}
  M2, M4, M6, M8, ME, MC, C2, C4, C6, C8, CE : Array [0..127] of Byte;

var
  {This indicates whether the file should be played through a General MIDI
  device or through an FM synthesizer, such as the Sound Blaster}
  Device : Byte;
  {This indicates whether we have a Sound Blaster (6 voices) or an SB Pro or
  better (15 voices) - the 5 drums are always available}
  Voices : Byte;
  {This stores the Base address of the Sound Blaster and GM device}
  FMBase, GMBase : Word;
  {The master volume. Normal volume is 128.}
  MasterVolume : LongInt;

{This procedure compensates a given volume for the master volume}
function DoVolume (Before : Byte) : Byte;
var
  After : LongInt;

begin
  After := Before;
  After := After * MasterVolume;
  After := After shr 7;
  if After > 127 then After := 127;
  DoVolume := After and $FF;
end;

{This procedure changes the speed of the timer to adjust the tempo of a song
NewSpeed gives the amount of microseconds per quarter note}
procedure ChangeSpeed (NewSpeed : LongInt);
var
  QuarterNotesPerSecond : Real;
  Divisor               : Real;

begin
  {Calculate the amount of quarter notes in a second}
  QuarterNotesPerSecond := (1000000 / NewSpeed);
  {For every quarternote, we have TicksPerQNote ticks}
  Divisor := QuarterNotesPerSecond * TicksPerQNote;
  {If Windows is present, the timer frequency must remain below 1000}
  if Windows then begin
    if Divisor > 1000 then begin
      WinTick := 1 + trunc (Divisor / 1000);
      Divisor := Divisor / WinTick;
    end
  end else WinTick := 1;
  {Set the appropriate values for the timer interrupt}
  TickCounter := trunc ($1234DD / Divisor);
  Port[$43] := $34;
  Port[$40] := lo (TickCounter);
  Port[$40] := hi (TickCounter);
end;

{Writes a value to a specified index register on the FM card}
procedure WriteFM (Chip, Register, Value : Byte);
var
  Counter, Temp : Byte;
  Address : Word;

begin
  case Chip of
    0 : Address := FMBase;
    1 : Address := FMBase + 2;
  end;
  {Select register}
  Port [Address] := Register;
  {Wait for card to accept value}
  for Counter := 1 to 25 do Temp := Port [Address];
  {Send value}
  Port [Address + 1] := Value;
  {Wait for card to accept value}
  for Counter := 1 to 100 do Temp := Port [Address];
end;

{Sets a channel on the FM synthesizer to a specific instrument}
procedure SetInstr (Voice, I, Volume : Byte);

var
  Chip, Value : LongInt;

begin
  if Voice > 8 then begin
    Chip := 1;
    dec (Voice, 9);
  end else Chip := 0;
  {Correction for volume}
  Value := 63 - (M4 [I] and 63);
  Value := Value * Volume div 127;
  if Value > 63 then Value := 0 else Value := 63 - Value;
  Value := (M4 [I] and $C0) or Value;
  {Set up voice modulator}
  WriteFM (Chip, $20 + OpAdr [Voice], M2 [I]);
  WriteFM (Chip, $40 + OpAdr [Voice], Value);
  WriteFM (Chip, $60 + OpAdr [Voice], M6 [I]);
  WriteFM (Chip, $80 + OpAdr [Voice], M8 [I]);
  WriteFM (Chip, $E0 + OpAdr [Voice], ME [I]);
  {The "or 3 shl 4" is enables the voice on the OPL3}
  WriteFM (Chip, $C0 + OpAdr [Voice], MC [I] or 3 shl 4);

  {Correction for volume}
  Value := 63 - (C4 [I] and 63);
  Value := Value * Volume div 127;
  if Value > 63 then Value := 0 else Value := 63 - Value;
  Value := (C4 [I] and $C0) or Value;
  {Set up voice carrier}
  WriteFM (Chip, $23 + OpAdr [Voice], C2 [I]);
  WriteFM (Chip, $43 + OpAdr [Voice], Value);
  WriteFM (Chip, $63 + OpAdr [Voice], C6 [I]);
  WriteFM (Chip, $83 + OpAdr [Voice], C8 [I]);
  WriteFM (Chip, $E3 + OpAdr [Voice], CE [I]);
end;

{Sets up a drum channel, in much the same way as a normal voice}
procedure SetDrum (Operator, O2, O4, O6, O8, OE, OC : Byte);
begin
  WriteFM (0, $20 + Operator, O2);
  WriteFM (0, $40 + Operator, O4);
  WriteFM (0, $60 + Operator, O6);
  WriteFM (0, $80 + Operator, O8);
  WriteFM (0, $E0 + Operator, OE);
  WriteFM (0, $C0 + Operator, OC);
end;

{Enables a note on the FM synthesizer}
procedure EnableNote (Voice, Number : Byte);
var
  Chip, Note, Block : Byte;
  {For simulating high octaves}
  FNumber : Word;

begin
  {Calculate which part of the OPL3 chip should receive the data}
  if Voice > 8 then begin
    Chip := 1;
    dec (Voice, 9);
  end else Chip := 0;
  {Calculate appropriate data for FM synthesizer}
  FNumber := FNr [Number];
  Block := Number shr 4;
  {Store data to disable the note when necessary}
  NoteOffData [Voice, 0] := lo(FNumber);
  NoteOffData [Voice, 1] := hi(FNumber) + (Block shl 2);
  {Write data to FM synthesizer}
  WriteFM (Chip, $A0+Voice, lo(FNumber));
  WriteFM (Chip, $B0+Voice, hi(FNumber) + (Block shl 2) + 32);
end;

{Disables a note on the FM synthesizer}
procedure DisableNote (Voice : Byte);
var
  Chip : Byte;

begin
  {Calculate which part of the OPL3 chip should receive the data}
  if Voice > 8 then begin
    Chip := 1;
    dec (Voice, 9);
  end else Chip := 0;
  {Write data to FM synthesizer}
  WriteFM (Chip, $A0+Voice, NoteOffData [Voice, 0]);
  WriteFM (Chip, $B0+Voice, NoteOffData [Voice, 1]);
end;

{Cuts a note on the FM synthesizer immediately}
procedure CutNote (Voice : Byte);
var
  Chip : Byte;

begin
  {Calculate which part of the OPL3 chip should receive the data}
  if Voice > 8 then begin
    Chip := 1
  end else Chip := 0;
  {Set decay rate to fast - to avoid "plink" sound}
  WriteFM (Chip, $80 + OpAdr [Voice mod 9], $F);
  WriteFM (Chip, $83 + OpAdr [Voice mod 9], $F);
  {Disable the note}
  DisableNote (Voice);
end;

{Processes a "NoteOff" event for the FM synthesizer}
procedure NoteOff (MIDIChannel, Number, Velocity : Byte);
var
  FoundChannel, FMChannel : Byte;

begin
  {Assume the note can't be found}
  FoundChannel := 255;
  {Scan for note on FM channels}
  for FMchannel := 0 to Voices do begin
    if InUse[FMChannel] = true then begin
      {Is this the correct channel?}
      if (MIDILink [FMChannel] = MIDIChannel)
      and (NoteNumber [FMChannel] = Number) then begin
        {If the correct channel has been found then report that}
        FoundChannel := FMChannel;
        Break;
      end;
    end;
  end;
  if FoundChannel <> 255 then begin
    {Disable the note}
    DisableNote (RealVoice [FoundChannel]);
    {Store appropriate information}
    InUse [FoundChannel] := false; {InUse flag}
  end;
end;

{Processes a "NoteOn" event for the FM synthesizer}
procedure NoteOn (MIDIChannel, Number, Velocity : Byte);
var
  FreeChannel, FMChannel : Byte;
  Oldest : LongInt;

begin
  {Velocity of zero means note off}
  if Velocity = 0 then begin
    NoteOff (MIDIChannel, Number, Velocity);
    Exit;
  end;
  {Assume no free channel}
  FreeChannel := 255;
  {Scan for free channel}
  for FMchannel := 0 to Voices do begin
    if InUse[FMChannel] = false then begin
      {If a free channel has been found then report that}
      FreeChannel := FMChannel;
      break;
    end;
  end;
  {If there was no free channel, the SB's 6/15 voice polyphony
  has been exceeded and the "oldest" note must be deactivated}
  if FreeChannel = 255 then begin
    Oldest := MaxLongInt;
    {Scan for the oldest note}
    for FMChannel := 0 to Voices do begin
      if Activated [FMChannel] < Oldest then begin
        FreeChannel := FMChannel;
        Oldest := Activated [FMChannel];
      end;
    end;
    {Disable the note currently playing}
    CutNote (RealVoice [FreeChannel]);
  end;
  {Change the instrument settings for the FM channel chosen}
  SetInstr (RealVoice [FreeChannel], Instrument [MIDIChannel], Velocity);
  {Start playing the note}
  EnableNote (RealVoice [FreeChannel], Number);
  {Store appropriate information}
  InUse [FreeChannel] := true; {InUse flag}
  Activated [FreeChannel] := MIDICounter; {Activation time}
  MIDILink [FreeChannel] := MIDIChannel; {Link FM channel to MIDI channel}
  NoteNumber [FreeChannel] := Number; {Note number (which note is being played)}
  NoteVelocity [FreeChannel] := Velocity; {Velocity (=volume)}
end;

{Plays a drum note}
procedure DrumOn (MIDIChannel, Number, Velocity : Byte);
begin
  {If velocity is 0, note is turned off, this is ignored}
  if Velocity = 0 then Exit;
  {Convert velocity to "level" needed by SB and reduce the volume slightly}
  Velocity := word(Velocity shl 3) div 10;
  Velocity := 63 - (Velocity shr 1);
  {Bass drum}
  if Number in [35, 36, 41, 43] then begin
    {Set channel 6 to bass, allowing for volume}
    SetDrum (16, 0, 13, 248, 102, 0, 48);
    SetDrum (19, 0, Velocity, 246, 87, 0, 16);
    {Enable bass and immediately deactivate}
    WriteFM (0, $BD, ByteBD or 16);
    WriteFM (0, $BD, ByteBD);
  end;
  {HiHat}
  if Number in [37, 39, 42, 44, 46, 56, 62, 69, 70, 71, 72, 78] then begin
    {Set channel 7 to hihat, allowing for volume}
    SetDrum (17, 0, Velocity, 240, 6, 0, 16);
    {Enable hihat and immediately deactivate}
    WriteFM (0, $BD, ByteBD or 1);
    WriteFM (0, $BD, ByteBD);
  end;
  {Snare drum}
  if Number in [38, 40] then begin
    {Set channel 7 to snare drum, allowing for volume}
    SetDrum (20, 0, Velocity, 240, 7, 2, 16);
    {Enable hihat and immediately deactivate}
    WriteFM (0, $BD, ByteBD or 8);
    WriteFM (0, $BD, ByteBD);
  end;
  {TomTom}
  if Number in [45, 47, 48, 50, 60, 61, 63, 64, 65, 66, 67, 68, 73, 74, 75, 76, 77] then begin
    {Set channel 8 to tomtom, allowing for volume}
    SetDrum (18, 2, Velocity, 240, 6, 0, 16);
    {Enable tomtom and immediately deactivate}
    WriteFM (0, $BD, ByteBD or 4);
    WriteFM (0, $BD, ByteBD);
  end;
  {Cymbal}
  if Number in [49, 51, 52, 53, 54, 55, 57, 58, 59, 79, 80, 81] then begin
    {Set channel 8 to cymbal, allowing for volume}
    SetDrum (21, 4, Velocity, 240, 6, 0, 16);
    {Enable cymbal and immediately deactivate}
    WriteFM (0, $BD, ByteBD or 2);
    WriteFM (0, $BD, ByteBD);
  end;
end;

{Disables a drum note, well, it actually does nothing since drum notes
do not need to be disabled}
procedure DrumOff (MIDIChannel, Number, Velocity : Byte);
begin
end;

{Sends a GM command to the GM device}
procedure SendGM (c : Byte);
var
  Value : Byte;

begin
  repeat until ((Port [GMBase + 1] and $40) = 0);
  Port [GMBase] := c;
end;

{This function reads a byte from a specific track}
function ReadByte (TrackNumber : Byte) : Byte;
begin
  if WaitingFor [TrackNumber] < $FFFFFF then begin
    ReadByte := TrackData [TrackNumber]^[NextBytePtr [TrackNumber]];
    inc (NextBytePtr [TrackNumber]);
  end else ReadByte := 0;
end;

{This function reads a Variable Length Encoded (VLE) number from the track}
function GetVLE (TrackNumber : Byte) : LongInt;
var
  ByteRead : Byte;
  Result : LongInt;

begin
  {Assume zero}
  Result := 0;
  repeat
    {Read first byte}
    ByteRead := ReadByte (TrackNumber);
    {Store 7bit part}
    Result := (Result shl 7) or (ByteRead and $7F);
  until (ByteRead and $80) = 0;
  GetVLE := Result;
end;

{This procedure stores the time for the next event}
procedure GetDeltaTime (TrackNumber : Byte);
begin
  inc (WaitingFor [TrackNumber], GetVLE (TrackNumber));
end;

{This procedure handles the MIDI events}
procedure DoEvent (TrackNumber : Byte);
var
  MIDICommand : Byte;
  MetaEvent   : Byte;
  DataLength  : LongInt;
  Data        : LongInt;
  Counter     : Byte;
  P1, P2      : Byte;

begin
  {Get the MIDI event command from the track}
  MIDICommand := ReadByte (TrackNumber);
  {If this is not a command, we are in "running" mode and the last
  command issued on the track is assumed}
  if MIDICommand and $80 = 0 then begin
    MIDICommand := LastCommand [TrackNumber];
    dec (NextBytePtr [TrackNumber]);
  end;
  {Store the command for running mode}
  LastCommand [TrackNumber] := MIDICommand;
  {
    META-EVENTS
    ===========
    Special commands controlling timing etc.
  }
  if MIDICommand = $FF then begin
    MetaEvent  := ReadByte (TrackNumber);
    DataLength := GetVLE (TrackNumber);
    case MetaEvent of
      $2F : begin {End of track}
              WaitingFor [TrackNumber] := $FFFFFF;
            end;
      $51 : begin {Tempo change}
              Data := ReadByte (TrackNumber);
              Data := (Data shl 8) or ReadByte (TrackNumber);
              Data := (Data shl 8) or ReadByte (TrackNumber);
              ChangeSpeed (Data);
            end;
      else begin {Others (text events, track sequence numbers etc. - ignore}
        for Counter := 1 to DataLength do ReadByte (TrackNumber);
      end;
    end;
  end;
  {
    CHANNEL COMMANDS
    ================
    Upper nibble contains command, lower contains channel
  }
  case (MIDICommand shr 4) of
    $8 : begin {Note off}
           {This allows the use of a wavetable General Midi instrument (such
           as the Roland SCC1 (or an emulation thereof) or the FM synthesizer}
           P1 := ReadByte (TrackNumber);
           P2 := DoVolume (ReadByte (TrackNumber));
           case Device of
             {FM - Sound Blaster or AdLib}
             FM : begin
                    case MIDICommand and $F of
                      9, 15 : DrumOff (MIDICommand and $F, P1, P2);
                      else NoteOff (MIDICommand and $F, P1, P2);
                    end;
                  end;
             {GM - General MIDI device}
             GM : begin
                    SendGM (MIDICommand); SendGM (P1); SendGM (P2);
                  end;
           end;
        end;
    $9 : begin {Note on}
           P1 := ReadByte (TrackNumber);
           P2 := DoVolume (ReadByte (TrackNumber));
           case Device of
             FM : begin
                    case MIDICommand and $F of
                      9, 15 : DrumOn (MIDICommand and $F, P1, P2);
                      else NoteOn (MIDICommand and $F, P1, P2);
                    end;
                  end;
             GM : begin
                    SendGM (MIDICommand); SendGM (P1); SendGM (P2);
                  end;
           end;
         end;
    $A : begin {Key Aftertouch - only supported for GM device}
           P1 := ReadByte (TrackNumber);
           P2 := DoVolume (ReadByte (TrackNumber));
           if Device = GM then begin
             SendGM (MIDICommand); SendGM (P1); SendGM (P2);
           end;
         end;
    $B : begin {Control change - only supported for GM device}
           case Device of
             FM : begin
                    ReadByte (TrackNumber); ReadByte (TrackNumber);
                  end;
             GM : begin
                    SendGM (MIDICommand); SendGM (ReadByte (TrackNumber)); SendGM (ReadByte (TrackNumber));
                  end;
           end;
         end;
    $C : begin {Patch change - this changes the instrument on a channel}
           case Device of
             FM : begin
                    Instrument [MIDICommand and $F] := ReadByte (TrackNumber);
                  end;
             GM : begin
                    SendGM (MIDICommand); SendGM (ReadByte (TrackNumber));
                  end;
           end;
         end;
    $D : begin {Channel aftertouch - only supported on GM device}
           case Device of
             FM : begin
                    ReadByte (TrackNumber);
                  end;
             GM : begin
                    SendGM (MIDICommand); SendGM (ReadByte (TrackNumber));
                  end;
           end;
         end;
    $E : begin {Pitch wheel change - only supported on GM device}
           case Device of
             FM : begin
                    ReadByte (TrackNumber); ReadByte (TrackNumber);
                  end;
             GM : begin
                    SendGM (MIDICommand); SendGM (ReadByte (TrackNumber)); SendGM (ReadByte (TrackNumber));
                  end;
           end;
         end;
  end;
  {
    SYSTEM COMMANDS
    ===============
    These are ignored.
  }
  if (MIDICommand shr 4 = $F) then begin
    case MIDICommand of
      $F0 : repeat until ReadByte (TrackNumber) = $F7; {System Exclusive}
      $F2 : begin ReadByte (TrackNumber); ReadByte (TrackNumber); end; {Song Position Pointer}
      $F3 : ReadByte (TrackNumber); {Song Select}
    end;
  end;
end;

{Returns TRUE if the MIDI file is still playing. FALSE if it has stopped}
function Playing : Boolean;
var
  CurrentTrack : Byte;
  Result : Boolean;

begin
  {Assume it has stopped}
  Result := false;
  {Check for at least one track still playing}
  for CurrentTrack := 1 to NumberOfTracks do
    Result := Result or (WaitingFor [CurrentTrack] < $FFFFFF);
  Playing := Result;
end;

{This is the new timer interrupt handler}
{$F+}
procedure TimerHandler; interrupt;
var
  CurrentTrack : Byte;

begin
  {Increase MIDI counter, compensating for Windows if necessary}
  inc (MIDICounter, WinTick);
  {Check all the channels for MIDI events}
  for CurrentTrack := 1 to NumberOfTracks do begin
    {If it is time to handle an event, do so}
    if NextBytePtr [CurrentTrack] < TrackSize [CurrentTrack] then
    while MIDICounter >= WaitingFor [CurrentTrack] do begin
      {Call the event handler}
      DoEvent (CurrentTrack);
      {Store the time for the next event}
      GetDeltaTime (CurrentTrack);
    end;
  end;
  {Check whether we need to call the original timer handler}
  ClockTicks := ClockTicks + TickCounter;
  {Do so if required}
  if ClockTicks > 65535 then begin
    dec (ClockTicks, 65536);
    asm pushf end;
    BIOSTimerHandler;
  end else
    Port [$20] := $20;
end;
{$F-}

{Installs the MIDI timer handler}
procedure InstallTimer;
begin
  TickCounter := 0;
  {Assume tempo 120 according to MIDI spec}
  ChangeSpeed (TicksPerQNote * 25000 div 3);
  {Install new timer handler}
  SetIntVec(8, Addr(TimerHandler));
end;

{Restores the BIOS timer handler}
procedure RestoreTimer;
begin
  {Return to 18.2 times a second}
  Port[$43] := $34;
  Port[$40] := 0;
  Port[$40] := 0;
  {Install old timer handler}
  SetIntVec(8, @BIOSTimerHandler);
end;

{This converts a 32bit number from little-endian (Motorola) to big-endian
(Intel) format}
function L2B32 (L : LongInt) : LongInt;
var
  B : LongInt;
  T : Byte;

begin
  for T := 0 to 3 do begin
    B := (B shl 8) or (L and $FF);
    L := L shr 8;
  end;
  L2B32 := B;
end;

{This converts a 16bit number from little-endian (Motorola) to big-endian
(Intel) format}
function L2B16 (L : Word) : Word;
begin
  L2B16 := lo (L) shl 8 + hi (L);
end;

{This loads the MIDI file into memory}
function LoadMidi (FileName : String) : Boolean;
var
  {To access the file itself}
  MIDIFile       : File;
  MIDIHeader     : FileHeaderType;
  TrackHeader    : TrackHeaderType;
  {For loading the tracks}
  CurrentTrack,t : Byte;

begin
  {Assume failure}
  LoadMIDI := false;

  {Open the file}
  Assign (MIDIFile, FileName);
  Reset (MIDIFile, 1);

  {Read in the header}
  BlockRead (MIDIFile, MIDIHeader, SizeOf (MIDIHeader));
  {If the first four bytes do not constiture "MTHd", this is not a MIDI file}
  if TRUE{MIDIHeader.MTHd = $6468544D} then begin
    {If the header size is other than 6, this is an unknown
    type of MIDI file}
    if L2B32(MIDIHeader.HeaderSize) = 6 then begin
      {Convert file format identifier}
      MIDIHeader.FileFormat := L2B16(MIDIHeader.FileFormat);
      {If it is an asynchronous file (type 2), I don't know how to play it}
      if MIDIHeader.FileFormat <> 2 then begin
        {Store the tempo of the file}
        TicksPerQNote := L2B16(MIDIHeader.TicksPerQNote);
        {Store the number of tracks in the file}
        NumberOfTracks := L2B16(MIDIHeader.NumberOfTracks);
        if MIDIHeader.FileFormat = 0 then NumberOfTracks := 1;
        {When we reach this, we can start loading}
        for CurrentTrack := 1 to NumberOfTracks do begin
          {Load track header}
          BlockRead (MIDIFIle, TrackHeader, SizeOf (TrackHeader));
          {If the first 4 bytes do not form "MTrk", the track is invalid}
          if TrackHeader.MTrk <> $6B72544D then Exit;
          {We need to convert little-endian to big endian}
          TrackHeader.TrackSize := L2B32 (TrackHeader.TrackSize);
          {If it's too big, we can't load it}
          if TrackHeader.TrackSize > 65534 then Exit;
          TrackSize [CurrentTrack] := TrackHeader.TrackSize;
          {Assign memory for the track}
          GetMem(TrackData [CurrentTrack], TrackSize [CurrentTrack]);
          BlockRead (MIDIFile, TrackData [CurrentTrack]^, TrackSize [CurrentTrack]);
        end;
        LoadMIDI := true;
      end;
    end;
  end;

  {Close it}
  Close (MIDIFile);
end;

{This unloads the MIDI file from memory}
procedure UnLoadMidi;
var
  CurrentTrack : Byte;

begin
  StopMIDI;
  for CurrentTrack := 1 to NumberOfTracks do
    if TrackSize [CurrentTrack] <> 0 then begin
      If TrackData[CurrentTrack] <> nil then FreeMem(TrackData [CurrentTrack], TrackSize [CurrentTrack]);
      TrackSize [CurrentTrack] := 0;
    end;
end;

{This resets the drums}
procedure EnableDrums;
begin
  {Enable waveform select}
  WriteFM (0, 1, $20);
  {Enable percussion mode, amplify AM & VIB}
  WriteFM (0, $BD, ByteBD);
  {Set drums frequencies}
  WriteFM (0, $A6, lo(400));
  WriteFM (0, $B6, hi(400) + (2 shl 2));
  WriteFM (0, $A7, lo(500));
  WriteFM (0, $B7, hi(500) + (2 shl 2));
  WriteFM (0, $A8, lo(650));
  WriteFM (0, $B8, hi(650) + (2 shl 2));
end;

{This starts playing the MIDI file}
procedure PlayMIDI;
var
  CurrentTrack : Byte;
begin
  {MIDI might already be playing, so stop it first}
  StopMIDI;
  {Clear read pointers for every track}
  for CurrentTrack := 1 to NumberOfTracks do begin
    NextBytePtr [CurrentTrack] := 0;
    WaitingFor [CurrentTrack] := 0;
    LastCommand [CurrentTrack] := $FF;
    GetDeltaTime (CurrentTrack);
  end;
  MIDICounter := 0;
  WinTick := 1;
  EnableDrums;
  InstallTimer;
end;

{Guess!!}
procedure StopMIDI;
var
  CurrentChannel : Byte;
begin
  RestoreTimer;
  {Send "All notes off" to each channel}
  case Device of
    FM : for CurrentChannel := 0 to 14 do begin
           if InUse [CurrentChannel] then DisableNote (CurrentChannel);
         end;
    GM : for CurrentChannel := 0 to 15 do begin
           SendGM ($B0 or CurrentChannel);
           SendGM (123);
           SendGM (0);
         end;
  end;
end;

{Set the playback volume}
procedure SetVol (NewVol : Byte);
begin
  MasterVolume := NewVol;
end;

{Check for the existence of an OPL2/3 chip}
function TestOPL (Test : Word) : Byte;
var
  A, B : Byte;

begin
  {Assume no OPL was found}
  TestOPL := 0;

  {Find it}
  Port [Test] := 0; Delay (1); Port [Test + 1] := 0; Delay (1);
  Port [Test] := 4; Delay (1); Port [Test + 1] := $60; Delay (1);
  Port [Test] := 4; Delay (1); Port [Test + 1] := $60; Delay (1);
  A := Port [Test];
  Port [Test] := 2; Delay (1); Port [Test + 1] := $FF; Delay (1);
  Port [Test] := 4; Delay (1); Port [Test + 1] := $21; Delay (1);
  B := Port [Test];
  Port [Test] := 4; Delay (1); Port [Test + 1] := $60; Delay (1);
  Port [Test] := 4; Delay (1); Port [Test + 1] := $60; Delay (1);

  if ((A and $E0)=0) and ((B and $E0)=$C0) then
    {This might be an OPL2}
    TestOPL := 2
  else
    {There's nothing here, so stop looking}
    Exit;

  {Check for OPL3}
  if Port [Test] and $06 = 0 then TestOPL := 3;
end;

{This function returns true if a GM device is detected at the specified port}
function TestGM (Base : Word) : Boolean;
begin
  TestGM := false;
  Delay (10);
  if ((Port [Base + 1] and $40) = 0) then begin
    Port [Base] := $F8;
    Delay (10);
    if ((Port [Base + 1] and $40) = 0) then TestGM := true;
    Port [Base] := $FF;
    Delay (10);
    Port [Base+1] := $3F;
  end;
end;

{This function reports whether Windows is present. Windows interferes with
the timer interrupt and measures have to be taken.}
function MSWindows : Boolean; assembler;
asm
  mov ax, $1600
  int $2F
end;

{Initialize FM driver}
function SetFM : Boolean;
var
  Bnk : File;

begin
  {Assume a standard SB or AdLib: 6 melodic voices, 5 percussion voices}
  Voices := 5;
  {Check for FM card}
  if TestOPL ($388) > 0 then FMBase := $388;
  {Check for OPL3 at $220 and $240}
  case TestOPL ($240) of
    2 : FMBase := $240;
    3 : begin FMBase := $240; Voices := 14; end;
  end;
  case TestOPL ($220) of
    2 : FMBase := $220;
    3 : begin FMBase := $220; Voices := 14; end;
  end;
  if FMBase <> 0 then begin
    {Enable OPL3 if present}
    if Voices <> 5 then begin
      WriteFM (1, 5, 1);
      WriteFM (1, 4, 0);
    end;
    {Load FM instrument definitions}
    Assign (Bnk, 'FM.DAT');
    Reset (Bnk, 1);
    BlockRead (Bnk, M2, SizeOf (M2));
    BlockRead (Bnk, M4, SizeOf (M4));
    BlockRead (Bnk, M6, SizeOf (M6));
    BlockRead (Bnk, M8, SizeOf (M8));
    BlockRead (Bnk, ME, SizeOf (ME));
    BlockRead (Bnk, MC, SizeOf (MC));
    BlockRead (Bnk, C2, SizeOf (C2));
    BlockRead (Bnk, C4, SizeOf (C4));
    BlockRead (Bnk, C6, SizeOf (C6));
    BlockRead (Bnk, C8, SizeOf (C8));
    BlockRead (Bnk, CE, SizeOf (CE));
    Close (Bnk);
    Device := FM;
  end;
  SetFM := Device = FM;
end;

{Initialize GM driver}
function SetGM : Boolean;
begin
  {Try detecting a GM device}
  GMBase := 0;
  if TestGM ($300) then GMBase := $300;
  if TestGM ($330) then GMBase := $330;
  {If it is detected, use it}
  if GMBase <> 0 then Device := GM;
  SetGM := Device = GM;
end;

begin
  {No device found yet}
  Device := None;
  {Start at normal volume}
  SetVol (128);
  {Check whether Windows is present}
  Windows := MSWindows;
  {Save old timer handler}
  GetIntVec(8, @BIOSTimerHandler);
end.