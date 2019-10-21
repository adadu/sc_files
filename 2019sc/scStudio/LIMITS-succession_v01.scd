// All clear and quit
p.clear;
s.quit;

// Setup audio io, boot & add proxyspace
(
//SERVER and BUFFER
//increased buffers for samples
s.options.numBuffers = 1024 * 16;
//this is about 1GB, may vary based on RAM
s.options.memSize=2.pow(21);

//boot server
s.boot;

///////////////// RME Fireface 800 (which has ADAT out for ES-3)
s.options.device="Fireface 800 (3EC)";
///////////////// Fireface w/ 8 ANALOG INS activated
s.options.numInputBusChannels = 8;
s.options.outputStreamsEnabled = "11111111";
///////////////// Fireface w/ ADAT OUTS activated
///////////////// 0-9=ANALOG 1-10
///////////////// 10-11=SPDIF 1-2(11-12)
///////////////// 12-19=ADAT OUT 1-8(13-20)
s.options.numOutputBusChannels = 19;
//////////////disable SPDIF outputs
s.options.outputStreamsEnabled = "1111111111";//0011111111";

//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;
)


// Korg nanoKontrol2
/*
S1 freeze, S2 scamble, S3 fftNoise, S4 enhance, s5 conformer, S6 bin, S7 mag
M1 lorises, M2, hirises (sin ch)
R1 stop mod1 & mod2, R2 nil, R3 p1, R4 p2, R5 p3, R6 p4, R7 p5, R8 p6
*/


////////// SYNTHDEFS /////////////
// 8 synths will appear for offsets
(

//microkontrol
k = MKtl(\nk2, "*trol2");

// sc virtual osc
SynthDef(\sinOut, { | freq=440, t_trig, ch=1, atk=0, sus=0, rel=3, amp=0.4, dur=1, /*octave, stepsPerOctave, */port=0, ffreq=2000, res=0.1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	var sig = /*SawDPW*/LFSaw.ar(Lag.kr(freq, port), 0, 1, 0);
	sig = MoogVCF.ar(sig, ffreq, res);
	Out.ar(ch, sig * envGen);
}).add;


// sc virtual osc
SynthDef(\noiseOut, { | freq = 440, t_trig, ch = nil, atk=0, sus=0, rel=3, amp = 0.5, /*ampCh = nil, */dur = 1, octave = 0, stepsPerOctave = 12 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	var sig = PinkNoise.ar(freq,0);
	freq = freq + (octave * stepsPerOctave);
	freq = freq / stepsPerOctave;
	Out.ar(ch, sig * envGen);
	//Amp for audio rate modulation
	//Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
}).add;

/*
vplaym: enveloped mono buffer player
For mono buffers only

Arguments:
out = Channel out
buf = Buffer index
rate = Speed of playback
amp = volume
pan = pan (stereo)
atk = attack
rel = release
pos = position to start playback from 0 to 1
*/
SynthDef(\vplaym,
	{arg out = 0, buf = 0, rate = 1, amp = 0.5, pan = 0, atk=0.01, rel=1, pos=0;
		var sig, env;
		sig = Pan2.ar(PlayBuf.ar(1,buf,BufRateScale.ir(buf) * rate,1,BufDur.kr(buf)*pos*44100,doneAction:2),pan);
		env = EnvGen.ar(Env.linen(0.0,rel,0.0,1));
		sig = sig * env;
		sig = sig * amp;
		Out.ar(out,sig);
}).add;

// fft freeze
~freeze = SynthDef(\fftFreeze, {
    arg out = 0;
	var in, chain;
	in = SoundIn.ar(0);
	chain = FFT({ LocalBuf(1024) }, in);
	chain = PV_MagFreeze(chain, LFNoise0.kr([LFNoise0.kr(2).exprange(2,10), LFNoise0.kr(2).exprange(2,10)]));
	Out.ar(out, Pan2.ar(IFFT(chain), 0, 0.3));// inverse FFT
}).add;

~freeze.free;

~scramble = SynthDef(\scrambleMags, { arg out = 0, phaseMul = LFNoise2.kr(Pexprand(1.1, 200, inf).asStream.nextN(50));
var in, chain, inputAmp, threshhold, gate;
in = SoundIn.ar(0);
b = Buffer.alloc(s, 44100 * 4.0, 1);
inputAmp = Amplitude.kr(in);
threshhold = 0.01;	// noise gating threshold
gate = Lag.kr(inputAmp > threshhold, 0.01);
chain = FFT(LocalBuf(1024), in);
phaseMul = LFNoise2.kr(Pexprand(40.1, 50, inf).asStream,1);
chain = chain.pvcalc(b.numFrames, {|mag, phase, index|
		[mag.scramble, (phase * phaseMul)];
}, frombin: 0, tobin: 128, zeroothers: 0);
	Out.ar(out, Pan2.ar(IFFT(chain), SinOsc.kr(LFNoise0.kr(3.39)), gate * 1.8));
		//Pan2.ar(IFFT(chain),Dust2.kr(2), 1.0) * gate*1.2);
}).add;

~scramble.free;

// fft noise
~fftNoise = SynthDef(\fftNoise, {
	arg out = 0;
	var in, chain;
	in = SoundIn.ar(0);
	b = Buffer.alloc(s, 44100 * 4.0, 1);
	chain = FFT(LocalBuf(512), in);
	chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
		[mag, LFNoise0.kr.range(0, 3000.14)];
	}, frombin: 0, tobin: 250, zeroothers: 1);
	Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;

~fftNoise.free;

// fft spectral "enhance"
~enhance = SynthDef(\specEnhance, { arg numPart = 4, ratio = 1.91, out = 0;
    var in, chain;
	in = SoundIn.ar(0);
    chain = FFT({LocalBuf(2048, 1)}, in);
    chain = PV_SpectralEnhance(chain, numPart, ratio, 0.99);
	Out.ar(out, Pan2.ar(0.5 * IFFT(chain), 0)); // inverse FFT
}).add;

~enhance.free;

// fft conformal map
~conformer = SynthDef(\conformer, { arg out = 0;
	var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(2048), in);
	chain = PV_ConformalMap(chain,
	LFNoise0.kr([0.5,3.5].exprand(5,-0.9,0.5)),
	LFNoise0.kr([0.1,3.9].exprand(5,-1.5,1.8)));
    Out.ar(out, Pan2.ar(IFFT(chain), 0, 0.3));
}).add;

