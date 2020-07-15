(
// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2");

// connect all output channels with system
"SC_JACK_DEFAULT_OUTPUTS".setenv("system");

s.boot;
)

(
// sc virtual osc
SynthDef(\sawd, { | freq = 440, t_trig, ch = nil, atk=0, sus=0, rel=3, amp = 0.5, ampCh = nil, dur = 1, octave = 0, stepsPerOctave = 12 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	var sig = LFSaw.ar(freq, 0, 1, 0);
	freq = freq + (octave * stepsPerOctave);
	freq = freq / stepsPerOctave;
	Out.ar(ch, sig * envGen);
	//Amp for audio rate modulation
	//Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;
)

SynthDef.new(\default, {
arg dur, attack=0.01, release=1.0,
t_gate=1, out, freq=442, cutoff=5500,
rq=1, pan=0.0, amp=0.5;
var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);
var sig = DPW3Tri.ar(freq: freq, mul: env);
sig = RLPF.ar(sig, cutoff.clip(20.0, 20000.0), rq.clip(0.0,1.0));
sig = Pan2.ar(sig, pan);
Out.ar(out, sig * amp);
}).add;


Pbind(\instrument, \sawd, \ch, 3, \dur, 0.125, \degree, Pwhite(0,10)).play

s.quit