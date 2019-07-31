"SC_JACK_DEFAULT_OUTPUTS".setenv(
    "system:playback_1",
    "system:playback_2"
    );

ServerQuit.add({
    'FAIL: scsynth quit'.postln;
    1.exit();
}, Server.default);
