

s.boot;

{ SoundIn.ar([0,1]) }.play;
s.meter;


b = Buffer.alloc(s,2048,1);

(
var exBuf;
Dialog.getPaths({ arg paths; //get a second soundfile;
    paths.do({ arg p; exBuf = Buffer.read(s, p);

        SynthDef("help-max", { arg out=0, soundBufnum1=2, soundBufnum2 = 3;
            var inA, chainA, inB, chainB, chain ;
            inA = PlayBuf.ar(1, soundBufnum1, BufRateScale.kr(soundBufnum1), loop: 1);
            inB =  PlayBuf.ar(1, soundBufnum2, BufRateScale.kr(soundBufnum2), loop: 1);
            chainA = FFT(LocalBuf(2048), inA);
            chainB = FFT(LocalBuf(2048), inB);
            chain = PV_RectComb2(chainA, chainB,  MouseX.kr(0, 32), MouseY.kr, 0.3);
            Out.ar(out,  0.5 * IFFT(chain).dup);
        }).play(s, [\soundBufnum1, b, \soundBufnum2, exBuf]);
    })
},{
    "cancelled".postln;
});
)


(
//first attempt
SynthDef(\DRRhythm, { arg inbus=0, out=0;
	var chainin, dry, chain, gate, freezeout;
	gate = MouseY.kr > 0.5;
	dry = SoundIn.ar(inbus);
	chainin = dry; // * EnvGen.ar(Env([1,0,1], [1.5, 0.5], releaseNode:1),gate);
	chain = FFT(LocalBuf(64), chainin);
	chain = PV_MagFreeze(chain, gate);
	freezeout = IFFT(chain) * EnvGen.ar(Env.asr(0.3, 1.0, 0.8),gate);
	Out.ar(out, Pan2.ar(freezeout + dry, 0, 0.3));
}).send(s);
)

a = Synth(\DRRhythm, [\inbus, 0, \out, 0]);
a.stop