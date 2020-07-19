s.quit;


(
s.quit;

// 10in 10out

//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 10;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2,system:capture_3,system:capture_4,system:capture_5,system:capture_6,system:capture_7,system:capture_8,system:capture_9,system:capture_10");
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10");

// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");

//increase memory
s.options.memSize = 4 * 8192;

s.boot;
)

k = MKtl('midi_3_linnst', "linnstrument_8chan");
k.trace;
k.gui;

k.elAt( \bt );

// [ button, chanTouch, pad, padMove, padUp, padX, padY, slider ]

/*
0	Group: 'vol'
	0	'vol_L'
	1	'vol_R'
1	Group: 'sw'
	0	'sw_1'
	1	'sw_2'

2	Group: '1'
	0	Group: 'pad'
		0	Group: 0
           0	'1_pad_0_on'
           1	'1_pad_0_off'
           2	'1_pad_0_touch'
        1	Group: 1
		   0	'1_pad_1_on'
		   1	'1_pad_1_off'
		   2	'1_pad_1_touch'

9   Group: '8'
	0	Group: 'pad'
		0	Group: 0
			0	'8_pad_0_on'
			1	'8_pad_0_off'
			2	'8_pad_0_touch'
		1	Group: 1
			0	'8_pad_1_on'
			1	'8_pad_1_off'
			2	'8_pad_1_touch'

1	'8_bnd'
2	'8_tch'
3	'8_pdY'
*/


(
SynthDef.new(\defo, {
arg dur, attack=0.01, release=1.0,
gate=1, out, freq=442, cutoff=5500,
rq=1, pan=0.0, amp=0.5;

var env = EnvGen.kr(Env.perc(attack, release), gate, timeScale: dur, doneAction: 2);
var sig = DPW3Tri.ar(freq: freq, mul: env);
sig = RLPF.ar(sig, cutoff.clip(20.0, 20000.0), rq.clip(0.0,1.0));
sig = Pan2.ar(sig, pan);
Out.ar(out, sig * amp);
}).add;
)

// bruno midi keyboard
(
var noteArray = Array.newClear(128); // array has one slot per possible MIDI note
MIDIdef.noteOn(\myKeyDown, {arg vel, note, co;
noteArray[note] = Synth(\defo, [\freq, note.midicps, \amp, vel.linlin(0,
		127, 0, 1), \dur, 1, \cutoff, co.linlin(0,127,0,10000)]);
["NOTE ON", note].postln;
});
MIDIdef.noteOff(\myKeyUp, {arg vel, note;
noteArray[note].set(\gate, 0);
["NOTE OFF", note].postln;
});
)
// end bruno

m = MChanVoicer(0);
m.dump;


(
var noteArray = Array.newClear(128);
Ndef(\m, {arg vel, note, co;
noteArray[note] = Synth(\defo, [\freq, note.midicps, \amp, vel.linlin(0,
		127, 0, 1), \dur, 1, \cutoff, co.linlin(0,127,0,10000)]);
}).play;
)


m.noteEl.action = { |el| Ndef(\m).set(\freq, el.deviceValue); };
m.velEl.action = { |el| Ndef(\m).set(\amp, el.value.squared); };
m.startFunc = { "roger, starting note, over".postln };
m.endFunc = { "over and out.".postln };

m.noteOn(64, 80);
m.noteOn(67, 40);
m.heldNotes; // two held notes
m.noteOff(67); // down to previous note
m.heldNotes;
m.noteOff(64); // now off

// connect a midi keyboard
MIDIIn.connectAll;

// single channel only
~non = MIDIFunc.noteOn({ |vel, note, chan|
    k.noteOn(note, vel);
}, nil, k.chan);

~nof = MIDIFunc.noteOff({ |vel, note, chan|
    k.noteOff(note, vel);
}, nil, k.chan);

// and add responders for bend and press ...




(
// With a rotating polyphony keyboard like the QuNexus, try this:

//s.boot; s.latency = nil;

g = NPVoicer(Ndef(\piano));     // make an NPVoicer with an Ndef in it
g.prime(\defo);            // prepare it with the default synthdef
g.play;                    // play it

// test by hand
//g.put(1, [\freq, 48.midicps]);
//g.setAt(1, \freq, 60.midicps);
//g.release(1);

// make 10 voicers
~voicers = (0..9).collect { |i|
    var v = MChanVoicer(i);
    var ii = i + 10;
    v.startFunc = { |voicer, note, vel|  g.put(ii, [\freq, note.midicps, \vel, (vel / 127).squared].postln); };
    v.noteEl.action = { |el| g.setAt(ii, \pitch, el.deviceValue); };
    v.velEl.action = { |el| g.setAt(ii, \amp, el.value.squared); };
    v.endFunc = { g.release(ii) };
};

// listen to all midi channels
MIDIIn.connectAll;
~non = MIDIFunc.noteOn({ |vel, note, chan|
    ~voicers[chan].noteOn(note, vel);
}, srcID: nil);

~nof = MIDIFunc.noteOff({ |vel, note, chan|
    ~voicers[chan].noteOff(note, vel);
}, srcID: nil);

)



// make noteOnOff + touch control with groupType \noteOnOffTouch
// FIX GUI
(
d = (
deviceName: "test", protocol: 'midi', idInfo: "test",
elementsDesc: (
        shared: (elementType: \pad, midiChan: 0, groupType: \noteOnOffTouch),
        elements: // [];
        (48..49).collect { |midiNum, i|
            ( midiNum: midiNum,
                style: (row: 0, column: i, width: 1, height: 1)
            )
        }
    )
);
m.free; m = MKtl(\test, d).trace; m.postElements; g = m.gui;
)

