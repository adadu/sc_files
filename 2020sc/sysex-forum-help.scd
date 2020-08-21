(
s.quit;
o = Server.local.options;
// Fireface w/ ADAT OUTS activated
o.numOutputBusChannels = 20;
// disable SPDIF outputs
o.outputStreamsEnabled = "11111111110011111111";
// 0-9=ANALOG 0-9
// 10-11=SPDIF 1-2
// 12-19=ADAT OUT 1-8
o.numOutputBusChannels = 20;
// 0-9=ANALOG 0-9
//o.numInputBusChannels = 10;
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)

~m = MIDIOut.newByName("MIDI Express XT", "Port 2");
m = MIDIOut.newByName("MIDI Express XT", "Port 2");

// i'm looking to manipulate parameters via sysex on a Wavestation A/D with supercollider
// F0 42 31 28 41 71 00 7F [30] 00 F7
// F0 42 31 28 41 71 00 2B [39 39] 00 F7
// how does the minimum value of 30 increment to the max of 39 39? is this nrpn?
// any tweakers?

// data helper, how to insert nrpn into sysex?
0x1F.value;
0200 >> 7;
3939 >> 7;
1278 >> 7;

F0 42 30 28 //korg header
41 //param change msg
71 00//LSB param, param num listing is 117, this is hex val
2B //MSB param
43 //param value in 7bit ASCII, 16 char max, 7F=space, 2B is 43
00 // ASCII null temrination
F7 //end of sysex

// close, but doesn't work

// try writing a function that uses some of the data processing manifest heap uses

//Transmission format »ASCII Dec., 0-terminated«
// 7bit transmitted value = value * 127 / (max + 1 - min) or
// 14bit transmitted value = value * 16384 / (max + 1 - min)
(
~msb = {
	| val |
	// var msbNum = num >> 7;
	//var msbVal = val.asBinaryDigits;
	//var msbVal = val.asHexString(2);
	//var msbVal = "$" ++ val.ascii;
	//msbVal = msbVal.ascii;
	//var msbVal = val * 127 / (127 + 1 - 1);
	//msbVal = msbVal.ascii;
	var msbVal = val;
	if (val.notNil) {
		msbVal;
	};
};
)
~msb.(0);
$0.ascii;
//

"+".ascii
30 to 39  // 1e to 27
31 30 to 31 39 // 1f to 27
32 30 to 32 39
...
39 39 end // 27 27

0x1e.asHexString
1f
20
21
22
23
24
25 (37)
26
27 (39)

7f (127)

