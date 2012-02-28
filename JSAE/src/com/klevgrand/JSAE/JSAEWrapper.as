<<<<<<< HEAD
﻿package com.klevgrand.JSAE
{
	
	import cmodule.libs.JSAE.CLibInit;
	
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * JSAEWrapper is a glue between the C++ project "JSAE" - Johan Sundhage Audio Engine
	 * which is a light-weight platform independent audio rendering engine - and Adobe
	 * Flash applications.
	 * 
	 * To be able to use this API in Flash the library file JSAE.swc must be linked to the project.
	 */
	
	public class JSAEWrapper extends EventDispatcher
	{

		/**
		 * When createing a Sound, this flag marks the sound as normal.
		 * Limitations are no realtime-pitching.
		 */
		public static const JSAESoundSourceTypeNormal:int = 0;
		
		/**
		 * Used when creating sounds.
		 * Creates a looped sound. This type of sounds pitch can be altered in real time.
		 */
		public static const JSAESoundSourceTypeLooped:int = 1;
		
		/**
		 * Uses a soundsource that will callback to AS3 for extracting mp3 data
		 * This method doesn't support pitch alteration.
		 */
		public static const JSAESoundSourceTypeStreaming:int = 2;
		
		/**
		 * A silent sound source. (contains no data but behaves exatcly as a normal one)
		 */
		public static const JSAESoundSourceTypeSilence:int = 3;
		
		/**
		 * Flanger effect params
		 * "freq"		Speed in hz.
		 * "time"		The biggest time difference in milliseconds
		 * "amount"		mix. 0 is dry 1 is wet
		 */
		public static const JSAEEffectIdFlanger:int = 0;
		
		/**
		 * Lowpass params
		 * "freq"		Frequency
		 * "resonance"	Resonance value. A low value means higher Q-value (0.1 is low and 3 is high)
		 */
		public static const JSAEEffectIdLowpass:int = 1;
		
		/**
		 * TapeDelay params
		 * "time"		Delay time in milliseconds
		 * "feedback"	First response gain (0-1)
		 * "decay"		Gain for each loop (0-1)
		 * "amount"		mix. 0 is dry 1 is wet
		 * 
		 */
		public static const JSAEEffectIdTapeDelay:int = 2;
		
		/**
		 * Simple dist, params
		 * "gainIn"		gain in as factor. 
		 * "gainOut"	post dist gain as factor
		 */		
		public static const JSAEEffectIdDirtyDist:int = 3;
		
		/**
		 * Highpass filter, params
		 * "freq"		frequency
		 * "resonance"	q value
		 */
		public static const JSAEEffectIdBiquadFilterHighpass:int = 4;
		
		/**
		 * Lowpass filter, params
		 * "freq"		frequency
		 * "resonance"	q value
		 */		
		public static const JSAEEffectIdBiquadFilterLowpass:int = 5;
		
		/**
		 * Bandpass filter, params
		 * "freq"		frequency
		 * "resonance"	q value
		 */				
		public static const JSAEEffectIdBiquadFilterBandpass:int = 6;
		
		/**
		 * Peak filter, params
		 * "freq"		frequency
		 * "resonance"	q value
		 * "gain"		gain in db.
		 */	
		public static const JSAEEffectIdBiquadFilterPeak:int = 7;
		
		/**
		 * Low shelf filter, params
		 * "freq"		frequency
		 * "resonance"	q value
		 * "gain"		gain in db.
		 */			
		public static const JSAEEffectIdBiquadFilterLowshelf:int = 8;
		
		/**
		 * High shelf filter, params
		 * "freq"		frequency
		 * "resonance"	q value
		 * "gain"		gain in db.
		 */					
		public static const JSAEEffectIdBiquadFilterHighshelf:int = 9;
		
		/**
		 * Pan effect, params
		 * "pan"		pan value (-1 to 1)
		 */		
		public static const JSAEEffectIdPan:int = 10;
		
		
		/**
		 * If a sound won't belong to a group, use this value when creating it.
		 */
		public static const JSAE_NO_GROUP:int = -1;
		
		
		public static const JSAE_BUFFERSIZE_2048:int = 2048;
		public static const JSAE_BUFFERSIZE_4096:int = 4096;
		public static const JSAE_BUFFERSIZE_6144:int = 6144;
		public static const JSAE_BUFFERSIZE_8192:int = 8192;
		
		
		protected static const LATENCY_AT_2048:int = 4500;
		protected static const LATENCY_AT_4096:int = 8200;
		protected static const LATENCY_AT_6144:int = 19500;
		protected static const LATENCY_AT_8192:int = 35000;

		internal var _lib:Object = null;
		private var _masterSound:Sound = null;
		private var _playingMasterSound:SoundChannel = null;
		
		private var _callbackObject:Object;
		public var streamingSounds:Object = {};
		
		
		private var _isRunning:Boolean = false;
		
		private var _graphicsLatency:int;
		private var _bufferSize:uint;
		
		
		public function get graphicsLatency():int {
			return _graphicsLatency;
		}
		/**
		 * @return true if the flash sound system and JSAE is running.
		 */
		public function get isRunning():Boolean { return _isRunning; }
		
		private static var instance:JSAEWrapper = null;
		
		/**
		 * Initializes the alchemy library.
		 * @param bufferSize Buffer size in frames. Minimum is 2048, maximum 8192 (due to C-level memory management)
		 * 
		 **/
		public static function initialize(bufferSize:int):JSAEWrapper {
			instance = new JSAEWrapper(new SingletonEnforcer(), bufferSize);
			return instance;
		}
		
		/**
		 * @return JSAEWrapper instance.
		 */
		public static function getInstance():JSAEWrapper {
			return instance;
		}
		
		/**
		 * Stops the engine and frees sound buffers
		 */
		public static function dispose():void {
			if (!instance) return;
			instance.dispose();
			instance = null;
		}
		
		/**
		 * Private constructor.
		 */
		public function JSAEWrapper(s:SingletonEnforcer, bufferSize:int)
		{

			if (bufferSize == JSAE_BUFFERSIZE_2048) _graphicsLatency = LATENCY_AT_2048;
			else if (bufferSize == JSAE_BUFFERSIZE_4096) _graphicsLatency = LATENCY_AT_4096;
			else if (bufferSize == JSAE_BUFFERSIZE_6144) _graphicsLatency = LATENCY_AT_6144;
			else if (bufferSize == JSAE_BUFFERSIZE_8192) _graphicsLatency = LATENCY_AT_8192;
			else _graphicsLatency = 0;
			_bufferSize = bufferSize;
			var loader:CLibInit = new CLibInit();
			_lib = loader.init();
			_callbackObject = new Object();
			_callbackObject.clazz = this;
			_callbackObject.bufferSize = bufferSize;
			_callbackObject.properData = new ByteArray();
			
			_callbackObject.jsaeCallback = function(eventId:int, soundId:uint, runningSoundId:int, diffInSamples:int):void {
				this.clazz.dispatchEvent(new JSAEEvent(eventId, soundId, runningSoundId, diffInSamples));
			};
				
			_callbackObject.jsaeGetBuffer = function(soundId:uint, offsetInFrames:uint):ByteArray {
				var s:Sound = this.clazz.streamingSounds[soundId.toString()];
				this.properData.clear();
				s.extract(this.properData, this.bufferSize, offsetInFrames);
				this.properData.position = 0;				
				return this.properData;
			};
			
			_lib.initEngine(_callbackObject, bufferSize);
		}
		
		/**
		 * Starts the flash sound system
		 */
		public function run():void {
			if (_isRunning) return;
			_isRunning = true;
			
			_masterSound = new Sound();
			_masterSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);
			_playingMasterSound = _masterSound.play();

			// start sample-callbacks
		}
		
		/**
		 * Stops the flash sound system
		 */
		public function stop():void {
			if (_isRunning == false) return;
			_isRunning = false;
			_playingMasterSound.stop();
			_masterSound = null;
			_playingMasterSound = null;
			// stop sample-callbacks and set master to null
		}
		
		
		private function dispose():void {
			stop();
		}
		
		
		private function onSampleData(e:SampleDataEvent):void {
			e.data.position = 0;
			_lib.iterateEverything(e.data);
		}
		
		public function iterateBuffer(soundId:uint, startPos:uint, totalBytes:uint, ba:ByteArray):void {
			//trace(soundId, startPos, totalBytes, ba.length);
			_lib.iterateBuffer(soundId, startPos, totalBytes, ba);
		}
		
		/**
		 * Adds a sound to JSAE.
		 * @param sound Sound instance
		 * @param groupId What group sound should belong to.
		 * @param optionalData reserved
		 * @param async if true, perform an asynchronous extraction of sample data. @see JSAEAsyncExtractor
		 * @return unique sound id.
		 */
		
		public function addSound(sound:Sound, groupId:int, musicalLength:Number, optionalData:int, async:Boolean = false):uint {
			if (sound == null && optionalData != JSAESoundSourceTypeSilence) return 0;
			var sid:uint;
			if (optionalData == JSAESoundSourceTypeStreaming) {
				var slen:int = Math.floor(sound.length*44.1*2*2);
				
				sid = _lib.addSound(null, groupId, musicalLength, slen, optionalData);
				streamingSounds[sid.toString()] = sound;
				
				return sid;
			}
			
			if (optionalData == JSAESoundSourceTypeSilence) {
				sid = _lib.addSilence(groupId, musicalLength);
				//sid = _lib.addSound(null, groupId, musicalLength, musicalLength, optionalData);
				return sid;
			}
			
			if (async) {
				// todo: perform asynchronous extracting.
				// cheat: length is as if it was floats..
				sid =  _lib.addSound(null, groupId, musicalLength, sound.length*44.1*2*2*2, optionalData, true);
				JSAEAsyncExtractor.getInstance().addJob(sound, sid, musicalLength, optionalData);
				//trace("id: ",sid);
				return sid;
			} else {
				
				var ba:ByteArray = new ByteArray();
				var len:int = sound.extract(ba, sound.length*44.1,0);
				ba.position = 0;
				sid =  _lib.addSound(ba, groupId, musicalLength, ba.length, optionalData, false);
				ba.clear();
				return sid;
			}
		}
		
		/**
		 * Adds a silent sound to JSAE. (use this instead of silent sound buffers: saves CPU)
		 * The returned instance behaves exactly as an ordinary sound (JSAESoundSourceTypeNormal)
		 * @param groupId group id
		 * @param musicalLength Musical length in seconds
		 * @return sound id.
		 */
		public function addSilence(groupId:int, musicalLength:Number):uint {
			return _lib.addSilence(groupId, musicalLength);
		}
		
		
		/**
		 * @return JSAE frame position. This is the master clock which is iterated after each buffer fill.
		 */
		public function getFramePosition():uint { return _lib.getFramePosition(); }
		
		/**
		 * Retrieves a running sounds sample position
		 * 
		 * @param soundId Sound reference
		 * @param runningSoundId running sound id
		 * @return a running sound id's sample position
		 */
		public function getSoundPosition(soundId:uint, runningSoundId:int):int {
			return _lib.getSoundPosition(soundId, runningSoundId);
		}
		/**
		 * @return JSAE buffer size
		 */
		
		public function getBufferSize():uint { return _bufferSize; }
		
		/**
		 * Creates a group.
		 * @param gain Volume
		 * @return unique group id.
		 */
		public function createGroup(gain:Number):int { return _lib.createGroup(gain); }
		
		/**
		 * Alter a specific group's gain.
		 * @param groupId group id.
		 * @param gain Volume
		 */
		public function setGroupGain(groupId:int, gain:Number):void { _lib.setGroupGain(groupId, gain); }
		
		/**
		 * Removes a group from JSAE.
		 * OBS! Sounds and effects belonging to group won't be disposed. Before removing a group user should always dispose sounds and effects.
		 * @param groupId group id.
		 */
		public function removeGroup(groupId:int):void { _lib.removeGroup(groupId); }
		
		/**
		 * Adds a sound to the playing cue.
		 * @param soundId sound id.
		 * @param offset offset in samples relative to master clock. Playing a sound as soon as possible should use getFramePosition()+0
		 * @param pitch sound pitch as factor. 1 is normal, 0.5 is half speed, 2 is double speed
		 * @param gain sound volume (not implemented if sound belongs to group. should be fixed)
		 * @return the running sound id. This is the reference if user will manipulate a playing sound.
		 */
		public function playSound(soundId:uint, offset:uint, pitch:Number, gain:Number):int { return _lib.playSound(soundId, offset, pitch, gain); }
		
		public function playSoundInGroup(soundId:uint, offset:uint, pitch:Number, gain:Number, groupId:int):int {
			return _lib.playSoundInGroup(soundId, offset, pitch, gain, groupId);
		}
		/**
		 * Alters a running sounds gain in real time with proper interpolation.
		 * @param soundId sound id
		 * @param runningSoundId running sound id
		 * @param gain Gain as factor.
		 */
		public function setRunningSoundGain(soundId:uint, runningSoundId:int, gain:Number):void {
			_lib.setRunningSoundGain(soundId, runningSoundId, gain);
		}
		
		/**
		 * Alters a running sounds pitch in real time with proper implementation.
		 * OBS! Only use this method with JSAESoundSourceTypeLooped
		 * @param soundId sound id
		 * @param runningSoundId running sound id
		 * @param pitch pitch as factor. (value can be positive and negative)
		 * 
		 */
		public function setRunningSoundPitch(soundId:uint, runningSoundId:int, pitch:Number):void {
			_lib.setRunningSoundPitch(soundId, runningSoundId, pitch);
		}
		/**
		 * Sets the pause flag for a running sound.
		 * @param soundId sound if
		 * @param runningSoundId running sound id
		 * @param val TRUE if pause, FALSE if unpause.
		 */
		public function setRunningSoundPause(soundId:uint, runningSoundId:int, val:Boolean):void {
			
			var num:int = 0;
			if (val == true) num = 1;
			_lib.setRunningSoundPause(soundId, runningSoundId, num);
		}
		
		/**
		 * Updates a sound instances musical length
		 */
		public function setSoundMusicalLength(soundId:uint, newLength:Number):void {
			_lib.setSoundMusicalLength(soundId, newLength);
		}
		
		/**
		 * Stops a playing sound.
		 * @param soundId sound id.
		 * @param runningSoundId the running sound id (returned by playSound)
		 */
		public function stopSound(soundId:uint, runningSoundId:int):void { _lib.stopSound(soundId, runningSoundId); }
		
		/**
		 * Deallocates an added sound and removes it from JSAE. Be very careful using this; if sound is playing while executing app will crash.
		 * @param soundId sound id.
		 */
		public function removeSound(soundId:uint):void { _lib.removeSound(soundId); }
		
		/**
		 * Creates an insert effect that belongs to a group.
		 * @param effectTypeId What effect (see constants JSAEEffectIdFLanger etc)
		 * @param groupId group id.
		 * @return unique id of effect.
		 */
		public function createEffect(effectTypeId:uint, groupId:int):uint { return _lib.createEffect(effectTypeId, groupId); }
		
		/**
		 * Alter a effect parameter.
		 * @param effectId effect id. (returned by createEffect)
		 * @param paramName What parameter to alter. See constant docs.
		 * @param value The parameter value.
		 */
		public function setEffectParam(effectId:uint, paramName:String, value:Number):void { _lib.setEffectParam(effectId, paramName, value); }
		
		/**
		 * Bypasses / Enables an effect.
		 * @param effectId effect id
		 * @param value if true: the effect is processing data, if false it is not.
		 */
		public function setEffectActive(effectId:uint, value:Boolean):void { _lib.setEffectActive(effectId, value); }
		
		/**
		 * Removes an effect.
		 * @param effectId effect id
		 * @param groupId effect's group.
		 */
		public function removeEffect(effectId:uint, groupId:int):void { _lib.removeEffect(effectId, groupId); }
		
	}
	
}

