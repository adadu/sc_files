//FFT freezings
s.boot;

//FFT buffer
// /Users/draft/git/sounds/sounds-test/iBelieveICanFly441k.wav
c = Buffer.read(s,"./Users/draft/git/samples/sounds-test/iBelieveICanFly441k.wav");
c.free

// OK, this is the sickest UGEN, can i get it to do a live thing?
(
var in, sf;
//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
in = RecordBuf.ar([0], bufnum: 0, offset: 0.0, recLevel: 1.0, preLevel: 0.0, run: 1.0, loop: 1.0, trigger: 1.0, doneAction: 0); //SoundIn.ar(6);
f = 1024;
h = 0.25;
y = in.duration.calcPVRecSize(f, h);
Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer
z = Buffer.read(s, y);
)


(
q = {
	arg out=0, recBuf=1;
    var in, chain, bufnum, playbuf, playbuf2;
	in = SoundIn.ar(0);
	chain = FFT({ LocalBuf.new(1024) }, in);
	playbuf = PlayBuf.ar(1, in, BufRateScale.kr(in), loop: 1);
	playbuf2 = playbuf;
	chain = PV_BufRd(chain, playbuf2, MouseX.kr(0.0, 1.0));
	Out.ar(out, IFFT(chain, 1).dup);
}.play;
)
q.free


//test spectral enhance
(
SynthDef(\specEnhance, { arg numPart = 2, ratio = 2, out;
    var in, chain;
	in = SoundIn.ar(0); //WhiteNoise.ar(0.1).dup;
    chain = FFT({LocalBuf(2048, 1)}, in);
    chain = PV_SpectralEnhance(chain, numPart, ratio, MouseX.kr(0, 0.99));
    Out.ar(out, IFFT(chain).dup) // inverse FFT
}).add;
)

a = Synth(\specEnhance);
a.set(\ratio, 8);
a.set(\numPart, 4);
a.free




