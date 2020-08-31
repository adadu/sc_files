/*
I'm hoping to get some help with sending sysex to a Korg Wavestation A/D. I've searched the forums, but the closest I've come up with is my last sysex ask for help, with a different synth (Roland MKS-70). I apologize in advance for how epic my post is here, I've tried to make it somewhat easy with comments/symbols to just copy/paste this into SC. SC code is up front here, more info below that.

There's probably a simple thing I'm doing wrong relating to comparing values as generated from a Pseq sent to a function. I get a Pbinop /non boolean error. But there's probably also a much more efficient way to achieve what I'm trying to do... which is simply adjusting params on an external hardware synth in time with patterns.
*/

// BEGIN SC code
(
s.quit;
//boot
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)

//midi out on macOS
~m = MIDIOut.newByName("X MIDI interface", "Port X");

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
{msbVal < 58} {msbVal}
{msbVal < 68} {[49,msbVal-10]}
{msbVal < 78} {[50,msbVal-20]}
{msbVal < 88} {[51,msbVal-30]}
{msbVal < 98} {[52,msbVal-40]}
{msbVal < 108} {[53,msbVal-50]}
{msbVal < 118} {[54,msbVal-60]}
{msbVal < 128} {[55,msbVal-70]}
{msbVal < 138} {[56,msbVal-80]}
{msbVal < 148} {[57,msbVal-90]}
/*
values 99-127, if desired
{msbVal < 158} {[58,msbVal-90]}
{msbVal < 168} {[59,msbVal-90]}
{msbVal < 178} {[60,msbVal-90]};
*/
if (val.notNil) {
if (msbVal < 58, {p}, {p.join(", ")});
};
};
)

~msb.(127);
// test. 0-9 returns single number. 10-99 returns two values.

(
~sysExArrayB = Pbind(
    \type, \midi,
    \midicmd, \sysex,
\midiout, ~m,
\array, Ptuple([
0xf0, 0x42, 0x30, 0x28, //Korg header, chan is 3rd byte 3n
0x41, //Param change msg
0x75, 0x00, //LSB of param number for amp time release
0x2b, //MSB of param number
/*
This works to access full range, but is too limited/not ideal
		*/
Pseq((0..9)+48,inf).stutter(10).trace,
Pseq((0..9)+48,inf),


/*
THIS IS NOT WORKING (~msb part below)
^^ The preceding error dump is for ERROR: Non Boolean in test.
RECEIVER: a Pbinop
*/
//~msb.(Pseq((0..99),inf)), //Amp release time
0x00, 0xf7])
    .collect { |array| [array.as(Int8Array)] },  // <<-- brackets here
\dur, 0.05,
).play;
)
// END SC code

/*
I want to be able to send a 0-127 (or 0-99) value range with a pattern to adjust parameters on the Wavestation. The challenge I'm running into is that the synth wants values in a very specific way - the manual describes it as "Parameter value in 7bit ASCII (16 characters max) (7F = space)". In researching this I saw a reference calling this "Transmission format »ASCII Dec., 0-terminated", and "7bit transmitted value = value * 127 / (max + 1 - min) or 14bit transmitted value = value * 16384 / (max + 1 - min)" - from (Emagic's Apple Sounddiver programming manual 1997, http://www.deepsonic.ch/deep/docs_manuals/emagic_apple_sounddiver_programming_manual.pdf)

Sending a Pseq((0-127)+48 will send 0-9 on the synth's parameters that allows for a 0-99 range. I can access the entire range by sending two Pseqs, but I don't want to have to do it that way.
// Pseq((0..9)+48,inf).stutter(10).trace,
// Pseq((0..9)+48,inf),

Looking at the transmitted output by adjusting the encoder I can see its range:
min: F0 42 31 28 41 71 00 7F [30] 00 F7
max: F0 42 31 28 41 71 00 2B [39 39] 00 F7

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

F0 42 3n 28 Wavestation sysex header
01000001 (42) Parameter Change Message
0LLLLLLL LSB of parameter number
(section 5.12)
0HHHHHHH MSB of parameter number
0xxxxxxx Parameter value in 7bit ASCII
- (16 characters max) (7F = space)
-
00000000 (00) ASCII null termination
11110111 (F7) End of exclusive

5.12 Parameter Number Table (page 143)
/* 117 */ AMP_ENV_RATE_4,
***
*/

/*
Thanks in advance for your help!!
JEA
*/