Quarks.gui
Quarks.install("https://github.com/musikinformatik/apex-sc-dafx.git");

Apex2GUI.new(server_, path)

Apex2GUI.new(s,

s.boot
EaseGallery.new;

Understanding Streams, Patterns and Events - Part 5
Event.default

(
Pbind(
	\instrument, \default,
    \dur, 0.02,
	\trig,1,
    //\legato, Pseq([ Pseries(0.05, 0.05, 40), Pseries(2.05, -0.05, 40) ], inf),
    //\midinote, Pseq(#[48, 51, 55, 58, 60, 58, 55, 51], inf),
	\freq, Pseq([Pgeom(30.0, 1.1, 100),Pgeom(30.0, 1.2, 80),Pgeom(30.0, 1.3, 60)],inf), //Pseries(200, 1, inf),
	\amp, 0.3//Pgeom(0, 0.01, 100)
).play
)

Ease

(
SynthDef(\default,{ |out, t_trig| });
)
(
Pmono(\default,
    \dur, 0.02,
	\trig,1,
    //\legato, Pseq([ Pseries(0.05, 0.05, 40), Pseries(2.05, -0.05, 40) ], inf),
    //\midinote, Pseq(#[48, 51, 55, 58, 60, 58, 55, 51], inf),
	\freq, Pseq([Pgeom(30.0, 1.1, 100),Pgeom(30.0, 1.2, 80),Pgeom(30.0, 1.3, 60)],inf), //Pseries(200, 1, inf),
	\amp, 0.3//Pgeom(0, 0.01, 100)
).play
)

Pgeom
Pseries

Pbind



a= EaseInOutBounce.new(1.70158)
a.value(0.5)

{|t| EaseInOutBounce.(t/99, 1.70158)}.dup(100).plot

s.boot
{SinOsc.ar(EaseInBounce.kr(Line.kr(0, 1, 2, doneAction:2), 1.70158).exprange(500, 760), 0, 0.3)}.play

{|t| EaseInBounce.(t/99, 1.70158)}.dup(100).plot


