/*
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

JSAE Flash - a 32x32 loop matrix

A small application where the user can alter a sequence of sounds.
The x-axis is time (in 16'th of a quarter) and the y-axis what sound
that should be triggered.

There's also a couple of slider to alter tempo and effects (delay, eq)

*/

package  {
	
	import flash.display.MovieClip;
	import flash.media.SoundTransform;

	import com.klevgrand.JSAE.JSAEEvent;
	import com.klevgrand.JSAE.JSAEWrapper;
	import flash.events.MouseEvent;
	import flash.media.Sound;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import flash.display.Sprite;
	import fl.controls.Slider;
	import fl.events.SliderEvent;
	
	// 162,4 --> 60/162 * 4 * 44100 = 
	
	public class Test3 extends MovieClip {
		// in samples.. (4 beats @ 162 bpm)
//		private var soundLen:Number = (60/78)*0.25;
		private var soundLen:Number = (60/78)*0.25;
		
		// original
		private var mxSeq:Array = [];
		
		// what is playing
		private var mxLoop:Array = [];
		private var mxLoopIndex:int = 0;
		private var mxLoopSignal:Boolean = true;
		private var mxLoopCheckup:Object;
		private var loopGroupId:int;


		private var delayId:int;
		private var lowpassId:int;
		
		
		
		private var jsae:JSAEWrapper;
		
		public static const BUFFERSIZE:int = JSAEWrapper.JSAE_BUFFERSIZE_4096;
		
		
		public var playBtn:MovieClip;
		public var stopBtn:MovieClip;
		public var mouseArea:MovieClip;
		private var grid:Grid;
		private var indicator:Sprite;
		public var tempoSlider:Slider;
		
		
		public var delayTimeSlider:Slider;
		public var delayFeedbackSlider:Slider;
		public var delayDecaySlider:Slider;
		public var delayMixSlider:Slider;
		
		public var lowpassFreqSlider:Slider;
		public var lowpassResonanceSlider:Slider;
		
		
		

		public function Test3() {
			soundLen = Math.round(soundLen*1000)/1000;
			//trace(soundLen);

			playBtn.addEventListener(MouseEvent.CLICK, onPlayMx);
			stopBtn.addEventListener(MouseEvent.CLICK, onStopMx);
			
			var startTime:Number = getTimer();
			
			
			// setup jsae
			jsae = JSAEWrapper.initialize(BUFFERSIZE);
			jsae.addEventListener(JSAEEvent.SOUND_MUSICAL_END, onMusicalEnd);
			loopGroupId = jsae.createGroup(0.8);
			
			
			mxLoop.push(jsae.addSound(new Loop1(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop2(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop3(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop4(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop5(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop6(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop7(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop8(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop9(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop10(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop11(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop12(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop13(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop14(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop15(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop16(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop17(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop18(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop19(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop20(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop21(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop22(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop23(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop24(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop25(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop26(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop27(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop28(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop29(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop30(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop31(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));
			mxLoop.push(jsae.addSound(new Loop32(), loopGroupId, soundLen, JSAEWrapper.JSAESoundSourceTypeNormal));

			// create hashmap
			mxLoopCheckup = createCheckup(mxLoop);
			
			// keep original data in mxSeq
			for (var i:int = 0; i<mxLoop.length; i++) {
				mxSeq.push(mxLoop[i]);
			}
			delayId = jsae.createEffect(JSAEWrapper.JSAEEffectIdTapeDelay, loopGroupId);
			lowpassId = jsae.createEffect(JSAEWrapper.JSAEEffectIdLowpass, loopGroupId);
			jsae.setEffectParam(delayId, "amount", 0);
			jsae.setEffectParam(lowpassId, "freq", 20000);
			
			jsae.run();
			// 20 ljud a 
			var diff:Number = (getTimer()-startTime)/1000;
			
			//trace("Init time: ", diff);
			
			tempoSlider.maximum = 1000;
			tempoSlider.addEventListener(SliderEvent.THUMB_DRAG, onTempoChange);
			
			delayTimeSlider.maximum = 1000;
			delayFeedbackSlider.maximum = 1000;
			delayDecaySlider.maximum = 1000;
			delayMixSlider.maximum = 1000;
			
			delayTimeSlider.addEventListener(SliderEvent.THUMB_DRAG, onDelayTimeChange);
			delayFeedbackSlider.addEventListener(SliderEvent.THUMB_DRAG, onDelayFeedbackChange);
			delayDecaySlider.addEventListener(SliderEvent.THUMB_DRAG, onDelayDecayChange);
			delayMixSlider.addEventListener(SliderEvent.THUMB_DRAG, onDelayMixChange);
			
			lowpassFreqSlider.maximum = 1000;
			lowpassResonanceSlider.maximum = 1000;
			lowpassFreqSlider.addEventListener(SliderEvent.THUMB_DRAG, onLowpassFreqChange);
			lowpassResonanceSlider.addEventListener(SliderEvent.THUMB_DRAG, onLowpassResonanceChange);
			
			indicator = new Sprite();
			indicator.graphics.beginFill(0xff0000, 0.5);
			indicator.graphics.drawRect(0,0,20,640);
			indicator.x = 100;
			indicator.y = 20;
			addChild(indicator);
			
			grid = new Grid(32, 32);
			grid.x = 100;
			grid.y = 20;
			grid.addEventListener("gridclick", onGridClick);
			addChild(grid);
		}
		private function onGridClick(e:Event):void {
			var clickable:Clickable = grid.lastItem;
			var seqPos = clickable.px;
			var soundRef = clickable.py;
			mxLoop[seqPos] = mxSeq[soundRef];
			
			
		}
		
		private function onLowpassFreqChange(e:SliderEvent):void {
			var f:Number = e.value/(e.target as Slider).maximum;
			jsae.setEffectParam(lowpassId, "freq", f*18000+50);
		}
		
		private function onLowpassResonanceChange(e:SliderEvent):void {
			var f:Number = e.value/(e.target as Slider).maximum;
			jsae.setEffectParam(lowpassId, "resonance", f*5+0.2);
			
		}
		
		private function onDelayTimeChange(e:SliderEvent):void {
			var f:Number = e.value/(e.target as Slider).maximum;
			jsae.setEffectParam(delayId, "time", f*1500+50);

		}
		
		private function onDelayFeedbackChange(e:SliderEvent):void {
			var f:Number = e.value/(e.target as Slider).maximum;
			jsae.setEffectParam(delayId, "feedback", f);
			
		}
		
		private function onDelayDecayChange(e:SliderEvent):void {
			var f:Number = e.value/(e.target as Slider).maximum;
			jsae.setEffectParam(delayId, "decay", f);
			
		}
		
		private function onDelayMixChange(e:SliderEvent):void {
			var f:Number = e.value/(e.target as Slider).maximum;
			jsae.setEffectParam(delayId, "amount", f);
			
		}
		
		
		private function onTempoChange(e:SliderEvent):void {
			var f:Number = e.value/(e.target as Slider).maximum;
			var bpm:Number = 70+f*50;
			for (var i:int=0; i<mxLoop.length; i++) {
				var time:Number = (60/bpm)*0.25;
				jsae.setSoundMusicalLength(mxLoop[i], (60/bpm)*0.25);
			}
		}
		
		private function createCheckup(items:Array) {
			var obj:Object = {};
			
			for (var i:int = 0; i<items.length; i++) {
				obj[String(items[i])] = true;
			}
			
			return obj;
		}
		private function onPlayMx(e:MouseEvent):void {
			if (mxLoopSignal == false) return;
			mxLoopSignal = false;
//			for (var i:int = 0; i<mxLoop.length; i++) {
//				jsae.playSound(mxLoop[i], jsae.getFramePosition()+i*soundLen*44100, 1, 1);
//			}
			jsae.playSound(mxLoop[mxLoopIndex], jsae.getFramePosition(), 1, 1);
		}
		private function onStopMx(e:MouseEvent):void {
			mxLoopSignal = true;
			
		}
		
		private function onMusicalEnd(e:JSAEEvent):void {
			
			if (mxLoopCheckup[String(e.soundId)] == true && mxLoopSignal == false) {
				//trace(e.diffInSamples);
				mxLoopIndex = (mxLoopIndex+1)%mxLoop.length;
				jsae.playSound(mxLoop[mxLoopIndex], jsae.getFramePosition()+e.diffInSamples, 1.0, 1.0);
				setTimeout(moveIndicator, (e.diffInSamples+jsae.graphicsLatency)/44.1);
				function moveIndicator():void {
					indicator.x = 100+mxLoopIndex*20;
				}
			}
			
			
		}
		
	}
	
}
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.Event;



class Grid extends Sprite {
	protected static const squareSize:Number = 20;
	private var clickables:Array = [];
	private var w:int;
	private var h:int;
	public var lastItem:Clickable;
	
	public function Grid(w:int, h:int) {
		this.w = w;
		this.h = h;
		
		var bkg:Sprite = new Sprite();
		bkg.graphics.lineStyle(0.5,0,0.5);
		var i:int, j:int;
		for (i = 0; i<w+1; i++) {
			bkg.graphics.moveTo(i*squareSize,0);
			bkg.graphics.lineTo(i*squareSize,h*squareSize);
		}
		for (i = 0; i<h+1; i++) {
			bkg.graphics.moveTo(0,i*squareSize);
			bkg.graphics.lineTo(w*squareSize, i*squareSize);
		}
		
		addChild(bkg);
		
		
		
		for (i=0; i<w; i++) {
			clickables[i] = [];
			for (j=0; j<h; j++) {
				clickables[i][j] = new Clickable(false, i,j);
				clickables[i][j].x = i*squareSize;
				clickables[i][j].y = j*squareSize;
				clickables[i][j].addEventListener(MouseEvent.CLICK, onClick);
				addChild(clickables[i][j]);
				
			}
		}
		
		for (i=0; i<w; i++) {
			clickables[i][i].setOn();
		}
		
		
		
		
	}
	
	private function onClick(e:MouseEvent):void {
		var clickable:Clickable = e.target as Clickable;
		if (clickable.isOn) return;
		for (var c:int=0; c<h; c++) {
			clickables[clickable.px][c].setOff();
		}
		clickable.setOn();
		
		lastItem = clickable;
		dispatchEvent(new Event("gridclick"));
		
	}
	
}

class Clickable extends Sprite {
	public var isOn:Boolean;
	public var px:int;
	public var py:int;
	
	public function Clickable(isOn:Boolean, px:int, py:int) {
		this.isOn = isOn;
		if (isOn) setOn();
		else setOff();
		this.px = px;
		this.py = py;
	}
	public function setOn():void {
		isOn = true;
		this.graphics.clear();
		this.graphics.beginFill(0xffff00, 1);
		this.graphics.drawRect(1,1,18,18);
		this.graphics.endFill();
	}
	
	public function setOff():void {
		isOn = false;
		this.graphics.clear();
		this.graphics.beginFill(0x00ff00, 0.2);
		this.graphics.drawRect(1,1,18,18);
		this.graphics.endFill();
		
	}
}
