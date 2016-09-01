~masterEQ = ChannelEQ.new(2, s, 0, 0);

(
~pd_addr = NetAddr("127.0.0.1", 9000);

SynthDef(\tak, {| out = 0, freq = 300, modfreq = 5, amp = 0.6, amp2 = 0.9, filfreq = 3200, rq = 0.1, gate = 1,
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
	Out.ar(out, Pan2.ar((lowcut_sig) * env, pan, amp));
}).add;


SynthDef(\a, {arg amp = 1.0;
    var sig;
    sig = SinOsc.ar(300)*0.8;

    Out.ar(0, Pan2.ar(sig, 0, amp));
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
n.sendMsg("/rssi", 58);




(
var timeMul = 1, ampMul = 100,
onebeat = 2.666666666666/4, // 4 * beat = 1 bar
msgGot, freqVal, setFreq = nil,
synthNodes;

freqVal = Array.with(0.33, 0.38, 0.42, 0.48, 0.51, 0.58, 0.61);

msgGot = Array.newClear(10);
10.do{| i | msgGot[i] = false};

synthNodes = Array.newClear(5);

//-- FUNCTION --
setFreq = {|arg_freq|

~p1.stream = Pbind(
		\instrument,        \tak,
        \dur,    Pseq([ onebeat, onebeat, onebeat, onebeat ]*timeMul, inf),
		\legato, 0.5,
		\freq, #[180, 240, 300]*arg_freq,
        \atTime, Pseq([
            0.3, 0.3, 0.3, 0.4, 0.3, 0.3,
            0.4, 0.3, 0.3, 0.4, 0.6, 0.3, 0.01
        ], inf),
        \susTime, Pseq([
            2, 2, 2, 2, 2, 2,
            2, 2, 2, 2, 2, 2, 2
        ], inf),
		\amp, ampMul
).asStream;

};



//-- NODE WATCHER --
// ~grp = Group.new(s);
// NodeWatcher.register(~grp);


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
    msg.postln;

}, '/but');

~o1 = OSCFunc({|msg, time, addr, recvPort|
    var getVal = msg[1].asInteger;
    // getVal.postln;
    // msg.postln;

    // if (getVal == -1, {
    //     "button pressed!".postln;
    // });

    if ((30 <= getVal) && (getVal < 40) && (msgGot[0] == false), {
        "30 ~ 40".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[0] = true;


        // setFreq.value(freqVal[0]);
        ~pd_addr.sendMsg("/rssi", 3);


        //Test
        5.do{| i | synthNodes[i].set(\amp, 0)};
        synthNodes[0].set(\amp, 1);



        // ~grp.run(false);
        // ~grp.freeAll;
        // if (~grp.isRunning == false, {
        //     {SinOsc.ar(300)*0.8!2}.play(~grp);
        //     "synth added!!".postln;
        //     ~grp.run(true);
        // });




        });

    if ((40 <= getVal) && (getVal < 50) && (msgGot[1] == false), {
        "40 ~ 50".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[1] = true;

        // setFreq.value(freqVal[1]);
        ~pd_addr.sendMsg("/rssi", 4);

        5.do{| i | synthNodes[i].set(\amp, 0)};
        synthNodes[1].set(\amp, 1);

        // ~grp.run(false);
        // ~grp.freeAll;
        // if (~grp.isRunning == false, {
        //     {LFPulse.ar(200)*0.2!2}.play(~grp);
        //     "synth added!!".postln;
        //     ~grp.run(true);
        // });


        });

    if ((50 <= getVal) && (getVal < 60) && (msgGot[2] == false), {
        "50 ~ 60".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[2] = true;

        // setFreq.value(freqVal[2]);
        ~pd_addr.sendMsg("/rssi", 5);


        5.do{| i | synthNodes[i].set(\amp, 0)};
        synthNodes[2].set(\amp, 1);

        // ~grp.run(false);
        // ~grp.freeAll;
        // if (~grp.isRunning == false, {
        //     {BrownNoise.ar(0.5)!2}.play(~grp);
        //     ~grp.run(true);
        // });


        });

    if ((60 <= getVal) && (getVal < 70) && (msgGot[3] == false), {
        "60 ~ 70".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[3] = true;


        // setFreq.value(freqVal[3]);
        ~pd_addr.sendMsg("/rssi", 6);


        5.do{| i | synthNodes[i].set(\amp, 0)};
        synthNodes[3].set(\amp, 1);

        // ~grp.run(false);
        // ~grp.freeAll;
        // if (~grp.isRunning == false, {
        //     {SinOsc.ar(LFNoise0.kr(7).range(600,300))*0.3!2}.play(~grp);
        //     ~grp.run(true);
        // });


        });

    if ((70 <= getVal) && (getVal < 90) && (msgGot[4] == false), {
        "70 ~ 90".postln;
        getVal.postln;
        10.do{| i | msgGot[i] = false; };
        msgGot[4] = true;


        // setFreq.value(freqVal[4]);
        ~pd_addr.sendMsg("/rssi", 7);

        5.do{| i | synthNodes[i].set(\amp, 0)};
        synthNodes[4].set(\amp, 1);

        // ~grp.run(false);
        // ~grp.freeAll;
        // if (~grp.isRunning == false, {
        //     {WhiteNoise.ar(1)*0.2!2}.play(~grp);
        //     ~grp.run(true);
        // });


        });

}, '/rssi');



// -- SOUND --
/*~p1 = Pbind(
    \instrument, \tak,
    \dur, Pseq([
		onebeat, onebeat, onebeat, onebeat
	]*timeMul, inf),
	\legato, 0.5,
    \freq, #[180, 240, 300]*0.315,
	\atTime, Pseq([
        0.3, 0.3, 0.3, 0.4, 0.3, 0.3,
        0.4, 0.3, 0.3, 0.4, 0.6, 0.3, 0.01
    ], inf),
	\susTime, Pseq([
        2, 2, 2, 2, 2, 2,
        2, 2, 2, 2, 2, 2, 2
    ], inf),
	\amp, ampMul
).play;*/


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

NodeWatcher.register(a);
a = {SinOsc.ar(100)}.play;
a.free;
a.species
a.isPlaying


(
~grp = Group.new(s);
NodeWatcher.register(~grp);
// {SinOsc.ar(300)!2}.play(~grp);
)


~grp.freeAll;
~grp.run(false);

~grp.isRunning



{SinOsc.ar(300)!2}.play(~grp);
~grp.run(true);


(
~grp.queryTree{|msg|
   var i = 1, tabs = 0, dumpFunc;
   ("NODE TREE Group" + msg[1]).postln;
   if(msg[2] > 0, {
       dumpFunc = {|numChildren|
           tabs = tabs + 1;
           numChildren.do({
               i = i + 3;
               tabs.do({ "   ".post });
               msg[i].post;
               (" " ++ msg[i + 2]).postln;
               if(msg[i + 1] > 0, { dumpFunc.value(msg[i + 1]) });
           });
           tabs = tabs - 1;
       };
       dumpFunc.value(msg[2]);
   });

}
)

~grp.group.inspect

~grp.query;
~grp.run(false);
~grp.isRunning
~grp.run(true);
~grp.freeAll;
a.run(false);
a.run(true);
a.isRunning
a.isPlaying
a.dumpTree;
a.freeAll



a.isPlaying











