## SuperCollider + JACK + GStreamer + Pion WebRTC example

First, to get some test audio streaming over the web with JACK, GStreamer and Pion from a docker container, check out this Pion WebRTC example [app](https://github.com/pion/example-webrtc-applications/tree/master/gstreamer-send#open-gstreamer-send-example-page)

* Go to the jsfiddle example it references, [here](https://jsfiddle.net/z7ms3u5r/). This is where you'll hear the audio streaming from your docker container.
* Copy the long token in the "Browser base64 Session Description" text area, save this for a few steps below

Then, in your terminal within this cloned repo
* `cd examples/supercollider`
* `docker build -f Dockerfile.supercollider -t j-sc-2 .`
* `docker run --volume=/dev/shm:/dev/shm:rw --user=po -it j-sc-2 bash`

Now, to play a test tone in the container and stream to the jsfiddle, run the following in the container:

* set the token you copied from the jsfiddle to a variable with `BROWSER_SDP=<token-you-copied>`
* then start gstreamer/pion: `echo $BROWSER_SDP | gstreamer-send -audio-src "audiotestsrc ! audioconvert ! audioresample"`

There's also an example audio file included in the Dockerfile.supercollider. To play it, run the following in the container (may need to reload the jsfiddle, recopy the token and set to BROWSER_SDP again if you tried the test tone above):

* `echo $BROWSER_SDP | gstreamer-send -audio-src "filesrc location=/usr/src/vocals.wav ! wavparse ! audioconvert ! audioresample"`

The test tone and the audio file should both be audible through the JS fiddle once you copy the response token returned from each `echo ...` command into the `Golang base64 Session Description` text field and click "Start Sesssion"

#### Problem: cannot get SuperCollider to stream with JACK + GStreamer + Pion

Assuming the docker image from above is built, open three separate terminal windows and run the `docker run...` command in each to open three bash sessions in the container:

* `docker run --volume=/dev/shm:/dev/shm:rw --user=po -it j-sc-2 bash`

In the first session, start JACK:

* `jackd -r -d dummy -r 44100`

In the second one, after reloading the JS fiddle, copying the token and setting BROWSER_SDP=<token> in the container, start the gstreamer-send Pion program:

* `echo $BROWSER_SDP | gstreamer-send -audio-src "jackaudiosrc ! audioconvert ! audioresample ! autoaudiosink"`

Copy the token response for use later in the JSFiddle after you run SuperCollider in the steps below

* Now, in the third session, confirm that you see the new JACK ports that gstreamer has created after executing the `gstreamer-send...` command:
* `jack_lsp`

you should see something like this:

```
system:capture_1
system:capture_2
system:playback_1
system:playback_2
gstreamer-send-01:in_jackaudiosrc0_1
gstreamer-send-01:in_jackaudiosrc0_2
gstreamer-send:out_autoaudiosink0-actual-sink-jackaudio_1
gstreamer-send:out_autoaudiosink0-actual-sink-jackaudio_2
```

The important ones are `gstreamer-send-01:in_jackaudiosrc0_1` and `gstreamer-send-01:in_jackaudiosrc0_2`. GStreamer created these JACK ports, and these are what we need to hook SuperCollider up to (see `startup.scd`, where these are hardcoded for now)

Then run supercollider:
* `xvfb-run -a sclang /usr/src/tst.sc`

You should see something like:

```
JackDriver: client name is 'SuperCollider'
SC_AudioDriver: sample rate = 44100.000000, driver's block size = 1024
JackDriver: connected  system:capture_1 to SuperCollider:in_1
JackDriver: connected  system:capture_2 to SuperCollider:in_2
JackDriver: connected  SuperCollider:out_1 to gstreamer-send-01:in_jackaudiosrc0_1
SuperCollider 3 server ready.
Requested notification messages from server 'localhost'
localhost: server process's maxLogins (1) matches with my options.
localhost: keeping clientID (0) as confirmed by server process.
Shared memory server interface initialized
/home/po/.config/SuperCollider
Hello World!
```

SuperCollider is running the tst.sc file referenced in the Dockerfile (it prints "Hello World!" and plays some sound. Note the `JackDriver: connected  SuperCollider:out_1 to gstreamer-send-01:in_jackaudiosrc0_1`, which confirms SuperCollider could connect to this JACK port created by GStreamer (not sure why the second port is not being connected to, but that's for later).

Now, go back to the JSFiddle and paste the response from the gstreamer-send command, then click "Start Sesssion".

No audio can be heard...

Hypothesis: this must mean that:
* the gstreamer-send is missing something required to convert the JACK stream into something audible for the JSFiddle and/or
* the SC output needs to be hooked up to the JACK input port GStreamer created before JACK can then output it to GStreamer