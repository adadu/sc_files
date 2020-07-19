
/*
connect hardware (thunderbolt 3/thunderbolt 2 > thunderbolt 2/firewire 800 > firewire 800 cable > rme fireface 800
boot computer, turn on audio interface
open ubuntustudio-controls, cpu governor performance, intel boost off (first time only)
select firewire, sampling rate 48000, jack buffer size/latency 128, peroids 2
open ffado mixer for graphical control of most rme fireface800 settings
ctrl-m for levels, right click to select 'always on top'
TO DO:
? disable pulse to jack bridge and bridge usb devices ?? this may not be necessary
? can midi also work?
*/

/*
2020feb20
played w more settings, some ndef, some jitlib tutorials, experimented with particular grain synth.

*/


s.quit

(
//set number of inputs and outputs
s.options.numInputBusChannels= 10;
s.options.numOutputBusChannels= 20;

// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2"); //note that i've only enabled 2
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 spdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10,system:playback_11,system:playback_12,system:playback_13,system:playback_14,system:playback_15,system:playback_16,system:playback_17,system:playback_18,system:playback_19,system:playback_20");
// setup for using Audient iD4 usb, would need alsa
// "SC_JACK_DEFAULT_INPUTS".setenv("iD4:capture_1,iD4:capture_2");
// "SC_JACK_DEFAULT_OUTPUTS".setenv(iD4:playback_1, iD4:playback_2");
s.boot
)

z = Sleet.new(numChannels: 2);
SleetTest1


Platform.resourceDir

p = Particular.new(numChannels: 2);
b = Buffer.readChannel(s, "/home/jea/git/samples/001set/clap/dr110.clap.wav", channels:[1]);
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
// Random sine grains
(
~nins = Pdef(\g1,
    Pbind(
		\instrument, p.def("sinc", "fm"),
        \dur, 0.125,
        \freq, Pwhite(0.0,1.0),
		//\pan, Pexprand(-1.00,1.00,inf)
    )
).play;
)
p.postEnvs
p.postSynths
p.defs
p.panFunction

(
// Simple time stretch
Pdef(\timeStretch,
    Pbind(
        \instrument, p.def("hann", "buf1"),
        \buffer, b,
        \timestretch, 12,
        \overlaps, 3, // Overlap between grains
        \bufdur, Pkey(\timestretch) * Pfunc({|ev| ev[\buffer].duration}),
		\start, Pseg([0, 1], Pkey(\bufdur), \exp, inf), // Buffer pointer
        \freq, Pexprand(0.9,0.80,inf), // Playback rate
		\dur, Pexprand(0.12,0.01,inf), // Duration of each sound event
        \sustain, Pkey(\overlaps) * Pkey(\dur),
		\pan, Pkey(\start) // Pan follows buffer pointer
    )
).play;
)

~nins.clear
~nins


Quarks.gui

Quarks.install("https://github.com/jrsurge/SuperDiffuse")


{ Klang.ar(`[ {exprand(400, 2000)}.dup(16), nil, nil ], 1, 0).dup * 0.04 }.scope(2);
{ Klank.ar(`[[200, 671, 1153, 1723], nil, [1, 1, 1, 1]], Impulse.ar(2, 0, 0.1)) }.play;
{ Formlet.ar(Impulse.ar(MouseX.kr(2,300,1), 0, 0.4), 800, 0.01, 0.1) }.scope(1, zoom:4);
(
// Dust randomly triggers Decay to create an exponential
// decay envelope for the WhiteNoise input source
{
z = Decay.ar(Dust.ar(1,0.5), 0.3, WhiteNoise.ar);
DelayN.ar(z, 0.1, 0.1, 1, z); // input is mixed with delay via the add input
}.scope(1, zoom: 4)
)

(
{
z = Decay.ar(Impulse.ar(2,0,0.4), 0.3, WhiteNoise.ar);
DelayL.ar(z, 0.3, MouseX.kr(0,0.3), 1, z); // input is mixed with delay via the add input
}.scope(1, zoom: 4)
)

(
{
    var z;
    z = Decay.ar(Dust.ar(1,0.5), 0.1, WhiteNoise.ar);
    8.do { z = AllpassL.ar(z, 0.04, 0.04.rand, 2) };
    z
}.scope(1);
)


(
{
    // mixing sine oscillators in parallel
    var n = 16; // number of structures to make
    // mix together  parallel structures
    Mix.fill(n,
            {
                var amp;
                amp = FSinOsc.kr(exprand(0.1,1),2pi.rand).max(0);
                Pan2.ar(
                    FSinOsc.ar(exprand(100,1000.0), 0, amp),
                    1.0.rand2)
            }
    ) / (2*n)            // scale amplitude
}.scope(2);
)

(
{
    var n;
    n = 64; // number of 'voices'
    Mix.ar( // mix all stereo pairs down.
        Pan2.ar( // pan the voice to a stereo position
            CombL.ar( // a comb filter used as a string resonator
                Dust.ar( // random impulses as an excitation function
                    // an array to cause expansion of Dust to n channels
                    // 1 means one impulse per second on average
                    1.dup(n),
                    0.3 // amplitude
                ),
                0.01, // max delay time in seconds
                // array of different random lengths for each 'string'
                {0.004.rand+0.0003}.dup(n),
                4 // decay time in seconds
            ),
            {1.0.rand2}.dup(n) // give each voice a different pan position
        )
    )
}.scope(2, zoom:4);
)


