//Load setup file to get examples working
("setup.scd").loadRelative;


(
//rme fireface800
s.options.device="Fireface 800 (3EC)";
s.options.numInputBusChannels = 8;
s.options.numOutputBusChannels = 8;
s.boot;
)


s.freeAll;
p.free
s.quit

//Concat and Concat2
//Tartini

{ Decay.ar(Impulse.ar(1), 0.1, WhiteNoise.ar) }.play
{ CombL.ar(Decay.ar(Impulse.ar(1), 0.1, WhiteNoise.ar), 0.02, 0.001, 3, 1) }.play

(
SynthDef(\ks_string, { arg note, pan, rand, delayTime; var x, y, env;
env = Env.new(#[1, 1, 0],#[2, 0.001]);
// A simple exciter x, with some randomness.
x = Decay.ar(Impulse.ar(0, 0, rand), 0.1+rand, WhiteNoise.ar);
         x = CombL.ar(x, 0.05, note.reciprocal, delayTime, EnvGen.ar(env, doneAction:2));
        x = Pan2.ar(x, pan);
        Out.ar(0, LeakDC.ar(x));
}).add;
)

{ // and play the synthdef
	20.do({
		Synth(\ks_string,
        [\note, [48, 50, 53, 58].midicps.choose,
        \pan, 1.0.rand2,
        \rand, 0.1+0.1.rand,
        \delayTime, 2+1.0.rand]);
[0.125, 0.25, 0.5].choose.wait;
		});

}.fork;


Pdef(\kspattern,
	Pbind(\instrument, \ks_string, // using our sine synthdef
		\note, Pseq.new([60, 61, 63, 66], inf).midicps, // freq arg
		\dur, Pseq.new([0.25, 0.5, 0.25, 1], inf), // dur arg
		\rand, Prand.new([0.2, 0.15, 0.15, 0.11], inf), // dur arg
		\pan, 1.0.rand2,
		\delayTime, 2+1.0.rand; // envdur arg
	)
).play;

{
var burstEnv, burst;
burstEnv = EnvGen.kr(Env.perc(0, 0.01), gate: Impulse.kr(1.5)); burst = WhiteNoise.ar(burstEnv);
CombL.ar(burst, 0.2, 0.003, 1.9, add: burst);
}.play;


// pink noise
{
var burstEnv, burst;
burstEnv = EnvGen.kr(Env.perc(0, 0.01), gate: Impulse.kr(1.5)); burst = PinkNoise.ar(burstEnv);
CombL.ar(burst, 0.2, 0.003, 1.9, add: burst);
}.play;

SynthDef(\pluck, {arg freq=440, trig=1, time=2, coef=0.1, cutoff=2, pan=0; var pluck, burst;
        burst = LPF.ar(WhiteNoise.ar(0.5), freq*cutoff);
        pluck = Pluck.ar(burst, trig, freq.reciprocal, freq.reciprocal, time, coef:coef);
        Out.ar(0, Pan2.ar(pluck, pan));
}).add;

Synth(\pluck);
Synth(\pluck, [\coef, 0.01]);
Synth(\pluck, [\coef, 0.3]);
Synth(\pluck, [\coef, 0.7]);
Synth(\pluck, [\coef, 0.3, \time, 0.1]);
Synth(\pluck, [\coef, 0.3, \time, 5]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 1]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 2]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 5]);
Synth(\pluck, [\coef, 0.2, \time, 5, \cutoff, 15]);

SynthDef(\xylo, { |out=0, freq=440, gate=1, amp=0.3, sustain=0.5, pan=0|
var sig = StkBandedWG.ar(freq, instr:1, mul:3);
var env = EnvGen.kr(Env.adsr(0.0001, sustain, sustain, 0.3), gate, doneAction:2); Out.ar(out, Pan2.ar(sig, pan, env * amp));
}).add;
Synth(\xylo)
Pbind(\instrument, \xylo, \freq, Pseq(({|x|x+60}!13).mirror).midicps, \dur, 0.2).play

( {
var env, in, freq, hasFreq; // the audio input
in = SoundIn.ar(6);
// the pitch variable and the hasFreq (Pitch.kr returns a list like this [freq, hasFreq])
# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.2, median: 7);
// when the hasFreq is true (pitch is found) we generate a ADSR envelope that is open until // the hasFreq is false again or the amplitude is below the ampThreshold of the Pitch.
env = EnvGen.ar(Env.adsr(0.51, 0.52, 1, 0.51, 1, -4), gate: hasFreq);
// we plug the envolope to the volume argument of the Sine
        SinOsc.ar(freq, 0, env * 0.5) ! 2
}.play;
)


( {
var env, in, freq, hasFreq, amp;
// the audio input
in = SoundIn.ar(6);
amp = Amplitude.kr(in, 0.25, 0.25);
// the pitch variable and the hasFreq (Pitch.kr returns a list like this [freq, hasFreq])
# freq, hasFreq = Pitch.kr(in, ampThreshold: 0.2, median: 7);
// when the hasFreq is true (pitch is found) we generate a ADSR envelope that is open until // the hasFreq is false again or the amplitude is below the ampThreshold of the Pitch.
env = EnvGen.ar(Env.adsr(0.51, 0.52, 1, 0.51, 1, -4), gate: hasFreq);
// we plug the envolope to the volume argument of the Sine
        SinOsc.ar(freq, 0, env * amp) ! 2
}.play;
)

(
SynthDef(\pitcher,{
var in, amp, freq, hasFreq, out, threshold, gate;
threshold = 0.05; // change
in = LPF.ar(Mix.new(SoundIn.ar(6)), 2000); amp = Amplitude.kr(in, 0.25, 0.25);
# freq, hasFreq = Tartini.kr(in); gate = Lag.kr(amp > threshold, 0.01);
        // -- to look at the values, uncomment the following lines
        // -- (you need a recent build with the Poll class)
        Poll.kr(Impulse.kr(10), freq, "frequency:");
        //Poll.kr(Impulse.kr(10), amp, "amplitude:");
        //Poll.kr(Impulse.kr(10), hasFreq, "hasFreq:");
	out = Mix.new(VarSaw.ar(freq * [0.5,1,2], 0, 0.2, gate* hasFreq *amp ));
	//out = Mix.new(SinOsc.ar(freq * [0.5,1,2], 0, 0.2 * amp*hasFreq*gate));
	6.do({
		out = AllpassN.ar(out, 0.040, [0.040.rand,0.040.rand], 2)
	});
    Out.ar(0,out)
}).play(s);
)

{WalshHadamard.ar(SoundIn.ar(6), MouseX.kr(0,64))}.play

{var n= 1024; WaveletDaub.ar(SoundIn.ar(6), n, MouseX.kr(2,n))}.play


