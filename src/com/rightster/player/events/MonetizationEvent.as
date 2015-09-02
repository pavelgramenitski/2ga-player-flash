package com.rightster.player.events {
	import flash.events.Event;
	
	/**
	 * @author Sidharth
	 */
	public class MonetizationEvent extends Event {
		public static const AD_REQUESTED  : String = "MonetizationEvent.AD_REQUESTED";
		public static const AD_STARTED : String = "MonetizationEvent.AD_STARTED";
		public static const AD_ENDED : String = "MonetizationEvent.AD_ENDED";
		public static const AD_PLAYING : String = "MonetizationEvent.AD_PLAYING";
		public static const AD_PAUSED : String = "MonetizationEvent.AD_PAUSED";
		public static const AD_BUFFERING : String = "MonetizationEvent.AD_BUFFERING";
		public static const AD_STOP : String = "MonetizationEvent.AD_STOP";
		public static const AD_TIMER : String = "MonetizationEvent.AD_TIMER";
		
		public static const AD_SKIPPABLE : String = "MonetizationEvent.AD_SKIPPABLE";
		public static const AD_NOT_SKIPPABLE : String = "MonetizationEvent.AD_NOT_SKIPPABLE";
		public static const AD_ALLOW_SKIP : String = "MonetizationEvent.AD_ALLOW_SKIP";
		public static const AD_DISALLOW_SKIP : String = "MonetizationEvent.AD_DISALLOW_SKIP";
		
		public static const AD_OVERLAY_STARTED : String = "MonetizationEvent.AD_OVERLAY_STARTED";
		public static const AD_OVERLAY_ENDED : String = "MonetizationEvent.AD_OVERLAY_ENDED";
		public static const AD_OVERLAY_MINIMIZE : String = "MonetizationEvent.AD_OVERLAY_MINIMIZE";
		public static const AD_OVERLAY_MAXIMIZE : String = "MonetizationEvent.AD_OVERLAY_MAXIMIZE";
		
		public var data : Object;
		public function MonetizationEvent(type : String, data : Object = null) {
			super(type, false, false);
			this.data = data;
		}
	}
}