// sound input: use headphones to prevent feedback
(
SynthDef("conformer1", { arg out;
    var in, chain;
    in = SoundIn.ar(0);
    chain = FFT(LocalBuf(1024), in);
    chain = PV_ConformalMap(chain, MouseX.kr(-1.0,1.0).postln, MouseY.kr(-3.0,3.0).postln);
    Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;
)

d= Synth("conformer1");
d.free;


/////   ???? ???? /////////
Buffer.alloc(s, 44100 * 8.0, 1);
c = Buffer.read(s,"./Users/draft/git/samples/sounds-test/iBelieveICanFly441k.wav");
c.free
(
SynthDef(\tvp1, { arg out;
    var in, chain;
	in = SoundIn.ar(0); // PlayBuf.ar(1, d, BufRateScale.kr(d), 1, 0, 1);
	chain = FFT({LocalBuf(1024,1)}, in);
	chain = TPV.ar(chain, 1024, 512, 200,100, MouseX.kr(0.0,1.0), 1, 0.2);
	Out.ar(out, IFFT(chain));
}).add;
)
d= Synth(\tvp1);
d.free;




Buffer.alloc(s, 44100 * 4.0, 1);
(
SynthDef(\maxmag, {arg fftbuf;
    var in, chain, out;
    in = SoundIn.ar(0);
    chain = FFT(fftbuf, in);
    // let the strongest (0 - 1023) partials through
    chain = PV_MaxMagN(chain, MouseX.kr(0,1023));
    out = IFFT(chain);
    Out.ar(0, out);
}).add;
)

e = Synth(\maxmag);
e.free

// the fft buf
s.sendMsg(\b_alloc, 0, 2048);
// start the synth
s.sendMsg(\s_new, \maxmag, z = s.nextNodeID, 0, 1, \fftbuf, 0);
// free it
s.sendMsg(\n_free, z);
s.sendMsg(\b_free, 0);


PowerOfTwoAllocator(20, 1)


s.freeAllBuffers

["ls","/"].unixCmd;

(
q = {
    var in, chain;
	//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    in = SoundIn.ar(0);
	chain = FFT({ LocalBuf(1024) } !2, in);
	chain = PV_MagFreeze(chain, LFNoise0.kr(LFNoise0.kr(2).exprange(2,10), 0.5));
    IFFT(chain) // inverse FFT
}.play;


s.record(duration: 15);
s.stopRecording;

)
q.free

Buffer.alloc(s, 44100 * 4.0, 1);

// ????????
(
SynthDef(\bufrd, {arg recBuf=1, soundBufnum=2, out;
    var in, chain, bufnum;
    in = SoundIn.ar(0);
	//in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 0);
	b = Buffer.alloc(s, 44100 * 4.0, 1);
	//chain = FFT({LocalBuf(1024, 1)}.dup, in);
	chain = FFT({ LocalBuf(1024, 1, 0.25, 1) }.dup, in);
	chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, 0.25, 1);
	chain = PV_BufRd(chain, 1, MouseX.kr(0.0,1.0));
    out = IFFT(chain);// inverse FFT
	Out.ar(0, out);
}).add;
)
d= Synth(\bufrd);
d.free;
// the fft buf
s.sendMsg(\b_alloc, 0, 2048);
s.sendMsg(\s_new, \bufrd, z = s.nextNodeID, 0, 1, \fftbuf, 0);
s.sendMsg(\n_free, z);
s.sendMsg(\b_free, 0);




(
r = {
    var in, chain, mV, newIn, chain2;
	//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    in = SoundIn.ar(0);
	chain = FFT(LocalBuf(256), in);
	mV= MouseX.kr(-1,1.0);
	chain = PV_BrickWall(chain, mV);
    mV.poll;
	newIn = IFFT(chain); // inverse FFT
	chain2 = FFT({LocalBuf(128) } !2, newIn);
	chain2 = PV_BrickWall(chain2, mV);
		IFFT(chain2)
}.play;
)
r.free

(
SynthDef(\fftgrain, { |out, sustain = 1, rate = 0.2|
    var in, chain;
	in = SoundIn.ar(0); //WhiteNoise.ar(0.1).dup;
	b = Buffer.alloc(s, 44100 * 4.0, 1);
    chain = FFT({LocalBuf(1024, 1)}.dup, in);
    chain = PV_BrickWall(chain,
        SinOsc.kr(rate * XLine.kr(1, 15 * [1, 1.6], sustain), Rand(0, pi))
    );
    Out.ar(out, IFFT(chain) * XLine.kr(1, 0.001, sustain)) // inverse FFT
}).add;
)

v = Synth(\fftgrain);
v.free;

(
Pbind(
    \instrument, \fftgrain,
    \rate, Pwhite().linexp(0, 1, 0.01, 300),
    \legato, Pwhite(1, 3.0, inf),
    \dur, Prand([0.2, 1, 1.2], inf)
).play
)

( {
var in, chain, b;
in = SoundIn.ar(0);
b = Buffer.alloc(s, 44100 * 4.0, 1);
chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
if((index-LFPar.kr(0.1).range(2, b.numFrames/20)).abs < 10, mag, 0); // swept bandpass
}, frombin: 0, tobin: 250, zeroothers: 0);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

( {
var in, chain, v;
in = SoundIn.ar(0);
	chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
        [mag.sqrt, pi.rand];
}, frombin: 0, tobin: 256, zeroothers: 1);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

( {
var in, chain;
in = SoundIn.ar(0);
b = Buffer.alloc(s, 44100 * 4.0, 1);
chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(c.numFrames, {|mag, phase, index|
        [mag, LFNoise0.kr.range(0, 3.14)];
}, frombin: 0, tobin: 250, zeroothers: 1);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

( {
var in, chain, v;
in = SoundIn.ar(0);
b = Buffer.alloc(s, 44100 * 4.0, 1);
//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1); //SoundIn.ar(0);
chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
		[mag * MouseX.kr(0.5, 2), phase / MouseY.kr(0.5, 30)]
}, frombin: 0, tobin: 250, zeroothers: 0);
Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

// spectral delay w math
( {
var in, chain, v;
in = SoundIn.ar(0); //PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
b = Buffer.alloc(s, 44100 * 4.0, 1);
chain = FFT(LocalBuf(512), in);
v = MouseX.kr(0.01, 1);
chain = chain.pvcollect(c.numFrames, {|mag, phase, index| mag + DelayN.kr(mag, 1, v);
}, frombin: 0, tobin: 128, zeroothers: 1);
	Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

250.do({|i|(i*(250.reciprocal)).postln;})

// more delay math
( {
var in, chain, v;
in = SoundIn.ar(0); //PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
b = Buffer.alloc(s, 44100 * 4.0, 1);
chain = FFT(LocalBuf(1024), in);
v = MouseX.kr(0.1, 2);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
		mag + DelayN.kr(mag, 1, v*(index*256.reciprocal));
}, frombin: 0, tobin: 256, zeroothers: 0);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

//add noise

( {
var in, chain, v;
in = SoundIn.ar(0); //PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
b = Buffer.alloc(s, 44100 * 4.0, 1);
	chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
        [mag, LFNoise0.kr.range(0, 3000.14)];
}, frombin: 0, tobin: 250, zeroothers: 1);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

(
SynthDef(\gat, { var in, inputAmp, threshhold, gate;
in = SoundIn.ar(0);
inputAmp = Amplitude.kr(in);
threshhold = 0.02;	// noise gating threshold
gate = Lag.kr(inputAmp > threshhold, 0.01);
}).add;
)

~v = {LFNoise0 .kr(RandSeed.kr(trig: 0.0, seed: 50)/*Dust.kr(0.5).asStream*/).asStream}; //{WhiteNoise.kr(600)}; // //{ Pexprand(0.1, 200, inf).asStream };//{Dwhite(0.1, 600,inf).asStream};//{LFNoise2.kr(10)};
~v.play;
~v.free;
//square mags, rando phase to pi
(
SynthDef(\scraMag, { arg phaseMul;
var in, chain, inputAmp, threshhold, gate;
in = SoundIn.ar(0); //PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
b = Buffer.alloc(s, 44100 * 4.0, 1);

inputAmp = Amplitude.kr(in);
threshhold = 0.02;	// noise gating threshold
gate = Lag.kr(inputAmp > threshhold, 0.01);

chain = FFT(LocalBuf(1024), in);
chain = chain.pvcalc(b.numFrames, {|mag, phase, index|
		[mag.scramble, (phase * phaseMul/*pi.rand*/)];
}, frombin: 0, tobin: 128, zeroothers: 0);
        Out.ar(0, 0.5 * IFFT(chain).dup * gate);
}).add;
)
//~v.free;
~scraMag = (\scraMag);
~scraMag.set(\phaseMul, ~v);

~scraMag.play;

~scraMag.free;

p.clear


pi.rand.postln

( {
var in, chain, v;
in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1); chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(c.numFrames, {|mag, phase, index|
if((index-LFPar.kr(0.1).range(2, c.numFrames/20)).abs < 10, mag, 0); // swept bandpass
}, frombin: 0, tobin: 250, zeroothers: 0);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)


{var n= 1024;
	WaveletDaub.ar(SoundIn.ar(6), n, MouseX.kr(2,n))}.play

( {
var in, chain, n=512;
in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
chain = FFT(LocalBuf(1024), in);
chain = chain.pvcalc(c.numFrames, {|mag, phase, index|
		[mag.sqrt.scramble, (phase * pi.rand).reverse];
}, frombin: 0, tobin: 256, zeroothers: 1);
	WaveletDaub.ar(chain, n, MouseX.kr(0,n), mul: 0.01!2)
}.play
)

s.boot
s.freeAllBuffers
s.quit
s.queryAllNodes
s.freeAll