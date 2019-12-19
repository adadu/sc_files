//AtsCalibration
// look up my edited help files
// edited AtsCalibration.sc for hardware

/*
Example loading Expert Sleepers ES-3
*/

(
//Define the number of inputs and outputs for the ES-8
o = Server.local.options;
// Fireface w/ ADAT OUTS activated
// s.options.numOutputBusChannels = 20;
// disable SPDIF outputs
o.outputStreamsEnabled = "11111111110011111111";
// 0-9=ANALOG 0-9
// 10-11=SPDIF 1-2
// 12-19=ADAT OUT 1-8
o.numOutputBusChannels = 20;
// 0-9=ANALOG 0-9
o.numInputBusChannels = 10;
//SERVER and BUFFER
//increased buffers for samples
o.numBuffers = 1024 * 16;
//set memory size
//this is about 1GB, may vary based on RAM
o.memSize=2.pow(20);
Server.internal.options.memSize =2.pow(20);
//load the ES-3 Device
o.device = "ES-3";
//boot the server
s.boot;
)

// ATS

c=nil;
c = AtsCalibration.init(s);
c.initGui(2, s);

// Plot calibration data
(
//[cv-data, freqs, amps]
~mydatapoints[1][1].asArray.plot;
["Min Freq:", ~mydatapoints[1][1].asArray.sort.first, "Max Freq:", ~mydatapoints[1][1].asArray.sort.last];
)

replug
lin
pwm w
1v exp cv in
sin out, pulse out