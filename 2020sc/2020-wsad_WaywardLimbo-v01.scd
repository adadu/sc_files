//WAVESTATION OR DIE
//2020jul19

(
s.quit;
// 01 --- motu 10 channel out setup
// MAC
s.options.device = "iD4";
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 2;
s.options.outputStreamsEnabled = "11";
s.options.numOutputBusChannels.postln;
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)

~mOut = MIDIOut.newByName("MIDIPort32", "Port 1");


p = {128.do({ |pitch| ~mOut.noteOff(0, pitch, 1); }); }; CmdPeriod.add(p);

(
(128.do({ |pitch| ~mOut.noteOff(0, pitch); });)
)


(
//start midi
~mks = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, ~mOut,
	\chan, Pdefn(\mksCh, 0),
	\note, Pdefn(\mksNote, 60),
	\octave, Pdefn(\mksOct, 0),
	\dur, Pdefn(\mksDur, 0.5),
	\amp, Pdefn(\mksAmp, 1),
	\control, Pdefn(\mksCont),
	\bend, Pdefn(\mksBend),
);
)

Scale.directory;
Tuning.directory;
//sending MIDI notes to WS a/d
(
~ws1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, ~mOut, \chan, 1,
	\scale, Pdefn(\wsScale, Scale.lydian),
	\tuning, Pdefn(\wsTuning, Tuning.mean6),
	\degree, Pdefn(\wsDegree, Pseq((12..12), inf)),
	// \note, Pdefn(\wsNote,3),
	\dur, Pdefn(\wsDur, 0.5),
	\sustain, Pdefn(\wsSustain),
	\amp, Pdefn(\wsAmp, 0.8),
	\octave, Pdefn(\wsOctave,Pseq((-1..5),inf)),
	\ctranspose, Pdefn(\wsCtranspose),
)
)

(
~ws2 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, ~mOut, \chan, 0,
	\scale, Pdefn(\ws2Scale, Scale.lydian),
	\tuning, Pdefn(\ws2Tuning, Tuning.mean6),
	\degree, Pdefn(\ws2Degree, Pseq((12..12), inf)),
	// \note, Pdefn(\wsNote,3),
	\dur, Pdefn(\ws2Dur, 0.5),
	\sustain, Pdefn(\ws2Sustain),
	\amp, Pdefn(\ws2Amp, 0.8),
	\octave, Pdefn(\ws2Octave,Pseq((-1..3),inf)),
)
)

x = ~ws1.play;
x.stop;

y = ~ws2.play;
y.stop;


Tuning.sept1.semitones
Tuning.et41.semitones
Tuning.et41.ratios
(
Pdefn(\wsDegree, Pshuf([1,3,9,11], inf));
Pdefn(\wsScale, Scale.lydian);
Pdefn(\wsTuning, Tuning.mean6);
//Pdefn(\wsTuning, Tuning.pythagorean);
Pdefn(\wsDur, Pbjorklund2(Pexprand(2,8).round(1),8,inf,Pwhite(2,8).asStream)/8);
	//Pbjorklund2(Pexprand(3,5).round(1),2,inf,Pwhite(2,7).asStream)/8);
Pdefn(\wsAmp, Pwhite(0.1, 0.99, inf));
Pdefn(\wsOctave, Pshuf((1..3),inf));
)

Pdefn(\wsDegree, Pseq([3,1,-2-3], inf));
Pdefn(\wsOctave, Prand([4], inf));

Pdefn(\wsDegree, Pshuf([1,3,9,11], inf));

Scale.directory
Tuning.directory
(
Pdefn(\wsScale, Scale.partch_o1);
Pdefn(\wsTuning, Tuning.just);
//Pdefn(\wsTuning, Tuning.pythagorean);
Pdefn(\wsDegree, Prand([2,3,5,7,9,-1,-3].mirror2, inf));
Pdefn(\wsDegree, Pseq([2,5,7,11,-1,-2].mirror1, inf));
// Pdefn(\wsNote, 5);//Pseq([2,4,3,6,10]*0.4, inf));
Pdefn(\wsDur, PdurStutter(Pseq((2..6),inf), Pseq([0.75, 1.25, 1]*0.77, inf)));
Pdefn(\wsAmp, Pexprand(0.01, 0.99, inf));
Pdefn(\wsOctave, Pseq((1..3).stutter(2),inf));
Pdefn(\wsCtranspose, Pseq((2..5).mirror2.stutter(4),inf));
//Pdefn(\wsCtranspose, 0);
)

(
Pdefn(\wsScale, Scale.lydian);
Pdefn(\wsTuning, Tuning.mean6);
//Pdefn(\wsTuning, Tuning.pythagorean);
Pdefn(\wsDegree, Prand([2,3,9,11,-2], inf));
//Pdefn(\wsDegree, Prand([2,5,7,11,-1,-3], inf));
// Pdefn(\wsNote, 5);//Pseq([2,4,3,6,10]*0.4, inf));
Pdefn(\wsDur, PdurStutter(Pshuf((2..3),inf), Pseq([0.75, 1, 2, 0.1]*1.1, inf)));
Pdefn(\wsAmp, Pexprand(0.2, 0.99, inf));
Pdefn(\wsOctave, Prand((2..4),inf));
Pdefn(\wsCtranspose, Pseq([1,0,1,0,0,1],inf));
Pdefn(\wsCtranspose, 0);
)

(
Pdefn(\wsDegree, Pseq([2,3,4], inf));
Pdefn(\wsOctave, Prand((4..4),inf));
Pdefn(\wsDur, Pseq([Pgeom(0.07, 1.01, 75)],inf) *1);
Pdefn(\wsDur, 0.1);
Pdefn(\wsAmp, Pexprand(0.2, 0.99, inf));
)

