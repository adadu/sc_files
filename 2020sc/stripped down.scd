s.quit;

(
s.quit;
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10,system:capture_11,system:capture_12,system:capture_13,system:capture_14,system:capture_15,system:capture_16,system:capture_17,system:capture_18,system:capture_19,system:capture_20");
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");

// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");
s.boot
)

(

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
)

// 828 slave: 0-11 audio outs, 12/13 spdif ?, 14-21 adat
// rme master: 22-30

~p = Pbind(\dur, Prand([1,2,2,1,1] * 0.125, inf), \degree, Prand((0..10)+10,inf,4), \pan,Pshuf((-99..99)*0.01,inf), \release,Pseq((1..2) * 0.5,inf),  \cutoff, Prand((50..15000),inf), \rq, Prand((0..30)*0.01,inf), \out,0).play;
~p.stop


(
SynthDef.new(\iter, {
	arg dur, freq=40, attack=0.005, release=0.3, t_gate=1, amp=0.5;
	var sig = 0;
	var env = EnvGen.kr(Env.perc(attack, release), t_gate, timeScale: dur, doneAction: 2);

	10.do{
		var temp = VarSaw.ar(
			freq * {Rand(0.99, 1.02)}!2,
			{Rand(0.0, 1.0)}!2,
			0.05!2, env
		);
		sig = sig + temp;
	};
	sig = sig * env;
	Out.ar(0, sig * amp);
}).add;
)

(
x = Pbind(
	\instrument, \iter,
	\degree, Pexprand(Pexprand(1, 6), 40, inf),
	\scale, Scale.minor,
	\dur, Pgeom(0.2, 1, inf),
	\rest, Pexprand(0.5, 0.2, inf),
	\rel, 0.7
).play;
)

Scale.directory;

x.free;
x.stop;

b.free
c.free