(
~sysExArrayB = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, ~m,
	\array, Ptuple([
		0xf0, 0x42, 0x30, 0x28, //Korg header, chan is 3rd byte 3n
		0x41, //Param change msg
		0x75, 0x00, //LSB of param number eg 117 for amp time release
		0x2b, //msb eg 43 in dec
		//Pseq((48..60),inf),
		//~msb.(-1230),
		~msb.(Pseq((0..127),inf)).trace, //Amp release level
		00, 0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, 0.1,
).play;
)

~testSys = Pbind(
	\type, \midi,
    \midicmd, \sysex,
	\midiout, ~m,
	\array, ~msb.(Pseq((0..127),inf)).trace

(
~ws1 = Pbind(\type, \midi, \midicmd, \noteOn, \midiout, ~m, \chan, 0,
	\scale, Pdefn(\wsScale, Scale.lydian),
	\tuning, Pdefn(\wsTuning, Tuning.mean6),
	\degree, Pdefn(\wsDegree, Pseq((12..12), inf)),
	// \note, Pdefn(\wsNote,3),
	\dur, Pdefn(\wsDur, 0.5),
	\sustain, Pdefn(\wsSustain),
	\amp, Pdefn(\wsAmp, 0.8),
	\octave, Pdefn(\wsOctave,Pseq((-1..5),inf)),
	\ctranspose, Pdefn(\wsCtranspose),
)
)

x = ~ws1.play;
x.stop;

(
Pdefn(\wsDegree, Pshuf([1,3,9,11], inf));
Pdefn(\wsScale, Scale.lydian);
Pdefn(\wsTuning, Tuning.mean6);
//Pdefn(\wsTuning, Tuning.pythagorean);
Pdefn(\wsDur, Pbjorklund2(Pexprand(2,8).round(1),8,inf,Pwhite(2,8).asStream)/8);
	//Pbjorklund2(Pexprand(3,5).round(1),2,inf,Pwhite(2,7).asStream)/8);
Pdefn(\wsAmp, Pwhite(0.1, 0.99, inf));
Pdefn(\wsOctave, Pshuf((1..3),inf));
)

~sysExArrayB.free

(
~sendNRPN = {
        | number, value, channel=1, midi_out=nil |
        var cCC_MSB = 99;
        var cCC_LSB = 98;
        var cDATA_MSB = 6;
        var cDATA_LSB = 38;
        var number_msb = number >> 7;
        var number_lsb = number & 127;
        var value_msb = value >> 7;
        var value_lsb = value & 127;
        if (midi_out.notNil) {
            midi_out.control(channel, cCC_MSB, number_msb);
            midi_out.control(channel, cCC_LSB, number_lsb);
            midi_out.control(channel, cDATA_MSB, value_msb);
            midi_out.control(channel, cDATA_LSB, value_lsb);
        };
    };
)
~sendNRPN.(117, 77, 1, ~m);



~msb1 = { |value |
        var b1 = value & 127;
        var b2 = (value >> 7) & 127;
}

~msb1.(60)


/*
I send values to nrpn with code like this (I cannot test at the moment but it's loosely based on code I use all the time with my prophet rev2 synth)


    sendNRPN = {
        | number, value, channel=1, midi_out=nil |
        var cCC_MSB = 99;
        var cCC_LSB = 98;
        var cDATA_MSB = 6;
        var cDATA_LSB = 38;
        var number_msb = number >> 7;
        var number_lsb = number & 127;
        var value_msb = value >> 7;
        var value_lsb = value & 127;
        if (midi_out.notNil) {
            midi_out.control(channel, cCC_MSB, number_msb);
            midi_out.control(channel, cCC_LSB, number_lsb);
            midi_out.control(channel, cDATA_MSB, value_msb);
            midi_out.control(channel, cDATA_LSB, value_lsb);
        };
    };

// try it: sendNRPN.(1024, 19, 1, mo);
// sends value 19 to NRPN 1024 on midi channel 1
// (fill in your own values of course)
// "mo" is an initialized and connected MidiOut instance

If you insist on sending it from a pattern, you could e.g.

p = Pbind(
     ...
     \mycustomkey, Pfunc({|ev| sendNRPN.(1024, 19, 1, mo); })
);
p.play;

The above would reevaluate mycustomkey, and therefore resend the value to the NRPN, everytime a new event is about to be generated. The code can be modified to send only once, or send only under certain conditions, etc.
manifest.heap@
*/

/*
Ah, there is one subtle error in the pattern.

First, let me reformat for legibility (and use .collect, which I find somewhat more idiomatic than Pfunc {} <> pattern).

~sysExArray = Pbind(
    \type, \midi,
    \midicmd, \sysex,
    \midiout, m,
    \array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x01, 0x22, Pseq((0..127), inf), 0xf7])
    .collect { |array| array.as(Int8Array) },
    \dur, 0.5
);

The catch is that "top-level" arrays in an event are interpreted in terms of multichannel expansion.

(freq: [a, b]).play will play two synths, one with frequency a, the other with b. It does *not* send one synth message with two frequencies. For that, you need (freq: [[a, b]]).

A sysex event with (array: Int8Array[a, b]) is interpreted as requiring two MIDI messages.

If the array itself is to be an argument for one message, then it needs to be wrapped in another array layer:

~sysExArray = Pbind(
    \type, \midi,
    \midicmd, \sysex,
    \midiout, m,
    \array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x01, 0x22, Pseq((0..127), inf), 0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
    \dur, 0.5
).play;

But the key point is the Ptuple -- Christof is right to point out that patterns within an array do not cause the entire array to be treated as a pattern.

hjh
*/

/*

// First get your midi device
MIDIClient.init;
~roland = MIDIOut("device name", "port name");
~channel = 0; // or whatever channel the synth is listening on

// Try this one including MSB and LSB value
(
~roland.control(~channel, 99, 0); // voice one
~roland.control(~channel, 98, 23); // lpf
~roland.control(~channel, 6, 0); // value MSB
~roland.control(~channel, 38, 64); // value LSB
)

// If that doesn't work, try this
(
~roland.control(~channel, 99, 0); // voice one
~roland.control(~channel, 98, 23); // lpf
~roland.control(~channel, 6, 64); // value
)
 wondersluyter@
*/

