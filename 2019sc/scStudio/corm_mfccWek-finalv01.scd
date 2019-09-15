s.quit;
p.clear

// Setup audio io, boot & add proxyspace
(
//SERVER and BUFFER
//increased buffers for samples
s.options.numBuffers = 1024 * 16;
//this is about 1GB, may vary based on RAM
s.options.memSize=2.pow(20);
2.pow(20).postln;
//boot server
s.boot;

// CORM macOS aggregate Audient iD4 + USBStreamer
s.options.device = "CORM";
s.options.outputStreamsEnabled = "1111111111";
s.options.numInputBusChannels = 2;
s.options.numOutputBusChannels = 10;
"INs".postln;
s.options.numInputBusChannels.postln;
"OUTs".postln;
s.options.numOutputBusChannels.postln;

//start proxyspace
p=ProxySpace.push(s);
//start tempo clock
p.makeTempoClock;
//give proxyspace a tempo
p.clock.tempo = 2;
)

s.quit

// OSC Communication
(
~mfcc = {
    var in, fft, array;
	in = SoundIn.ar(0);
    fft = FFT(LocalBuf(1024), in);
    array = MFCC.kr(fft);
    Out.kr(0, array); // control bus out
    //Out.ar(0, Pan2.ar(in)); // audio bus out
};

c = Bus(\control, 0, 13); // create control bus
d = SoundIn.ar(0);
n.free; // free old reciever if it already exists
n = NetAddr("127.0.0.1", 57120); // create the NetAddr, 57120

~mfccDisplay = {
	var ms, sender;
	// Continuous graphical display of MFCC values; free routine before closing window
	w = Window.new("13 MFCC coefficients", Rect(800, 500, 300, 300));
	ms = MultiSliderView.new(w, Rect(10, 10, 260, 280));
	ms.value_(Array.fill(13, 0.0));
	ms.valueThumbSize_(20.0);
	ms.indexThumbSize_(20.0);
	ms.gap_(0);
	w.front;
	//set up the sender
	sender = NetAddr.new("127.0.0.1", 6448);
	// function to run display and send values to wekinator
	r = {
		inf.do {
			c.getn(13, { |val| { ms.value_(val * 0.9) }.defer });
			t = c.getnSynchronous(13);
			sender.sendMsg("/wek/inputs", *t); //send bus value
			0.01.wait; //25 frames per second 0.04
		}
	}.fork
};
)

// free mfcc, busses, and close windows
(
~mfcc.free;
r.stop;
t.free;
c.free;
d.free;
w.close;
n.free;
~mfccDisplay.free;
)

////////// SYNTHDEFS /////////////

