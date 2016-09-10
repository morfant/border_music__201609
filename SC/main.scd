//Test
n = NetAddr("localhost", 57120);
n.sendMsg("/rssi", 33);
n.sendMsg("/rssi", 43);
n.sendMsg("/rssi", 56);
n.sendMsg("/rssi", 62);
n.sendMsg("/rssi", 76);
n.sendMsg("/rssi", 86);
n.sendMsg("/rssi", 30 + 50.rand);

n.sendMsg("/but", 0);





/*------------------------------------------------*/
/*--------------------- Preset ---------------------*/
/*------------------------------------------------*/
(
thisProcess.interpreter.executeFile("/Users/giy/Desktop/border_music/SC/recAndPlay.scd");
thisProcess.interpreter.executeFile("/Users/giy/Desktop/border_music/SC/buffer_read.scd");
thisProcess.interpreter.executeFile("/Users/giy/Desktop/border_music/SC/synths.scd");
)


/*------------------------------------------------*/
/*------------------- Main Loop -------------------*/
/*------------------------------------------------*/
(
var timeMul = 1, ampMul = 100, bpm = 40, onebeat,
msgGot, freqVal, rangeIdx,
setFreq = nil, recAndPlay = nil, runNodeOnly = nil, postRange = nil, modeInc = nil,
laughSoundNodes, synthNode, v_synthNodes, songNodes,
playIdx = 0, playHanIdx = 0,
mode = -2, fadeOutTime = 16, range;


// Set range MAX / min
range = IdentityDictionary(know: false);
range = (\A : [40, 50], \B : [50, 60], \C : [60, 70], \D : [70, 80], \E : [80, 90]);

rangeIdx = IdentityDictionary(know: false);
rangeIdx = (\A :0, \B : 1, \C : 2, \D : 3, \E : 4);

onebeat = 60/bpm;

// mode 0 : ambient freq set
freqVal = Array.with(0.315, 0.38, 0.42, 0.48, 0.51, 0.58, 0.61);

msgGot = Array.newClear(10);
10.do{| i | msgGot[i] = false};

laughSoundNodes = Array.newClear(5);
v_synthNodes = Array.newClear(5);
songNodes = Array.newClear(5);

//-- FUNCTION --
setFreq = {|arg_freq|
    ~p1.stream = Pbind(
        \instrument, \tak,
        \dur, onebeat*timeMul,
        \freq, #[180, 240, 300]*arg_freq,
        \atTime, 0.6,
        \susTime, onebeat*timeMul,
        \relTime, 0.1,
        \amp, ampMul
    ).asStream;
};

recAndPlay = {|arg_bufnum, arg_bus|
    fork {
        if (mode == 5, {
            Synth.before(~micInEQ.synth, \rec, [\inbus, arg_bus, \bufnum, arg_bufnum, \over, 0.5, \prev, 0.4]);
        },{
            Synth.before(~micInEQ.synth, \rec, [\inbus, arg_bus, \bufnum, arg_bufnum, \over, 1, \prev, 0]);
        });

        ~recBufLen.wait; //first record loop done. second record loop start.
        Synth(\ting, [\freq, 1000, \amp, 0.5]);

        ~recBufLen.wait; //second record loop done - record finished.
        Synth(\ting, [\freq, 600, \amp, 0.6]);

        ("Record: " + arg_bufnum + " done.").postln;

        // Before mode end. (prepare next mode)
        if (mode == 0, {~p1.stop;});
        if (mode == 1, { 5.do{| i | v_synthNodes[i].free;} });
        if (mode == 2, { 5.do{| i | songNodes[i].free;}; synthNode.run(true); });

        // Play recoreded buffer except mode is 5
        if (mode != 5, { Synth(\play, [\out, arg_bus, \bufnum, arg_bufnum]); });

        if (mode < 7, { mode = mode + 1; });
    }
};

runNodeOnly = {|nodeName, idx|
    5.do{| i | nodeName[i].run(false);};
    nodeName[idx].run(true);
};

postRange = {|r_sym|
    (range[r_sym][0] + "~" + range[r_sym][1]).postln;
};

modeInc = {
    mode = mode + 1;
};


//-- MIXER --
~mixer = Synth.before(~masterEQ.synth, \mixer, [\out, 0, \amp, 0.6, \pan, -0.3,
    \amp0, 0.2, \amp1, 0.2, \amp2, 0.1, \amp3, 0.15, \amp4, 0.2, \amp5, 0.3, \amp6, 1.0,
    \pan0, 0, \pan1, 0, \pan2, -0.2, \pan3, 0.2, \pan4, 0, \pan5, 0, \pan6, 0,
    \ths , 0.5, \slB, 1, \slA, 1, \clpTime, 0.01, \relTime, 0.1
]);


//-- SYNTH NODES --
//mode == -1 : laugh (no EQ: out 98 -> mixer -> 0)
laughSoundNodes[0] = Synth.newPaused(\bufRead, [\pan, -0.8, \out, 98, \amp, 0.2, \loop, 1, \bufnum, ~v_laughing]);
laughSoundNodes[1] = Synth.newPaused(\bufRead, [\pan, -0.3, \out, 98, \amp, 0.4, \loop, 1, \bufnum, ~v_laughing]);
laughSoundNodes[2] = Synth.newPaused(\bufRead, [\pan, 0.6, \out, 98, \amp, 0.6, \loop, 1, \bufnum, ~v_laughing]);
laughSoundNodes[3] = Synth.newPaused(\bufRead, [\pan, 1, \out, 98, \amp, 1, \loop, 1, \bufnum, ~v_laughing]);
laughSoundNodes[4] = Synth.newPaused(\bufRead, [\pan, 0.2, \out, 98, \amp, 0.8, \loop, 1, \bufnum, ~v_laughing]);

//mode == 0 : ambient (no EQ: out 100 -> mixer -> 0)
~p1 = Pbind(
    \instrument, \tak,
    \dur, onebeat*timeMul,
    \freq, #[180, 240, 300]*0.315,
    \atTime, 0.6,
    \susTime, onebeat*timeMul,
    \relTime, 0.1,
    \amp, ampMul
).play;
~p1.stop;

//mode == 1 : voices (out 52 -> EQ -> 102 -> mixer -> 0)
v_synthNodes[0] = Synth.newPaused(\bufRead, [\pan, -0.3, \out, 52, \loop, 1, \bufnum, ~voice[0]]);
v_synthNodes[1] = Synth.newPaused(\bufRead, [\pan, -0.3, \out, 52, \loop, 1, \bufnum, ~voice[1]]);
v_synthNodes[2] = Synth.newPaused(\bufRead, [\pan, -0.3, \out, 52, \loop, 1, \bufnum, ~voice[2]]);
v_synthNodes[3] = Synth.newPaused(\bufRead, [\pan, -0.3, \out, 52, \loop, 1, \bufnum, ~voice[3]]);
v_synthNodes[4] = Synth.newPaused(\bufRead, [\pan, -0.3, \out, 52, \loop, 1, \bufnum, ~voice[4]]);

//mode == 2 : song (out 54 -> EQ -> 104 -> mixer -> 0)
songNodes[0] = Synth.newPaused(\bufRead, [\pan, 0.4, \out, 54, \loop, 1, \bufnum, ~v_song_part[0]]);
songNodes[1] = Synth.newPaused(\bufRead, [\pan, 0.4, \out, 54, \loop, 1, \bufnum, ~v_song_part[1]]);
songNodes[2] = Synth.newPaused(\bufRead, [\pan, 0.4, \out, 54, \loop, 1, \bufnum, ~v_song_part[2]]);
songNodes[3] = Synth.newPaused(\bufRead, [\pan, 0.4, \out, 54, \loop, 1, \bufnum, ~v_song_part[3]]);
songNodes[4] = Synth.newPaused(\bufRead, [\pan, 0.4, \out, 54, \loop, 1, \bufnum, ~v_song_part[4]]);

//mode == 3 : beating sound
synthNode = Synth.newPaused(\aha, [\out, 106, \freq, #[180, 240, 300], \amp, 30]);

//mode == 4 : number (out 58 -> EQ -> 108 -> mixer -> 0)
//mode == 5 : number_han (out 58 -> EQ -> 108 -> mixer -> 0)
//mode == 6 : micin (out 60 -> EQ -> 110 -> mixer -> 0)



//-- OSC --
~o1.free;~o2.free;
~o2 = OSCFunc({|msg, time, addr, recvPort|
    "Button pressed".postln;
    ("mode: " + mode).postln;
    Synth(\ting, [\freq, 800, \amp, 0.4]);

    switch (mode,
        -2, { modeInc.value; },
        -1, { 5.do{| i | laughSoundNodes[i].free}; ~p1.play; modeInc.value},
        0, {recAndPlay.value(~recbuf_a, 100)},
        1, {recAndPlay.value(~recbuf_b, 52)},
        2, {recAndPlay.value(~recbuf_c, 54)},
        3, { modeInc.value },
        4, {recAndPlay.value(~recbuf_e, 58)},
        5, {recAndPlay.value(~recbuf_e, 58)},
        // 6, {~micin = Synth(\micin, [\out, 60, \amp, 0.2]); modeInc.value;},
        6, { modeInc.value;},
        7, {~mixer.release(fadeOutTime) }
    );
}, '/but');


~o1 = OSCFunc({|msg, time, addr, recvPort|
    var getVal = msg[1].asInteger;
    // getVal.postln;
    // msg.postln;

    /*----------------------------  range A  ----------------------------*/
    if ((range[\A][0] <= getVal) && (getVal < range[\A][1]) && (msgGot[0] == false), {
        postRange.value(\A);
        getVal.postln;

        10.do{| i | msgGot[i] = false; };
        msgGot[0] = true;

        switch (mode,
            -1, { runNodeOnly.value(laughSoundNodes, 0) },
            0, { setFreq.value(freqVal[0]) },
            1, { runNodeOnly.value(v_synthNodes, 0) },
            2, { runNodeOnly.value(songNodes, 0) },
            4, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number[playIdx]]); playIdx = (playIdx + 1)%11; },
            5, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number_han[playHanIdx]]); playHanIdx = (playHanIdx + 1)%11; },
        );

        if (mode >= 3, { synthNode.set(\freq, #[180, 240, 300]*(1 + (getVal/100)), \if, 3) });
        // ~pd_addr.sendMsg("/rssi", 3);
        });


    /*---------------------------- range B ----------------------------*/
    if ((range[\B][0] <= getVal) && (getVal < range[\B][1]) && (msgGot[1] == false), {
        postRange.value(\B);
        getVal.postln;

        10.do{| i | msgGot[i] = false; };
        msgGot[1] = true;

        switch (mode,
            -1, { runNodeOnly.value(laughSoundNodes, 1) },
            0, { setFreq.value(freqVal[1]) },
            1, { runNodeOnly.value(v_synthNodes, 1) },
            2, { runNodeOnly.value(songNodes, 1) },
            4, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number[playIdx]]); playIdx = (playIdx + 1)%11; },
            5, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number_han[playHanIdx]]); playHanIdx = (playHanIdx + 1)%11; },
        );

        if (mode >= 3, { synthNode.set(\freq, #[180, 240, 300]*(1 + (getVal/100)), \if, 4.0) });
        // ~pd_addr.sendMsg("/rssi", 4);
        });




    /*----------------------------  range C ----------------------------*/
    if ((range[\C][0] <= getVal) && (getVal < range[\C][1]) && (msgGot[2] == false), {
        postRange.value(\C);
        getVal.postln;

        10.do{| i | msgGot[i] = false; };
        msgGot[2] = true;

        switch (mode,
            -1, { runNodeOnly.value(laughSoundNodes, 2) },
            0, { setFreq.value(freqVal[2]) },
            1, { runNodeOnly.value(v_synthNodes, 2) },
            2, { runNodeOnly.value(songNodes, 2) },
            4, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number[playIdx]]); playIdx = (playIdx + 1)%11; },
            5, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number_han[playHanIdx]]); playHanIdx = (playHanIdx + 1)%11; },
        );

        if (mode >= 3, { synthNode.set(\freq, #[180, 240, 300]*(1 + (getVal/100)), \if, 4.7) });
        // ~pd_addr.sendMsg("/rssi", 5);
        });




    /*---------------------------- range D ----------------------------*/
    if ((range[\D][0] <= getVal) && (getVal < range[\D][1]) && (msgGot[3] == false), {
        postRange.value(\D);
        getVal.postln;

        10.do{| i | msgGot[i] = false; };
        msgGot[3] = true;

        switch (mode,
            -1, { runNodeOnly.value(laughSoundNodes, 3) },
            0, { setFreq.value(freqVal[3]) },
            1, { runNodeOnly.value(v_synthNodes, 3) },
            2, { runNodeOnly.value(songNodes, 3) },
            4, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number[playIdx]]); playIdx = (playIdx + 1)%11; },
            5, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number_han[playHanIdx]]); playHanIdx = (playHanIdx + 1)%11; },
        );

        if (mode >= 3, { synthNode.set(\freq, #[180, 240, 300]*(1 + (getVal/100)), \if, 5.5) });
        // ~pd_addr.sendMsg("/rssi", 6);
        });



    /*---------------------------- range E ----------------------------*/
    if ((range[\E][0] <= getVal) && (getVal < range[\E][1]) && (msgGot[4] == false), {
        postRange.value(\E);
        getVal.postln;

        10.do{| i | msgGot[i] = false; };
        msgGot[4] = true;

        switch (mode,
            -1, { runNodeOnly.value(laughSoundNodes, 4) },
            0, { setFreq.value(freqVal[4]) },
            1, { runNodeOnly.value(v_synthNodes, 4) },
            2, { runNodeOnly.value(songNodes, 4) },
            4, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number[playIdx]]); playIdx = (playIdx + 1)%11; },
            5, { Synth(\bufReadEnv, [\out, 58, \bufnum, ~number_han[playHanIdx]]); playHanIdx = (playHanIdx + 1)%11; },
        );

        if (mode >= 3, { synthNode.set(\freq, #[180, 240, 300]*(1 + (getVal/100)), \if, 4.4) });
        // ~pd_addr.sendMsg("/rssi", 7);
        });

}, '/rssi');



// -- mode 1 ambient sound Pattern --
// if (mode == 0, {
//     ~p1 = Pbind(
//         \instrument, \tak,
//         \dur, onebeat*timeMul,
//         \freq, #[180, 240, 300]*0.315,
//         \atTime, 0.6,
//         \susTime, onebeat*timeMul,
//         \relTime, 0.1,
//         \amp, ampMul
//     ).play;
// });
//
// ~p1.stop;

/*
~p2 = Pbind(
	\instrument,        \tak,
	\dur,    Pseq([
		onebeat, onebeat, onebeat, onebeat
	]*timeMul, inf),
	\legato, 0.5,
    \freq, Pseq([
        648
        // 543, 544, 545, 544, 648, 543,
        // 542, 543, 549, 544, 728, 543,
        // 543, 544, 545, 544, 648, 543,
        // 542, 543, 549, 544, 868, 543,
    ]*0.1729, inf), //original 0.38
	\atTime, Pseq([
        0.3, 0.3, 0.3, 0.4, 0.3, 0.3,
        0.4, 0.3, 0.3, 0.4, 0.6, 0.3, 0.01
    ], inf),
	\susTime, Pseq([
        2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 0.3
    ], inf),
	\amp, ampMul * 0.7
).play;
*/


)

