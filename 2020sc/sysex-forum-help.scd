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

~t = MIDIOut.newByName("MIDI Monitor (Untitled)","MIDI Monitor (Untitled)");

~m = MIDIOut.newByName("MIDI Express XT", "Port 2");
m = MIDIOut.newByName("MIDI Express XT", "Port 2");

//Transmission format »ASCII Dec., 0-terminated«
// 7bit transmitted value = value * 127 / (max + 1 - min) or
// 14bit transmitted value = value * 16384 / (max + 1 - min)

(
~lsb = {
	| lsb |
	var lsbVal = lsb;
	if (lsb.notNil, {lsbVal}, {0x7f});
};
)

/*
I'm hoping to get some help with sending sysex to a Korg Wavestation A/D. I've searched the forums, but the closest I've come up with is my last sysex ask for help, with a different synth (Roland MKS-70). There's probably a simple thing I'm doing wrong relating to comparing values as generated from a Pseq sent to a function. I get a Pbinop /non boolean error. But there's probably also a much more efficient way to achieve this, simply adjusting params on an external hardware synth in time with patterns.

I want to be able to send a 0-127 (or 0-99) value range with a pattern to adjust parameters on the Wavestation. The challenge I'm running into is that the synth wants values in a very specific way - the manual describes it as "Parameter value in 7bit ASCII (16 characters max) (7F = space)". In researching this I saw a reference calling this "Transmission format »ASCII Dec., 0-terminated", and "7bit transmitted value = value * 127 / (max + 1 - min) or 14bit transmitted value = value * 16384 / (max + 1 - min)" - from (Emagic's Apple Sounddiver programming manual 1997, http://www.deepsonic.ch/deep/docs_manuals/emagic_apple_sounddiver_programming_manual.pdf)

Sending a Pseq((0-127)+48 will send 0-9 on the synth's parameters that allows for a 0-99 range. I can access the entire range by sending two Pseqs, but I don't want to have to do it that way.
	Pseq((0..9)+48,inf).stutter(10).trace,
	Pseq((0..9)+48,inf),

Looking at the transmitted output by adjusting the encoder I can see its range:
	min:	F0 42 31 28 41 71 00 7F [30] 00 F7
	max:	F0 42 31 28 41 71 00 2B [39 39] 00 F7

So this is what I've determined I want to be sending. The value (VAL) is the tricky part:
	0 42 30 28 // Korg header
	41 // Param change msg
	71 00 // LSB param, param num listing is 117
	2B // MSB param
	VAL //param value in 7bit ASCII, 16 char max, 7F=space
	00 // ASCII null temrination
	F7 //end of sysex

I created a function that adds 48 to incoming values (expecting 0-127 midi values) and then evaluates it with a case statement to output either 30..39 or [30..39, 31..39]. Explained another way, this means that when it receives one value from 0-9, it returns one value ranging from 30 to 39. When the incoming value is greater than 9, it returns 2 values, the first franges from 30 to 39, the second ranges from 31 to 39. There's a bit at the end that returns values if not nil, and if that value is an array, it joins the two numbers, removing array brackets.

Manual excerpts:

***
KORG WAVESTATION A/D PERFORMANCE NOTES
Appendix 4: MIDI SYSTEM EXCLUSIVE FORMAT
https://www.korg.com/us/support/download/manual/1/225/1557/

2.1.14 Parameter Change Messages (page 129)
	The normal parameter change messages include parameters
	numbered up to 379.

	F0 42 3n 28		Wavestation sysex header
	01000001 (42)	Parameter Change Message
	0LLLLLLL		LSB of parameter number
					 (section 5.12)
	0HHHHHHH		MSB of parameter number
	0xxxxxxx		Parameter value in 7bit ASCII
		-			 (16 characters max) (7F = space)
		-
	00000000 (00)	ASCII null termination
	11110111 (F7)	End of exclusive

5.12 Parameter Number Table (page 143)
	/* 117 */	AMP_ENV_RATE_4,
***