Pdefn(\wsDegree,Pbrown(1, 23, 1, inf));
Pdefn(\wsDegree,Pwrand([1,5,4,11], [2,7,13,1].normalizeSum, inf));
Pdefn(\wsDegree, Pslide(#[1, 2, 3, 4, 5], inf, 3, 1, 0)*1);
Pdefn(\wsOctave, Pslide(#[1, 2, 3], inf, 3, 1, 0)*1);

Pdefn(\wsDur, Pslide(#[1, 2, 3, 4, 5], inf, 3, 1, 0)*0.05);


(
Pdefn(\wsDegree, Pslide([Pwrand([-1,5,-4,11], [2,7,13,1].normalizeSum, inf)], inf, 7, 1, 0));
Pdefn(\wsDur, Pslide([Pwrand([2,1,2,4]*0.05, [3,4,2,1].normalizeSum, inf) * Pwrand([1,2,3,4]*0.77, [3,4,2,1].normalizeSum,inf)], inf, 8, 1, 1).stutter(Rand(5)) * 1);
Pdefn(\wsOctave, Prand((1..2),inf));
)

// WS2 voicing
(
Pdefn(\wsDegree,Pbrown(-3, 21, 1, inf));
Pdefn(\wsDur, Pslide(#[1,2,1,3,4,2]*0.4, inf, 8, 0, 1));
//Pdefn(\ws2Dur, Pslide([Pwrand([2,1,2,4]*0.5, [3,4,2,1].normalizeSum, inf)
Pdefn(\ws2Scale, Scale.lydian);
Pdefn(\ws2Tuning, Tuning.mean6);
)

// data helper, how to insert nrpn into sysex?
0x1F.value;
0200 >> 7;
3939 >> 7;

// i'm looking to manipulate parameters via sysex on a Wavestation A/D with supercollider
// F0 42 31 28 41 71 00 7F [30] 00 F7
// F0 42 31 28 41 71 00 2B [39 39] 00 F7
// how does the minimum value of 30 increment to the max of 39 39? is this nrpn?
// any tweakers?
(
~sysExArrayB = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, ~mOut,
	\array, Ptuple([0xf0, 0x42, 0x31, 0x28, 0x41, 0x71, 0x00,
		0x2b, Pseq((30..39), inf), //Amp release level
		00, 0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, 0.5,
).play;
)

~sysExArrayB.free

(
var relEv, val, upper, lower;
relEv = 80;
val = (relEv).round.asInteger;
upper = val&2r11111110000000>>7;
lower = val&2r00000001111111;
[upper, lower].postln;
~mOut.control([upper, lower])
)
// I send values to nrpn with code like this (I cannot test at the moment
// 	but it's loosely based on code I use all the time with my prophet rev2
// synth)
//
(
sendNRPN = {
	| number, value, channel=1, midi_out=nil |
	var cCC_MSB = 99;
	var cCC_LSB = 98;
	var cDATA_MSB = 6;
	var cDATA_LSB = 38;
	var number_msb = number >> 7;
	var number_lsb = number & 127;
	var value_msb = value >> 7;
	var value_lsb = value & 127;
	if (midi_out.notNil) {
		midi_out.control(channel, cCC_MSB, number_msb);
		midi_out.control(channel, cCC_LSB, number_lsb);
		midi_out.control(channel, cDATA_MSB, value_msb);
		midi_out.control(channel, cDATA_LSB, value_lsb);
	};
};
)

//MOD
(
sendNRPN = {
	| number, value, channel=1 |
	//var cCC_MSB = 99;
	//var cCC_LSB = 98;
	var cDATA_MSB = 6;
	var cDATA_LSB = 38;
	//var number_msb = number >> 7;
	//var number_lsb = number & 127;
	var value_msb = value >> 7;
	var value_lsb = value & 127;
	if (~mOut.notNil) {
		//midi_out.control(channel, cCC_MSB, number_msb);
		//midi_out.control(channel, cCC_LSB, number_lsb);
		~mOut.control(cDATA_MSB, value_msb);
		~mOut.control(cDATA_LSB, value_lsb);
	};
};
)

//
// // try it: sendNRPN.(1024, 19, 1, mo);
// // sends value 19 to NRPN 1024 on midi channel 1
// // (fill in your own values of course)
// // "mo" is an initialized and connected MidiOut instance
//
// If you insist on sending it from a pattern, you could e.g.
//
// p = Pbind(
// 	...
// 	\mycustomkey, Pfunc({|ev| sendNRPN.(1024, 19, 1, mo); })
// );
// p.play;
//
// The above would reevaluate mycustomkey, and therefore resend the value
// to the NRPN, everytime a new event is about to be generated. The code
// can be modified to send only once, or send only under certain
// conditions, etc.
//
// Maybe others have better solutions.

(
~wsT = Pbind(\type, \midi, \midicmd, \polyTouch, \midiout, ~mOut, \chan, 1, \dur,Prand((1..10)*0.01,inf), \polyTouch, Pwhite(0, 127, inf))
)
y = ~wsT.play;
y.stop;

(
~mk1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, ~mOut, \scale, Scale.major(\sruti), \degree, Prand((23..37),inf), /* Pseq([Prand((1..16), inf,5), Prand((1..16), inf,7), Prand((1..16), inf,3), Prand((1..16), inf,2)], inf),*/ \dur, Pbjorklund2(Pexprand(2,8).round(1),16,inf,Pwhite(2,4).asStream)/8,\amp,Pexprand (0.8, 0.99, inf), \octave, 2);
~mk1.play;
)
~mk1.free