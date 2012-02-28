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


package com.klevgrand.JSAE
{
	import flash.events.Event;
	
	public class JSAEEvent extends Event
	{
		/**
		 * Thrown before a sample will start to play. The diffInSamples param tells
		 * how many frames (based on master clock) left until sample will play
		 */
		public static const SOUND_START:String = "soundstart";
		
		/**
		 * Thrown when a sound reaches its actual end.
		 */
		public static const SOUND_END:String = "soundend";
		
		/**
		 * Thrown when a sound is ready for disposal.
		 */
		public static const SOUND_WILL_DISPOSE:String = "soundwilldispose";
		
		/**
		 * Thrown when a sound reaches its musical end. Use diffInSamples to sync other
		 * sounds with the throwing sounds timing.
		 */
		public static const SOUND_MUSICAL_END:String = "soundmusicalend";
		
		public static const JSAEEventIdSoundEnd:int = 0;
		public static const JSAEEventIdSoundMusicalEnd:int = 1;
		public static const JSAEEventIdSoundStart:int = 2;
		public static const JSAEEventIdSoundWillDispose:int = 3;
		
		/**
		 * Sound instance id
		 */
		public var soundId:uint;
		
		/**
		 * Running sound id.
		 */
		public var runningSoundId:uint;
		
		/**
		 * Difference in samples
		 */
		public var diffInSamples:int;
		
		/**
		 * Use to clone
		 */
		public var typeId:int;
		
		/**
		 * Event constructor. Will dispatch an event based on type.
		 * @param type The type (directly mapped to JSAE C++ framework)
		 * @param soundId the sound if
		 * @param runningSoundId the running sound id
		 * @param diff in samples
		 */
		public function JSAEEvent(type:int, soundId:uint, runningSoundId:int, diffInSamples:int)
		{
			this.typeId = type;
			this.soundId = soundId;
			this.runningSoundId = runningSoundId;
			this.diffInSamples = diffInSamples;
			var evt:String = "unknown";
			if (type == JSAEEventIdSoundEnd) evt = SOUND_END;
			else if (type == JSAEEventIdSoundMusicalEnd) evt = SOUND_MUSICAL_END;
			else if (type == JSAEEventIdSoundStart) evt = SOUND_START;
			else if (type == JSAEEventIdSoundWillDispose) evt = SOUND_WILL_DISPOSE;
			
			super(evt, false, false);
			
		}
	}
}