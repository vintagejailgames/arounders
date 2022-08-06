program asci;

uses crt;

type passwords = array[2..30] of string[10];


var
  i,j : integer;
  password: passwords;
  f : file of passwords;

begin

password[2] := 'DELPHIMOLA';
password[3] := 'XIMOCOWBOY';
password[4] := 'AMENAIRTEL';
password[5] := 'FRAYBOTIJO';
password[6] := 'AROUNDERSX';
password[7] := 'USERLOGGED';
password[8] := 'BALOOISBAK';
password[9] := 'PEPEPINTOR';
password[10] := 'AEROJAULES';
password[11] := 'TELEFONICA';
password[12] := 'WELOVEJAIL';
password[13] := 'BORRULLETS';
password[14] := 'NUKINJAILS';
password[15] := 'JAILHYMNOS';
password[16] := 'DUKENUKEM3';
password[17] := 'PACOFORYOU';
password[18] := 'BACTERIOLS';
password[19] := 'BRYNDISMAN';
password[20] := 'FUCKEMALLS';
password[21] := 'NOLEMMINGS';
password[22] := 'GRACIASPOR';
password[23] := 'BUBLEBUBLE';
password[24] := 'ENQUEDAUNA';
password[25] := 'LADELFINAL';
password[26] := 'ENQUEDAMES';
password[27] := 'NOSAACABAT';
password[28] := 'NOFALTMOLT';
password[29] := 'IPENULTIMA';
password[30] := 'ELPASSWORD';

For i := 2 to 30 do
  for j := 1 to 10 do
    password[i][j] := chr( ord(password[i][j])+100 +j);


assign(f,'..\data\offsets.bal');
rewrite(f);
write(f,password);
close(f);

{for i := 0 to 255 do write(i,'=',chr(i),' ');}

end.