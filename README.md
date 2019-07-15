# pulse-streamer
* docker build -f Dockerfile -t pulse-streamer .
* docker run -it pulse-streamer /bin/bash
* pulseaudio --start

see: https://github.com/pion/example-webrtc-applications/tree/master/gstreamer-send#open-gstreamer-send-example-page

* echo $BROWSER_SDP | gstreamer-send -audio-src "audiotestsrc ! audioconvert ! audioresample"
* paste the response in the jsfiddle and hear the test tone

next steps: produce a custom live audio stream (e.g. supercollider) from within the container, consume from the jsfiddle
