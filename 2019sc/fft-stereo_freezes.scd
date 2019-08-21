//FFT freezings
s.boot;

//FFT buffer
// /Users/draft/git/sounds/sounds-test/iBelieveICanFly441k.wav
c = Buffer.read(s,"./Users/draft/git/samples/sounds-test/iBelieveICanFly441k.wav");

// OK, this is the sickest UGEN, can i get it to do a live thing?
(
var in, sf;
//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
in = RecordBuf.ar([6], bufnum: 0, offset: 0.0, recLevel: 1.0, preLevel: 0.0, run: 1.0, loop: 1.0, trigger: 1.0, doneAction: 0); //SoundIn.ar(6);
f = 1024;
h = 0.25;
y = Buffer.alloc(s, 44100 * 4.0, 1); // a four second 1 channel Buffer // in.duration.calcPVRecSize(f, h));
z = Buffer.read(s, y);
)


(
q = {
	arg out=0, recBuf=1;
    var in, chain, bufnum, playbuf, playbuf2;
	in = SoundIn.ar(6);
	chain = FFT({ LocalBuf.new(1024) }, in);
	/*playbuf = PlayBuf.ar(1, in, BufRateScale.kr(in), loop: 1);
	playbuf2 = playbuf;*/
	chain = PV_BufRd(chain, playbuf2, MouseX.kr(0.0, 1.0));
	Out.ar(out, IFFT(chain, 1).dup);
}.play;
)
q.free


//test spectral enhance
(
SynthDef(\specEnhance, { arg ratio = 2, out;
    var in, chain;
	in = SoundIn.ar(6); //WhiteNoise.ar(0.1).dup;
    chain = FFT({LocalBuf(2048, 1)}, in);
    chain = PV_SpectralEnhance(chain, 2, ratio, MouseX.kr(0, 0.99));
    Out.ar(out, IFFT(chain).dup) // inverse FFT
}).add;
)

a = Synth(\specEnhance);
a.set(\ratio, 2.5);
a.free




// sound input: use headphones to prevent feedback
(
SynthDef("conformer1", { |out|
    var in, chain;
    in = SoundIn.ar(6);
    chain = FFT(LocalBuf(1024), in);
    chain = PV_ConformalMap(chain, MouseX.kr(-1.0,1.0), MouseY.kr(-1.0,1.0));
    Out.ar(out, Pan2.ar(IFFT(chain), 0));
}).add;
)

d= Synth("conformer1")
d.free



(
{

    var in, fft;

	in = SoundIn.ar(6); // PlayBuf.ar(1, d, BufRateScale.kr(d), 1, 0, 1);
    fft = FFT(LocalBuf(1024, 1), in, wintype:1);
    TPV.ar(fft, 1024, 512, 200,100, MouseX.kr(0.0,1.0), 1, 0.2).dup

}.play
)

Buffer.alloc(s, 44100 * 4.0, 1);
(
SynthDef(\maxmag, {arg fftbuf;
    var in, chain, out;
    in = SoundIn.ar(6);
    chain = FFT(fftbuf, in);
    // let the strongest (0 - 1023) partials through
    chain = PV_MaxMagN(chain, MouseX.kr(0,1023));
    out = IFFT(chain);
    Out.ar(0, out);
}).add;
)
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
    in = SoundIn.ar(6);
	chain = FFT({ LocalBuf(64) } !2, in);
	chain = PV_MagFreeze(chain, SinOsc.kr(LFNoise0.kr([4, 5])));
    IFFT(chain) // inverse FFT
}.play;

)
q.free

(
u = {
    var in, chain, bufnum;
	//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    //in = SoundIn.ar(6);
	bufnum = LocalBuf.new(1024);
	chain = PV_BufRd(c, 1, MouseX.kr(0.0,1.0));
    IFFT(chain) // inverse FFT
}.play;

)
u.free



(
r = {
    var in, chain, mV, newIn, chain2;
	//in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    in = SoundIn.ar(6);
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
	in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
    //in = SoundIn.ar(6); //WhiteNoise.ar(0.1).dup;
    chain = FFT({LocalBuf(128, 1)}.dup, in);
    chain = PV_BrickWall(chain,
        SinOsc.kr(rate * XLine.kr(1, 15 * [1, 1.6], sustain), Rand(0, pi))
    );
    Out.ar(out, IFFT(chain) * XLine.kr(1, 0.001, sustain, doneAction: Done.freeSelf)) // inverse FFT
}).add;
)

(
Pbind(
    \instrument, \fftgrain,
    \rate, Pwhite().linexp(0, 1, 0.01, 300),
    \legato, Pwhite(1, 3.0, inf),
    \dur, Prand([0.2, 1, 1.2], inf)
).play
)

( {
var in, chain, v;
in = SoundIn.ar(6);
chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
if((index-LFPar.kr(0.1).range(2, b.numFrames/20)).abs < 10, mag, 0); // swept bandpass
}, frombin: 0, tobin: 250, zeroothers: 0);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

( {
var in, chain, v;
in = SoundIn.ar(6);
	chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
        [mag.sqrt, pi.rand];
}, frombin: 0, tobin: 256, zeroothers: 1);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

( {
var in, chain, v;
in = SoundIn.ar(6); chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
        [mag, LFNoise0.kr.range(0, 3.14)];
}, frombin: 0, tobin: 250, zeroothers: 1);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

( {
var in, chain, v;
in = SoundIn.ar(6); chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(b.numFrames, {|mag, phase, index|
        [mag * MouseX.kr(0.5, 2), phase / MouseY.kr(0.5, 30)]
}, frombin: 0, tobin: 250, zeroothers: 0);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

// spectral delay w math
( {
var in, chain, v;
in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1);
chain = FFT(LocalBuf(1024), in);
v = MouseX.kr(0.1, 1);
chain = chain.pvcollect(c.numFrames, {|mag, phase, index| mag + DelayN.kr(mag, 1, v);
}, frombin: 0, tobin: 256, zeroothers: 1);
	Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

250.do({|i|(i*(250.reciprocal)).postln;})

// more delay math
( {
var in, chain, v;
in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1); chain = FFT(LocalBuf(1024), in);
v = MouseX.kr(0.1, 2);
chain = chain.pvcollect(c.numFrames, {|mag, phase, index|
        mag + DelayN.kr(mag, 1, v*(index*256.reciprocal));
}, frombin: 0, tobin: 256, zeroothers: 0);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

//add noise

( {
var in, chain, v;
in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1); chain = FFT(LocalBuf(1024), in);
chain = chain.pvcollect(c.numFrames, {|mag, phase, index|
        [mag, LFNoise0.kr.range(0, 3.14)];
}, frombin: 0, tobin: 250, zeroothers: 1);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

//square mags, rando phase to pi
( {
var in, chain, v;
in = PlayBuf.ar(1, c, BufRateScale.kr(c), loop: 1); chain = FFT(LocalBuf(1024), in);
chain = chain.pvcalc(c.numFrames, {|mag, phase, index|
		[mag.sqrt.scramble, (phase * pi.rand).reverse];
}, frombin: 2, tobin: 256, zeroothers: 1);
        Out.ar(0, 0.5 * IFFT(chain).dup);
}.play(s);
)

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