MIDIClient.init;
MIDIClient.destinations;

(
var mOut = MIDIOut.newByName("MIDI Express XT", "Port 2");

p = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	\octave, Prand((-3..8), inf),
	\degree, Pshuf([0, 9, 8, 7] * -1, inf),
	\dur, Pwrand([0.25, Pn(0.2, 5)], #[0.01, 0.01], inf),
	\amp, Pexprand(0.2, 1.0, inf)
).play(quant: 1);
)


(
var mOut = MIDIOut.newByName("MIDI Express XT", "Port 2");

q = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	\degree, Pseq((-12..12).reverse + 12 / 7, inf),
	\dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
	\amp, Pexprand(0.5, 1.0, inf)
).play(quant: 1);
)

p.stop;

q.stop;

(
var mOut = MIDIOut.newByName("Native Instruments FM8 Virtual Input", "Native Instruments FM8 Virtual Input");

r = Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, mOut,
	\chan, 0,
	\degree, Pshuf((-12..48).reverse + 12 /2, inf),
	\dur, Pwrand([0.25, Pn(0.125, 2)], #[0.8, 0.2], inf),
	\amp, Pexprand(0.5, 1.0, inf)
).play(quant:1);
)
t = r.asStream;
while { (s = t.next).notNil } { s.postln };

p = Pseq([60, 72, 71, 67, 69, 71, 72, 60, 69, 67], 1);
r = p.asStream;
while { (m = r.next).notNil } { m.postln };


r.next.postln;

r.stop;
r.pause;
r.resume;

t = r + r;
t.play;
t.stop;