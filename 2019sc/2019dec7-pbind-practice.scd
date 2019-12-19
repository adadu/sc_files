// JEA
// 2019dec7

(
//Define the number of inputs and outputs for the ES-8
o = Server.local.options;
// Fireface w/ ADAT OUTS activated
// s.options.numOutputBusChannels = 20;
// disable SPDIF outputs
//o.outputStreamsEnabled = "11111111110011111111";
// 0-9=ANALOG 0-9
// 10-11=SPDIF 1-2
// 12-19=ADAT OUT 1-8
//o.numOutputBusChannels = 20;
// 0-9=ANALOG 0-9
//o.numInputBusChannels = 10;
//SERVER and BUFFER
//increased buffers for samples - default * 1024
o.numBuffers = 1024 * 16;
//set memory size
//this is about 1 GB, may vary based on RAM
o.memSize=2.pow(20);
Server.internal.options.memSize =2.pow(20);
//load the ES-3 Device
//o.device = "ES-3";

//PROXYSPACE
//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 1;

//boot the server
s.boot;
)

s.quit;

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


(
~def1 = Pbind(\instrument, \default,
	\freq, Pshuf((230..580).mirror,inf,12),
	\dur, Pseq((10..50), inf) * Pseq((0.01..0.001),inf).asStream,
	\cutoff,Pseq((1400..1200),inf).asStream
);
)
~def1.play;
~def1.free(2);



// PpolyPar practice or experiments

// basic SynthDefs, EnvGate invents a gate arg which is necessary for release

(
SynthDef(\saw, { |freq = 400, freqlag = 0.0, amp = 0.1, amplag = 0.01|
    Out.ar(0, Saw.ar(Lag.kr(freq, freqlag), VarLag.kr(amp, amplag, warp: 1)) ! 2 * EnvGate());
}).add;

SynthDef(\pulse, { |freq = 400, freqlag = 0.0, amp = 0.1, amplag = 0.05|
    Out.ar(0, Pulse.ar(Lag.kr(freq, freqlag), mul: VarLag.kr(amp, amplag, warp: 1)) ! 2 * EnvGate());
}).add;

SynthDef(\sine, { |freq = 400, freqlag = 0.0, amp = 0.1, amplag = 0.05|
    Out.ar(0, SinOsc.ar(Lag.kr(freq, freqlag), 0, mul: VarLag.kr(amp, amplag, warp: 1)) ! 2 * EnvGate());
}).add;
)

// simple usage, each stream is setting the corresponding instrument

// per convention keys after \dur are the ones to be set
// note that you'd need \freq (the SynthDef arg)

(
t = PpolyPar([
	[
		\dur, 1/3,
        \amp, Pwrand([0, 0.07], [3,5]/8, inf),
		\midinote, Pseq((87..95), inf),
	],
	[
        \dur, 1/6,
        \amp, Pwrand([0, 0.07], [1, 7]/8, inf),
        \midinote, Pshuf((30..68), inf),

    ],
	[
        \dur, Prand([1, 1, 2]/4, inf),
        \amp, Pwrand([0, 0.07, 0.1], [0.3, 0.3, 0.4], inf),
        /*\freqlag, 0.01,
        \amplag, Prand([0.2, 0.4], inf),*/
        \midinote, Pbrown(70, 90, 5),
    ]],
[\default, \default, \default]
).play;
)

t.stop;

(
// Function to create midinote patterns in different ranges

r = { |add = 0| Pstutter(5, Pwhite(60, 70) + add) };

// each setting stream affects two synths: those of corresponding indices of \synths,
// but only with one value: the Integer polled from the Pstutter stream

t = PpolyPar([[
        \synths, [0, 1],
        \dur, 1/6,
        \midinote, r.(),
        \amp, 0.04
    ],[
        \synths, [0, 2],
        \dur, 1/4,
        \midinote, r.(10),
        \amp, 0.03
    ],[
        \synths, [1, 2],
        \dur, 1/3,
        \midinote, r.(20),
        \amp, 0.05
    ]],
    [\saw, \pulse, \sine]
).play
)

