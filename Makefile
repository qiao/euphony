all: $(shell find src/coffee -name "*.coffee" -type f)
	coffee -o src/compiled src/coffee

build:
	@cat \
		css/font-awesome.css \
		css/nanoscroller.css \
		css/style.css \
		> build/application.css
	@cat \
		lib/MIDI.js/VersionControl.Base64.js \
		lib/MIDI.js/lib/base64binary.js \
		lib/MIDI.js/lib/jasmid/stream.js \
		lib/MIDI.js/lib/jasmid/midifile.js \
		lib/MIDI.js/lib/jasmid/replayer.js \
		lib/MIDI.js/DOMLoader.XMLHttp.js \
		lib/MIDI.js/DOMLoader.script.js \
		lib/MIDI.js/MIDI.audioDetect.js \
		lib/MIDI.js/MIDI.loadPlugin.js \
		lib/MIDI.js/MIDI.Plugin.js \
		lib/MIDI.js/MIDI.Player.js \
		lib/MIDI.js/Color.js \
		lib/MIDI.js/MusicTheory.js \
		lib/MIDI.js/MusicTheory.Synesthesia.js \
		lib/jquery-1.7.1.min.js \
		lib/jquery.easing.js \
		lib/jquery.nanoscroller.min.js \
		lib/Three.js \
		lib/OrbitControls.js \
		lib/state-machine.min.js \
		lib/spin.min.js \
		lib/async.min.js \
		src/compiled/PianoKeyboard.js \
		src/compiled/NoteRain.js \
		src/compiled/NoteParticles.js \
		src/compiled/Scene.js \
		src/compiled/LoaderWidget.js \
		src/compiled/PlayerWidget.js \
		src/compiled/Euphony.js \
		src/compiled/Main.js \
		> build/application.js
	@uglifyjs -o build/application.js build/application.js


watch:
	coffee -wo src/compiled src/coffee	

server:
	python -m SimpleHTTPServer

.PHONY: build watch server
