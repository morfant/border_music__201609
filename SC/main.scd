~masterEQ = ChannelEQ.new(2, s, 0, 0);


(

~masterEQ.gui.onSelect('normal');

~pd_addr = NetAddr("127.0.0.1", 9000);

SynthDef(\mixer, {
    | out = 0, gate = 1, amp = 0.8, pan = 0,
    amp1 = 1, amp2 = 1, amp3 = 1, amp4 = 1, amp5 = 1,
    pan1 = 0, pan2 = 0, pan3 = 0, pan4 = 0, pan5 = 0 |

	var sig1, sig2, sig3, sig4, sig5, sumSig, compSig;
    sig1 = Pan2.ar(In.ar(100, 2), pan1, amp1);
    sig2 = Pan2.ar(In.ar(102, 2), pan2, amp2);
    sig3 = Pan2.ar(In.ar(104, 2), pan3, amp3);
    sig4 = Pan2.ar(In.ar(106, 2), pan4, amp4);
    sig5 = Pan2.ar(In.ar(108, 2), pan5, amp5);

    sumSig = Mix.ar([sig1, sig2, sig3, sig4, sig5]);
    compSig = Compander.ar(
        in: sumSig,
        thresh: 0.5,
        slopeBelow: 1,
        slopeAbove: 1,
        clampTime: 0.01,
        relaxTime: 0.1
    );
    Out.ar(out, Pan2.ar(compSig, pan, amp));
}).add;



SynthDef(\tak, {| out = 100, freq = 300, modfreq = 5, amp = 0.6, amp2 = 0.9, filfreq = 3200, rq = 0.1, gate = 1,
	atTime = 0.1, susTime = 2.0, relTime = 0.1, pan = 0 |

	var sig, env, sig2, del, mod, lowcut_sig;
	mod = LFSaw.kr(1/10, add: 1);
	sig = LFCub.ar(freq, mod);
	sig2 = Impulse.ar(0, mul: amp2);
	sig = BPF.ar((sig+sig2), filfreq, rq, sig*0.3);
	sig = DelayN.ar(sig, 0.4, 0.1, add: sig*0.3);
	lowcut_sig = HPF.ar(sig, 100);
	env = EnvGen.kr(Env.linen(atTime, susTime, relTime), gate, doneAction: 2);
	// Out.ar(0, Pan2.ar((sig) * env, pan, amp));
	Out.ar(100, Pan2.ar((lowcut_sig) * env, pan, amp));
}).add;


SynthDef(\a, {| dt = 0.5, if = 3, mf = 10, out = 0, freq = 300, modfreq = 5, amp = 0.6, amp2 = 0.9, filfreq = 3200, rq = 0.1, gate = 1,
	atTime = 0.1, susTime = 2.0, relTime = 0.1, pan = 0 |

	var sig, env, sig2, del, mod, lowcut_sig;
    mod = LFSaw.kr(mf).range(0, 1);
	sig = LFCub.ar(freq,  mod);
    sig2 = Impulse.ar(if, mul: amp2);
    sig = BPF.ar((sig + sig2), filfreq, rq, sig*0.3);
    // sig = BPF.ar((sig + sig2), filfreq, rq);
    sig = DelayN.ar(sig, 0.6, dt, add: sig*0.3);
    // sig = DelayN.ar(sig, 0.6, dt);
	lowcut_sig = HPF.ar(sig, 100);
    // env = EnvGen.kr(Env.linen(atTime, susTime, relTime), gate, doneAction: 2);
	// Out.ar(0, Pan2.ar((sig) * env, pan, amp));
	Out.ar(out, Pan2.ar(lowcut_sig, pan, amp));

}).add;

SynthDef(\b, {arg amp = 1.0;
    var sig;
    sig = LFPulse.ar(200)*0.2;

    Out.ar(0, Pan2.ar(sig, 0, amp));
}).add;

SynthDef(\c, {arg amp = 1.0;
    var sig;
    sig = BrownNoise.ar(0.5);

    Out.ar(0, Pan2.ar(sig, 0, amp));
}).add;

SynthDef(\d, {arg amp = 1.0;
    var sig;
    sig = SinOsc.ar(LFNoise0.kr(7).range(600,300))*0.3;

    Out.ar(0, Pan2.ar(sig, 0, amp));
}).add;

SynthDef(\e, {arg amp = 1.0;
    var sig;
    sig = WhiteNoise.ar(1)*0.2;

    Out.ar(0, Pan2.ar(sig, 0, amp));
}).add;


)


//Test
n = NetAddr("localhost", 57120);
n.sendMsg("/rssi", 38);
n.sendMsg("/but", 0);
~buf_a.plot;
~buf_a.free;

~buf_a.path
~buf_a.bufnum
Buffer