~conformer.free;

// fft bin stretch
~bin = SynthDef(\binStretch, { arg out = 0, mod = 0.892327;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(512), in);
	mod = LFSaw.kr(LFNoise0.kr([11.5,13.5])).range(0.25,1.3, \expontential);
	chain = PV_BinShift(chain, mod,1);
		//MouseX.kr(0.25, 2, \exponential), 1);
	Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;

~bin.free;

// fft mag stretch
~mag = SynthDef(\magStretch, { arg out = 0, mod = 0.892327;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(2048), in);
    chain = PV_BinShift(chain, mod); //MouseX.kr(0.25, 2, \exponential)
	Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;

~mag.free;

// buttons for synthdefs
k.elAt(\bt, \S, \1).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~freeze;
		~freeze.set(\out, 0);
	}{   ~freeze.free(3);}
});

k.elAt(\bt, \S, \2).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~scramble;
		~scramble.set(\out, 0);
	}{   ~scramble.free(3);}
});

k.elAt(\bt, \S, \3).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~fftNoise;
		~fftNoise.set(\out, 0);
	}{   ~fftNoise.free(3);}
});

k.elAt(\bt, \S, \4).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~enhance;
		~enhance.set(\out, 0);
	}{   ~enhance.free(3);}
});

k.elAt(\bt, \S, \5).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~conformer;
		~conformer.set(\out, 0);
	}{   ~conformer.free(3);}
});

k.elAt(\bt, \S, \6).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~bin;
		~bin.set(\out, 0);
	}{   ~bin.free(3);}
});

k.elAt(\bt, \S, \7).action_({  |elem|
    if(elem.value > 0)
	{	~vox = ~mag;
		~mag.set(\out, 0);
	}{   ~mag.free(3);}
});
)

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®

(
// manual stop, but not offsets
k.elAt(\tr, \stop).action_({  |elem|
    if(elem.value > 0)
	{
~freeze.free(2);
~scramble.free(2);
~fftNoise.free(2);
~enhance.free(2);
~conformer.free(2);
~bin.free(2);
~mag.free(2);
~vox.free;
~mod1.free;
~mod2.free;
~mod3.free;
~mod4.free;
~mod5.free;
~vplaym.free;
	} { }
});
)

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®


