AtsCalibration {

	*init {arg server_;

		SynthDef(\testOSC3h, {arg id=1,input=1,out=0,cv=1.neg;
			var in,freq, hasFreq, trig;
			in = SoundIn.ar(input);
			trig = Impulse.kr(100);
			//Tartini is much better at pitch tracking than Pitch.kr
			# freq, hasFreq = Tartini.kr(LPF.ar(in,9999));
			//# freq, hasFreq = Pitch.kr(LPF.ar(in,9999));

			Out.ar(out, K2A.ar(cv));

			SendTrig.kr(trig, (id*10)+10, freq );
			SendTrig.kr(trig, (id*10)+11, cv);
			SendTrig.kr(trig, (id*10)+12, Amplitude.kr(in,0,1));
		}).send(server_);

		~freq2cv = {arg freq, frequencyarr, controlvoltagearr;
			var index1, maxmindiff, freqdiff, cvmaxmindiff, cvdiff;

			if(freq<=frequencyarr[0])
			{
				controlvoltagearr[0];
			}{
				if(freq>=frequencyarr.asArray.last)
				{1}{
					if(freq>=frequencyarr[frequencyarr.size-1])
					{
						controlvoltagearr[controlvoltagearr.size-1];
					}{
						index1 =  (frequencyarr.asArray).indexOfGreaterThan(freq);
						maxmindiff=  (frequencyarr.asArray)[index1]-(frequencyarr.asArray)[index1-1];
						cvmaxmindiff=(controlvoltagearr.asArray)[index1]-(controlvoltagearr.asArray)[index1-1];
						freqdiff=freq-(frequencyarr.asArray)[index1-1];
						((controlvoltagearr.asArray)[index1-1]) + (cvmaxmindiff*(freqdiff/maxmindiff));
					};
				};
			};
		};

		//function that collects voices that can synthesize at each partial

		~voicesperpartial={arg arr;
			var out = LinkedList.new;
			(1+arr.flatten.sort.last).do({ arg item, i;
				out.add(LinkedList.new);
				arr.size.do({arg item2, i2;
					if(arr[i2].includes(i))
					{
						out[i].add(i2);
					};
				});
			});
			out;
		};

		/* example
		~voicesperpartial.value([ LinkedList[ 1, 2, 3, 4, 5, 6, 7, 8, 9], LinkedList[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ]);
		~voicesperpartial.value([ LinkedList[ 1, 2, 3, 4, 5, 6, 7, 8, 9], LinkedList[ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ] ,LinkedList[ 5, 6, 7, 8, 9, 10 ],LinkedList[ 9, 10 ] ]);
		*/

		~voice_sort2 = {arg arr, partials, nvoices;
			var voice_index=0, partial_index = 0, pass_index = 0, out=LinkedList.new, temparr=LinkedList.new.add(LinkedList.new);

			while ({partial_index < partials.size}, {
				if(arr[partials[partial_index]].isEmpty)
				{
					partial_index=partial_index+1;
				}{
					if(arr[partials[partial_index]].includes(voice_index))
					{
						temparr[pass_index].add([partials[partial_index],voice_index]);
						voice_index=voice_index+1%nvoices;
						partial_index = partial_index + 1;

						if(voice_index==0)
						{
							temparr.add(LinkedList.new);
							pass_index=pass_index+1;
						};
					}{
						voice_index=voice_index+1%nvoices;
					};
				};
			});

			temparr.do({ arg item;
				if(item.size==0){}{
					out.add(item)};
			});
			out.postcs;
		};

		/*
		x = ~voice_sort2.value(LinkedList[ LinkedList[ 0 ], LinkedList[ 0, 1 ], LinkedList[ 0, 1, 2 ], LinkedList[ 0, 1, 2 ], LinkedList[ 0, 1, 2 ], LinkedList[ 2 ], LinkedList[ 2 ] ],3);
		x.postln;
		*/

		//helper function removes unused calibration units
		~no_nil = {arg arr;
			var out= LinkedList.new;
			arr.do({arg item,i;
				if(item[0] != nil)
				{
					out.add(item);
				};
			});
			out;
		};

		/*
		write file of cv calibration data to be read for synthesis
		LinkedList[[LinkedList[CV-DATA],[CV-FREQ]...] ]
		*/

		~list_to_file = {arg out_file, arr_to_file, button_;
			var arr_to_file2 = LinkedList.new;

			Routine{
				out_file.write("LinkedList[ ".asString);
				arr_to_file.size.do({ arg item3, i3;
					"voice".postln;
					0.5.wait;
					2.do({ arg item2, i2;
						arr_to_file[i3][i2].do({ arg item,i;
							if((i2==0)&&(i==0))
							{
								out_file.write("[ ".asString);
							};
							if(i==0)
							{
								out_file.write("LinkedList[ ".asString);
							};
							if(arr_to_file[i3][i2].size-1!=i)
							{
								out_file.write(item.asCompileString++", ");
							}{
								out_file.write(item.asCompileString)
							};
							if( (arr_to_file[i3][i2].size - 1) == i)
							{
								out_file.write("] ".asString);
								if( i2==0 )
								{
									if(((arr_to_file.size) != i3)){	out_file.write(", ".asString);};
								};
								if( i2==1)
								{
									out_file.write("] ".asString);
									if(((arr_to_file.size-1) != i3))
									{
										out_file.write(", ".asString);
									};
								};
							};
						});
					});
				});
				out_file.write("] ".asString);
				out_file.close;
			};
		};

		//Create CV and Freq pairs
		~mydatapoints = LinkedList.new;
		~syntharr=LinkedList.new;
	}



	*initGui {arg numunits = 1, server_, min_text_val_input = 0.09, max_text_val_input = 0.79;
		var cvout=1.neg, cvout2=LinkedList.new, freq=440, farr= LinkedList.new, amparr= LinkedList.new, cvoutinc = 0.005, calibration_time_resolution = 0.1, cvarr = LinkedList.new, freqlist=LinkedList.new,  oscarr=LinkedList.new, amplist=LinkedList.new, freq_routine, amp_routine, cvmins = Array.fill(numunits,1.neg), cvmaxes = Array.fill(numunits,1), subdivisions = 400,
		/*
		GUI elements
		*/
		fnumberboxes = LinkedList.new, cvnumberboxes = LinkedList.new, ampnumberboxes= LinkedList.new, maxbutton = LinkedList.new,  freqbox=LinkedList.new, close_button, file_button, freq_calibration_button=LinkedList.new, amp_calibration_button=LinkedList.new, wsize, adder, guioffset=150, newoffset=0, display_window, text_var, popup_menu_output, popup_menu_input, number_box, number_box2, start_button, min_max_button, minvaltextbox = LinkedList.new, maxvaltextbox = LinkedList.new, min_text_val, max_text_val;

		//column auto-layout GUI when  numunits > 4
		if(numunits>4)
		{
			wsize=(8*guioffset*2)/2.6;
		}{
			wsize=(guioffset*2.7)+10;
		};

		if(numunits>3)
		{
			adder=4;
		}{
			adder=numunits;
		};

		display_window = Window.new("Oscillator Calibration",Rect(128, 64, wsize, adder*guioffset+35));

		display_window.view.background_(Color.new255(171,225,255,255));

		numunits.do({ arg item, i;
			~mydatapoints.add(Array.newClear(3));
			freqlist.add(LinkedList.new.add(freq));
			amplist.add(LinkedList.new.add(0));
		});

		numunits.do({ arg item, i;
			StaticText(display_window, Rect(303+newoffset,((i%4)*guioffset)+90,45,25)).string = "MIN";

			StaticText(display_window, Rect(344+newoffset,((i%4)*guioffset)+90,45,25)).string = "MAX";

			min_text_val = NumberBox(display_window, Rect(295+newoffset,((i%4)*guioffset)+110,40,20));
			min_text_val.value = min_text_val_input;
			min_text_val.action = {arg numb;
				"set the starting voltage".postcs;
				cvmins[i] = numb.value;
				//cvnumberboxes[i].value= numb.value;
				numb.postcs;
				cvmins.postcs;

			};
			minvaltextbox.add(min_text_val);


			max_text_val = NumberBox(display_window, Rect(340+newoffset,((i%4)*guioffset)+110,40,20));
			max_text_val.value = max_text_val_input;
			max_text_val.action = {arg numb; "set the starting voltage".postcs;
				numb.postcs;
				cvmaxes[i] = numb.value;
			};
			maxvaltextbox.add(max_text_val);


			freqbox.add(i+1);
			farr.add(freq);
			amparr.add(0);
			cvout2.add(cvout);
			cvarr.add(LinkedList.new.add(cvout));

			//Create CV calibration synths and store them
			~syntharr.add(Synth.new("testOSC3h").set(\id, i, \input, i+1, \out, i, \cv, -1));

			//GUI
			if(i>=4)
			{
				newoffset=500;
			};

			text_var = StaticText(display_window, Rect(20+newoffset, ((i%4)*guioffset)+30, 200, 20));
			text_var.string = "Input Channel";
			text_var = StaticText(display_window, Rect(20+newoffset, ((i%4)*guioffset)+60, 200, 20));
			text_var.string = "Output Channel";

			//output
			popup_menu_output = PopUpMenu(display_window,Rect(120+newoffset, ((i%4)*guioffset)+60, 50, 20));
			popup_menu_output.items = ["12","13","14","15","16","17","18","19"];
			popup_menu_output.action = { arg menu;
				~syntharr[i].set(\out, (menu.item.asInteger)-1);
			};
			popup_menu_output.value=i;

			//input
			popup_menu_input = PopUpMenu(display_window,Rect(120+newoffset, ((i%4)*guioffset)+30, 50, 20));
			popup_menu_input.items = ["1","2","3","4","5","6","7","8","9","10"];
			popup_menu_input.action = { arg menu;
				~syntharr[i].set(\input, (menu.item.asInteger));
			};
			popup_menu_input.value=i;

			//controls input freq numberbox
			number_box = 	NumberBox(display_window, Rect(120+newoffset,((i%4)*guioffset)+85, 100, 20));
			number_box.action = {arg numb;
				numb.value.postln;
			};
			fnumberboxes.add(number_box);

			text_var = StaticText(display_window, Rect(20+newoffset, ((i%4)*guioffset)+85, 200, 20));
			text_var.string = "Input  Pitch:";
			text_var = StaticText(display_window, Rect(20+newoffset, ((i%4)*guioffset)+110, 200, 20));
			text_var.string = "Control Signal:";
			text_var = StaticText(display_window, Rect(20+newoffset, ((i%4)*guioffset)+135, 200, 20));
			text_var.string = "Amplitude";
			//control voltage meter
			number_box2 = NumberBox(display_window, Rect(120+newoffset, ((i%4)*guioffset)+110, 100, 20));
			//b.action = {arg numb; numb.value.postln; };
			cvnumberboxes.add(number_box2);
			//cvnumberboxes[i].value=1.neg;

			number_box2 = NumberBox(display_window, Rect(120+newoffset, ((i%4)*guioffset)+135, 100, 20));
			//b.action = {arg numb; numb.value.postln; };
			ampnumberboxes.add(number_box2);
			ampnumberboxes[i].value=69;
			number_box2 = Button(display_window, Rect(180+newoffset,((i%4)*guioffset)+ 55,200,20))
			.states_([
				["start amplitude calibration analysis", Color.black, Color.new255(221,75,57,255)],
				["calibrating...", Color.white, Color.black],
			]);
			amp_calibration_button.add(number_box2);
			amp_calibration_button[i].action_({ arg butt;
				"Starting Calibration Routine".postln;
				if(butt.value==1)
				{
					amp_routine = {
						((cvmaxes[i]-cvmins[i])/cvoutinc).do{arg hh, hhh;
							if(hhh==0){
								/*
								cvout2[i] = cvout;
								cvarr[i] = LinkedList.new.add(cvout);
								~syntharr[i].set(\cv, cvout2[i]);
								*/

								cvout2[i] = cvmins[i];
								cvarr[i] = LinkedList.new.add(cvmins[i]);
								~syntharr[i].set(\cv, cvout2[i]);

								calibration_time_resolution.wait;
								amplist[i] = LinkedList.new.add(amparr[i]);
							};

							cvout2[i]=cvout2[i]+cvoutinc;
							~syntharr[i].set(\cv, cvout2[i]);
							cvarr[i].add(cvout2[i]);
							calibration_time_resolution.wait;
							amplist[i].add(amparr[i]);
							~mydatapoints[i][0] = cvarr[i];
							~mydatapoints[i][2] =  amplist[i];

							if(hh>=((2/cvoutinc).asInteger-1))
							{
								if((2/cvoutinc).asInteger==(2/cvoutinc))
								{
									amp_calibration_button[i].value_(0);
									"Calibration Complete".postln;
								}{
									cvout2[i]=1;
									cvarr[i].add(1);
									~mydatapoints[i][0] = cvarr[i];
									~syntharr[i].set(\cv, cvout2[i]);
									calibration_time_resolution.wait;
									amplist[i].add(amparr[i]);
									~mydatapoints[i][2] = amplist[i];
									amp_calibration_button[i].value_(0);
									"Calibration Complete".postln;
								};
							};
							calibration_time_resolution.wait;
						};
					}.fork(SystemClock);
				};
				if(butt.value==0)
				{
					amp_routine.stop;
				};
			});

			start_button = Button(display_window, Rect(180+newoffset,((i%4)*guioffset)+30,200,20))
			.states_([
				["start frequency calibration analysis", Color.black, Color.new255(221,75,57,255)],
				["calibrating...", Color.white, Color.black],
			]);
			freq_calibration_button.add(start_button);
			freq_calibration_button[i].action_({ arg butt;

				if(butt.value==1)
				{
					freq_routine =	 {
						(2/cvoutinc).do{arg hh, hhh;
							//reset counter that increments through CV values
							if(hhh==0)
							{
								/*
								cvout2[i] = cvout;
								cvarr[i] = LinkedList.new.add(cvout);
								~syntharr[i].set(\cv, cvout2[i]);
								*/

								cvout2[i] = cvmins[i];
								cvarr[i] = LinkedList.new.add(cvmins[i]);
								~syntharr[i].set(\cv, cvout2[i]);

								calibration_time_resolution.wait;
								freqlist[i] = LinkedList.new.add(farr[i]);
							};
							{
								cvnumberboxes[i].valueAction = cvout2[i];
							}.defer;



							//cvout2[i]=cvout2[i]+cvoutinc;
							cvout2[i]= cvout2[i] + ((cvmaxes[i]-cvmins[i])/subdivisions);
							~syntharr[i].set(\cv, cvout2[i]);
							calibration_time_resolution.wait;
							cvarr[i].add(cvout2[i]);
							freqlist[i].add(farr[i]);
							~mydatapoints[i][0] = cvarr[i];
							~mydatapoints[i][1] =  freqlist[i];

							if(hh>=((2/cvoutinc).asInteger-1))
							{
								if((2/cvoutinc).asInteger==(2/cvoutinc))
								{
									freq_calibration_button[i].value_(0);
									"Calibration Complete".postln;
								}{
									cvout2[i]=1;
									cvarr[i].add(1);
									~mydatapoints[i][0] = cvarr[i];
									~syntharr[i].set(\cv, cvout2[i]);
									calibration_time_resolution.wait;
									freqlist[i].add(farr[i]);
									~mydatapoints[i][1] = freqlist[i];
									freq_calibration_button[i].value_(0);
									"Calibration Complete".postln;
								};
							};
							calibration_time_resolution.wait
						};
					}.fork(AppClock);
				};

				if(butt.value==0)
				{
					freq_routine.stop;
				};
			});

			min_max_button = Button(display_window, Rect(230+newoffset,((i%4)*guioffset)+110,60,20));
			maxbutton.add(min_max_button);
			maxbutton[i].states_([
				["min cv", Color.black, Color.new255(221,75,57,255)],
				["max cv", Color.white, Color.black],
			]);
			maxbutton[i].action_({ arg butts;
				butts.value.postln;
				if(butts.value==1)
				{
					//~syntharr[i].set(\cv, 0.9);
					~syntharr[i].set(\cv, cvmaxes[i]);
					//cvnumberboxes[i].value=1;
					cvnumberboxes[i].value = 0.8;
				};
				if(butts.value==0)
				{
					~syntharr[i].set(\cv, cvmins[i]);
					//	cvnumberboxes[i].value=1.neg;
					//cvnumberboxes[i].value = 0.2;
				};
			});

			oscarr.add(OSCresponder(server_.addr,'/tr',{ arg time,responder,msg;
				//update frequency stream and sort the info by channel
				if( msg[2].asString.at(1).asString.asInteger == 0)
				{
					farr[(msg[2].asString.at(0).asString.asInteger-1)] = msg[3];
					{
						fnumberboxes[(msg[2].asString.at(0).asString.asInteger-1)].valueAction = (msg[3]).round(0.0003);
					}.defer;
				};

				if( msg[2].asString.at(1).asString.asInteger ==1)
				{
					{
						cvnumberboxes[(msg[2].asString.at(0).asString.asInteger-1)].valueAction = (msg[3]).round(0.000000001);
					}.defer;
				};

				if( msg[2].asString.at(1).asString.asInteger ==2)
				{
					{
						ampnumberboxes[(msg[2].asString.at(0).asString.asInteger-1)].valueAction = 	(msg[3]).round(0.01);
						amparr[(msg[2].asString.at(0).asString.asInteger-1)]=msg[3].round(0.0001);
					}.defer;
				};
			}).add;
			);
		});

		file_button = Button(display_window, Rect(20,((4.clip2(numunits))*guioffset)+10,360,20))
		.states_([
			["Write File", Color.black, Color.white],
			["Writing File...", Color.black, Color.new255(221,75,57,255)],
		])
		.action_({ arg butt;

			if(butt.value==1)
			{
				~list_to_file.value(
					File(("~/Desktop/"++"CV_List_"++(History.dateString)++".sc").standardizePath ,"w"),
					~no_nil.value(~mydatapoints)
				).play;

				{
					(0.5*numunits).wait;
					file_button.value_(0);
				}.fork(AppClock);

			}
		});

		close_button = Button(display_window, Rect(20,5,360,20))
		.states_([
			["release synths", Color.black, Color.white],
			["clear memory", Color.black, Color.white],
			["close window", Color.black, Color.white],
			["closing window", Color.black, Color.white],
		])
		.action_({ arg butt;
			if(butt.value==1)
			{
				~syntharr.do({ arg item, i;
					item.free;
				});
				oscarr.do({ arg item, i;
					item.remove;
				});
			};

			if(butt.value==3)
			{
				Window.closeAll;
			};

			if(butt.value==2)
			{
				numunits = nil; cvout=nil; cvout2=nil; freq=nil;farr= nil;amparr= nil;
				cvoutinc = nil;calibration_time_resolution = nil; ~syntharr=nil; cvarr = nil;
				guioffset=nil; fnumberboxes = nil; cvnumberboxes = nil; ampnumberboxes= nil;
				maxbutton = nil; freqlist=nil;  oscarr=nil; amplist=nil; freqbox=nil;
				close_button=nil;file_button=nil; newoffset=nil; freq_calibration_button=nil;
				amp_calibration_button=nil; wsize=nil; adder=nil;~syntharr=nil;
			};
		});
		display_window.front;

	}

}