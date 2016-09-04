(

fork{

    {
        if (~micInEQ.isNil == true, {
            ~micInEQ = ChannelEQ.new(2, s, 60, 110);
        }, {
            if (~micInEQ.exist == false, {
                ~micInEQ = ChannelEQ.new(2, s, 60, 110);
            });
        });

    }.defer;

    0.5.wait;

    {
        if (~numberVoiceEQ.isNil == true, {
            ~numberVoiceEQ = ChannelEQ.new(2, s, 58, 108);
        }, {
            if (~numberVoiceEQ.exist == false, {
                ~numberVoiceEQ = ChannelEQ.new(2, s, 58, 108);
            });
        });

    }.defer;

    0.5.wait;

    {
        if (~voiceEQ.isNil == true, {
            ~voiceEQ = ChannelEQ.new(2, s, 52, 102);
        }, {
            if (~voiceEQ.exist == false, {
                ~voiceEQ = ChannelEQ.new(2, s, 52, 102);
            });
        });

    }.defer;

    0.5.wait;

    {
        if (~songEQ.isNil == true, {
            ~songEQ = ChannelEQ.new(2, s, 54, 104);

        }, {
            if (~songEQ.exist == false, {
                ~songEQ = ChannelEQ.new(2, s, 54, 104);

            });
        });
    }.defer;

    0.5.wait;


    {
        if (~masterEQ.isNil == true, {
            ~masterEQ = ChannelEQ.new(2, s, 0, 0);

        },{
            if (~masterEQ.exist == false, {
                ~masterEQ = ChannelEQ.new(2, s, 0, 0);
            });
        });

    }.defer;

    0.5.wait;

    {
    ~micInEQ.gui.onSelect('yang_mic');
    ~numberVoiceEQ.gui.onSelect('yang_nv');
    ~voiceEQ.gui.onSelect('x_telephone');
    ~songEQ.gui.onSelect('yang_song');
    ~masterEQ.gui.onSelect('normal');
    }.defer;

};


// ~pd_addr = NetAddr("127.0.0.1", 9000);


SynthDef(\micin, {
    | out = 60, amp = 0, gate = 1,
    ths = 0.3, slB = 1, slA = 0.7, clpTime = 0.01, relTime = 0.1 |
    var sig, compSig;
    sig = SoundIn.ar(0);
    compSig = Compander.ar(
        in: sig,
        thresh: ths,
        slopeBelow: slB,
        slopeAbove: slA,
        clampTime: clpTime,
        relaxTime: relTime
    );
    Out.ar(out, Pan2.ar(compSig, 0, amp));
}).add;

SynthDef(\mixer, {
    | out = 0, gate = 1, amp = 0.8, pan = 0,
    amp0 = 1, amp1 = 1, amp2 = 1, amp3 = 1, amp4 = 1, amp5 = 1, amp6 = 1,
    pan0 = 0, pan1 = 0, pan2 = 0, pan3 = 0, pan4 = 0, pan5 = 0, pan6 = 0,
    ths = 0.5, slB = 1, slA = 1, clpTime = 0.01, relTime = 0.1 |

	var sig0, sig1, sig2, sig3, sig4, sig5, sig6, sumSig, compSig, env;
    sig0 = Pan2.ar(In.ar(98, 2), pan0, amp0);
    sig1 = Pan2.ar(In.ar(100, 2), pan1, amp1);
    sig2 = Pan2.ar(In.ar(102, 2), pan2, amp2);
    sig3 = Pan2.ar(In.ar(104, 2), pan3, amp3);
    sig4 = Pan2.ar(In.ar(106, 2), pan4, amp4);
    sig5 = Pan2.ar(In.ar(108, 2), pan5, amp5);
    sig6 = Pan2.ar(In.ar(110, 2), pan6, amp6);

    env = EnvGen.kr(Env.asr(0.01, 1, 1), gate, doneAction: 2);
    sumSig = Mix.ar([sig0, sig1, sig2, sig3, sig4, sig5, sig6]);
    compSig = Compander.ar(
        in: sumSig,
        thresh: ths,
        slopeBelow: slB,
        slopeAbove: slA,
        clampTime: clpTime,
        relaxTime: relTime
    );
    Out.ar(out, Pan2.ar(compSig*env, pan, amp));
}).add;


SynthDef(\ting, {| out = 0, freq = 1000, amp = 1, amp2 = 0.9, filfreq = 1500, rq = 0.3, gate = 1, pan = 0 |
	var sig, env, lowcut_sig;
	sig = LFPar.ar(freq);
	sig = RHPF.ar(sig, filfreq, rq, sig*0.8);
	lowcut_sig = HPF.ar(sig, 100);
	env = EnvGen.kr(Env.perc(0.05, 0.6), gate, doneAction: 2);
	Out.ar(out, Pan2.ar(lowcut_sig * env, pan, amp));
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


SynthDef(\aha, {|
    dt = 0.2, if = 3, mf = 10, out = 106, freq = 300, amp = 0.6, amp2 = 0.9, filfreq = 3200, rq = 0.1, gate = 1,
	atTime = 0.1, susTime = 2.0, relTime = 0.1, pan = 0 |

	var sig, env, sig2, del, mod, lowcut_sig;
    mod = LFSaw.kr(mf).range(0, 1);
	sig = LFCub.ar(freq,  mod);
    sig2 = Impulse.ar(if, mul: amp2);
    sig = BPF.ar((sig + sig2), filfreq, rq, sig*0.3);
    sig = DelayN.ar(sig, 0.6, dt, add: sig*0.3);
	lowcut_sig = HPF.ar(sig, 100);
	Out.ar(out, Pan2.ar(lowcut_sig, pan, amp));

}).add;

)