// make noteOnOffVel + touch control with groupType \noteOnOffVelTouch
// FIX GUI
(
d = (
deviceName: "test", protocol: 'midi', idInfo: "test",
elementsDesc: (
        shared: (elementType: \pad, midiChan: 0, groupType: \noteOnOffVelTouch),
        elements: (48..55).collect { |midiNum, i|
            ( midiNum: midiNum )
        }
    )
);
m.free; m = MKtl(\test, d).trace; m.postElements; g = m.gui;
)



// Play from a keyboard or drum pad
(
MIDIdef.noteOn(\someKeyboard, { arg vel, note;
Synth("quick", [\freq, note.midicps, \amp, vel.linlin(0, 127, 0, 1)]);
});
)

MKtl('midi_3_linnst').closeDevice;


// Play it with a MIDI keyboard
(
var noteArray = Array.newClear(128); // array has one slot per possible MIDI note
MIDIdef.noteOn(\myKeyDown, {arg vel, note;
noteArray[note] = Synth(\defo, [\freq, note.midicps, \amp, vel.linlin(0,
127, 0, 1)]);
["NOTE ON", note].postln;
});
MIDIdef.noteOff(\myKeyUp, {arg vel, note;
noteArray[note].set(\gate, 0);
["NOTE OFF", note].postln;
});
)
// PS. Make sure SC MIDI connections are made (MIDIIn.connectAll)







(
m = MChanVoicer(0);
m.dump;

Ndef(\m, { |pitch=60, amp = 0.0|
    VarSaw.ar(pitch.midicps) * 0.5 * amp.lag(0.1) ! 2;
}).play;

m.noteEl.action = { |el| Ndef(\m).set(\pitch, el.deviceValue); };
m.velEl.action = { |el| Ndef(\m).set(\amp, el.value.squared); };
m.startFunc = { "roger, starting note, over".postln };
m.endFunc = { "over and out.".postln };

m.noteOn(64, 80);
m.noteOn(67, 40);
m.heldNotes; // two held notes
m.noteOff(67); // down to previous note
m.heldNotes;
m.noteOff(64); // now off

// connect a midi keyboard
MIDIIn.connectAll;

// single channel only
~non = MIDIFunc.noteOn({ |vel, note, chan|
    m.noteOn(note, vel);
}, nil, m.chan);

~nof = MIDIFunc.noteOff({ |vel, note, chan|
    m.noteOff(note, vel);
}, nil, m.chan);

// and add responders for bend and press ...
)

(
// With a rotating polyphony keyboard like the QuNexus, try this:

//s.boot; s.latency = nil;

g = NPVoicer(Ndef(\piano));     // make an NPVoicer with an Ndef in it
g.prime(\default);            // prepare it with the default synthdef
g.play;                    // play it

// test by hand
g.put(1, [\freq, 48.midicps]);
g.setAt(1, \freq, 60.midicps);
g.release(1);

// make 10 voicers
~voicers = (0..9).collect { |i|
    var v = MChanVoicer(i);
    var ii = i + 10;
    v.startFunc = { |voicer, note, vel|  g.put(ii, [\freq, note.midicps, \vel, (vel / 127).squared].postln); };
    v.noteEl.action = { |el| g.setAt(ii, \pitch, el.deviceValue); };
    v.velEl.action = { |el| g.setAt(ii, \amp, el.value.squared); };
    v.endFunc = { g.release(ii) };
};

// listen to all midi channels
MIDIIn.connectAll;
~non = MIDIFunc.noteOn({ |vel, note, chan|
    ~voicers[chan].noteOn(note, vel);
}, srcID: nil);

~nof = MIDIFunc.noteOff({ |vel, note, chan|
    ~voicers[chan].noteOff(note, vel);
}, srcID: nil);

// add full test here with bend and press control on each channel...
)



// linnstrument midi
// https://gist.github.com/kisielk/941ccd49b023c5b0e591a4967214d490

(
var notes, synths, on, off, mod, bend, touch;
~num_channels = 8;
~bend_range = 24;

MIDIIn.connectAll;

notes = Array.newClear(~num_channels);
synths = Array.newClear(~num_channels);

on = MIDIFunc.noteOn({ | vel, num, chan, src |
	// ("on" + chan + num + vel).postln;
	notes[chan] = num;
	synths[chan] = Synth(\default, [\freq, num.midicps, \amp, vel * (1.0/128.0)]);
});
off = MIDIFunc.noteOff({ | vel, num, chan, src |
	// ("off" + chan + num + vel).postln;
	synths[chan].release;
	notes[chan] = nil;
	synths[chan] = nil;
});
mod = MIDIFunc.cc({ | val, num, chan, src |
	// ("cc1" + chan + num + val).postln;
}, 1);
bend = MIDIFunc.bend({ | val, chan, src |
	var bend = ~bend_range * ((val - 8192)/8192);
	// ("bend" + chan + val).postln;
	if (synths[chan] != nil) {
		synths[chan].set(\freq, (notes[chan] + bend).midicps);
	};
});
touch = MIDIFunc.touch({ | val, chan, src |
	// ("touch" + chan + val).postln;
	if (synths[chan] != nil) {
		synths[chan].set(\amp, val * (1.0/128.0));
	};
});
q = {
	on.free;
	off.free;
	mod.free;
	bend.free;
	touch.free;
}
)
q.value;

// end linnstrument midi

