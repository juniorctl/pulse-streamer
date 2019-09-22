"SC_JACK_DEFAULT_OUTPUTS".setenv(
    "gstreamer-send-01:in_jackaudiosrc0_1",
    "gstreamer-send-01:in_jackaudiosrc0_2"
    );

ServerQuit.add({
    'FAIL: scsynth quit'.postln;
    1.exit();
}, Server.default);
