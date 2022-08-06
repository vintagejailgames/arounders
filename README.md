<sub>JailDoctor Games Presenta...</sub>
# Arounders
<sup>v1.00 RELEASE 2</sup>

<img width="752" src="https://user-images.githubusercontent.com/110221325/183260269-c1cdd3db-ce50-455c-8c31-9b7d4afd6e9d.png">

## HISTÒRIA

Al principi dels temps l'univers era una massa concentrada de materia que va explotar i... però avancem un poc en la història: Açò era baloo, barba peluda, el pelo pinxo i pantaló bermuda, que se anava a menjar narantxes, se ana a dentr para echar desmadre, però antes se ana a fer-se un cortaet... i això pot ser FATAL...

## REQUERIMENTS TÈCNICS

Aquest joc s'ha testejat en un PIII 450, un PMMX 200 i un P 75, sense cap mena de problemes. Teòricament, deuria funcionar també en un 486 o inclus en un 386 de gama alta.

 * Targeta de só compatible amb la SoundBlaster.
 * Targeta de video VGA.
 * Ratolí.
 * Teclat.
 * Disc Dur.
 * Monitor.
 * Impresora (??)
 * OPCIONAL: Scanner, scanner!

## INSTRUCCIONS

Has de dur a tots els arounders necessaris des d'una porta del nivell fins l'altra.

Teclat:
  * `ESC` Abandonar la partida
  * `P` Pausa (tornar a apretar per a eixir de la Pausa)

Ratolí:
  * `Botó Esquerre` Seleccionar arounder / seleccionar acció
  * `Botó Dret` El arounder seleccionat deixa de fer el que està fent

Accions: (ordenades d'esquerra a dreta de la barra)

 * **Aroundar**: Per defecte, no farà falta mai que apretem aquest botó. El arounder caminarà fins que no puga seguir (i pegarà la volta) o fins la mort...

 * **Parar**: El arounder pararà de aroundar i, a més, farà pegar la volta a tots els arounders que se li acosten. Aquesta acció es du a terme nomes pulsar el botó.

 * **Cavar**: El arounder farà un forat en la paret fins que no hi haja res més que foradar. Aquesta acció es du a terme quan el arounder es trobe amb una paret.

 * **Escalar**: El arounder escalarà fins que arrive dalt del tot, o no puga seguir. Es durà a terme al trobar-se una paret.

 * **Perforar**: Fà un forat en terra, fins que no puga seguir avall. Es durà a terme només pulsar el botó.

 * **Escalera**: Construeix una escalera fins que no puga seguir o s'acaven els escalons. Es durà a terme nomes pulsar el botó.

 * **Pasarela**: Com la escalera però en horitzontal. Construeix un pont. Es durà a terme al pulsar-lo.

 * **Corda**: El arounder solta una corda desde un precipici fins a terra. Es durà a terme al trobar-se una paret. Tots els arounders que arriven a un precipici amb corda, baixaran per ella, però els que se troben baix pujaran per ella. Si pugen per el costat equivocat, cauran.

 * **Suicidi**: El arounder agarra i explota de rabia. La mort es immediata.

 * **Suicidi col·lectiu**: Voràs un montó de pixels en la pantalla !!!

Crec que tot lo demés ja parla per si sol...

<img width="752" src="https://user-images.githubusercontent.com/110221325/183260295-3ff2c778-78aa-4882-850a-b83e358ae3b1.png">

## RECOMANACIONS

 * El secret de la majoria dels nivells és començar bé. Deuràs tindre reflexos d'acer per a completar els nivells !!!

 * Només començar el nivell, apreta la pausa i mira-ho tot bé. La pausa serà una gran aliada, ja que mentre estas en pausa pots moure el cursor.

 * Els arounders no poden caure de molt alt, nomes soporten cuatre vegades la seua altura. Un pixel de més i tindràs tortilla de arounder.

 * Alguns nivells es poden solventar de diverses formes, si t'atranques, prova altra forma. Molts nivells son més fàcils del que pareix.

 * Però en altres nivells necessitaras apurar fins l'ultim pixel: Si no aconsegueixes passar-te'l, pot ser no apures el suficient.

 * Recorda que totes les accions es poden parar quan a tu t'interese pulsant el botó dret.

## BUGS & POLLS

 * En algunes targetes de só SoundBlaster el General MIDI no funciona, degut a que aquestes targetes utilitzen el seu propi UART.

 * De vegades, a meitant nivell, tots els arounders exploten inexplicablement...

 * La acció corda és molt sensible. Si la utilitzes, i abans del precipici hi ha un desnivell d'uns pocs pixels, el aounder intentarà sense exit utilitzar la corda, perdent-la.

## Com jugar hui en dia

Amb DosBox. Augmenta els cicles a tu gusto, sinó anirà massa lento.

## Com compilar hui en dia

Turbo Pascal 7 desde DosBox. No funciona des del IDE, compilar a arxiu directament. Activar "286 Instructions", en "Options -> Compiler"

![turbopascalx86](https://user-images.githubusercontent.com/110221325/181739514-656e6aa9-eda0-4f85-b6a5-43e1558f080a.png)

La versió compilada del release funciona correctament, però quan he compilat ara me peta al anar a començar a jugar, algo del heap, en aquella època programavem com el cul. Algún dia igual ho mire. O no.
