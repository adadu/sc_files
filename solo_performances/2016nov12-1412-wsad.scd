MIDIClient.init;
MIDIClient.destinations;

//VARS
(
c = Prand((0.01..5),inf);
)

//LOOP sentinal
(
var mOut = MIDIOut.newByName("MIDIPort32", "Port 1");
x = Pdefn(\loop1, Pseq([40,30,12], inf));
u = Pdefn(\loop2, Pseq([\rest, \rest, 2, 10, \rest, 21], inf));
y = Pbind(\type, \midi, \midiout, mOut, \midinote, Pdefn(\loop1), \dur, 0.2, \amp, Pexprand(0.8, 1.0, inf));
t = Pbind(\type, \midi, \midiout, mOut, \midinote, Pdefn(\loop2), \dur, 0.1, \amp, Pexprand(0.8, 1.0, inf));
)

(
z = y.play;
v = t.play;
)

(
z.stop;
v.stop;
)

//AUTO-involvement with a duckasaurus
(
var mOut = MIDIOut.newByName("MIDIPort32", "Port 1");

s = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	//\octave, Prand((-2..2), inf),
	\midinote, Prand([1, 19, 40, 50, 43], inf),
	\dur, Prand([1,2,3,4,5] * [c], inf),
	//\dur, Prand([0.5, 0.3, 0.02, 1, 0.1], inf),
	//\dur, Pwrand([0.25, Pn(0.2, 5)] * 0.01, #[0.01, 0.001], inf),
	\amp, Pexprand(0.8, 1.0, inf),
).play(quant: 1);
)

s.stop;
q.stop;

//JUMPING froggy schloffs

(
var mOut = MIDIOut.newByName("MIDIPort32", "Port 1");

q = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	\degree, Pshuf((-12..12).reverse + 12 / 7, inf),
	\dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
	\amp, Pexprand(0.5, 1.0, inf)
).play(quant: 1);
)

q.stop;

// switch patch, then
//IFGHT glitch chicken
(
var mOut = MIDIOut.newByName("MIDIPort32", "Port 1");

m = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	//\octave, Prand((-4..2), inf),
	\midinote, Pshuf([30, 50, 41, 99, 62], inf),
	\dur, Prand((0.01..0.09), inf),
	//\dur, Prand([0.5, 0.3, 0.02, 1, 0.1], inf),
	//\dur, Pwrand([0.25, Pn(0.2, 5)] * 0.01, #[0.01, 0.001], inf),
	\amp, Pexprand(0.8, 1.0, inf)
).play(quant: 1);
)

m.stop;

//FIGHT glitch beef
(
var mOut = MIDIOut.newByName("MIDIPort32", "Port 1");

n = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	//\octave, Prand((-4..2), inf),
	\midinote, Pshuf([30, 33, 61, \rest] / [c], inf),
	\dur, Pshuf([5, 7, 3] *[c] * 0.1, inf),
	\amp, Pexprand(0.8, 1.0, inf)
).play(quant: 1);
)

n.stop;
