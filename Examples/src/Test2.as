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

JSAE Flash - creating groups and effects.

This example demonstrates how to create a group and play sounds through it.
A group can contain an unlimited number of dsp effects. This example
creates a simple delay and let the user change some of its parameters by moving
the mouse over the gray area.

*/

package  {
	
	import flash.display.MovieClip;
	import com.klevgrand.JSAE.JSAEEvent;
	import com.klevgrand.JSAE.JSAEWrapper;
	import flash.events.MouseEvent;
	
	
	public class Test2 extends MovieClip {
		private var jsae:JSAEWrapper;
		
		// gui
		public var playBtn:MovieClip;
		public var stopBtn:MovieClip;
		public var mouseArea:MovieClip;
		
		// states
		private var loopIsPlaying:Boolean = false;

		// references to playing sound and playing sound
		private var loopId:uint;
		private var runningLoopId:int;
		
		// reference to group
		private var groupId:int;		
		// reference to delay effect
		private var delayId:uint;
		
		// constr.
		public function Test2() {
			jsae = JSAEWrapper.initialize(2048);
			
			// create a new group with gain
			groupId = jsae.createGroup(0.6);
			
			// create a delay effect and put it in the group
			delayId = jsae.createEffect(JSAEWrapper.JSAEEffectIdTapeDelay, groupId);
			
			// change some effect parameters. Effects and parameters are documented in JSAEWrapper.as
			jsae.setEffectParam(delayId, "time", 200);
			jsae.setEffectParam(delayId, "amount", 0.5);
			
			
			// Create a looped soundsource and put it in the group.
			loopId = jsae.addSound(new Loop(), groupId, 0, JSAEWrapper.JSAESoundSourceTypeLooped);
			
			// start engine
			jsae.run();
			
			// buttons....
			playBtn.addEventListener(MouseEvent.CLICK, onLoopPlay);
			stopBtn.addEventListener(MouseEvent.CLICK, onLoopStop);
			
			// mouse area...
			mouseArea.addEventListener(MouseEvent.MOUSE_MOVE, onMove);

			
		}
		
		// mus över area
		private function onMove(e:MouseEvent):void {
			if (!loopIsPlaying) return;
			
			var xf:Number = mouseArea.mouseX/mouseArea.width;
			var yf:Number = mouseArea.mouseY/mouseArea.height;
			// change decay
			jsae.setEffectParam(delayId, "decay", xf);
			// change feedback
			jsae.setEffectParam(delayId, "feedback", yf);
			
		}
		
		// start the loop
		private function onLoopPlay(e:MouseEvent):void {
			if (loopIsPlaying) return;
			runningLoopId = jsae.playSound(loopId, jsae.getFramePosition(), 1.0, 0.8);
			loopIsPlaying = true;
		}
		
		// stop the loop
		private function onLoopStop(e:MouseEvent):void {
			if (!loopIsPlaying) return;
			jsae.stopSound(loopId, runningLoopId);
			loopIsPlaying = false;
		}
		
	}
	
}