//Main Loop
(
var timeMul = 1, ampMul = 100, bpm = 40, onebeat,
msgGot, freqVal, recordLen = 8,
setFreq = nil, recAndPlay = nil,
synthNodes, mode = 0;


onebeat = 60/bpm;

freqVal = Array.with(0.33, 0.38, 0.42, 0.48, 0.51, 0.58, 0.61);

msgGot = Array.newClear(10);
10.do{| i | msgGot[i] = false};

synthNodes = Array.newClear(5);

//-- FUNCTION --
setFreq = {|arg_freq|

~p1.stream = Pbind(
    \instrument, \tak,
    \dur, onebeat*timeMul,
    \freq, #[180, 240, 300]*arg_freq,
	\atTime, 0.6,
	\susTime, onebeat*timeMul,
    \relTime, 0.3,
	\amp, ampMul
).asStream;

};

recAndPlay = {|arg_bufnum|
    fork {
        Synth(\rec, [\bufnum, arg_bufnum, \over, 1, \prev, 0]);
        (recordLen*2).wait; //record twice
        ("Record: " + arg_bufnum + " done.").postln;


        if (mode == 0, {~p1.stop;});


        mode = mode + 1;
        Synth(\play, [\bufnum, arg_bufnum]);

    }
};



//-- NODE WATCHER --
// ~grp = Group.new(s);
// NodeWatcher.register(~grp);

~mixer = Synth(\mixer, [\out, 0, \amp, 0.6], addAction: 'addToTail');


synthNodes[0] = Synth(\a, [\amp, 0]);
synthNodes[1] = Synth(\b, [\amp, 0]);
synthNodes[2] = Synth(\c, [\amp, 0]);
synthNodes[3] = Synth(\d, [\amp, 0]);
synthNodes[4] = Synth(\e, [\amp, 0]);
// synthNodes[1] = {LFPulse.ar(200)*0.2!2}.play;
// synthNodes[2] = {BrownNoise.ar(0.5)!2}.play;
// synthNodes[3] = {SinOsc.ar(LFNoise0.kr(7).range(600,300))*0.3!2}.play;
// synthNodes[4] =  {WhiteNoise.ar(1)*0.2!2}.play;
// synthNodes[5] = {SinOsc.ar(300)*0.8!2}.play;
// synthNodes[0] = {SinOsc.ar(300)*0.8!2}.play;


//-- OSC --
~o1.free;~o2.free;
~o2 = OSCFunc({|msg, time, addr, recvPort|
    "Button pressed".postln;

    switch (mode,
        0, {recAndPlay.value(~buf_a)},
        1, {recAndPlay.value(~buf_b)},
        2, {recAndPlay.value(~buf_c)},
        3, {recAndPlay.value(~buf_d)},
        4, {recAndPlay.value(~buf_e)}
    );

}, '/but');

~o1 = OSCFunc({|msg, time, addr, recvPort|
    var getVal = msg[1].asInteger;
    // getVal.postln;
    // msg.postln;

    if ((30 <= getVal) && (getVal < 40) && (msgGot[0] == false), {
        "30 ~ 40".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[0] = true;


        setFreq.value(freqVal[0]);
        ~pd_addr.sendMsg("/rssi", 3);


        //Test
        // 5.do{| i | synthNodes[i].set(\amp, 0)};
        // synthNodes[0].set(\amp, 1);



        });

    if ((40 <= getVal) && (getVal < 50) && (msgGot[1] == false), {
        "40 ~ 50".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[1] = true;

        setFreq.value(freqVal[1]);
        ~pd_addr.sendMsg("/rssi", 4);

        // 5.do{| i | synthNodes[i].set(\amp, 0)};
        // synthNodes[1].set(\amp, 1);



        });

    if ((50 <= getVal) && (getVal < 60) && (msgGot[2] == false), {
        "50 ~ 60".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[2] = true;

        setFreq.value(freqVal[2]);
        ~pd_addr.sendMsg("/rssi", 5);


        // 5.do{| i | synthNodes[i].set(\amp, 0)};
        // synthNodes[2].set(\amp, 1);


        });

    if ((60 <= getVal) && (getVal < 70) && (msgGot[3] == false), {
        "60 ~ 70".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[3] = true;


        setFreq.value(freqVal[3]);
        ~pd_addr.sendMsg("/rssi", 6);


        // 5.do{| i | synthNodes[i].set(\amp, 0)};
        // synthNodes[3].set(\amp, 1);


        });

    if ((70 <= getVal) && (getVal < 90) && (msgGot[4] == false), {
        "70 ~ 90".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[4] = true;


        setFreq.value(freqVal[4]);
        ~pd_addr.sendMsg("/rssi", 7);

        // 5.do{| i | synthNodes[i].set(\amp, 0)};
        // synthNodes[4].set(\amp, 1);


        });

}, '/rssi');



// -- SOUND --
~p1 = Pbind(
    \instrument, \tak,
    \dur, onebeat*timeMul,
    \freq, #[180, 240, 300]*0.315,
	\atTime, 0.6,
	\susTime, onebeat*timeMul,
    \relTime, 0.3,
	\amp, ampMul
).play;


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