// Modular music interlude w buttons
(
// 01
k.elAt(\bt, \R, \3).action_({  |elem|
    if(elem.value > 0)
	{
	~mod1 = Pmono(\sinOut,
	\ch,1,
	\trig, 1,
	\note, Pseq([30,30].mirror1,inf).asStream,
	\dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	\amp, 0.5,
	\port, 0,
);

	~mod1.set(\note, Pseq([30,30],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, 0.5, \port, 0, \octave, 0, \atk, 0.001,\sus, 0.05, \rel, 0.4).quant(1);
	}{   }
});

// 02
k.elAt(\bt, \R, \4).action_({  |elem|
    if(elem.value > 0)
	{
		~mod1.set(\note, Pseq([30,33,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((30..99) *0.01, inf).asStream, \port, nil, \octave, 0).quant(1);
	} { }
});

// 03
k.elAt(\bt, \R, \5).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((30..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
	} { }
});

// 04
k.elAt(\bt, \R, \6).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,45,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((60..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
	} { }
});

// 05
k.elAt(\bt, \R, \7).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,45,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
(
~mod2 =	Pmono(\sinOut,
	\ch,2,
	\trig, 1,
	\note, Pseq([30,30],inf),
	\dur, 0.1,
	\amp, 0.5,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	//\calibration, 0.09773, //0.0967
	//\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, 0,
	\port, 0,
	);

~mod2.set(\note, Pseq([30,33,45,25],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0, \atk, 0.001,\sus, 0.05, \rel, 0.4).quant(1);
		)
	} { }
});

// 06
k.elAt(\bt, \R, \8).action_({  |elem|
    if(elem.value > 0)
	{
~mod1.set(\note, Pseq([30,33,45,25,47],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
~mod2.set(\note, Pseq([30,33,45,25,47],inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/4, \amp, Pexprand(0.7,0.7,inf).asStream, \amp, Pseq((70..99) *0.01, inf).asStream, \port, Pseq([0,1,3],inf).asStream, \octave, 0).quant(1);
	} { }
});

k.elAt(\bt, \R, \1).action_({  |elem|
    if(elem.value > 0)
	{
		// turn off mod1, mod2
		~mod1.set(\amp, Pseq((70..0) * 0.001,1).asStream, \dur, 0.001).quant(1);
		~mod2.set(\amp, Pseq((70..0) * 0.001,1).asStream, \dur, 0.001).quant(1);
} { }
});
)

//experiment w psrp
~mod1.set(\note, (Psrp(Pseq([30,33,45,25],inf),0.3).linlin(-1.0,1.0,25,45)).asStream, \ffreq, 2450, \res, 0.3);
~mod2.set(\ffreq, 1200, \res, 0.5, \rel, 0.4, \octave, Pseq((0..3),inf).asStream);

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®




// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®

(
// Modular 2 osc slow morphing pitch and env w buttons
k.elAt(\bt, \M, \1).action_({  |elem|
    if(elem.value > 0)
	{
~mod1 = Pmono(\dcev,
	\ch,6,
	\ampCh,2,
	\trig, 1,
	\note, Pseq((23..47), inf).asStream,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf).asStream,
	\amp, Pseq((15..45).mirror2, inf).asStream * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf).asStream * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf).asStream *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf).asStream *0.1,
	\calibration, 0.0967,
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, Pseq((2..2),inf).asStream,
	\port, Pkey(\dur) *2,
);

~mod2 = Pmono(\dcev,
	\ch,7,
	\ampCh,3,
	\trig, 1,
	\note, Pseq((23..47), inf).asStream,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf).asStream,
	\amp, Pseq((15..45).mirror2, inf).asStream * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf).asStream * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf).asStream *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf).asStream *0.1,
	\calibration, 0.09773, //0.0967
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, Pseq((2..2),inf).asStream,
	\port, Pkey(\dur).asStream *2,
);

		~mod1.set(\note, Pseq((23..47), inf).asStream, \dur, Pexprand(5.33, 9.79,inf).asStream * 0.5, \amp, Pseq((15..45).mirror2, inf).asStream * 0.01,\octave, Pseq((1..2),inf).asStream, \atk, Prand([1,5,9],inf).asStream * 0.1, \sus, Prand([1,10,100],inf).asStream *0.01, \rel, Prand([1,5,9],inf).asStream *0.1, \port, nil).quant(1);
		~mod2.set(\note, Pseq((23..47), inf).asStream, \dur, Pexprand(5.33, 9.79,inf).asStream * 0.5, \amp, Pseq((15..45).mirror2, inf).asStream * 0.01,\octave, Pseq((1..2),inf).asStream, \atk, Prand([1,5,9],inf).asStream * 0.1, \sus, Prand([1,10,100],inf).asStream *0.01, \rel, Prand([1,5,9],inf).asStream *0.1, \port, nil).quant(1);
	} { }
});

