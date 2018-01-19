// connect MIDI

//MIDIIn.connectAll

(
ServerOptions.devices;
s.options.device = "MOTU 828";
s.options.numOutputBusChannels = 16;
s.options.outputStreamsEnabled = "1111111111111111";
s.options.memSize = 16384;
s.options.numOutputBusChannels.postln;
s.boot;
)
//If you want to use multiple controller elements,
//you may want to take a look at the Modality quark:

// make an MKtl for a korg nanokontrol2, keeps all its elements
// organized in groups, and keeps actions for all elemetns and groups.
k = MKtl(\nk2, "*trol2");
k.gui;    // make a gui for it

// access first slider by index or name:
k.elAt(\sl, 0);
k.elAt(\sl, \1);

// get its normalized value
k.elAt(\sl, 0).value;
// or its device-side value (here, midi)
k.elAt(\sl, \1).deviceValue;
// scale value
k.elAt(\sl, \1).value.linexp(0, 1, 200, 5000);
// one can also create a bus that will have the normalized value:
k.elAt(\sl, 0).initBus

// now for your example:
(
SynthDef(\vocal, {|freq = 110, f1 = 1000, f2 = 2300|
        var sig, frq, frmt, env;
        env = EnvGen.kr(Env.perc, doneAction: 2);
        sig = Mix.new(Formant.ar([freq, freq*3], [f1, f2], 800, [0.2, 0.03] * env));
        Out.ar(0, sig.dup)
}).add;
)


// for polling the slider on each beginning note, the simplest solution:
(
~seqArp1 = Pseq(([60, 74, 67, 74, 64, 79, 72, 79]-24).midicps, inf).asStream;
~patArp1 = Pbind(
        \instrument, \vocal,
        \freq, ~seqArp1,
        // ask the slider for its value and do scaling here:
        \f1, Pfunc({ k.elAt(\sl, \1).value.linexp(0, 1, 200, 5000) }),
        \dur, 0.25
        ).trace.play;
)

// also polling, and more flexible: use the slider element to set a Pdefn,
// and lookup the Pdefn in the pattern.
// Pdefn can contain a number, or a pattern, or other things,
// and you can change it while running.
(
k.elAt(\sl, 0).action = { |el| Pdefn(\f1, el.value.linexp(0, 1, 200, 5000)) };
k.elAt(\sl, 0).doAction;

~seqArp1 = Pseq(([60, 74, 67, 74, 64, 79, 72, 79]-24).midicps, inf).asStream;
~patArp1 = Pbind(
        \instrument, \vocal,
        \freq, ~seqArp1,
        // ask Pdefn for its current value on each new event
        \f1, Pdefn(\f1),
        \dur, 0.25
        ).trace.play;
)

// same with bus, as JH proposes:
// make a bus for f1
~f1bus = Bus.control;
// tell slider 1 to set the bus to scaled value
k.elAt(\sl, 0).action = { |el| ~f1bus.set( el.value.linexp(0, 1, 200, 5000)) };
// set it once, so it has the sliders current value
k.elAt(\sl, 0).doAction;

(
~seqArp1 = Pseq(([60, 74, 67, 74, 64, 79, 72, 79]-24).midicps, inf).asStream;
~patArp1 = Pbind(
        \instrument, \vocal,
        \freq, ~seqArp1,
        // map the bus onto synth input f1
        \f1, ~f1bus.asMap,
        \dur, 0.1
        ).trace.play;
)

