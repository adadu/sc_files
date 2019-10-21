//AtsCV.init

AtsCV {

	*initSynths {arg server_;

		SynthDef(\help_PlayBuf, {| out = 0,out1 = 1, bufnumfreq = 0, bufnumamp = 1, dur=3, framenum=2252 |
			//Freq output bus
			Out.ar(out,
				PlayBuf.ar(1, bufnumfreq, (framenum/(dur*44100)), doneAction:2)
			);
			//Amp output bus
			Out.ar(out1,
				PlayBuf.ar(1, bufnumamp,  (framenum/(dur*44100)), doneAction:2)
			);

		}).send(server_);
		"Synth Loaded".postcs;
	}


	*init {

		//load variables below as classvars to allow multiple instances of calibrations
		~minmax = LinkedList.new;
		~validpars_per_voice = LinkedList.new;
		~validparsbyloudness = LinkedList.new;
		~loudness_amp = LinkedList.new;
		~sorted_indexes = LinkedList.new;
		~partials_ordered_by_module_voice = LinkedList.new;
		~module_indexes_sorted_by_partial = LinkedList.new;
		~myvoicelist = LinkedList.new;
		~mybuffer=LinkedList.new;
		~myvoicelist1;
		~pre_buffer = LinkedList.new;
		~buffers = LinkedList.new;

		~freq2cv = {arg freq, frequencyarr, controlvoltagearr;
			var index1, maxmindiff, freqdiff, cvmaxmindiff, cvdiff;

			if(freq<=frequencyarr[0])
			{
				controlvoltagearr[0];
			}{
				if(freq>=frequencyarr.asArray.last)
				{1}{
					if(freq>=frequencyarr[frequencyarr.size-1]){controlvoltagearr[controlvoltagearr.size-1]}{
						index1 =  (frequencyarr.asArray).indexOfGreaterThan(freq);
						maxmindiff=  (frequencyarr.asArray)[index1]-(frequencyarr.asArray)[index1-1];
						cvmaxmindiff=(controlvoltagearr.asArray)[index1]-(controlvoltagearr.asArray)[index1-1];
						freqdiff=freq-(frequencyarr.asArray)[index1-1];
						((controlvoltagearr.asArray)[index1-1]) + (cvmaxmindiff*(freqdiff/maxmindiff));
					};
				};
			};
		};

		~partials_min_max = {arg atsfile, datasink, wait_time=0.1;
			var parnum = atsfile.numPartials, inc=0, temp_par_info;

			Routine {
				"identifying range of partials".post;
				parnum.do { |i|
					".".post;
					temp_par_info = atsfile.getParFreq(i).asArray.sort;
					datasink.add([temp_par_info[0],temp_par_info.last]);
					0.1.wait;
				};
				"Done".postln;
			}
		};

		/*
		Identify the partials that within each module range
		Function Duration: numPartials*numvoices*wait_time
		*/

		~partials_per_voice = {arg atsfile, minmax, datasink, numvoices, wait_time=0.1;
			var parnum = atsfile.numPartials, inc=0, temp_par_info;

			Routine {
				numvoices.do({ arg item, i;
					datasink.add(LinkedList.new);
				});

				"identifying valid partials for each voice".post;
				numvoices.do { |i|
					minmax.size.do { |ii|
						".".post;
						if((minmax.asArray[ii][1] <=~mydatapoints[i][1].last) && (minmax.asArray[ii][0] >=~mydatapoints[i][1][0])){
							datasink.asArray[i].add(ii);
						};
						wait_time.wait;
					};
				};
				"Done".postln;
			}
		};

		/*
		Identify the loudest amplitude value in the file and create an array
		of indexes corresponding to the order of partials sorted by loudness.
		Function Duration: validpartialset.size*wait_time
		*/

		~sort_partials = {arg atsfile, valid_partials, datasink, datasink2, loudest_amp, numvoices, wait_time=0.1;
			var validpartialset = LinkedList.new, parnum = validpartialset.size, inc=0, outlist = LinkedList.new, loudestamp=0.00, tempvar, tarr=Dictionary.new, s_pars=Array.newClear(numvoices);

			Routine {
				"sorting valid partials by loudness".post;
				numvoices.do({ arg item, i;
					s_pars[i] = LinkedList.new;
				});
				(valid_partials.flatten.as(Set).asArray).do({ arg item, i;
					validpartialset.add(item);
				});
				validpartialset.size.do { |i|
					".".post;
					//	i.postln;
					tempvar= atsfile.getParAmp(validpartialset[i]).asArray.sort;
					if(loudestamp < tempvar.last){loudestamp=tempvar.last};
					outlist.add([validpartialset[i],tempvar.sum]);
					wait_time.wait;
				};
				outlist.asArray.sortBy(1).reverse.do { arg item, i;
					datasink2.add(item[0]);
					tarr.put(item[0], i);
				};
				valid_partials.do { arg item, i;
					item.do { arg item2, i2;
						s_pars[i].add([tarr.at(item2), item2]);
					};
					datasink.add(s_pars[i].asArray.sortBy(0));
				};
				datasink.do { arg item, i;
					item.do { arg item2, i2;
						item2.removeAt(0);
					};
					datasink[i]; //.postln;
				};
				"Done".postln;
				"Loudest Amp: ".post;
				loudest_amp.add(loudestamp.postln);
			};
		};


		/*
		identify the module voices that synthesize each partial (sorted by loudness)
		Output: [loudest partial:[module_index_1, module_index_2], 2nd loudest partial: [module_index_1]...]
		Function Duration: indexes*voice_partials*wait_time
		*/

		~voices_per_partial = {arg indexes, voice_partials, datasink, wait_time=0.1;
			var out = LinkedList.new;
			Routine {"module indexes for each partial".post;
				indexes.do({ arg item, i;
					datasink.add(LinkedList.new);
					voice_partials.size.do({arg item2, i2;
						//item.postln;
						if(voice_partials[i2].includes(item)){datasink[i].add(i2)}
					});
					".".post;
					wait_time.wait;
				});
				"Done".post;
				"".postln;
			};
		};


		/*
		identify the order of partials to synthesize and what voice should synthesize them
		Output: recordingpass[recordingpass 0: [partial, voice index], recordingpass 1: [next recording pass]...];
		Function Duration: varies. Roughly indexes*voice_partials*wait_time
		*/


		~voice_sort = {arg arr, partials, datasink, nvoices, wait_time=0.1;
			var voice_index=0, partial_index = 0, pass_index = 0, out = LinkedList.new, temparr=LinkedList.new;

			Routine { "assigning partial ordering per voice".post;
				while ({partial_index < partials.size}, {
					"partial being sorted: ".post; partial_index.postln;
					if(arr[partial_index].isEmpty)
					{
						partial_index=partial_index+1;
					}{
						if(arr[partial_index].includes(voice_index))
						{
							temparr.add([partials[partial_index],voice_index]);
							voice_index=voice_index+1%nvoices;
							partial_index = partial_index + 1;
						}{
							voice_index=voice_index+1%nvoices;
						};
					};
					//".".post;
					wait_time.wait;
				});
				temparr.postcs;
				temparr.do({ arg item;
					datasink.add(item);
				});
				"Done".postln;
			};
		};


		/*
		Helper Function
		*/

		~voice_partial_assignment = {arg sortedpars, datasink;
			var out = LinkedList.new;
			Routine{
				sortedpars.do { arg item2, i2;
					datasink.add(item2.asArray.flatten);
				};
			};
		};

		~copyarr_nil_elements = {arg arr, datasink_linkedlist;
			arr.do { arg item2, i2;
				datasink_linkedlist.add(LinkedList.new.add(Array.newClear(item2.size)));
			};
		};



		~cleanup = {
			Routine{
				~minmax = nil;
				~validpars_per_voice = nil;
				~validparsbyloudness = nil;
				~sorted_indexes = nil;
				~partials_ordered_by_module_voice = nil;
				~module_indexes_sorted_by_partial = nil;

				"memory cleanup...".post;
				"complete".postln;
				0.1.wait;
			}
		};

		~voice_sequencing = {arg arr, nvoices, datasink, wait_time=0.05;
			var temp1=LinkedList.new, match=0, index=0, copy=LinkedList.new, arri=LinkedList.new, final = LinkedList.new, temp_var;
			Routine
			{
				arr.do({arg item_, i_;
					copy.add(item_);
				});

				(copy.size).do({arg i;
					match=0;
					index = 0;

					if(i==0)
					{
						temp1.add(LinkedList.new);
						temp1[i].add(copy[i]);
					}{
						while ( { (match==0) && (index < (temp1.size) ) }, {
							arri=LinkedList.new;
							temp1[index].do({arg item2_, i2_;
								arri.add(item2_[1]);
							});

							if(arri.includes(copy[i][1]) == false)
							{
								temp1[index].add(copy[i]);
								match = 1;
							}{
								//if there is no match
								if(index == (temp1.size-1) )
								{
									temp1.add(LinkedList.new.add(copy[i]));
									match = 1;
								};
							};
							//	i.postln;

							if(temp1.size>1)
							{
								if(temp1.first.size==nvoices)
								{
									temp_var = temp1.popFirst;
									//	temp_var.postln;
									final.add(temp_var);
								};
							};
							//	index.postln;
							index = index + 1;
							wait_time.wait;
						});
					};
					wait_time.wait;
				});
				"done".postln;
				(final++temp1).do({ arg item;
					datasink.add(item);
				});
			};
		};

		~create_buffers = {arg atsfile, data, cvdata, datasink, loudest_amplitude, wait_time=0.05, server_;
			var inc2=0, cvList, out;
			//loop through each recording pass
			Routine {
				"Creating buffer.".post;
				data.do({ arg passvals, i; //pass
					out = LinkedList.new;
					passvals.do({ arg voicevals2, i2; //voices
						cvList = LinkedList.new;

						(atsfile.getParFreq(voicevals2[0]).asArray).do({ arg freqtocv, i;
							cvList.add(~freq2cv.(freqtocv, cvdata[voicevals2[1]][1], cvdata[voicevals2[1]][0]));
						});

						".".post;

						out.add(
							[inc2,i2,"pass:", i, voicevals2,
								Buffer.sendCollection(server_, Array.fill(10+((atsfile.numFrames/atsfile.sndDur).asInteger),cvList[0])++cvList, 1, 0),
								Buffer.sendCollection(server_,
									(Array.fill(10,1)++Array.fill((atsfile.numFrames/atsfile.sndDur).asInteger,-1))++(((atsfile.getParAmp(voicevals2[0])*(1/loudest_amplitude))*2)),
									1, 0)]);

						inc2=inc2+1;
						wait_time.wait;
					});
					datasink.add(out);
				});
				"Done".post;
			};
		};

		~create_buffers3 = {arg atsfile, data, cvdata, datasink, loudest_amplitude, wait_time=0.05, server_;
			var inc2=0, cvList, out;
			//loop through each recording pass
			Routine {
				"Creating buffer.".post;
				data.do({ arg passvals, i; //pass
					out = LinkedList.new;
					passvals.do({ arg voicevals2, i2; //voices
						cvList = LinkedList.new;

						(atsfile.getParFreq(voicevals2[0]).asArray).do({ arg freqtocv, i;
							cvList.add(~freq2cv.(freqtocv, cvdata[voicevals2[1]][1], cvdata[voicevals2[1]][0]));
						});

						".".post;
						//add the time stamp and following silence
						out.add(
							[inc2,i2,"pass:", i, voicevals2,
								Buffer.sendCollection(server_, (Array.fill(10, cvList[0])++Array.fill(1000, cvList[0])) ++ cvList, 1, 0),
								Buffer.sendCollection(server_,
									(Array.fill(10, 2)++Array.fill(1000, 0))++(((atsfile.getParAmp(voicevals2[0])*(1/loudest_amplitude))*2)),
									1, 0),"mtch", ((Array.fill(10, cvList[0])++Array.fill(10, cvList[0])) ++ cvList).size,((Array.fill(10, 2)++Array.fill(10, 0))++(((atsfile.getParAmp(voicevals2[0])*(1/loudest_amplitude))*2))).size, atsfile.numFrames]);

						inc2=inc2+1;
						wait_time.wait;
					});
					datasink.add(out);
				});
				"Done".post;
			};
		};

		~create_buffers2 = {arg atsfile, data, cvdata, datasink, loudest_amplitude, wait_time=0.05, server_;
			var inc2=0, cvList, out;
			//loop through each recording pass
			Routine {
				"Creating buffer.".post;
				data.do({ arg passvals, i; //pass
					out = LinkedList.new;
					passvals.do({ arg voicevals2, i2; //voices
						cvList = LinkedList.new;

						(atsfile.getParFreq(voicevals2[0]).asArray).do({ arg freqtocv, i;
							cvList.add(~freq2cv.(freqtocv, cvdata[voicevals2[1]][1], cvdata[voicevals2[1]][0]));
						});

						".".post;

						out.add(
							[inc2,i2,"pass:", i, voicevals2,
								Buffer.sendCollection(server_, Array.fill(10+((atsfile.numFrames/atsfile.sndDur).asInteger),cvList[0])++cvList, 1, 0),
								Buffer.sendCollection(server_,
									(Array.fill(10,2)++Array.fill((atsfile.numFrames/atsfile.sndDur).asInteger,0))++(((atsfile.getParAmp(voicevals2[0])*(1/loudest_amplitude))*2)),
									1, 0)]);

						inc2=inc2+1;
						wait_time.wait;
					});
					datasink.add(out);
				});
				"Done".post;
			};
		};

		~create_buffers4 = {arg atsfile, data, cvdata, datasink, loudest_amplitude, wait_time=0.05, server_;
			var inc2=0, cvList, out;
			//loop through each recording pass
			Routine {
				"Creating buffer.".post;
				data.do({ arg passvals, i; //pass
					out = LinkedList.new;
					passvals.do({ arg voicevals2, i2; //voices
						cvList = LinkedList.new;

						(atsfile.getParFreq(voicevals2[0]).asArray).do({ arg freqtocv, i;
							cvList.add(~freq2cv.(freqtocv, cvdata[voicevals2[1]][1], cvdata[voicevals2[1]][0]));
						});

						".".post;

						out.add(
							[inc2,i2,"pass:", i, voicevals2,
								Buffer.sendCollection(server_, Array.fill(10+((atsfile.numFrames/atsfile.sndDur).asInteger),cvList[0])++cvList, 1, 0),
								Buffer.sendCollection(server_,
									(Array.fill(10,1)++Array.fill((atsfile.numFrames/atsfile.sndDur).asInteger,0))++(((atsfile.getParAmp(voicevals2[0])*(1/loudest_amplitude))*1)),
									1, 0)]);

						inc2=inc2+1;
						wait_time.wait;
					});
					datasink.add(out);
				});
				"Done".post;
			};
		};


/*

		In the create buffer function, add a pitch scalar maybe pass it in as breakpoints for interpolation?
		Second, maybe have a time pointer and stretch pointer in here?
		I can see really long washes -- also need to try to synthesize low pitch material
		next try drums
		*/


		~create_buffers5 = {arg atsfile, data, cvdata, datasink, loudest_amplitude, wait_time=0.05, server_;
			var inc2=0, cvList, out;
			//loop through each recording pass
			Routine {
				"Creating buffer.".post;
				data.do({ arg passvals, i; //pass
					out = LinkedList.new;
					passvals.do({ arg voicevals2, i2; //voices
						cvList = LinkedList.new;

						(atsfile.getParFreq(voicevals2[0]).asArray).do({ arg freqtocv, i;
							cvList.add(~freq2cv.(freqtocv, cvdata[voicevals2[1]][1], cvdata[voicevals2[1]][0]));
						});

						".".post;
						//add the time stamp and following silence
						out.add(
							[inc2,i2,"pass:", i, voicevals2,
								Buffer.sendCollection(server_, (Array.fill(10, cvList[0]) ++Array.fill(5, 0)++Array.fill(5, cvList[0])) ++ cvList, 1, 0),
								Buffer.sendCollection(server_,
									(Array.fill(10, loudest_amplitude)++Array.fill(10, 1.neg))++((atsfile.getParAmp(voicevals2[0])*(1/loudest_amplitude))),
									1, 0),"mtch", ((Array.fill(10, cvList[0])++Array.fill(10, cvList[0])) ++ cvList).size,((Array.fill(10, 1)++Array.fill(10, 0))++((atsfile.getParAmp(voicevals2[0])*(1/loudest_amplitude)))).size, atsfile.numFrames]);

						inc2=inc2+1;
						wait_time.wait;
					});
					datasink.add(out);
				});
				"Done".post;
			};
		};
	}

	*loadFiles
	{arg atspath, cvpath;
		var data;
		^Routine{


			"Loading ATS File...".postln;
			~ats_file = AtsFile.new(atspath.standardizePath).load;
			0.5.wait;
			data = File(cvpath.asString.standardizePath,"r");
			~mydatapoints = data.readAllString.interpret;
			"Loading CV File...".postln;
			0.1.wait;
			"CV File Loaded".postln;
		};
	}


	*convertData{

		^Pseq(
			[
				~partials_min_max.(~ats_file, ~minmax, 0.5),
				~partials_per_voice.(~ats_file, ~minmax, ~validpars_per_voice, ~mydatapoints.size, 0.05),
				~sort_partials.(~ats_file, ~validpars_per_voice, ~validparsbyloudness, ~sorted_indexes, 	~loudness_amp, ~mydatapoints.size, 0.05),
				~voice_partial_assignment.(~validparsbyloudness, ~partials_ordered_by_module_voice),
				~voices_per_partial.(~sorted_indexes, ~partials_ordered_by_module_voice, 	~module_indexes_sorted_by_partial),
				~voice_sort.(~module_indexes_sorted_by_partial, ~sorted_indexes, ~myvoicelist, ~mydatapoints.size, 0.05),
				~cleanup.value,
				~voice_sequencing.value(~myvoicelist, ~mydatapoints.size, ~pre_buffer)
			];
		).play;
	}

	*create_buffers { arg server_;
		~create_buffers5.(~ats_file, ~pre_buffer, ~mydatapoints, ~buffers, ~loudness_amp.asArray[0], 0.5, server_).play;
	}

	//bus_list_arr: [[osc_freq1_bus_num, osc_amp1_busnum],[osc_freq2_bus_num, osc_amp2_busnum]...]
	/*

	*resynthesizeBuffers {arg buffers, bus_list_arr;
	var partialindex = 0, passindex=0;

	fork { while {passindex<~buffers.size} {
	passindex.postln;

	Synth.new(\help_PlayBuf, [\out, bus_list_arr[partialindex][0],\out1, bus_list_arr[partialindex][1],\bufnumfreq,~buffers[passindex][0][5],\bufnumamp, ~buffers[passindex][1][6], \dur, ~ats_file.sndDur,\framenum, ~ats_file.numFrames]);

	passindex=passindex+1;
	(~ats_file.sndDur+5.2).wait;}
	};

	buffers.postln;
	}
	*/

	*resynthesizeBuffers {arg buffers, bus_list_arr, sample_rate=44100;
		var partialindex = 0, passindex=0;

		fork { while {passindex<~buffers.size} {
			passindex.postln;

			buffers[passindex].size.postln;
			buffers[passindex].size.do({ arg partial_index, i;
				["partial_index", partial_index].postln;

				Synth.new(\help_PlayBuf, [\out, bus_list_arr.asArray[buffers[passindex][partial_index][4][1]][0],\out1, bus_list_arr.asArray[buffers[passindex][partial_index][4][1]][1],\bufnumfreq,~buffers[passindex][partial_index][5],\bufnumamp, ~buffers[passindex][partial_index][6], \dur, (~ats_file.sndDur/~ats_file.numFrames) *~buffers[passindex][0][6].numFrames,\framenum, ~buffers[passindex][0][6].numFrames]);


			});


			passindex=passindex+1;
			(~ats_file.sndDur + ((~ats_file.sndDur/(~buffers[passindex][0][6].numFrames))*1010)+5.2).wait;
		}
		};

		buffers.postln;
	}

	*resynthesizeBuffers2 {arg buffers, bus_list_arr, sample_rate=44100, add_wait_time = 5.2;
		var partialindex = 0, passindex=0;

		fork { while {passindex<~buffers.size} {
			passindex.postln;

			buffers[passindex].size.postln;
			buffers[passindex].size.do({ arg partial_index, i;
				["partial_index", partial_index].postln;

				Synth.new(\help_PlayBuf, [
					\out, bus_list_arr.asArray[buffers[passindex][partial_index][4][1]][0],
					\out1, bus_list_arr.asArray[buffers[passindex][partial_index][4][1]][1],
					\bufnumfreq, ~buffers[passindex][partial_index][5],
					\bufnumamp, ~buffers[passindex][partial_index][6],
					\dur, (~ats_file.sndDur/~ats_file.numFrames) * ~buffers[passindex][0][6].numFrames,\framenum, ~buffers[passindex][0][6].numFrames]);
			});

			passindex=passindex+1;
			(((~ats_file.sndDur/~ats_file.numFrames) * ~buffers[passindex][0][6].numFrames)+add_wait_time).wait;
		}
		};

		buffers.postln;
	}
}