class SingletonEnforcer {}
=======
﻿/*Copyright (c) 2012 Johan SundhagePermission is hereby granted, free of charge, to any person obtaininga copy of this software and associated documentation files (the"Software"), to deal in the Software without restriction, includingwithout limitation the rights to use, copy, modify, merge, publish,distribute, sublicense, and/or sell copies of the Software, and topermit persons to whom the Software is furnished to do so, subject tothe following conditions:The above copyright notice and this permission notice shall beincluded in all copies or substantial portions of the Software.THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OFMERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE ANDNONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BELIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTIONOF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTIONWITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*/package com.klevgrand.JSAE{		import cmodule.libs.JSAE.CLibInit;		import flash.events.EventDispatcher;	import flash.events.SampleDataEvent;	import flash.media.Sound;	import flash.media.SoundChannel;	import flash.utils.ByteArray;	import flash.utils.Endian;		/**	 * JSAEWrapper is a glue between the C++ project "JSAE" - Johan Sundhage Audio Engine	 * which is a light-weight platform independent audio rendering engine - and Adobe	 * Flash applications.	 * 	 * To be able to use this API in Flash the library file JSAE.swc must be linked to the project.	 */		public class JSAEWrapper extends EventDispatcher	{		/**		 * When createing a Sound, this flag marks the sound as normal.		 * Limitations are no realtime-pitching.		 */		public static const JSAESoundSourceTypeNormal:int = 0;				/**		 * Used when creating sounds.		 * Creates a looped sound. This type of sounds pitch can be altered in real time.		 */		public static const JSAESoundSourceTypeLooped:int = 1;				/**		 * Uses a soundsource that will callback to AS3 for extracting mp3 data		 * This method doesn't support pitch alteration.		 */		public static const JSAESoundSourceTypeStreaming:int = 2;				/**		 * A silent sound source. (contains no data but behaves exatcly as a normal one)		 */		public static const JSAESoundSourceTypeSilence:int = 3;				/**		 * Flanger effect params		 * "freq"		Speed in hz.		 * "time"		The biggest time difference in milliseconds		 * "amount"		mix. 0 is dry 1 is wet		 */		public static const JSAEEffectIdFlanger:int = 0;				/**		 * Lowpass params		 * "freq"		Frequency		 * "resonance"	Resonance value. A low value means higher Q-value (0.1 is low and 3 is high)		 */		public static const JSAEEffectIdLowpass:int = 1;				/**		 * TapeDelay params		 * "time"		Delay time in milliseconds		 * "feedback"	First response gain (0-1)		 * "decay"		Gain for each loop (0-1)		 * "amount"		mix. 0 is dry 1 is wet		 * 		 */		public static const JSAEEffectIdTapeDelay:int = 2;				/**		 * Simple dist, params		 * "gainIn"		gain in as factor. 		 * "gainOut"	post dist gain as factor		 */				public static const JSAEEffectIdDirtyDist:int = 3;				/**		 * Highpass filter, params		 * "freq"		frequency		 * "resonance"	q value		 */		public static const JSAEEffectIdBiquadFilterHighpass:int = 4;				/**		 * Lowpass filter, params		 * "freq"		frequency		 * "resonance"	q value		 */				public static const JSAEEffectIdBiquadFilterLowpass:int = 5;				/**		 * Bandpass filter, params		 * "freq"		frequency		 * "resonance"	q value		 */						public static const JSAEEffectIdBiquadFilterBandpass:int = 6;				/**		 * Peak filter, params		 * "freq"		frequency		 * "resonance"	q value		 * "gain"		gain in db.		 */			public static const JSAEEffectIdBiquadFilterPeak:int = 7;				/**		 * Low shelf filter, params		 * "freq"		frequency		 * "resonance"	q value		 * "gain"		gain in db.		 */					public static const JSAEEffectIdBiquadFilterLowshelf:int = 8;				/**		 * High shelf filter, params		 * "freq"		frequency		 * "resonance"	q value		 * "gain"		gain in db.		 */							public static const JSAEEffectIdBiquadFilterHighshelf:int = 9;				/**		 * Pan effect, params		 * "pan"		pan value (-1 to 1)		 */				public static const JSAEEffectIdPan:int = 10;						/**		 * If a sound won't belong to a group, use this value when creating it.		 */		public static const JSAE_NO_GROUP:int = -1;						public static const JSAE_BUFFERSIZE_2048:int = 2048;		public static const JSAE_BUFFERSIZE_4096:int = 4096;		public static const JSAE_BUFFERSIZE_6144:int = 6144;		public static const JSAE_BUFFERSIZE_8192:int = 8192;						protected static const LATENCY_AT_2048:int = 4500;		protected static const LATENCY_AT_4096:int = 8200;		protected static const LATENCY_AT_6144:int = 19500;		protected static const LATENCY_AT_8192:int = 35000;		internal var _lib:Object = null;		private var _masterSound:Sound = null;		private var _playingMasterSound:SoundChannel = null;				private var _callbackObject:Object;		public var streamingSounds:Object = {};						private var _isRunning:Boolean = false;				private var _graphicsLatency:int;		private var _bufferSize:uint;						public function get graphicsLatency():int {			return _graphicsLatency;		}		/**		 * @return true if the flash sound system and JSAE is running.		 */		public function get isRunning():Boolean { return _isRunning; }				private static var instance:JSAEWrapper = null;				/**		 * Initializes the alchemy library.		 * @param bufferSize Buffer size in frames. Minimum is 2048, maximum 8192 (due to C-level memory management)		 * 		 **/		public static function initialize(bufferSize:int):JSAEWrapper {			instance = new JSAEWrapper(new SingletonEnforcer(), bufferSize);			return instance;		}				/**		 * @return JSAEWrapper instance.		 */		public static function getInstance():JSAEWrapper {			return instance;		}				/**		 * Stops the engine and frees sound buffers		 */		public static function dispose():void {			if (!instance) return;			instance.dispose();			instance = null;		}				/**		 * Private constructor.		 */		public function JSAEWrapper(s:SingletonEnforcer, bufferSize:int)		{			if (bufferSize == JSAE_BUFFERSIZE_2048) _graphicsLatency = LATENCY_AT_2048;			else if (bufferSize == JSAE_BUFFERSIZE_4096) _graphicsLatency = LATENCY_AT_4096;			else if (bufferSize == JSAE_BUFFERSIZE_6144) _graphicsLatency = LATENCY_AT_6144;			else if (bufferSize == JSAE_BUFFERSIZE_8192) _graphicsLatency = LATENCY_AT_8192;			else _graphicsLatency = 0;			_bufferSize = bufferSize;			var loader:CLibInit = new CLibInit();			_lib = loader.init();			_callbackObject = new Object();			_callbackObject.clazz = this;			_callbackObject.bufferSize = bufferSize;			_callbackObject.properData = new ByteArray();						_callbackObject.jsaeCallback = function(eventId:int, soundId:uint, runningSoundId:int, diffInSamples:int):void {				this.clazz.dispatchEvent(new JSAEEvent(eventId, soundId, runningSoundId, diffInSamples));			};							_callbackObject.jsaeGetBuffer = function(soundId:uint, offsetInFrames:uint):ByteArray {				var s:Sound = this.clazz.streamingSounds[soundId.toString()];				this.properData.clear();				s.extract(this.properData, this.bufferSize, offsetInFrames);				this.properData.position = 0;								return this.properData;			};						_lib.initEngine(_callbackObject, bufferSize);		}				/**		 * Starts the flash sound system		 */		public function run():void {			if (_isRunning) return;			_isRunning = true;						_masterSound = new Sound();			_masterSound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);			_playingMasterSound = _masterSound.play();			// start sample-callbacks		}				/**		 * Stops the flash sound system		 */		public function stop():void {			if (_isRunning == false) return;			_isRunning = false;			_playingMasterSound.stop();			_masterSound = null;			_playingMasterSound = null;			// stop sample-callbacks and set master to null		}						private function dispose():void {			stop();		}						private function onSampleData(e:SampleDataEvent):void {			e.data.position = 0;			_lib.iterateEverything(e.data);		}				public function iterateBuffer(soundId:uint, startPos:uint, totalBytes:uint, ba:ByteArray):void {			//trace(soundId, startPos, totalBytes, ba.length);			_lib.iterateBuffer(soundId, startPos, totalBytes, ba);		}				/**		 * Adds a sound to JSAE.		 * @param sound Sound instance		 * @param groupId What group sound should belong to.		 * @param optionalData reserved		 * @param async if true, perform an asynchronous extraction of sample data. @see JSAEAsyncExtractor		 * @return unique sound id.		 */				public function addSound(sound:Sound, groupId:int, musicalLength:Number, optionalData:int, async:Boolean = false):uint {			if (sound == null && optionalData != JSAESoundSourceTypeSilence) return 0;			var sid:uint;			if (optionalData == JSAESoundSourceTypeStreaming) {				var slen:int = Math.floor(sound.length*44.1*2*2);								sid = _lib.addSound(null, groupId, musicalLength, slen, optionalData);				streamingSounds[sid.toString()] = sound;								return sid;			}						if (optionalData == JSAESoundSourceTypeSilence) {				sid = _lib.addSilence(groupId, musicalLength);				//sid = _lib.addSound(null, groupId, musicalLength, musicalLength, optionalData);				return sid;			}						if (async) {				// todo: perform asynchronous extracting.				// cheat: length is as if it was floats..				sid =  _lib.addSound(null, groupId, musicalLength, sound.length*44.1*2*2*2, optionalData, true);				JSAEAsyncExtractor.getInstance().addJob(sound, sid, musicalLength, optionalData);				//trace("id: ",sid);				return sid;			} else {								var ba:ByteArray = new ByteArray();				var len:int = sound.extract(ba, sound.length*44.1,0);				ba.position = 0;				sid =  _lib.addSound(ba, groupId, musicalLength, ba.length, optionalData, false);				ba.clear();				return sid;			}		}				/**		 * Adds a silent sound to JSAE. (use this instead of silent sound buffers: saves CPU)		 * The returned instance behaves exactly as an ordinary sound (JSAESoundSourceTypeNormal)		 * @param groupId group id		 * @param musicalLength Musical length in seconds		 * @return sound id.		 */		public function addSilence(groupId:int, musicalLength:Number):uint {			return _lib.addSilence(groupId, musicalLength);		}						/**		 * @return JSAE frame position. This is the master clock which is iterated after each buffer fill.		 */		public function getFramePosition():uint { return _lib.getFramePosition(); }				/**		 * Retrieves a running sounds sample position		 * 		 * @param soundId Sound reference		 * @param runningSoundId running sound id		 * @return a running sound id's sample position		 */		public function getSoundPosition(soundId:uint, runningSoundId:int):int {			return _lib.getSoundPosition(soundId, runningSoundId);		}		/**		 * @return JSAE buffer size		 */				public function getBufferSize():uint { return _bufferSize; }				/**		 * Creates a group.		 * @param gain Volume		 * @return unique group id.		 */		public function createGroup(gain:Number):int { return _lib.createGroup(gain); }				/**		 * Alter a specific group's gain.		 * @param groupId group id.		 * @param gain Volume		 */		public function setGroupGain(groupId:int, gain:Number):void { _lib.setGroupGain(groupId, gain); }				/**		 * Removes a group from JSAE.		 * OBS! Sounds and effects belonging to group won't be disposed. Before removing a group user should always dispose sounds and effects.		 * @param groupId group id.		 */		public function removeGroup(groupId:int):void { _lib.removeGroup(groupId); }				/**		 * Adds a sound to the playing cue.		 * @param soundId sound id.		 * @param offset offset in samples relative to master clock. Playing a sound as soon as possible should use getFramePosition()+0		 * @param pitch sound pitch as factor. 1 is normal, 0.5 is half speed, 2 is double speed		 * @param gain sound volume (not implemented if sound belongs to group. should be fixed)		 * @return the running sound id. This is the reference if user will manipulate a playing sound.		 */		public function playSound(soundId:uint, offset:uint, pitch:Number, gain:Number):int { return _lib.playSound(soundId, offset, pitch, gain); }				public function playSoundInGroup(soundId:uint, offset:uint, pitch:Number, gain:Number, groupId:int):int {			return _lib.playSoundInGroup(soundId, offset, pitch, gain, groupId);		}		/**		 * Alters a running sounds gain in real time with proper interpolation.		 * @param soundId sound id		 * @param runningSoundId running sound id		 * @param gain Gain as factor.		 */		public function setRunningSoundGain(soundId:uint, runningSoundId:int, gain:Number):void {			_lib.setRunningSoundGain(soundId, runningSoundId, gain);		}				/**		 * Alters a running sounds pitch in real time with proper implementation.		 * OBS! Only use this method with JSAESoundSourceTypeLooped		 * @param soundId sound id		 * @param runningSoundId running sound id		 * @param pitch pitch as factor. (value can be positive and negative)		 * 		 */		public function setRunningSoundPitch(soundId:uint, runningSoundId:int, pitch:Number):void {			_lib.setRunningSoundPitch(soundId, runningSoundId, pitch);		}		/**		 * Sets the pause flag for a running sound.		 * @param soundId sound if		 * @param runningSoundId running sound id		 * @param val TRUE if pause, FALSE if unpause.		 */		public function setRunningSoundPause(soundId:uint, runningSoundId:int, val:Boolean):void {						var num:int = 0;			if (val == true) num = 1;			_lib.setRunningSoundPause(soundId, runningSoundId, num);		}				/**		 * Updates a sound instances musical length		 */		public function setSoundMusicalLength(soundId:uint, newLength:Number):void {			_lib.setSoundMusicalLength(soundId, newLength);		}				/**		 * Stops a playing sound.		 * @param soundId sound id.		 * @param runningSoundId the running sound id (returned by playSound)		 */		public function stopSound(soundId:uint, runningSoundId:int):void { _lib.stopSound(soundId, runningSoundId); }				/**		 * Deallocates an added sound and removes it from JSAE. Be very careful using this; if sound is playing while executing app will crash.		 * @param soundId sound id.		 */		public function removeSound(soundId:uint):void { _lib.removeSound(soundId); }				/**		 * Creates an insert effect that belongs to a group.		 * @param effectTypeId What effect (see constants JSAEEffectIdFLanger etc)		 * @param groupId group id.		 * @return unique id of effect.		 */		public function createEffect(effectTypeId:uint, groupId:int):uint { return _lib.createEffect(effectTypeId, groupId); }				/**		 * Alter a effect parameter.		 * @param effectId effect id. (returned by createEffect)		 * @param paramName What parameter to alter. See constant docs.		 * @param value The parameter value.		 */		public function setEffectParam(effectId:uint, paramName:String, value:Number):void { _lib.setEffectParam(effectId, paramName, value); }				/**		 * Bypasses / Enables an effect.		 * @param effectId effect id		 * @param value if true: the effect is processing data, if false it is not.		 */		public function setEffectActive(effectId:uint, value:Boolean):void { _lib.setEffectActive(effectId, value); }				/**		 * Removes an effect.		 * @param effectId effect id		 * @param groupId effect's group.		 */		public function removeEffect(effectId:uint, groupId:int):void { _lib.removeEffect(effectId, groupId); }			}	}class SingletonEnforcer {}
>>>>>>> License agreement
