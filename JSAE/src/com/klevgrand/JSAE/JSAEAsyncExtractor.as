package com.klevgrand.JSAE
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	

	/**
	 * 
	 */
	public class JSAEAsyncExtractor extends EventDispatcher
	{
		private static var _instance:JSAEAsyncExtractor = null;
		
		public static function getInstance():JSAEAsyncExtractor {
			if (_instance) return _instance;
			_instance = new JSAEAsyncExtractor(new SingletonEnforcerer());
			return _instance;
		}
		
		
		// class method imp
		
		private var _jobs:Array = [];
		private var _timerId:int;
		public static const SPEED:int = 30;
		public static const FRAMES_PER_ITERATION:int = 20000;
		
		public function JSAEAsyncExtractor(s:SingletonEnforcerer)
		{
			super(null);
		}
		
		public function addJob(sound:Sound, soundId:uint, musicalLength:Number, optionalData:int):void {
			var job:Job = new Job();
			job.sound = sound;
			job.soundId = soundId;
			
			job.musicalLength = musicalLength;
			job.optionalData = optionalData;
			job.framePosition = 0;
			job.totalFrames = sound.length*44.1;
			//job.extractedBytes = new ByteArray();
			job.progress = 0;
			_jobs.push(job);
			if (_jobs.length == 1) {
				startWorking();
			}
		}
		
		private function startWorking():void {
			_timerId = setInterval(iterateWork, SPEED);
		}
		private function stopWorking():void {
			clearInterval(_timerId);
		}
		
		public function iterateWork():void {
			//trace("tick");
			var finishedJobs:Array = [];
			var i:int;
			for (i = 0; i<_jobs.length; i++) {
				var job:Job = _jobs[i];
				var startPos:uint = job.framePosition;
				var endPos:uint = startPos+FRAMES_PER_ITERATION;
				if (endPos >= job.totalFrames) {
					endPos = job.totalFrames;
					job.finished = true;
					
				}
				var ba:ByteArray = new ByteArray();
				job.sound.extract(ba, endPos-startPos, startPos);
				ba.position = 0;
				job.progress = endPos/job.totalFrames;
				job.framePosition = endPos;
				
				JSAEWrapper.getInstance().iterateBuffer(job.soundId, startPos, ba.length, ba);
				ba.clear();
				// todo: dispatcha progress.
				if (job.finished) {
					finishedJobs.push(i);
					dispatchEvent(new JSAEAsyncEvent(JSAEAsyncEvent.SOUND_EXTRACTED, job.soundId, 1));
				} else {
					dispatchEvent(new JSAEAsyncEvent(JSAEAsyncEvent.SOUND_EXTRACT_PROGRESS, job.soundId, job.progress));
				}
			}
			
			for (i = 0; i<finishedJobs.length; i++) {
				_jobs.splice(finishedJobs[i], 1);
			}
			// end it...
			if (_jobs.length == 0) stopWorking();
		}
		
	}
	
}
import flash.media.Sound;
import flash.utils.ByteArray;

class SingletonEnforcerer {}

class Job {
	public var sound:Sound;
	public var musicalLength:Number;
	public var optionalData:int;
	public var framePosition:uint;
	public var totalFrames:uint;
	public var progress:Number;
	public var soundId:uint;
	//public var extractedBytes:ByteArray;
	public var finished:Boolean = false;
}
