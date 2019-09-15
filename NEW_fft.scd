// new fft

// fft freeze is so sick
(
q = {
    var in, chain;
	//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    in = SoundIn.ar(0);
	chain = FFT({ LocalBuf(1024) } !2, in);
	chain = PV_MagFreeze(chain, LFNoise0.kr([LFNoise0.kr(2).exprange(2,10), LFNoise0.kr(2).exprange(2,10)], 0.5));
    IFFT(chain) // inverse FFT
}.play;
)

//record sc output if you want
s.record(duration: 15);
s.stopRecording;


// beginnings of gate w amplitude detection
(
SynthDef(\gat, { var in, inputAmp, threshhold, gate;
in = SoundIn.ar(0);
inputAmp = Amplitude.kr(in);
threshhold = 0.02;	// noise gating threshold
gate = Lag.kr(inputAmp > threshhold, 0.01);
}).add;
)

~v = {LFNoise2.kr(Pexprand(0.1, 200, inf).asStream) };//{Dwhite(0.1, 600,inf).asStream};//{LFNoise2.kr(10)};
~v.play;
~v.free;
//square mags, rando phase to pi
(
SynthDef(\scraMag, { arg out = 0, phaseMul = LFNoise2.kr(Pexprand(0.1, 200, inf).asStream.nextN(50));
var in, chain, inputAmp, threshhold, gate;
in = SoundIn.ar(0); //PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
b = Buffer.alloc(s, 44100 * 4.0, 1);
inputAmp = Amplitude.kr(in);
threshhold = 0.01;	// noise gating threshold
gate = Lag.kr(inputAmp > threshhold, 0.01);
chain = FFT(LocalBuf(1024), in);
phaseMul = LFNoise2.kr(Pexprand(0.1, 200, inf).asStream);
chain = chain.pvcalc(b.numFrames, {|mag, phase, index|
		[mag.scramble, (phase * [phaseMul,phaseMul]/*pi.rand*/)];
}, frombin: 0, tobin: 128, zeroothers: 0);
        Out.ar(0, IFFT(chain).dup * gate);
}).add;
)
//~v.free;

~scraMag.set(\phaseMul);
~scraMag = (\scraMag);
~scraMag.play;

~scraMag.free;

p.clear


//add noise
(
SynthDef(\fftNoise, {
	var in, chain;
	in = SoundIn.ar(0); //PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
	b = Buffer.alloc(s, 44100 * 4.0, 1);
	chain = FFT(LocalBuf(512), in);
	chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
		[mag, LFNoise0.kr.range(0, 3000.14)];
	}, frombin: 0, tobin: 250, zeroothers: 1);
	Out.ar(0, 0.6 * IFFT(chain).dup);
}).add;
)
~nP = (\fftNoise);



//spectral enhance
(
SynthDef(\specEnhance, { arg numPart = 15, ratio = 1.91, out;
    var in, chain;
	in = SoundIn.ar(0); //WhiteNoise.ar(0.1).dup;
    chain = FFT({LocalBuf(2048, 1)}, in);
    chain = PV_SpectralEnhance(chain, numPart, ratio, 0.99);
    Out.ar(out, 0.5 * IFFT(chain).dup) // inverse FFT
}).add;
)

a = Synth(\specEnhance);
a.set(\ratio,1.99);
a.set(\numPart, 7);
a.free

//conformal map
(
SynthDef(\conformer1, { arg out;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(2048), in);
	chain = PV_ConformalMap(chain,
	LFNoise0.kr([0.5,3.5].exprand(5,-0.9,0.5)),
	LFNoise0.kr([0.1,3.9].exprand(5,-1.5,1.8)));
    Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;
)

d= Synth(\conformer1);
d.free;


(
SynthDef(\binStretch, { arg out, mod;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(512), in);
	mod = SinOsc.kr([960.5,980.5].exprand(3,-1.5,5.8));
	chain = PV_BinShift(chain, mod,1);
		//MouseX.kr(0.25, 2, \exponential), 1);
	Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;
)
e = Synth(\binStretch);
e.free

// probaby the most useful
(
SynthDef(\magStretch, { arg out, mod = 0.892327;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(2048), in);
    chain = PV_BinShift(chain, mod); //MouseX.kr(0.25, 2, \exponential)
	Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;
)
f = Synth(\magStretch);
f.free

s.record(duration: 15);
s.stopRecording;