k.elAt(\bt, \M, \2).action_({  |elem|
    if(elem.value > 0)
	{
		~mod1.set(\note, Pseq((23..47), inf).asStream, \dur, Pexprand(5.33, 9.79,inf).asStream * 0.5, \amp, Pseq((15..25).mirror2, inf).asStream * 0.02, \atk, Prand([1,5,9],inf).asStream * 0.1, \sus, Prand([1,10,100],inf).asStream *0.01, \rel, Prand([1,5,9],inf).asStream *0.1,\octave, Pseq((6..7),inf).asStream,
	\port, nil).quant(1);
		~mod2.set(\note, Pseq((23..47), inf).asStream, \dur, Pexprand(5.33, 9.79,inf).asStream * 0.5, \amp, Pseq((15..25).mirror2, inf).asStream * 0.02, \atk, Prand([1,5,9],inf).asStream * 0.1, \sus, Prand([1,10,100],inf).asStream *0.01, \rel, Prand([1,5,9],inf).asStream *0.1,\octave, Pseq((6..7),inf).asStream,
	\port, nil).quant(1);
	} { }
});

k.elAt(\bt, \M, \3).action_({  |elem|
    if(elem.value > 0)
	{
		~mod1.set(\note, Pshuf((23..47), inf).asStream, \dur, Pexprand(2.33, 6.79,inf).asStream * 0.01, \amp, Prand((15..79).mirror2, inf).asStream * 0.01,\octave, Pseq((4..8),inf).asStream, \atk, Prand([1,5,9],inf).asStream * 0.0001, \sus, Prand([1,10,100],inf).asStream *0.003, \rel, Prand([1,5,9],inf).asStream *0.001, \port, nil).quant(1);
		~mod2.set(\note, Pshuf((23..47), inf).asStream, \dur, Pexprand(2.33, 6.79,inf).asStream * 0.01, \amp, Prand((15..79).mirror2, inf).asStream * 0.01,\octave, Pseq((4..8),inf).asStream, \atk, Prand([1,5,9],inf).asStream * 0.0001, \sus, Prand([1,10,100],inf).asStream *0.003, \rel, Prand([1,5,9],inf).asStream *0.001,\port, nil).quant(1);
	} { }
});

k.elAt(\bt, \M, \4).action_({  |elem|
    if(elem.value > 0)
	{
		~mod1.set(\note, Prand([1,10]++(23..47), inf).asStream, \dur, Pexprand(2.33, 6.79,inf).asStream * 0.01, \amp, Prand((15..89).mirror2, inf).asStream * 0.01,\octave, Pseq([0]++(4..8),inf).asStream, \atk, Prand([1,5,9],inf).asStream * 0.0001, \sus, Prand([1,10,100],inf).asStream *0.003, \rel, Prand([1,5,9],inf).asStream *0.001, \port, Pexprand(2.33, 6.79,inf).asStream * 0.01 * 0.01).quant(1);
		~mod2.set(\note, Prand([1,10]++(23..47), inf).asStream, \dur, Pexprand(2.33, 6.79,inf).asStream * 0.01, \amp, Prand((15..89).mirror2, inf).asStream * 0.01,\octave, Pseq([-10]++(4..8),inf).asStream, \atk, Prand([1,5,9],inf).asStream * 0.0001, \sus, Prand([1,10,100],inf).asStream *0.003, \rel, Prand([1,5,9],inf).asStream *0.001, \port, Pexprand(2.33, 6.79,inf).asStream * 0.01 * 0.01).quant(1);
	} { }
});
)

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®