AtsCVBandPassNoise {

	*initSynths {arg server_;

		SynthDef(\help_PlayBuf, {| out = 0,out1 = 1, bufnum = 0, bufnum1 = 1, dur=3, framenum=2252 |
			//Freq output bus
			Out.ar(out,
				PlayBuf.ar(1, bufnum, (framenum/(dur*44100)), doneAction:2)
			);
			//Amp output bus
			Out.ar(out1,
				PlayBuf.ar(1, Lag.ar(bufnum1),  (framenum/(dur*44100)), doneAction:2)
			);

		}).send(server_);

		"Synth Loaded".postcs;

		~freq2cv = {arg freq, frequencyarr, controlvoltagearr;
			var index1, maxmindiff, freqdiff, cvmaxmindiff, cvdiff;

			if(freq<=frequencyarr[0])
			{
				controlvoltagearr[0];
			}{
				if(freq>=frequencyarr.asArray.last)
				{1}{
					if(freq>=frequencyarr[frequencyarr.size-1]){controlvoltagearr[controlvoltagearr.size-1]}{
						index1 =  (frequencyarr.asArray).indexOfGreaterThan(freq);
						maxmindiff=  (frequencyarr.asArray)[index1]-(frequencyarr.asArray)[index1-1];
						cvmaxmindiff=(controlvoltagearr.asArray)[index1]-(controlvoltagearr.asArray)[index1-1];
						freqdiff=freq-(frequencyarr.asArray)[index1-1];
						((controlvoltagearr.asArray)[index1-1]) + (cvmaxmindiff*(freqdiff/maxmindiff));
					};
				};
			};
		};

	}

	*loadFiles
	{arg atspath, cvpath;
		var data;
		^Routine{
			"Loading ATS File...".postln;
			~ats_file = AtsFile.new(atspath.standardizePath).load;
			0.5.wait;
			data = File(cvpath.asString.standardizePath,"r");
			~mydatapoints = data.readAllString.interpret;
			"Loading CV File...".postln;
			0.1.wait;
			"CV File Loaded".postln;
		};
	}



	*create_buffers { arg server_;


		//remove critcal bands frequencies that are out of the synth's range
		var minval = ~mydatapoints[0][1].asArray.sort.first,
		maxval = ~mydatapoints[0][1].asArray.sort.last,
		bandcopy=Array.newClear(25), validbands=LinkedList.new, validindexes=LinkedList.new, cvnoiselist=LinkedList.new,maxbandamp=0, tempout=nil,tempout2=nil;

		~critcalcenterfreqs1 = [ 50, 150, 250, 350, 450,570, 700, 840, 1000, 1170, 1370, 1600, 1850, 2150, 2500,2900, 3400, 4000, 4800, 5800,7000, 8500, 10500, 13500, 16000];

		bandcopy = ~critcalcenterfreqs1;

		bandcopy.do({ arg item, i;
			item.postln;
			if( (item<maxval) && (item>minval) ){
				validbands.add(item);
				validindexes.add([i,~ats_file.getBandNoi(i).sum]);
			};
		});

		"bandcopy".postcs;
		bandcopy.postcs;
		"minval".postcs;
		minval.postcs;
		"maxval".postcs;
		maxval.postcs;
		"validbands, unsorted".postcs;
		validbands.postcs;
		"validindexes sorted by loudness".postcs;
		validindexes = validindexes.asArray.sortBy(1).reverse.postcs;

		validindexes.do({ arg item, i;
			~critcalcenterfreqs1[item[0]].postln;
			cvnoiselist.add(~freq2cv.(~critcalcenterfreqs1[item[0]], ~mydatapoints[0][1], ~mydatapoints[0][0]));
		});
		"cvnoiselist".postcs;
		cvnoiselist.postcs;

		//find the loudest amp in all of the partials
		//"maxbandamp".postln;

		validindexes.do({ arg item, i;
			tempout = ~ats_file.getBandNoi(item[0]).sort.last;
			if(maxbandamp<tempout){
				maxbandamp = tempout;
			};
		});
		"maxbandamp".postcs;
		maxbandamp.postcs;
		/*
		Store the cv values into a buffer, append time stamp, normalize amplitudes to loudest amp value
		*/
		~mynoisebuffer = Array.newClear(validindexes.size);

		//["validindexes", validindexes, validbands].postcs;

		validindexes.do({ arg item, i;

			"list of freqs and corresponding CV value".postln;
			tempout2 = ~freq2cv.(~critcalcenterfreqs1[item[0]], ~mydatapoints[0][1], ~mydatapoints[0][0]);
			["tempout2", tempout2].postcs;
			[~critcalcenterfreqs1[item[0]], tempout2].postln;

			~mynoisebuffer[i]	= [
				Buffer.sendCollection(server_,
					Array.fill(20, tempout2)++
					Array.fill(~ats_file.numFrames, tempout2), 1, 0)
				,
				Buffer.sendCollection(server_,
					(Array.fill(10,2)++
						Array.fill(10,0))++
					(((~ats_file.getBandNoi(item[0])*(1/maxbandamp))*2)),
					1, 0) ];
		});
	}

	*resynthesizeBuffers {arg buffers, bus_list_arr, sample_rate=44100;
		var partialindex = 0, passindex=0;

		fork { while {passindex<~mynoisebuffer.size} {
			passindex.postln;
			(~mynoisebuffer[passindex]).do({ arg item, i;
				/*
				Synth.new(\help_PlayBuf,
				[\out, bus_list_arr[0][0],
				\out1, bus_list_arr[0][1],
				\bufnum,~mynoisebuffer[passindex][0],
				\bufnum1, ~mynoisebuffer[passindex][1],
				\dur, ~ats_file.sndDur,
				\framenum, ~ats_file.numFrames+((~ats_file.numFrames/~ats_file.sndDur)).asInteger+10]
				);
				*/

				Synth.new(\help_PlayBuf,
					[\out, bus_list_arr[0][0],
						\out1, bus_list_arr[0][1],
						\bufnum,~mynoisebuffer[passindex][0],
						\bufnum1, ~mynoisebuffer[passindex][1],
						\dur, ~ats_file.sndDur + (20 * (~ats_file.sndDur/~ats_file.numFrames)),
						\framenum, ~ats_file.numFrames+20]
				);


			});
			passindex=passindex+1;
			((~ats_file.sndDur + (20 * (~ats_file.sndDur/~ats_file.numFrames))) * 1.5).wait;
		}
		};

		//buffers.postln;
	}
}


