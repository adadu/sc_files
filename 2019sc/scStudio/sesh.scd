 //Load setup file to get examples working
("setup.scd").loadRelative;

l = Prand([2,9,8],inf);

(
p.clock.tempo = 150/60;
~c = Pbind(\instrument,\bplay,\buf,Prand([d["clap"][1], /*d["clap"][3], d["clap"][2], d["clap"][0]]*/],inf),\dur,Pbjorklund2(Pexprand(1,2).round(1),16,inf,Pwhite(2,4).asStream)/8,\amp,0.99,\rate,Prand([1,1.3,8],inf));
~c2 = Pbind(\instrument,\bplaym,\buf,d["hhc"][0],\dur,Pbjorklund2(Prand([2,3,4],inf),16,inf,Pwhite(2,4).asStream)/16,\amp,0.99,\rate,1);
~k = Pbind(\instrument,\bplaym,\buf,d["kick"][1],\dur,Pbjorklund2(Pseq((1..4),inf),32,inf,0.asStream)/16,\amp,0.99,\rate,0.40);
~snare = Pbind(\instrument,\bplaym,\buf,d["sn"][3],\dur,Pbjorklund2(Pseq((1..2),inf),16,inf,0.asStream)/16,\amp,0.99,\rate,1);
~c.play;
~c2.play;
~k.play;
~snare.play;
)
~c.free;
~c2.free;
~k.free;
~snare.free;
//snare running forwards and back
(
p.clock.tempo = 30/60;
~sn = Pbind(\instrument,\bplay,\buf,d["sn"][7],\dur,Pbjorklund2(Pexprand(1,4).round(1),32,inf,Pwhite(1,4).asStream)/64,\amp, Pexprand(0.16, 0.99, inf), \rate,Pexprand(0.83, 11.53,inf), \pan, Pbjorklund2(Pexprand(8,16).round(1),16,inf,Pwhite(1,5).asStream)/2 * Prand((-1..1),inf));
~sn.play;
)
~sn.free;



s.record(duration: 20);
s.stopRecording;

//modular control test
(
p.clock.tempo = 150/60;
~o2 = Pmono(\dcev,
	\ch,12,\ampCh,13,
	\trig, 1,
	\degree, Pshuf((23..43),inf),
	\scale, Scale.major(\sruti),
	\dur, Pbjorklund2(Pseq((1..4),inf),16,inf,1.asStream)/16,  //+ Prand([0.33,Rest(0.33), Rest(0.33)],inf) * 1, //Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/1,
	\amp, Pexprand(0.7, 1, inf),
	\atk, Prand([1,10,5,1],inf)*0.001,
	\sus,Prand([1,5,1,1,2],inf)*0.04,
	\rel,Prand([1,3,10,1],inf)*0.01,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, -2,
	\port, Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));
~o2.play;

~o3 = Pmono(\dcev,
	\ch,16,\ampCh,17,
	\trig, 1,
	\degree, Pseq((23..37),inf),
	\scale, Scale.major(\sruti),
	\dur, Pbjorklund2(Pseq((3..1),inf),16,inf,1.asStream)/1,
	\amp, 0.68,//Pexprand(0.68, 0.95, inf),
	\atk, Pseq([1,3],inf)*0.1,
	\sus,Pseq([1,3,5],inf)*0.05,
	\rel,Pseq([1,4,5],inf)*0.01,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, -6,
	//\port, Pseq([0,0,0.6,0,0.3],inf)
	); //Pexprand(0.03,0.5,inf));
~o3.play;

/*~o3 = Pmono(\zero,
	\ch,14,\ampCh,15,
	\trig, 1,
	\degree, Pseq([7,9,7,6],inf),
	\scale, Scale.minorPentatonic,
	\dur,Pbjorklund2(Pseq((3..1),inf),16,inf,0.asStream)/16,
	\amp, Pexprand(0.38, 0.45, inf),
	\att, 0.001,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pwhite(1,2),
	\port, Pseq([0,0,0.6,0],inf)
	); //Pexprand(0.03,0.5,inf));
~o3.play;*/

/*~o1 = Pmono(\zero,
	\ch,16,\ampCh,17,
	\trig, 1,
	\degree, Pseq([7,7,9,7,6,4],inf),
	\scale, Scale.minorPentatonic,
	\dur,Pbjorklund2(Pexprand(1,4).round(1),32,inf,Pwhite(2,4).asStream)/16,
	\amp, Pexprand(0.23, 0.29, inf),
	\att, 0.001,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, 0,
	); //Pexprand(0.03,0.5,inf));
~o1.play;*/
)

~o2.free;
~o3.free;
~o1.free;

Scale.directory
Scale.ushaqMashri.pitchesPerOctave;
Scale.ushaqMashri.stepsPerOctave;

Tuning.directory

//sending MIDI notes to MKS-70
(
~mk1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m2], \scale, Scale.major(\sruti), \degree, Prand((23..37),inf), /* Pseq([Prand((1..16), inf,5), Prand((1..16), inf,7), Prand((1..16), inf,3), Prand((1..16), inf,2)], inf),*/ \dur, Pbjorklund2(Pexprand(2,8).round(1),16,inf,Pwhite(2,4).asStream)/8,\amp,Pexprand (0.8, 0.99, inf), \octave, 2);
~mk1.play;
)
~mk1.free



//sending MIDI notes to WS a/d
(
~ws1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, d[\m1], \scale, Scale.major, \degree, Pshuf((24..48), inf,5), \dur, Pbjorklund2(Pexprand(2,4).round(1),16,inf,Pwhite(2,4).asStream)/1,\amp,Pexprand(0.1, 0.4, inf), \octave, 0);
~ws1.play;
)
~ws1.free

//MKS-70 sysex
(
~sysExArray = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, d[\m2],
	\array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x01,
		//0x36, Prand((0..80), inf), //env2 sus param, value
		//0x37, Prand((0..60), inf), //env2 rel param, value
		0x22, Prand((40..80), inf), //LPF Cutoff param, value
		//0x0D, 62, /*Pseq((1..127), inf, 2),*/ //DCO 1 Tune param, value
		//0x13, 62, /*Pseq((1..127), inf, 3),*/ //DCO 2 Tune param, value
		//0x0C, Pexprand(40, 127, inf),
		0x0C, Pexprand(40, 127, inf), //DCO 1 Waveform param, value
		0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, Pbjorklund2(Pexprand(2,11).round(1),33,inf,Pwhite(1,5).asStream)/4,
).play;
)
~sysExArray.free

//WS a/d sysex
(
~sysExArrayB = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, d[\m1],
	\array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x02,
		0x22, Pseq((40..80), inf), //LPF Cutoff param, value
		0x0D, Pseq((1..127), inf, 2), //DCO 1 Tune param, value
		0x13, Pshuf((1..127), inf, 3), //DCO 2 Tune param, value
		0x0C, Pexprand(40, 127, inf), 0xf7]) //DCO 1 Waveform param, value
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, Pexprand(0.5, 0.5, inf),
).play;
)
~sysExArrayB.free

~c.stop;
~c2.stop;
~k.stop;
~sn.stop;
~mk1.free;
~mk1Filt.free;
s.freeAll;

p.free
s.quit

