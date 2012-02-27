package com.klevgrand.JSAE
{
	import flash.events.Event;

	public class JSAEAsyncEvent extends Event
	{
		public static const SOUND_EXTRACTED:String = "jsaesoundextracted";
		public static const SOUND_EXTRACT_PROGRESS:String = "jsaesoundextractprogress";
		public static const SOUND_EXTRACT_JOBS_FINISHED:String = "jsaesoundextractfinished";
		public var soundId:uint;
		public var progress:Number;
		public function JSAEAsyncEvent(type:String, soundId:uint, progress:Number)
		{
			this.soundId = soundId;
			this.progress = progress;
			super(type);
		}
	}
}