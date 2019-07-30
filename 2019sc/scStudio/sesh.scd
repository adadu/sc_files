 //Load setup file to get examples working
("setup.scd").loadRelative;

l = Prand([2,9,8],inf);

(
p.clock.tempo = 150/60;
~c = Pbind(\instrument,\bplay,\buf,d["clap"][1],\dur,Pbjorklund2(Pexprand(2,15).round(1),16,inf,Pwhite(1,5).asStream)/4,\amp,1,\rate,1);
~c2 = Pbind(\instrument,\bplay,\buf,d["hhc"][0],\dur,Pbjorklund2(Pexprand(2,15).round(1),16,inf,Pwhite(1,5).asStream)/4,\amp,0.7,\rate,1);
~k = Pbind(\instrument,\bplay,\buf,d["kick"][17],\dur,Pbjorklund2(Pexprand(1,4).round(1),24,inf,Pwhite(1,5).asStream)/32,\amp,0.59,\rate,1);
~c.play;
~c2.play;
~k.play;
)
~c.free;
~c2.free;
~k.free;

//snare running forwards and back
(
p.clock.tempo = 150/60;
~sn = Pbind(\instrument,\bplay,\buf,d["sn"][0],\dur,Pwhite(1,4)/4,\amp,0.99,\rate,Prand([1,0.8],inf));
~sn.play;
)
~sn.free;

//sending MIDI notes to MKS-70
(
~mk1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m2], \degree, Pexprand([1,3,5,7,9,11,13],[7,9,11,13,15,17,19], inf), \dur, Pwhite(0.25,1),\amp,0.6);
~mk1.play;
)
~mk1.free

//Roland MKS-70 sysex message format

//individual TONE parameters IPR
//A   B   C   D   E   F   G     H    I    J
//F0H 41H 36H mcH 24H 20H toneH prmH valH F7H
//A= Exclusive message start
//B= Roland ID
//C= Operation code IPR
//D= MIDI channel (mcH) 00H to 0FH (1 to 16 decimal)
//E= JX10 Format
//F= Level 1 Tone
//G= (toneH) Group number 01H = Upper tone 02H = Lower tone
//H= (pmH) Parameter 00H-32H (0-51 decimal)
//I= (valH) Value 00H-F7H (0-127 decimal)
//J= End of Exclusive message

(
~sysExArray = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, d[\m2],
	\array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x01,
		0x22, Pexprand(40, 80, inf), //LPF Cutoff param, value
		0x0D, Pexprand(0, 127, inf), //DCO 1 Tune param, value
		0x0C, Pexprand(20, 127, inf),  0xf7]) //DCO 1 Waveform param, value
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, Pexprand(0.5, 0.5, inf),
).play;
)
~sysExArray.free

~c.stop;
~c2.stop;
~k.stop;
~sn.stop;
~mk1.free;
~mk1Filt.free;
s.freeAll

p.free
s.quit