// modular dc
(

~dc = SynthDef(\dcev, { | note=60, octave = 0, stepsPerOctave = 12, t_trig, atk=0, sus=0, rel=3, ch = nil, port = 0, calibration = 0.1, midiTune = 0, amp = 1, ampCh = nil, dur = 1 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	note = note;
	note = note + (octave * stepsPerOctave) + midiTune;
	note = (note / stepsPerOctave) * calibration;
	Out.ar(ch, K2A.ar(Lag.kr(note, port)));
	Out.ar(ampCh, K2A.ar(Lag.kr(envGen)));
}).add;

// sc virtual osc
~sin = SynthDef(\sinOut, { | freq = 440, t_trig, ch = nil, atk=0, sus=0, rel=3, amp = 0.5, ampCh = nil, dur = 1, octave = 0, stepsPerOctave = 12 |
	var level = amp;
	var env = Env([0, 1, 1, 0], [atk, sus, rel], [\lin, \lin, \lin]);
	var envGen = EnvGen.kr(env, t_trig, level, timeScale: dur);
	var sig = SinOsc.ar(freq, 0, 1, 0);
	freq = freq + (octave * stepsPerOctave);
	freq = freq / stepsPerOctave;
	Out.ar(ch, sig * envGen);
	//Amp for audio rate modulation
	//Out.ar(ampCh, K2A.ar(Lag.kr(amp * envGen)));
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

// fft spectral "enhance"
~enhance = SynthDef(\specEnhance, { arg numPart = 4, ratio = 1.91, out = 0;
    var in, chain;
	in = SoundIn.ar(0);
    chain = FFT({LocalBuf(2048, 1)}, in);
    chain = PV_SpectralEnhance(chain, numPart, ratio, 0.99);
	Out.ar(out, Pan2.ar(0.5 * IFFT(chain), 0)); // inverse FFT
}).add;

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

// fft bin stretch
~bin = SynthDef(\binStretch, { arg out = 0, mod = 0.892327;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(512), in);
	mod = SinOsc.kr([960.5,980.5].exprand(3,-1.5,5.8));
	chain = PV_BinShift(chain, mod,1);
		//MouseX.kr(0.25, 2, \exponential), 1);
	Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;

// fft mag stretch
~mag = SynthDef(\magStretch, { arg out = 0, mod = 0.892327;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(2048), in);
    chain = PV_BinShift(chain, mod); //MouseX.kr(0.25, 2, \exponential)
	Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;

// free synths so they are off upon start
~dc.free;
~sin.free;
~scramble.free;
~freeze.free;
~fftNoise.free;
~enhance.free;
~conformer.free;
~bin.free;
~mag.free;
)

// modular test
(
OSCdef(\o1,
	{ arg msg, time; [time, msg].postln;
		~mod1 =	Pmono(\dcev,
			\ch,6,
			\ampCh,2, // rme fireface 800 adat channels
			\trig, 1,
			//\note, Pseq((23..37), inf),
			//\degree, Pseq([1],1),
			\note, Pseq([30,63],30),
			//\scale, Scale.whole,
			//\tuning, \harmonic,
			\dur, 0.1,
			\amp, 0.5,
			\atk, 0.001,
			\sus, 0.05,
			\rel, 0.4,
			\calibration, 0.0967, //0.0074, 0.10255,
			\midiTune, -24,
			\stepsPerOctave, 12,
			\octave, 0,
		);
		/*~mod1.set(\note, Pseq([25,33,30].mirror1,inf).asStream, \dur, Pbjorklund2(Pseq((2..16),inf),16,inf,0).asStream/8, \amp, Pexprand(0.5,0.9,inf).asStream);*/
	},
	'/output_1');
)

(
OSCdef(\o1,
	{ arg msg, time; [time, msg].postln;
		~scramble.free(1);
		~fftNoise.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox.free;
		~vox = ~freeze;
		~freeze.set(\out, 0);
	},
	'/output_1');

OSCdef(\o2,
	{ arg msg, time; [time, msg].postln;

		~freeze.free(1);
		~fftNoise.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox.free;
		~vox = ~scramble;
		~scramble.set(\out, 0);
	},
	'/output_2');

OSCdef(\o3,
	{ arg msg, time; [time, msg].postln;
		~scramble.free(1);
		~freeze.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox.free;
		~vox = ~fftNoise;
		~fftNoise.set(\out, 0);
	},
	'/output_3');

OSCdef(\o4,
	{ arg msg, time; [time, msg].postln;
		~scramble.free(1);
		~freeze.free(1);
		~fftNoise.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox.free;
		~vox = ~enhance;
		~enhance.set(\out, 0);
	},
	'/output_4');

OSCdef(\o5,
	{ arg msg, time; [time, msg].postln;
		~scramble.free(1);
		~freeze.free(1);
		~fftNoise.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox = ~conformer;
		~conformer.set(\out, 0);
	},
	'/output_5');

OSCdef(\o6,
	{ arg msg, time; [time, msg].postln;
		~scramble.free(1);
		~freeze.free(1);
		~fftNoise.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox = ~bin;
		~bin.set(\out, 0);
	},
	'/output_6');

OSCdef(\o7,
	{ arg msg, time; [time, msg].postln;
		~scramble.free(1);
		~freeze.free(1);
		~fftNoise.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox = ~mag;
		~mag.set(\out, 0);
	},
	'/output_7');

OSCdef(\o8,
	{ arg msg, time; [time, msg].postln;
		~scramble.free(1);
		~freeze.free(1);
		~fftNoise.free(1);
		~enhance.free(1);
		~conformer.free(1);
		~bin.free(1);
		~mag.free(1);
		~vox = ~freeze;
		~freeze.set(\out, 0);
	},
	'/output_8');
)

ServerOptions.outDevices;


// manual stop
(
~scramble.free(2);
~freeze.free(2);
~fftNoise.free(2);
~enhance.free(2);
~conformer.free(2);
~bin.free(2);
~mag.free(2);
~vox.free;
)

// free mfcc, busses, and close windows
(
~mfcc.free;
r.stop;
t.free;
c.free;
d.free;
w.close;
n.free;
~mfccDisplay.free;
)


// ALL stop
(
~scramble.free(2);
~freeze.free(2);
~fftNoise.free(2);
~enhance.free(2);
~conformer.free(2);
~bin.free(2);
~mag.free(2);
~vox.free;
~mfcc.free;
r.stop;
t.free;
c.free;
d.free;
w.close;
n.free;
~mfccDisplay.free;
p.clear;
)

s.quit

// kill node
s.sendMsg(\n_free,1285);







(
// 2 osc slow morphing pitch and env
~dc = Pmono(\dcev,
	\ch,16,
	\ampCh,12, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..45).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..2),inf),
	\port, Pkey(\dur) *2,
);

~sin = Pmono(\dcev,
	\ch,17,\ampCh,13, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..65).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..2),inf),
	\port, Pkey(\dur) *2,
);

~mod3 = Pmono(\dcev,
	\ch,18,\ampCh,14, // rme fireface 800 adat channels
	\trig, 1,
	//\note, Pseq((23..37), inf),
	\degree, Prand((0..7),inf),
	\scale, Scale.whole,
	\tuning, \harmonic,
	\dur, /*Pseq([0.3, Rest(0.9)],inf)*/ Pexprand(5.33, 9.79,inf) * 0.1,
	\amp, Pseq((15..65).mirror2, inf) * 0.01,
	\atk, /*0.001,*/ Prand([1,5,9],inf) * 0.1,
	\sus, /*0.05,*/  Prand([1,10,100],inf) *0.01,
	\rel, /*0.5,*/ Prand([1,5,9],inf) *0.1,
	\calibration, 0.1,
	\midiTune, -12.75,
	\spo, 12,
	\octave, Pseq((2..4),inf),
	\port, Pkey(\dur) *2,
);
)




////// UTILITIES & USEFUL FUNCTIONS ////////

//dump all nodes to post window
s.queryAllNodes(queryControls);

// plot 13 coefficient values (+1 to match wekinators inputs)
c.getn(13, { |val| { val.plot; val.do({ arg item, i; [i+1, item].postln })}.defer });

//monitor all osc
OSCFunc.trace(true);
OSCFunc.trace(false);

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