//Platform.resourceDir
(
Ndef(\lv, {
    Mix(
        LeakDC.ar(
            LotkaVolterra.ar(SampleRate.ir*0.5,
                a: {LFNoise2.ar(Rand(0.000174, 0.00174)).range(0.49, 0.5)}!3,
                b: \b.kr(1.5, 0.1),
                c: {LFNoise2.ar(Rand(0.000174, 0.00174)).range(2, 4)}!4, // \c.kr(0.5, 0.1),
                a: {LFNoise2.ar(Rand(0.000174, 0.00174)).range(0.4, 0.41)}!4,
                h: \h.kr(0.01).lag2(1) * [0.5, 1, 2, 4],
                xi: 0.1 + \tr.tr(1)) * 0.2
        ) * [5, 3, 3, 1].normalizeSum;
    ).tanh
});

)

Ndef(\lv).set(\tr, 0.1)

Ndef(\lv).set(\a, 3.029850, \b, 4.094132, \c, 1.967217, \d, 2.295942);




Ndef(\lv).scope

Ndef(\lv).edit


//ATK troubleshooting

Platform.userExtensionDir.postln;
Platform.userExtensionDir.openOS;
Atk.openUserSupportDir;

/*
OPEN THE MOSCA GUI (edit to suit your situation)
*/

(
s = Server.local;
s.quit;
o = s.options;
//o.numAudioBusChannels = 2048;
o.numInputBusChannels = 10;
o.numOutputBusChannels = 10; // eg. 2 for stereo, 4 for 1st order ambisonics & 9 for 2nd order
// connect first to input channels with system
"SC_JACK_DEFAULT_INPUTS".setenv("system:capture_1,system:capture_2"); //note that i've only enabled 2
// connect all output channels with system
// rme fireface800 1-10 analog audio out, 10-11 .,mnbvspdif, 12-20 adat 1 out (0 is ch1, and linux jack won't allow enable/disable streams)
"SC_JACK_DEFAULT_OUTPUTS".setenv("system:playback_1,system:playback_2,system:playback_3,system:playback_4,system:playback_5,system:playback_6,system:playback_7,system:playback_8,system:playback_9,system:playback_10");
o.memSize = 64 * 8192;
o.numAudioBusChannels = 2048;
o.numWireBufs = 512;
s.waitForBoot {

// Add a SC internal decoder (1st order only)
// See the ATK docs for more info: http://doc.sccode.org/Classes/FoaDecode.html
//~decoder = FoaDecoderKernel.newUHJ;
s.sync;
~decoder = FoaDecoderKernel.newCIPIC(21); // Binaural
//5.wait;
s.sync;

MIDIIn.connect(inport: 0, device: 0);  // must connect to MIDI for MMC synch
s.sync;

/*Create a project directory and in it create to more directories "rir" and "auto". Place your ambisonic rirs in the rir folder. For some demo rirs and ambisonic recordings see the zip archive here: http://escuta.org/mosca

Create Mosca instance with arguments (projDir, nsources: 1, width: 800, dur: 180, rir: "allpass", server, decoder). If <decoder> is left blank, Mosca will send 2nd order and 1st order signals out of SC's outputs for decoding with an external decoder. */

// Use FreeVerb filter reverberation

~testMosca = Mosca.new(projDir: "/home/jea/git/moscatests", nsources: 11, width: 965, dur: 60, rir: "FreeVerb", freeroom: 0.5, freedamp: 0.5, decoder: ~decoder);

// without headtracking with rir supplied in the zip file mentioned above.

//~testMosca = Mosca.new(projDir: "/path/to/your/moscaproject", nsources: 12, width: 965, dur: 60, rir: "QL14Tail2Sec.amb", decoder: ~decoder);


// with headtracking (used with binaural decoder)

//~testMosca = Mosca.new(projDir: "/path/to/your/moscaproject", nsources: 12, width: 865, dur: 60, rir: "QL14Tail2Sec.amb", decoder: ~decoder, serport: "/dev/head_tracker", offsetheading: -2.6, recchans: 2, recbus: 0);



// Use RIR and send raw 1st order ambi sginal to outputs (channels 2-10)
//using no decoder, a raworder of 1 and rawbus value of 2.

//~testMosca = Mosca.new(projDir: "/path/to/your/moscaproject", nsources: 12, width: 995, dur: 60, rir: "QL14Tail2Sec.amb", rawbusfoa: 2, rawbussoa: 6, raworder: 2);


s.sync;


// use the following to experiment with heading adjustments
//~testMosca.offsetHeading(0.38);
};

)

// If you close the Mosca window, don't forget to free the decoder afterwards

(
(
~testMosca.free;
~decoder.free;
MIDIIn.disconnect(inport: 0, device: 0);
)