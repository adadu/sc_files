s.quit;

(
// 01 --- motu 10 channel out setup
s.options.device = "MOTU Express XT";
// s.options.numOutputBusChannels = 10;
// s.options.outputStreamsEnabled = "1111111111";
// s.options.numOutputBusChannels.postln;
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)

(
//global vars:
//midi out var
~mOut = MIDIOut.newByName("MIDI Express XT", "Port 3");
//tuning related
h = Prand((1..24), inf);
i = 6;
j = i * 2;
t = {Pdefn(\two3amp, -1); Pdefn(\four5amp, -1); };
p = {128.do({ |pitch| ~mOut.noteOff(0, pitch, 0); }); }; CmdPeriod.add(p);
)

// 03 --- begin midi and pmonos
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

(
//mks dark cluster
~mOut.program(0, 6);
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53]], inf));
Pdefn(\mksOct, 1);
Pdefn(\mksDur, 60 * 7);
)

y = ~mks.play(quant:1);

(
y.stop;
128.do({ |pitch| ~mOut.noteOff(0, pitch, 0); });
)

(
//mks ZONE 1
~mOut.program(0, 3);
Pdefn(\mksNote, Prand([[33, 35, 39, 42, 50, 53], \rest], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksOct, 0);
Pdefn(\mksDur, PdurStutter(Pseq((2..3),inf), Pseq([0.3, 0.5, 0.7], inf)));
)

/opt
Pdefn(\mksOct, Pshuf((0..2),inf));

(
//mks ZONE 2
~mOut.program(0, 3);
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53]], inf) * Pseq([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksOct, 1);
Pdefn(\mksDur, PdurStutter(Pseq((2..5),inf), Pseq([0.3, 0.5, 0.7], inf)));
)

//opt
Pdefn(\mksOct, Pshuf((0..2),inf));
Pdefn(\mksOct, Pshuf((0..1),inf));

(
Pdefn(\mksDur, Prand((9..17),inf));
Pdefn(\mksOct, Prand((2..2),inf));
Pdefn(\mksNote, Prand([[33, 35, 39, 42, 45, 47, 50, 52, 53], [38, 40, 44, 47, 50, 52, 55, 57, 58], [41, 43, 47, 50, 53, 55, 57, 59, 60]], inf) * Prand([4/3, 5/4, 6/5], inf));
Pdefn(\mksNote, Prand([[33, 35, 39, 42, 45, 47, 50, 52, 53]], inf));
)

//speedy
Pdefn(\mksDur, PdurStutter(Pseq((2..5),inf), Pseq([0.3, 0.5, 0.7], inf)));

//NEW NEW NEW
(
//mks ZONE 3 thru modular
~mOut.program(0, 7);
Pdefn(\mksNote, Pshuf([ [63, 68, 69], [61,66, 68], \rest] ,inf) * Pseq([3/3, 3/4], inf));
Pdefn(\mksDur, 0.1);
Pdefn(\mksOct, 0);
)
//opt
Pdefn(\mksNote, Pshuf([ [63, 68, 69], [61,66, 68]] ,inf) * Pseq([3/3, 2/1], inf));
Pdefn(\mksDur, PdurStutter(Pseq((2..5),inf), Pseq([0.3, 0.5, 0.7], inf)));
Pdefn(\mksOct, Pshuf((0..1),inf));
Pdefn(\mksOct, Pshuf((0..2),inf));


Pdefn(\mksNote, Prand([[0,1,2], \rest, [1,4,5,8], \rest, [1,3,4,5,8], \rest, [1,2,3,6,7,8], \rest] * 5, inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksNote, Pshuf([ [63, 68, 69], [61,66, 68], [55, 88]] ,inf));
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53], \rest], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksNote, Prand([ [33, 35, 39, 42, 50, 53] ],inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\mksNote, Pshuf([[33, 35, 39, 42, 45], [38, 40, 44, 47, 50], [41, 43, 47, 50, 53]], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));


Pdefn(\mksOct, 0);

Pdefn(\mksOct, 2);
Pdefn(\mksOct, Pshuf((0..1),inf));
Pdefn(\mksOct, Pshuf((0..4),inf));
Pdefn(\mksOct, Pshuf((0..2),inf));

Pdefn(\mksDur, 0.05);
Pdefn(\mksDur, 0.1);
Pdefn(\mksDur, 0.3);
Pdefn(\mksDur, 0.5);
Pdefn(\mksDur, 1);
Pdefn(\mksDur, 10);
Pdefn(\mksDur, Pwhite(1, 3, inf));
Pdefn(\mksDur, Pwhite(0.1, 0.3, inf));