// zerosc SUBotnick part
(
k.elAt(\bt, \M, \5).action_({  |elem|
    if(elem.value > 0)
	{
~mod3 =	Pmono(\dcev,
			\ch,[1,2],

	\trig, 1,
	\note, Pseq([30,30],inf),
	\dur, 0.1,
	\amp, 0.05,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	\calibration, 0.09773, //0.0967
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, 0,
	\port, 0,
	);

		~mod3.set(\note, Pshuf((23..37), inf, 5).asStream, \dur, Pbjorklund2(Prand((3..4),inf),16,inf,0).asStream/16, /*Pexprand(5.33, 9.79,inf).asStream * 0.5,*/ \amp, Pexprand(0.85,0.99,inf).asStream,/*Pseq((45..95).mirror2, inf).asStream*0.01,*/\octave, Pseq((0..3),inf).asStream, \atk, Prand((1..5),inf).asStream * 0.001, \sus, Prand([1,10,100],inf).asStream *0.001, \rel, Prand((1..5),inf).asStream *0.01, \port, 0).quant(1);

~mod4 =	Pmono(\dcev,
	\ch, nil,
	\ampCh,9,
	\trig, 1,
	\dur, 1,
	\note, 1,
	\sus, 0.05,
	\amp, Prand((-699..699) * 0.001,inf).asStream * Pseq((1..-1),inf).asStream,
	\atk, 0.3
	);

	} {~mod3.free; ~mod4.free;}
});
)

// ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®  ƒ∆§†∑®

// noise bursts
(
k.elAt(\bt, \M, \6).action_({  |elem|
    if(elem.value > 0)
	{
~mod5 =	Pmono(\noiseOut,
	\ch,5,
	\trig, 1,
	\note, Pseq([30,42],inf),
	\dur, 0.1,
	\amp, 0.5,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	//\calibration, 0.09773, //0.0967
	//\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, 0,
	\port, 0,
	);
	~mod5.set(
		\note, Pseq([30,42],inf).asStream,
		\dur, Pexprand(1.11,5.66,inf).asStream,
		\amp, Pexprand(0.001,0.011,inf).asStream,//0.5,
		\atk, 0.05,
		\sus, 0.5,
		\rel, Pexprand(1.4,2,inf).asStream,
		\octave, Prand((0..0),inf).asStream
		);
			} {~mod5.free;}
});
)


////////// DEV SECTION //////////

// zerosc SUBotnick part
(
k.elAt(\bt, \M, \5).action_({  |elem|
    if(elem.value > 0)
	{
~mod3 =	Pmono(\dcev,
	\ch,8,
	\ampCh,4,
	\trig, 1,
	\note, Pseq([30,30],inf),
	\dur, 0.1,
	\amp, 0.5,
	\atk, 0.001,
	\sus, 0.05,
	\rel, 0.4,
	\calibration, 0.09773, //0.0967
	\midiTune, -24,
	\stepsPerOctave, 12,
	\octave, 0,
	\port, 0,
	);
	} {~mod3.free;}
});
)

(
~mod3.set(\note, Pshuf((23..37), inf, 5).asStream, \dur, Pbjorklund2(Prand((3..4),inf),16,inf,0).asStream/16, /*Pexprand(5.33, 9.79,inf).asStream * 0.5,*/ \amp, Pexprand(0.85,0.99,inf).asStream,/*Pseq((45..95).mirror2, inf).asStream*0.01,*/\octave, Pseq((0..3),inf).asStream, \atk, Prand((1..5),inf).asStream * 0.001, \sus, Prand([1,10,100],inf).asStream *0.001, \rel, Prand((1..5),inf).asStream *0.01, \port, 0).quant(1);
)

(
k.elAt(\bt, \M, \5).action_({  |elem|
    if(elem.value > 0)
	{
~mod3.free;
	} {}
});
)

/////////// MODALITY ////////////

//microkontrol gui
k.gui;

// make sure there are no current assigned actions
k.resetActions;

// get its normalized value
k.elAt(\sl, 0).value;
// or its device-side value (here, midi)
k.elAt(\sl, \1).deviceValue;
// scale value
k.elAt(\sl, \1).value.linexp(0, 1, 200, 5000);

//custom nk2
k.elAt(\bt, \S, \1).value;
k.elAt(\bt,1,1).deviceValue;


////// UTILITIES & USEFUL FUNCTIONS ////////

//dump all nodes to post window
s.queryAllNodes(queryControls);
// kill node
s.sendMsg(\n_free,1239);
// check cpu usage
s.avgCPU;

// view scale, tuning and degrees
Scale.directory;
Tuning.directory;
Scale.whole.degrees;

// quit
(
p.free;
s.quit;
s.freeAll;
)
