# supercollider example
* `docker build -f Dockerfile.sc -t pulse-streamer-sc .`
* `docker run --privileged --ulimit nice=1:1 --ulimit rtprio=99:99 --ulimit memlock=800000000:800000000 --volume=/dev/shm:/dev/shm:rw --user=1000 -it awestruck /bin/bash`
* [you are now in the container]

# TODO
Cannot get JACK to start with realtime scheduling once inside the container. I think we need this to get SC audio to be consumed by Pulse/Jack/GStreamer. Many attempts from different angles without success.

Getting the following error when trying to run only JACK in realtime mode within the Docker container:

```
po@541e14f32d12:/$ jackd -R -d dummy -r 44100
jackdmp 1.9.12
Copyright 2001-2005 Paul Davis and others.
Copyright 2004-2016 Grame.
Copyright 2016-2017 Filipe Coelho.
jackdmp comes with ABSOLUTELY NO WARRANTY
This is free software, and you are welcome to redistribute it
under certain conditions; see the file COPYING for details
JACK server starting in realtime mode with priority 10
self-connect-mode is "Don't restrict self connect requests"
Cannot use real-time scheduling (RR/10)(1: Operation not permitted)
AcquireSelfRealTime error
```

Note the `Cannot use real-time scheduling (RR/10)(1: Operation not permitted)`. Original attempt was to run sclang to play a synth and stream it with gstreamer/pion. SC booted but complained about not being able to set the realtime scheduling priority:
```
po@5dd7cdee6d7a:/$ pulseaudio --start & jackd -r -d dummy -r 44100 & xvfb-run -a sclang /usr/src/tst.sc & echo $BROWSER_SDP | gstreamer-send -audio-src "pulsesrc ! audioconvert ! audioresample"
[1] 7
[2] 8
[3] 9
jackdmp 1.9.12
Copyright 2001-2005 Paul Davis and others.
Copyright 2004-2016 Grame.
Copyright 2016-2017 Filipe Coelho.
jackdmp comes with ABSOLUTELY NO WARRANTY
This is free software, and you are welcome to redistribute it
under certain conditions; see the file COPYING for details
JACK server starting in non-realtime mode
self-connect-mode is "Don't restrict self connect requests"

{$THIS_IS_THE_BROWSER_SDP_RESP}

Connection State has changed checking
compiling class library...
QStandardPaths: XDG_RUNTIME_DIR not set, defaulting to '/tmp/runtime-po'
	Found 845 primitives.
	Compiling directory '/usr/share/SuperCollider/SCClassLibrary'
	Compiling directory '/usr/share/SuperCollider/Extensions'
	numentries = 818594 / 11958602 = 0.068
	5353 method selectors, 2234 classes
	method table size 13112760 bytes, big table size 95668816
	Number of Symbols 12127
	Byte Code Size 364116
	compiled 317 files in 1.14 seconds

Info: 4 methods are currently overwritten by extensions. To see which, execute:
MethodOverride.printAll

compile done
localhost : setting clientID to 0.
internal : setting clientID to 0.
Couldn't set realtime scheduling priority 1: Operation not permitted
Class tree inited in 0.03 seconds


*** Welcome to SuperCollider 3.10.0. *** For help type ctrl-c ctrl-h (Emacs) or :SChelp (vim) or ctrl-U (sced/gedit).
Couldn't set realtime scheduling priority 1: Operation not permitted
Hello World!
WARNING: server 'localhost' not running.
Booting server 'localhost' on address 127.0.0.1:57110.
JackDriver: client name is 'SuperCollider'
SC_AudioDriver: sample rate = 44100.000000, driver's block size = 1024
JackDriver: connected  system:capture_1 to SuperCollider:in_1
JackDriver: connected  system:capture_2 to SuperCollider:in_2
JackDriver: connected  SuperCollider:out_1 to system:playback_1
JackDriver: connected  SuperCollider:out_2 to system:playback_2
SuperCollider 3 server ready.
JackDriver: max output latency 46.4 ms
Requested notification messages from server 'localhost'
localhost: server process's maxLogins (1) matches with my options.
localhost: keeping clientID (0) as confirmed by server process.
Shared memory server interface initialized
JackTimedDriver::Process XRun = 42 usec
JackTimedDriver::Process XRun = 69 usec
JackTimedDriver::Process XRun = 46 usec
JackTimedDriver::Process XRun = 41 usec
JackTimedDriver::Process XRun = 68 usec
JackTimedDriver::Process XRun = 52 usec
Connection State has changed connected
JackTimedDriver::Process XRun = 902 usec
...
```

The repeated `Couldn't set realtime scheduling priority 1: Operation not permitted` errors imply that JACK should be running in realtime (-R), but I cannot get it to start in realtime (-R).

Tried:
* setting rtprio, memlock and nice in limits.conf to high priorities in various directories
* These did not seem to be respected (was getting `Cannot lock down 82280346 byte memory area (Cannot allocate memory)` errors), so ran Docker with priorities and passed ulimits into `docker run...`. Only `--user=1000` helped avoid the memlock "Cannot lock down ..." errors.
* Notice that `CONFIG_RT_GROUP_SCHED` is enabled within the container: `zcat /proc/config.gz | grep CONFIG_RT_GROUP_SCHED`. This post from jackaudio.org suggests this "has the potential to wreak havoc on applications that want to use realtime scheduling". Followed instructions here to address without success: http://jackaudio.org/faq/linux_group_sched.html. See more details here: https://github.com/jackaudio/jackaudio.github.com/wiki/Cgroups (no success modifying cgconfig.conf or cgrules.conf)