t.stop;


// SynthDefs from Ex. 1a

(
// Similar to Ex. 1b, but the midinote pattern will cause the stream to generate arrays of two elements,
// they will be distributed to the indicated synths

r = { |add = 0, int = 7| Pstutter(5, Pwhite(60, 65) + [0, int] + add) };

// each setting streams affects two synths: those of corresponding indices of \synths

p = PpolyPar([[
        \synths, [0, 1],
        \dur, 1/6,
        \midinote, r.(0, 5),
        \amp, 0.04
    ],[
        \synths, [0, 2],
        \dur, 1/4,
        \midinote, r.(10, 6),
        \amp, 0.03
    ],[
        \synths, [1, 2],
        \dur, 1/3,
        \midinote, r.(20, 7),
        \amp, 0.05
    ]],
    [\saw, \pulse, \sine]
).play
)

p.stop;


(
// With t_gate a percussive envelope will be triggered,
// so articulation can be achieved within a monophonic stream.
// This is similar to Pbind, though only if envelopes are shorter than entry time differences.

SynthDef(\test, { |out = 0, freq = 440, att = 0.01, rel = 0.1, amp = 0.1, t_gate = 1|
    var sig = Saw.ar(freq, amp), delayedSig;
    sig = sig!2 * EnvGen.ar(Env.perc(att, rel), t_gate);
    // add some spatial variance by LFO on delaytime
    delayedSig = DelayL.ar(sig, delaytime: { LFDNoise3.kr(0.5).range(0.005, 0.02) } ! 2);
    Out.ar(out, delayedSig * EnvGate())
}).add;

// Effect synthdefs with in and out bus,
// both get an EnvGate which introduces a gate arg for proper release,
// one could also add a gate arg and an EnvGen using it.

// wet/dry-relation is fixed, considering the example with fx chain a bypass arg is introduced

SynthDef(\echo, { |out = 0, in, maxdtime = 0.2, dtime = 0.2, decay = 3, amp = 0.5, bypass = 0|
    var sig, insig;
    insig = In.ar(in, 2);
    sig = CombL.ar(insig, maxdtime, dtime, decay, amp, add: insig) * EnvGate();
    Out.ar(out, bypass * insig + ((1 - bypass) * sig));
}).add;


SynthDef(\wah, { |out = 0, in, freqLo = 200, freqHi = 5000, modFreq = 10, amp = 0.7, bypass = 0|
    var sig, insig;
    insig = In.ar(in, 2);
    sig = RLPF.ar(
        insig,
        LinExp.kr(LFDNoise1.kr(modFreq), -1, 1, freqLo, freqHi),
        0.1,
        amp,
        insig * 0.3
        ).softclip * 0.8 * EnvGate();
    Out.ar(out, bypass * insig + ((1 - bypass) * sig));
}).add;
)


// Whereas node order is done by PpolyPar, bus handling is the user's responsibility,
// it looks more flexible to me to define buses separately.

// one fx

b = Bus.audio(s, 2);

(
p = PpolyPar([[
        \dur, 0.5,
        \amp, 0.2,
        \out, b,
        \t_gate, 1,
        \midinote, Pwhite(50, 100)
    ],[
        // dur = inf causes just a running fx synth, none of its args is set by a stream
        \dur, inf,
        \in, b,
        \dtime, 0.1,
        \decay, 3
    ]],
    [\test, \echo]
).play
)

p.stop;

b.free;


