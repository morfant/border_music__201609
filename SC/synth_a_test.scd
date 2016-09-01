a = Synth(\a, [\freq, #[180, 240, 300], \amp, 30]);

a.set(\freq, #[180, 240, 300]*0.6, \mf, 1/100, \if, 2/3, \dt, 0.1, \amp, 40)
a.set(\freq, 10)

a.free;