package com.rightster.analytics {
	import com.rightster.player.events.GenericTrackerEvent;
	import com.google.analytics.AnalyticsTracker;
	import com.google.analytics.GATracker;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	/**
	 * @author Daniel
	 */
	public class GaTracker extends MovieClip implements IPlugin {
		private static const VERSION : String = "2.26.0";
		///private static const ACCOUNT_ID : String = "UA-22579865-1"; ///this is test account
		private static const ACCOUNT_ID : String = "UA-22606766-1";
		private static const LIB_AS_VERSION : String = "AS3";
		private static const Z_INDEX:int = PluginZindex.NONE;
		private static const PING_DURATION : uint = 30;
		private static const TIMER_DURATION : uint = 1000;
		private static const SERVICE_METHOD_IMPRESSION : uint = 0;
		private static const SERVICE_METHOD_PLAY : uint = 1;
		private static const SERVICE_METHOD_PING : uint = 2;
		private static const SERVICE_METHOD_ADREQUEST : uint = 3;
		private static const SERVICE_METHOD_ADSTART : uint = 4;
		private static const EVENT_PAGE_IMPRESSION : String = "PageImp_";
		private static const EVENT_PLAY : String = "Play_";
		private static const EVENT_PING : String =  "Ping_";
		private static const EVENT_AD_REQUEST : String = "AdRequest_";
		private static const EVENT_AD_START : String = "AdStart_";
		
		private var controller : IController;
		private var initialized : Boolean;
		private var tracker : AnalyticsTracker;		
		private var timer : Timer;
		private var secondCounter : uint;
		private var _loaded : Boolean = true;
		
		public function GaTracker() {
			Log.write("GaTracker version " + VERSION);
		}
		
		public function initialize(controller : IController, data : Object) : void {
			Log.write("GATracker.initialize");
			
			this.initialized = true;
			this.controller = controller;
			this.tracker = new GATracker(controller.stage, ACCOUNT_ID, controller.placement.forceHTTPS);
			
			//controller.addEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
			//controller.addEventListener(MonetizationEvent.AD_REQUESTED, trackAdRequest);
			controller.addEventListener(GenericTrackerEvent.TRACK, genericTrackerRequest);
		}		
		
		public function get zIndex() : int {
			return Z_INDEX;
		}
		
		public function get loaded() : Boolean {
			return _loaded;
		}
		
		public function dispose() : void {
			if (initialized) {				
				if(timer != null) timer.stop();
				//controller.removeEventListener(MonetizationEvent.AD_REQUESTED, trackAdRequest);
				//controller.removeEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
				controller.removeEventListener(GenericTrackerEvent.TRACK, genericTrackerRequest);
				controller = null;
				initialized = false;
			}
		}
		
		private function onPlayerStateChange(event:PlayerStateEvent):void {
			switch (controller.playerState) {
				case PlayerState.PLAYER_READY :
					trackEvent(SERVICE_METHOD_IMPRESSION);
				break;
				
				case PlayerState.VIDEO_STARTED :					
					trackPlay();
				break;
				
				case PlayerState.AD_STARTED :					
					trackEvent(SERVICE_METHOD_ADSTART);
				break;
			}
		}
		
		private function trackAdRequest(event : MonetizationEvent):void {
			trackEvent(SERVICE_METHOD_ADREQUEST);
		}
		
		private function genericTrackerRequest(event : GenericTrackerEvent):void{
			Log.write("GaTracker.genericTrackerRequest");
			var vars : URLVariables = new URLVariables();
			vars.label = escape("#") + controller.video.projectId;
			vars.category = controller.placement.publisherName + "/" + controller.placement.publisherId;
			vars.action = event.customAction+controller.video.playlistId;
			
			Log.write("GenericTrackerEvent.TRACK * ", vars.category, vars.action, vars.label, Log.TRACKING);
			tracker.trackEvent(vars.category, vars.action, vars.label);
		}
		private function trackPlay():void {			
			trackEvent(SERVICE_METHOD_PLAY);
			if (controller.video.trackingPing) {
				timer = new Timer(TIMER_DURATION);
				timer.addEventListener(TimerEvent.TIMER, trackPing);
				timer.start();
				secondCounter = 0;
			}
		}
		
		private function trackPing(event:Event):void {
			if (controller.playerState == PlayerState.VIDEO_PLAYING) {
				secondCounter++;
				if (secondCounter == PING_DURATION) {
					trackEvent(SERVICE_METHOD_PING);
					secondCounter = 0;
				}
			}
		}
		
		private function trackEvent(serviceMethod:uint):void {
			var vars : URLVariables = new URLVariables();
			vars.label = escape("#") + controller.video.projectId;
			vars.category = controller.placement.publisherName + "/" + controller.placement.publisherId;
			
			switch(serviceMethod){
				case SERVICE_METHOD_IMPRESSION :
					vars.action = EVENT_PAGE_IMPRESSION+controller.video.playlistId;
				break;
				
				case SERVICE_METHOD_PLAY :
					vars.action = EVENT_PLAY+controller.video.playlistId+"_"+getCurrentQuality();
				break;
				
				case SERVICE_METHOD_PING :
					vars.action = EVENT_PING+controller.video.playlistId+"_"+getCurrentQuality();
				break;
				
				case SERVICE_METHOD_ADREQUEST :
					vars.action = EVENT_AD_REQUEST+controller.video.playlistId;
				break;
				
				case SERVICE_METHOD_ADSTART :
					vars.action = EVENT_AD_START+controller.video.playlistId;
				break;
			}
			
			Log.write("GaTracking.trackEvent * ", vars.category, vars.action, vars.label, Log.TRACKING);
			tracker.trackEvent(vars.category, vars.action, vars.label);
		}
		
		private function getCurrentQuality():int {
			return controller.getPlaybackQualityIndex()+1;
		}
	}
}