(
~panBus1 = Bus.audio(s, 1);
~panBus2 = Bus.audio(s, 1);
~panBus3 = Bus.audio(s, 1);

~diffuse = Bus.audio(s,4);
)

(
// PANNER
SynthDef(\decorPan4, {
	|in, out=0, pan, decor=0.0, panwidth=2.0, orientation=0.5, panfreq=0.1|

	var chain, sig = PanAz.ar(4, In.ar(in, 1), pos: SinOsc.ar(panfreq), width: panwidth, orientation: orientation);

	Out.ar(out, sig);
}).add;

// QUAD GRAIN
SynthDef(\grain4, {
	|in, out=0, pan, decor=0.0, panwidth=2.0, orientation=0.5, panfreq=0.1, gdur=0.1, rate=10|

	var sig = PanAz.ar(4, In.ar(in, 1), pos: SinOsc.ar(panfreq), width: panwidth, orientation: orientation);

	sig = InGrain.ar(Impulse.ar(rate),gdur, sig);

	Out.ar(out, sig);
}).add;

// SINE
SynthDef(\testsig2, {
	| out, freq, amp=0.25, atk=1, dur=1, rel=1|
	var sig, env;

	// Envelope
    env = EnvGen.kr(Env([0, 1.0, 0.75, 0.0], [atk, dur, rel]), doneAction:2);

	sig = SinOsc.ar(freq);
	Out.ar(out, sig*amp*env);
}).add;

// DIFFUSER
SynthDef(\justpan, {
	|out=0, pan, inBus|

	var chain, sig, in;

	in = In.ar(inBus, 4);

	/*
	chain = [
		FFT(LocalBuf(2048), in[0]),
		FFT(LocalBuf(2048), in[1]),
		FFT(LocalBuf(2048), in[2]),
		FFT(LocalBuf(2048), in[3])];
	chain = PV_Diffuser(chain, 1);
	sig = IFFT(chain);
	*/

	sig = Pan2.ar(in, pan);

	Out.ar(out, sig);
}).add;
)

(
~sources = Group.new;
~effects = Group.new(s, \addToTail);
~panner = Synth(\grain4, [\in, ~panBus1, \rate, 10, \gdur, 0.01, \out, ~diffuse], ~effects);
~panner2 = Synth(\grain4, [\in, ~panBus2, \rate, 5, \gdur, 0.02, \out, ~diffuse], ~effects);
~panner3 = Synth(\grain4, [\in, ~panBus3, \rate, 20, \gdur, 0.125, \out, ~diffuse], ~effects);

~diffusesynth = Synth(\justpan, [\inBus, ~diffuse], ~effects, \addToTail);

~p1 =
	Pbind(\instrument, \testsig2,
	\freq, Pxrand((100..800),inf),
	\dur, Pseq([8, 9, 10, Rest(11)], inf) * Prand([0.5, 1, 2, 4],inf),
	\atk, Pkey(\dur)/2,
	\rel, Pkey(\atk),
	\amp, 0.1,
	\out, Pxrand([~panBus1, ~panBus2, ~panBus3], inf),
	\group, ~sources);

~p2 =
	Pbind(\instrument, \testsig2,
	\freq, Pxrand([110,120,140,200],inf)*Pseq([1,2,0.5,2],inf)*[1,Pxrand((1.05..1.2),inf)],
	\dur, Pseq([60, 64], inf),
	\atk, Pkey(\dur)/2,
	\rel, Pkey(\atk),
	\pan, [-1,1],
	\amp, 0.1,
	\out, ~diffuse,
	\group, ~sources);

~p1.play;
~p2.play;
)

~p2.stop;

s.plotTree;