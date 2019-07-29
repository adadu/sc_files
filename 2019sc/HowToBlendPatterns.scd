s.boot
Server.killAll

// one way to interpolate between patterns is to use .blend
(
var b= 0.59;  //blend fraction / mix. vary 0.0-1.0
Pbind(\degree, Pseq([0, 2, 3], inf).blend(Pseq([9, 1, 2], inf), b).trace, \dur, 0.1.blend(0.2, b)).play;
)

(
Pbind(
        \blend, Pseg(#[0, 1, 1, 0, 0], #[10, 2, 10, 2], 'lin', inf).trace,
        \degree, Pseq([0, 2, 3], inf).blend(Pseq([9, 1, 2], inf), Pkey(\blend)).round,
        \dur, 0.1.blend(0.2, Pkey(\blend))
).play;
)

// Oh wait, that's because i didn't change the key for dur... I think I get it - but is that the most efficient way? It seems like it could get pretty dense within a few steps..

(

Pbind(
        \blend1, Pseg(#[0, 1, 1, 0, 0], #[10, 2, 10, 2], 'lin', inf).trace,
	    \blend2, Pseg(#[1, 0, 1, 1, 0], #[4, 9, 1, 20], 'lin', inf).trace,
	\degree, (Pseq([0, 2, 3], inf).blend(Pseq([9, 1, 2], inf), Pkey(\blend1)).round).
	blend(Pseq([12, 14, 19, 18], inf),Pkey(\blend2)).round,

			\dur, 0.1.blend(0.2, Pkey(\blend1))
).play;

)

//yes, it'll quickly become a mess if you .blend multiple patterns.
//here's one idea how to simplify things...
(
var arr= #[
        [0, 2, 3],
        [9, 1, 2],
        [5],
        [12, 14, 19, 18]
];
Pbind(
        \index, Pseg(#[0, 1, 1], #[20, 2], 'lin', inf),
        \dur, Pkey(\index).linlin(0, 1, 0.1, 0.2),
        \degree, Pn(Plazy({|ev|
                var a= arr.blendAt(ev.index*(arr.size-1)).round.asInteger;
                "arr: %, index: %, dur: %".format(a, ev.index, ev.dur).postln;
                Pseq(a, 1)
        }))
).play;
)

//note that it blends not per note but rather per phrase - maybe that's ok.  also it only ever blends two patterns at a time.

//It's possible to ".collect" on the pattern and put all of the blending
// logic into that function.

p = Pbind(
    \midinote, Pwhite(48, 55, inf),
    \dur, Pwhite(1, 3, inf) * 0.5
);

q = Pbind(
    \midinote, Pwhite(72, 79, inf),
    \dur, Pwhite(1, 3, inf) * 0.125
);

~blend = EZSlider(nil, Rect(800, 200, 400, 50), "blend", [0, 1]);

r = Ptuple([p, q], inf).collect { |pair|
    var keys = pair[0].keys union: pair[1].keys,
    new = Event(proto: pair[0].proto, parent: pair[0].parent);
    keys.do { |key|
        var a = pair[0][key], b = pair[1][key];
        case
        { a.isNil } { new[key] = b }
        { b.isNil } { new[key] = a }
        { new[key] = blend(a, b, ~blend.value) }
    };
    new
}.play;

r.stop;

// BTW: ~blend.value works without 'defer' here because it's not
// a "real" GUI object. With a plain slider, you'd need a second variable
// for the value.

// If you have the JITLibExtensions quark, you
// can `blend` Events directly (!) -- which is blowing my mind. You can
// even specify different blend specs per key (which I'm not doing here).

r = Ptuple([p, q], inf).collect { |pair| blend(pair[0], pair[1],
~blend.value) }.play;
r.stop;


