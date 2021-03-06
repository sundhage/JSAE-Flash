﻿/*
Copyright (c) 2012 Johan Sundhage

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


/*

JSAE Flash - playing and controlling audio example.

Demonstrates two kinds of sound sources: Normal (RAW Buffer) and
Looped; an endless sound source that will loop continously.

A looped sound source can change pitch when running. Start a loop
and move around the mouse cursor in the gray area to change pitch and volume.

*/

package  {
	
	
	
	
	import flash.display.MovieClip;
	import com.klevgrand.JSAE.JSAEEvent;
	import com.klevgrand.JSAE.JSAEWrapper;
	import flash.events.MouseEvent;
	import com.klevgrand.JSAE.JSAEAsyncExtractor;
	import com.klevgrand.JSAE.JSAEAsyncEvent;

	
	public class Test1 extends MovieClip {
		
		private var jsae:JSAEWrapper;
		// gui grejjor
		public var playSeqBtn:MovieClip;
		public var stopSeqBtn:MovieClip;
		public var playLoopBtn:MovieClip;
		public var stopLoopBtn:MovieClip;
		public var mouseArea:MovieClip;
		
		
		// states
		private var seqIsPlaying:Boolean = false;
		private var loopIsPlaying:Boolean = false;
		
		// reference to JSAE-sounds
		private var seq1Id:uint;
		private var seq2Id:uint;
		
		// referens to playing sound (like a SoundChannel instance). (-1 means null)
		private var runningSeq1:int = -1;
		private var runningSeq2:int = -1;
		
		// referenser till ytterligare ett ljud, fast som är loopbart
		private var loopId:uint;
		private var runningLoopId:int;
		
		
		
		public function Test1() {
			// initialize JSAE with 2048 frames buffersize
			jsae = JSAEWrapper.initialize(2048);
			
			// listen to events dispached by JSAE
			jsae.addEventListener(JSAEEvent.SOUND_END, onSoundEnd);
			jsae.addEventListener(JSAEEvent.SOUND_MUSICAL_END, onSoundMusicalEnd);
			jsae.addEventListener(JSAEEvent.SOUND_START, onSoundStart);
			jsae.addEventListener(JSAEEvent.SOUND_WILL_DISPOSE, onSoundWillDispose);
			
			// create two sounds. Each sound has a musical length of 2 seconds (the actual sound length is more) 
			seq1Id = jsae.addSound(new Seq1(), JSAEWrapper.JSAE_NO_GROUP, 2.0, JSAEWrapper.JSAESoundSourceTypeNormal, true);
			seq2Id = jsae.addSound(new Seq2(), JSAEWrapper.JSAE_NO_GROUP, 2.0, JSAEWrapper.JSAESoundSourceTypeNormal, true);
			// create a loopable sound
			loopId = jsae.addSound(new Loop(), JSAEWrapper.JSAE_NO_GROUP, 0, JSAEWrapper.JSAESoundSourceTypeLooped, true);
			
			// wait for sounds extract
			JSAEAsyncExtractor.getInstance().addEventListener(JSAEAsyncEvent.SOUND_EXTRACT_JOBS_FINISHED, onSoundExtractFinished);
			

			// dispatched when all sounds are extracted.
			function onSoundExtractFinished(e:JSAEAsyncEvent):void {
				// start
				trace("finished");
				jsae.run();
				
				// buttons...
				playSeqBtn.addEventListener(MouseEvent.CLICK, onSeqPlay);
				stopSeqBtn.addEventListener(MouseEvent.CLICK, onSeqStop);
				playLoopBtn.addEventListener(MouseEvent.CLICK, onLoopPlay);
				stopLoopBtn.addEventListener(MouseEvent.CLICK, onLoopStop);
				
				// mouse move-area
				mouseArea.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
			
			
			
			
		}
		
		// ********************************** JSAE Events **********************************
		
		// dispatched when a sound has reached its end
		private function onSoundEnd(e:JSAEEvent):void {
			
		}
		// dispatched when a sound reaches its musical end (2 seconds in this case)
		private function onSoundMusicalEnd(e:JSAEEvent):void {
			// if it is the second sound -> restart both of them with proper delay
			if (e.soundId == seq2Id) {
				// diffInSamples is the offset compared to the current framePositions which iterates with
				// buffersize.
				runningSeq1 = jsae.playSound(seq1Id, jsae.getFramePosition()+e.diffInSamples, 1.0, 0.8);
				runningSeq2 = jsae.playSound(seq2Id, jsae.getFramePosition()+44100*2+e.diffInSamples, 1.0, 0.8);
				
			}
		}
		
		// dispatched when a sound starts playing
		private function onSoundStart(e:JSAEEvent):void {
			
		}
		// dispatched before a running sound is about to be disposed.
		private function onSoundWillDispose(e:JSAEEvent):void {
			
		}

		// ********************************** G U I **********************************
		
		// mouse movement...
		private function onMove(e:MouseEvent):void {
			if (!loopIsPlaying) return;
			
			var xf:Number = mouseArea.mouseX/mouseArea.width;
			var yf:Number = mouseArea.mouseY/mouseArea.height;
			// change volym
			jsae.setRunningSoundGain(loopId, runningLoopId, 1-yf);
			// change pitch
			jsae.setRunningSoundPitch(loopId, runningLoopId, xf*4-2);
			
		}
		
		// starts a sequence of 2 sounds.		
		private function onSeqPlay(e:MouseEvent):void {
			if (seqIsPlaying) return;
			
			// play now
			runningSeq1 = jsae.playSound(seq1Id, jsae.getFramePosition(), 1.0, 0.8);
			//play in 2 secs
			runningSeq2 = jsae.playSound(seq2Id, jsae.getFramePosition()+44100*2, 1.0, 0.8);
			
			seqIsPlaying = true;
		}
		
		// stops the sequence		
		private function onSeqStop(e:MouseEvent):void {
			if (!seqIsPlaying) return;
			// need to stop both sounds.
			jsae.stopSound(seq1Id, runningSeq1);
			jsae.stopSound(seq2Id, runningSeq2);
			seqIsPlaying = false;
		}
		
		// starts the loop
		private function onLoopPlay(e:MouseEvent):void {
			if (loopIsPlaying) return;
			runningLoopId = jsae.playSound(loopId, jsae.getFramePosition(), 1.0, 0.8);
			loopIsPlaying = true;
		}
		
		// stops the loop
		private function onLoopStop(e:MouseEvent):void {
			if (!loopIsPlaying) return;
			jsae.stopSound(loopId, runningLoopId);
			loopIsPlaying = false;
		}
		
	}
	
}
