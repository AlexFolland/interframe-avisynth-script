# This script was written by me, Alex Folland, in order to use InterFrame (frame rate interpolation script downloadable from here: http://www.spirton.com/interframe/ ) with any video easily.  I hereby waive all rights to this work by using the Creative Commons Zero license, as described here: http://creativecommons.org/choose/zero/ .  You are free to do whatever you want with it.  It's just data.

# This is the video file you want to load with this script.  A full path can be used.  If no path is used, the video must be in the same directory as this script.  A relative path can be used too.
	
	videofile = "c:\media\video\capture\waencode\wa-tas-mission-01-1turn-6.86sec-lex.mkv"
	
# If your input video has a variable frame rate, you'll have to set the frame rate yourself if you want the audio to be synchronized with the resulting video.  It would be ideal to not have to do this and pass vfr video straight to InterFrame, but I don't know how.  My vfr video I originally wrote this script for has an intro that's lower frame rate, then has 29.97 fps for the main part.  Therefore, I used 60000/2002.  If your input video has a constant frame rate, just set "variableframerate" to false, which will cause "inputfpsnumerator" and "inputfpsdenominator" to be ignored.

	variableframerate = false
	inputfpsnumerator = 60000
	inputfpsdenominator = 2002

# You should change this path to point to wherever your ffms2.dll is.  This is ffmpegsource, something that uses ffmpeg or libav to read video files and turn them into clips avisynth can understand.  You can find it here: http://code.google.com/p/ffmpegsource/ .  If this line returns an error or the output looks weird, try changing "loadcplugin" to just "loadplugin".  There are different ways to load ffmpegsource and I still don't fully understand the difference.  Mine works properly only with "loadcplugin".
	
	loadcplugin("a:\tools\ffmpegsource\ffms2.dll")
	
# These commands load the various things necessary to get InterFrame to work, including InterFrame itself.  Point them to wherever the corresponding files that came with InterFrame are located.  After doing that, if the script returns an error about being unable to load fftw3.dll, copy that file from interframe\dependencies to your windows\system32 and windows\syswow64 directories.  I realize this is stupid.  I couldn't get it to work any other way.  Sometimes, programmers (like me) are dumbasses.  :D
	
	import("a:\tools\avisynth\interframe\interframe.avsi")
	loadplugin("a:\tools\avisynth\interframe\dependencies\eedi2.dll")
	loadplugin("a:\tools\avisynth\interframe\dependencies\mvtools2.dll")
	loadplugin("a:\tools\avisynth\interframe\dependencies\removegrainsse3.dll")
	
# InterFrame settings start here.

	# Possible preset values from slowest to fastest: Placebo, Medium, Fast, Faster, Very Fast, Super Fast, Ultra Fast
		
		preset = "Fast"

	# Possible tuning values: Film, Animation, Smooth, UltraSmooth, Weak
		
		tuning = "Animation"

	# If you want the output fps to match your display, you likely want 60000 as the output fps numerator and 1001 as the output fps denominator, since most displays nowadays are 59.94 Hz, even if they say they're 60 Hz.
		
		outputfpsnumerator = 60000
		outputfpsdenominator = 1001

	# This is other dumb stuff that I don't fully understand.  usegpu might be useful to toggle, but I'm not sure how much it helps performance.  The InterFrame documentation said it adds blur that isn't very noticeable.  The dependencies path doesn't seem to matter, causing me to still have to load all the dependencies manually anyway, as done above.  Why doesn't it work?  Well, don't ask me.

		dependenciespath = "a:\tools\avisynth\interframe\dependencies\"
		usegpu = true
		inputtype = "2D"
		algorithm = 0
		sadmlmaskstrength = 0

# InterFrame settings end here.

# Playback speed multiplier!  1 is normal speed, 0.5 is half speed, 0.75 is 3/4 speed, etc.  This will be done before the interframe call, so the slow motion should be shown quite smoothly, assuming interframe is good.  It works nicely for simple motions.

	playbackspeedmultiplier = 1
	
# You can toggle InterFrame usage here. (true / false)

	useinterframe = true

# All settings end here.  The rest of the script just uses all the settings to make it work!

audiostream = ffaudiosource(videofile)
videostream = ffvideosource(videofile,fpsnum=variableframerate?inputfpsnumerator:-1,fpsden=variableframerate?inputfpsdenominator:1)
dubbedvideo = audiodub(videostream,audiostream)

playbackspeedmultiplier != 1 ? eval("""
	dubbedvideo = assumefps(dubbedvideo,framerate(dubbedvideo)*playbackspeedmultiplier,sync_audio=true)
""") : dubbedvideo

useinterframe ? eval("""
	setmemorymax(512)
	setmtmode(2)
	interframe(dubbedvideo,preset,tuning,outputfpsnumerator,outputfpsdenominator,dependenciespath,usegpu,inputtype,algorithm,sadmlmaskstrength)
""") : dubbedvideo