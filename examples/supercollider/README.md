## Pion WebRTC/Gstreamer example

First, check out this Pion example [app](https://github.com/pion/example-webrtc-applications/tree/master/gstreamer-send#open-gstreamer-send-example-page)

* Go to the jsfiddle example it references, [here](https://jsfiddle.net/z7ms3u5r/)
* Copy the `Browser base64 Session Description` token in the text field, save this for a few steps below

Then, in your terminal within this cloned repo and after cd'ing into `examples/supercollider`:
* `docker build -f Dockerfile.supercollider -t j-sc-2 .`
* `docker run --privileged --ulimit nice=1:1 --ulimit rtprio=99:99 --ulimit memlock=800000000:800000000 --volume=/dev/shm:/dev/shm:rw --user=po -it j-sc-2 /bin/bash`

Now, to play a test tone in the container and stream to the jsfiddle:

* `echo $BROWSER_SDP | gstreamer-send -audio-src "audiotestsrc ! audioconvert ! audioresample"`

Or the example audio file (may need to reload the jsfiddle and recopy the token and set to BROWSER_SDP again):

* `echo $BROWSER_SDP | gstreamer-send -audio-src "filesrc location=/usr/src/vocals.wav ! wavparse ! audioconvert ! audioresample"`

These should both be audible through the JS fiddle once you copy the response token returned from each `echo ...` command into the `Golang base64 Session Description` text field and click "Start Sesssion"

#### Problem: cannot get supercollider to stream with jack

Repeat the above steps, replacing the echo with:

* `echo $BROWSER_SDP | gstreamer-send -audio-src "jackaudiosrc connect=auto ! jackaudiosink connect=auto"`

No audio :(