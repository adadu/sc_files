// Korg Wavestation A/D sysex parameter changes via patterns
// BEGIN SC code
// see also this sc-users thread: https://www.listarc.bham.ac.uk/lists/sc-users/msg68360.html
(
s.quit;
//boot
s.boot;
//midi
MIDIClient.init;
MIDIClient.destinations;
)

// MAC OS
//midi out on macOS
~m = MIDIOut.newByName("X MIDI interface", "Port X");
//midi out on linux
~l = MIDIOut.newByName("mid16x", "mid16x MIDI 2").latency = (0); // (0.2555)

(
~msb = {
    | val = nil |
    /*
    optional part 1 of 2:
    map standard midi range 0-127 to 0-99 to match hardware
    var msbVal = val.linlin(0,127,0,99).asInteger+48;
    */
    var p;
    var msbVal = val+48;
    p=case
    /*
    work in progress:
    possible inclusion of 7F (127) when msb is zero
    it works to just use msb of param number, but could cause trouble w other params?
    {msbVal == 0} {7F, msbVal}
    */
    {msbVal < 58} {msbVal}
    {msbVal < 68} {[49,msbVal-10]}
    {msbVal < 78} {[50,msbVal-20]}
    {msbVal < 88} {[51,msbVal-30]}
    {msbVal < 98} {[52,msbVal-40]}
    {msbVal < 108} {[53,msbVal-50]}
    {msbVal < 118} {[54,msbVal-60]}
    {msbVal < 128} {[55,msbVal-70]}
    {msbVal < 138} {[56,msbVal-80]}
    {msbVal < 148} {[57,msbVal-90]};
    /*
    optional part 2 of 2
    values 99-127
    {msbVal < 158} {[58,msbVal-90]}
    {msbVal < 168} {[59,msbVal-90]}
    {msbVal < 178} {[60,msbVal-90]};
    */

    if (val.notNil) {
    p;
    };
};
)

(
~sysExArrayB = Pbind(
    \type, \midi,
    \midicmd, \sysex,
    \midiout, ~l,
    \array, Ptuple([
    0xf0, 0x42, 0x30, 0x28, //Korg header, chan is 3rd byte 3n
    0x41, //Param change msg
    0x75, 0x00, //LSB of param number for amp time release
    0x2b, //MSB of param number, tho manual says 0 should = 7F (127)
    Pseq((0..99),inf).collect(~msb), //Amp release time
    0x00, 0xf7])
    .collect { |array| [array.flat.as(Int8Array)] },  // collected to arr, flat, as Int8Arr
\dur, 0.3,
).play;
)
// END SC code