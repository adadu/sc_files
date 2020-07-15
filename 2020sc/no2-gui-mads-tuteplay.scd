//no2-gui-mads-tuteplay
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

//uses neovim and scnvim
// simple app of sc with gui

(
var numSliders = 4;
var numButtons = 2;
var sliders, buttons, sliderLayout, buttonLayout, layout;

w = Window.new;

sliders = numSliders.collect {
	Slider.new
	.action_({|obj| obj.value.postln })
	.background_(Color.rand(0.25,0.9))
};

buttons = numButtons.collect {
	Button.new
};

//magic
sliderLayout = HLayout.new(*sliders);
buttonLayout = VLayout.new(*buttons);

//final layout
layout = VLayout(buttonLayout, sliderLayout);

//start button
buttons[0]
.states_(
	[["Start", Color.black, Color.rand]]
)
.action_({|obj|
	Pdef(\quar).play
}
);

//stop button
buttons[1]
.states_(
	[["Stop", Color.black, Color.rand]]
)
.action_({|obj|
	Pdef(\quar).stop
}
);

//slider actions

//slider1
sliders[0]
.action_({|obj|
	// scale the duration make sure it is not zero
	var val = obj.value;
	val = val.linlin(0.0,1.0, 0.05, 1.0);
	Pdefn(\qdur, val)
});

//slider 2
sliders[1]
.action_({|obj|
var val = obj.value;
	val = val.linlin(0.0,1.0, 0.00, 7.0);
	Pdefn(\qdeg, Pwhite(0,val))
});

//slider 3 change oct
sliders[2]
.action_({|obj|
var val = obj.value;
	val = val.linlin(0.0,1.0, 2, 10);
	Pdefn(\qoct, val)
});

//slider 4 change amp
sliders[3]
.action_({|obj|
var val = obj.value;
	val = val.linlin(0.0,1.0, 0.00, 0.75);
	Pdefn(\qamp, val)
});

w.layout = layout;

w.front;
)

(
Pdef(\quar,
	Pbind(
		\dur, Pdefn(\qdur, 0.25),
		\degree, Pdefn(\qdeg, 0),
		\octave, Pdefn(\qoct, 4),
		\amp, Pdefn(\qamp, 0.5),
		)
).play
)
 