AtsCVCascadingHiLoNoise {

	*initSynths {arg server_;

		SynthDef(\help_PlayBuf, {| out = 0,out1 = 1, out2 = 2, bufnum = 0, bufnum1 = 1, bufnum2 = 2, dur=3, framenum=2252 |
			//HiPass output bus
			Out.ar(out,
				PlayBuf.ar(1, bufnum, (framenum/(dur*44100)), doneAction:2)
			);
			//LowPass 2output bus
			Out.ar(out1,
				PlayBuf.ar(1, bufnum1, (framenum/(dur*44100)), doneAction:2)
			);
			//Amp output bus
			Out.ar(out2,
				PlayBuf.ar(1, bufnum2,  (framenum/(dur*44100)), doneAction:2)
			);

		}).send(server_);


		~freq2cv = {arg freq, frequencyarr, controlvoltagearr;
			var index1, maxmindiff, freqdiff, cvmaxmindiff, cvdiff;

			if(freq<=frequencyarr[0])
			{
				controlvoltagearr[0];
			}{
				if(freq>=frequencyarr.asArray.last)
				{1}{
					if(freq>=frequencyarr[frequencyarr.size-1]){controlvoltagearr[controlvoltagearr.size-1]}{
						index1 =  (frequencyarr.asArray).indexOfGreaterThan(freq);
						maxmindiff=  (frequencyarr.asArray)[index1]-(frequencyarr.asArray)[index1-1];
						cvmaxmindiff=(controlvoltagearr.asArray)[index1]-(controlvoltagearr.asArray)[index1-1];
						freqdiff=freq-(frequencyarr.asArray)[index1-1];
						((controlvoltagearr.asArray)[index1-1]) + (cvmaxmindiff*(freqdiff/maxmindiff));
					};
				};
			};
		};

		"Synth Loaded".postcs;

	}

	*loadFiles
	{arg atspath, cvpath;
		var data;
		^Routine{
			"Loading ATS File...".postln;
			~ats_file = AtsFile.new(atspath.standardizePath).load;
			0.5.wait;
			data = File(cvpath.asString.standardizePath,"r");
			~mydatapoints = data.readAllString.interpret;
			"Loading CV File...".postln;
			0.1.wait;
			"CV File Loaded".postln;
		};
	}

	*create_buffers { arg server_, lowpass_idx=0, hi_pass_indx=1; //idx indicates module order in calibration file
		//remove critcal bands frequencies that are out of the synth's range

		var minval = ~mydatapoints[hi_pass_indx][1].asArray.sort.first,
		maxval = ~mydatapoints[hi_pass_indx][1].asArray.sort.last,
		minval2 = ~mydatapoints[lowpass_idx][1].asArray.sort.first,
		maxval2 = ~mydatapoints[lowpass_idx][1].asArray.sort.last,
		bandcopy=Array.newClear(25), bandcopy2=Array.newClear(25), validbands=LinkedList.new, validindexes=LinkedList.new, validbands2=LinkedList.new, validindexes2=LinkedList.new, cvnoiselist=LinkedList.new,maxbandamp=0, tempout=nil, tempout2=nil, tempout3=nil, tempout4=nil, bandedges=LinkedList.new;

		//bark scale data source: https://ccrma.stanford.edu/~jos/bbt/Bark_Frequency_Scale.html
		/*
		~critcalcenterfreqs1 = [ 50, 150, 250, 350, 450,570, 700, 840, 1000, 1170,1370, 1600, 1850, 2150, 2500,2900, 3400, 4000, 4800, 5800,7000, 8500, 10500, 13500, 16000];
		*/
		~barkbandedges1 = [0, 100, 200, 300, 400, 510, 630, 770, 920, 1080, 1270, 1480, 1720, 2000, 2320, 2700, 3150, 3700, 4400, 5300, 6400, 7700, 9500, 12000, 15500];

		bandcopy = ~barkbandedges1;
		bandcopy2 = ~barkbandedges1;

		//hi pass freqs in range
		bandcopy.do({ arg item, i;
			if( (item<maxval) && (item>minval) ){
				validbands.add(item);
			};
		});

		//low pass freqs in range

		bandcopy2.do({ arg item2, i;
			if( (item2<maxval2) && (item2>minval2) ){
				validbands2.add(item2);
			};
		});

		//collect the edges that can be synthesized and associate them to a band index

		~barkbandedges1.doAdjacentPairs({ arg item1, item2,item3; [item1, item2, item3].postln;
			if(validbands.includes(item1) && validbands2.includes(item2)){
				bandedges.add([item3, [item1, item2], ~ats_file.getBandNoi(item3).sum])
			};
		});

		validindexes = bandedges.asArray.sortBy(2).reverse.postcs;
		validindexes.do({ arg item, i;
			tempout = ~ats_file.getBandNoi(item[0]).sort.last.postcs;
			if(maxbandamp<tempout){
				maxbandamp = tempout;
			};
		});
		"maxbandamp".postcs;
		maxbandamp.postcs;

		/*
		Store the cv values into a buffer, append time stamp, normalize amplitudes to loudest amp value
		*/

		~mynoisebuffer = Array.newClear(validindexes.size);
		validindexes.do({ arg item, i;

			"list of freqs and corresponding CV value".postln;
			tempout2 = ~freq2cv.(item[1][0], ~mydatapoints[hi_pass_indx][1], ~mydatapoints[hi_pass_indx][0]); // high pass
			tempout3 = ~freq2cv.(item[1][1], ~mydatapoints[lowpass_idx][1], ~mydatapoints[lowpass_idx][0]); //low pass

			~mynoisebuffer[i]	= [
				Buffer.sendCollection(server_, Array.fill(20, tempout2)++Array.fill(~ats_file.numFrames, tempout2), 1, 0),
				Buffer.sendCollection(server_, Array.fill(20, tempout3)++Array.fill(~ats_file.numFrames, tempout3), 1, 0),
				Buffer.sendCollection(server_,
					(Array.fill(10,2)++
						Array.fill(10,0))++
					(((~ats_file.getBandNoi(item[0])*(1/maxbandamp))*2)),
					1, 0) ];
		});

	}
	//buffer -- [hipasscv,lowpasscv, ampcv]
	*resynthesizeBuffers {arg buffers, bus_list_arr, sample_rate=44100; //buslist arr index [lowpass buss, hipass buss, amp buss]
		var partialindex = 0, passindex=0;

		fork { while {passindex<~mynoisebuffer.size} {
			passindex.postln;
			(~mynoisebuffer[passindex]).do({ arg item, i;

				Synth.new(\help_PlayBuf,
					[\out, bus_list_arr[0],
						\out1, bus_list_arr[1],
						\out2, bus_list_arr[2],

						\bufnum,~mynoisebuffer[passindex][0],
						\bufnum1, ~mynoisebuffer[passindex][1],
						\bufnum2, ~mynoisebuffer[passindex][2],
						\dur, ~ats_file.sndDur + (20 * (~ats_file.sndDur/~ats_file.numFrames)),
						\framenum, ~ats_file.numFrames+20]
				);
			});

			passindex=passindex+1;

			((~ats_file.sndDur + (20 * (~ats_file.sndDur/~ats_file.numFrames))) * 1.5).wait;
		}
		};

		//buffers.postln;
	}

}