// SynthDefs from Ex. 2a
​
(
b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
)
​
​
// still none of the effects is set by a stream
​
(
p = PpolyPar([[
        // values before \dur are not sent to server, so do this work here:
        // echo (out b) is coupled with short release time
        // wah (out c) is coupled with longer release time
        \data, Prand([[b, 0.1], [c, 0.5]], inf),
        \dur, Prand([1, 1, 2]/5, inf),
        \amp, 0.3,
        // data dispatch from above, these values will be sent
        \rel, Pkey(\data).collect(_[1]),
        \out, Pkey(\data).collect(_[0]),
        \t_gate, 1,
        \midinote, Pwhite(50, 100)
    ],[
        \dur, inf,
        \in, b,
        \out, 0,
        \dtime, 0.1,
        \decay, 3
    ],[
        \dur, inf,
        \in, c,
        \amp, 0.3
    ]],
    [\test, \echo, \wah]
).play;
)
​
p.stop;
​
(
b.free;
c.free;
)



// SynthDefs from Ex. 2a

(
b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
)


// effects set by streams

(
p = PpolyPar([[
        // values before \dur are not sent to server, so do this work here:
        // echo (out b) is coupled with short release time
        // wah (out c) is coupled with longer release time
        \data, Prand([[b, 0.1], [c, 0.5]], inf),
        // will get "bars" of length 4/5
        \dur, Pn(Pshuf([1, 1, 2]/5)),
        \amp, 0.3,
        // data dispatch from above, these values will be sent
        \rel, Pkey(\data).collect(_[1]),
        \out, Pkey(\data).collect(_[0]),
        \t_gate, 1,
        \midinote, Pwhite(50, 100)
    ],[
        \dur, 4/5,
        \in, b,
        // change delaytime per "bar", random add avoids repeating echo frequencies
        \dtime, Pshuf([1, 2, 4]/40, inf) + (Pwhite(-0.5, 0.5)/40),
        \decay, 3
    ],[
        \dur, 4/5,
        \in, c,
        // change modFreq per "bar"
        \modFreq, Pshuf((1..20), inf),
        \amp, 0.3
    ]],
    [\test, \echo, \wah]
).play
)

p.stop;

(
b.free;
c.free;
)



// SynthDefs from Ex. 2a
​
(
b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
)
​
​
// Now we have more setting streams than synths,
// so we need to define which synth is to be set by which stream,
// this done via the \synths key, which must be contained in every collection of pairs.
​
(
p = PpolyPar([[
        \synths, 0,
        // values before \dur are not sent to server, so do this work here:
        // echo (out b) is coupled with short release time
        // wah (out c) is coupled with longer release time
        \data, Prand([[b, 0.1], [c, 0.5]], inf),
        // will get "bars" of length 4/5
        \dur, Pn(Pshuf([1, 1, 2]/5)),
        \amp, 0.3,
        // data dispatch from above, these values will be sent
        \rel, Pkey(\data).collect(_[1]),
        \out, Pkey(\data).collect(_[0]),
        \t_gate, 1
    ],[
        // stream setting frequency
        \synths, 0,
        \dur, 1/20,
        \midinote, Pshuf((45..90), inf)
    ],[
        \synths, 1,
        \dur, 4/5,
        \in, b,
        // change delaytime per "bar", random add avoids repeating echo frequencies
        \dtime, Pshuf([1, 2, 4]/40, inf) + (Pwhite(-0.5, 0.5)/40),
        \decay, 3
    ],[
        \synths, 2,
        \dur, 4/5,
        \in, c,
        // change modFreq per "bar"
        \modFreq, Pshuf((1..20), inf),
        \amp, 0.3
    ]],
    [\test, \echo, \wah]
).play
)
​
p.stop;
​
(
b.free;
c.free;
)


// SynthDefs from Ex. 2a

(
b = Bus.audio(s, 2);
c = Bus.audio(s, 2);
)

// Here effects are chained in order - see buses passed to \in and \out
// Again more setting streams than synths, so the \synths key is needed.