*/

// BEGIN SC code

/*(
s.quit;
//boot
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)

//midi out on macOS
~m = MIDIOut.newByName("X MIDI interface", "Port X");*/

(
~msb = {
	| val = nil |
	/*
	map range 0-127 to 0-99 to match hardware, if desired
	var msbVal = val.linlin(0,127,0,99).asInteger+48;
	*/
	var p;
	var msbVal = val+48;
	p=case
		{msbVal == 0}	{7F, msbVal}
		{msbVal < 58}	{msbVal}
		{msbVal < 68}	{[49,msbVal-10]}
		{msbVal < 78}	{[50,msbVal-20]}
		{msbVal < 88}	{[51,msbVal-30]}
		{msbVal < 98}	{[52,msbVal-40]}
		{msbVal < 108}	{[53,msbVal-50]}
		{msbVal < 118}	{[54,msbVal-60]}
		{msbVal < 128}	{[55,msbVal-70]}
		{msbVal < 138}	{[56,msbVal-80]}
		{msbVal < 148}	{[57,msbVal-90]};
		/*
		values 99-127, if desired
		{msbVal < 158}	{[58,msbVal-90]}
		{msbVal < 168}	{[59,msbVal-90]}
		{msbVal < 178}	{[60,msbVal-90]};
		*/

	/*if (val.notNil) {
		//if (msbVal < 58, {p}, {p.flat});
			if (msbVal < 58, {p}, {p.join(", ")});
	};*/
};
)

~msb.(99);
// test. 0-9 returns single number. 10-99 returns two values.

(
~sysExArrayB = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, ~t,
	\array, Ptuple([
		0xf0, 0x42, 0x30, 0x28, //Korg header, chan is 3rd byte 3n
		0x41, //Param change msg
		0x75, 0x00, //LSB of param number for amp time release
		//0x2b, //MSB of param number
		Pseq((0..99),inf).collect(~msb), //Amp release time
		0x00, 0xf7])
    .collect { |array| [array.flat.as(Int8Array)] },  // collected to arr, flat, as Int8Arr
	\dur, 0.3,
).play;
)

// END SC code

/*
Thanks in advance for your help!!
JEA
*/



/*
new from http://www.soundquest.org/Help/MidiQuest11/techdocs-macrolang.htm

Write Value as Text into Data

This command is used by the Korg Wavestation to write a value into into the SysEx message and terminate it with an F7H

GW (W..Z,V) n

where

W..Z,V = the contents of any variable

n = the offset into the current data pointer to write the current value in ASCII with an F7 terminator
*/

/*
new from https://kentonuk.com/wp-content/uploads/2019/06/cfrkman.pdf

Sx Ascii M/ I / Lsb38 bit value sent, split over 3 bytes. eg: 123 sent as ascii for 1 then ascii for 2 then ascii for 3sent most significant byte first. Unique to the Korg Wavestation as far as we know.
*/

//MKS-70 sysex
(
~sysExArray = Pbind(
    \type, \midi,
    \midicmd, \sysex,
	\midiout, d[\m7],
	\array, Ptuple([0xf0, 0x41, 0x36, 0x00, 0x24, 0x20, 0x01,
		0x36, Prand((0..80), inf), //env2 sus param, value
		0x37, Prand((0..60), inf), //env2 rel param, value
		0x22, Prand((40..80), inf), //LPF Cutoff param, value
		0x0D, Pseq((1..127), inf, 2), //DCO 1 Tune param, value
		0x13, Pseq((1..127), inf, 3), //DCO 2 Tune param, value
		0x0C, Pexprand(40, 127, inf), //DCO 1 Waveform param, value
		0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
	\dur, Pbjorklund2(Pexprand(2,11).round(1),33,inf,Pwhite(1,5).asStream)/4,
).play;
)
~sysExArray.free



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


(
~msb1 = { |value |
        var b1 = value & 127;
        var b2 = (value >> 7) & 127;
		b1;
};
)

~msb1.(60);


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

