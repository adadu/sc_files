(
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)


~mOut = MIDIOut.newByName("Live", "Live");

// begin midi and pmonos
(
//start midi
~fm8 = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, ~mOut,
	\chan, Pdefn(\fm8Ch, 0),
	\note, Pdefn(\fm8Note, 60),
	\octave, Pdefn(\fm8Oct, 0),
	\dur, Pdefn(\fm8Dur, 0.5),
	\amp, Pdefn(\fm8Amp, 1),
	// \control, Pdefn(\fm8ContCh, 0, Pdefn(\fm8ctlNum, 3), Pdefn(\fm8val, 64)),
	// how do you alter midi params w ccs through a pbind
	\bend, Pdefn(\fm8Bend),
);
)

y = ~fm8.play(quant:1);

(
Pdefn(\fm8Note, Prand([[40], \rest], inf) + Prand([4/3, 5/4, 6/5, \rest], inf) * Prand([1], inf));
Pdefn(\fm8Oct, 0);
Pdefn(\fm8Dur, PdurStutter(Pseq((1..3),inf), Pseq([0.3, 0.5, 0.7], inf)));
Pdefn(\fm8Amp, Pexprand(0.01, 0.99, inf));
)

(
Pdefn(\fm8Note, Pseq([40, 43, 49, 51, Rest(0.05)], inf) * (Pseq((2..7), inf) / Pseq((5..7), inf)));
Pdefn(\fm8Oct, Prand((1..2),inf));
Pdefn(\fm8Dur, PdurStutter(Pseq((0..2),inf), Pexprand(0.22, 0.6, inf)));
Pdefn(\fm8Amp, 1);
)




/opt
Pdefn(\fm8Oct, Pshuf((0..2),inf));
Pdefn(\fm8Dur, PdurStutter(Pseq((3..1),inf), Pseq([0.3, 0.5, 0.7], inf)));


(
Pdefn(\fm8Note, Pshuf([ [55, 57], [49, 54], [47, 52], \rest ], inf) * Prand([4/3, 5/4, 6/5, \rest], inf));
Pdefn(\fm8Dur, PdurStutter(Pseq((1..6),inf), Pseq([3, 7, 5],inf)));