(
p = PpolyPar([[
        \synths, 0, // source synth
        // will get "bars" of length 4/5
        \dur, Pn(Pshuf([1, 1, 2]/5)),
        \amp, 0.3,
        \rel, 0.2,
        \out, b,
        \t_gate, 1
    ],[
        // freq rhythm might differ from envelope rhythm (stream 0)
        \synths, 0,
        \dur, Pn(Pshuf([1, 1, 2]/5)),
        \midinote, Pshuf((45..90), inf)
    ],[
        \synths, 1, // echo
        \dur, 4/5,
        \in, b, // gets from source and sends to wah
        \out, c,
        // change delaytime per "bar", random add avoids repeating echo frequencies
        \dtime, Pshuf([1, 2, 4]/20, inf) + (Pwhite(-0.5, 0.5)/20),
        \decay, 3
    ],[
        \synths, 2, // wah
        \dur, 4/5,
        \in, c, // gets from echo, sends to out 0 by default
        // change modFreq per "bar"
        \modFreq, Pshuf((1..20), inf),
        \amp, 0.3
    ],[
        // this stream determines effects in action by setting bypass args of both fx synths
        \synths, [1, 2],
        \dur, 1/5,
        // alternate bypassing of wah synth
        \bypass, Pseq([[0, 0], [0, 1]], inf)
    ]],
    [\test, \echo, \wah]
).play
)

p.stop;

(
b.free;
c.free;
)




{ Pan2.ar(Mix(LFSaw.ar({rrand(40,8000)}!50,mul:0.01)),{rrand(-0.999,0.999)}!50,level:0.5)}.play;

// Synthdefs
(
// Modular synth
~mod1 = Pmono(\default,
	\ch,12,\ampCh,16, // rme fireface 800 adat channels
	\trig, 1,
	\note, Pshuf((30..80).mirror,inf,12),
	\dur, Prand((10..50), inf) * Phprand(0.1,0.001,inf).asStream,
	\amp, Phprand(0.111,0.99,inf),
	\atk, Phprand(0.001,0.699,inf),
	\sus, Phprand(0.151,0.315,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, Phprand(1,8,inf),
	\port,0.3,
);

// Modular synth 2
~mod2 = Pmono(\dcev,
	\ch,13,\ampCh,17, // rme fireface 800 adat channels
	\trig, 1,
	\note, Pshuf((30..80).mirror,inf,12),
	\dur, Prand((10..50), inf) * Phprand(0.1,0.001,inf).asStream,
	\amp, Phprand(0.111,0.99,inf),
	\atk, Phprand(0.001,0.699,inf),
	\sus, Phprand(0.151,0.315,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, Phprand(1,8,inf),
	\port,0.3,
);


// Modular synth 3
~mod3 = Pmono(\dcev,
	\ch,14,\ampCh,18, // rme fireface 800 adat channels
	\trig, 1,
	\note, Prand((0..11.99).mirror,inf,3),
	\dur, Phprand(0.0311,8.98,inf),
	\amp,Phprand(0.011,0.99,inf),
	\atk, Phprand(0.001,0.515,inf),
	\sus, Phprand(0.001,0.515,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave,Phprand(1,5,inf),
	\port,0.1,
);

~mod4 = Pmono(\dcev,
	\ch,15,\ampCh,19, // rme fireface 800 adat channels
	\trig, 1,
	\note, Prand((0..11.99).mirror,inf,3),
	\dur, Phprand(0.0311,8.98,inf),
	\amp, Phprand(0.011,0.99, inf),
	\atk, Phprand(0.001,0.515,inf),
	\sus, Phprand(0.001,0.515,inf),
	\rel, Phprand(0.001,0.515,inf),
	\calibration, 0.0967, //0.0074, 0.10255,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave,Phprand(1,5,inf),
	\port,0.1,
);
)

~mod1.play;
~mod2.play;
~mod3.play;
~mod4.play;

~mod1.free(2);
~mod2.free(2);
~mod3.free(4);
~mod4.free(4);