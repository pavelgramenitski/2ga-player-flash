package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author Daniel
	 */
	public class MediaProviderEvent extends Event {
		public static const STARTED : String = "MediaProviderEvent.STARTED";
		public static const ENDED : String = "MediaProviderEvent.ENDED";
		public static const PLAYING : String = "MediaProviderEvent.PLAYING";
		public static const PAUSED : String = "MediaProviderEvent.PAUSED";
		public static const BUFFERING : String = "MediaProviderEvent.BUFFERING";
		public static const META_DATA : String = "MediaProviderEvent.META_DATA";
		public static const CUE_POINT : String = "MediaProviderEvent.CUE_POINT";
		public static const NC_INITIALIZED : String = "MediaProviderEvent.NC_INITIALIZED";
		public static const NS_INITIALIZED : String = "MediaProviderEvent.NS_INITIALIZED";
		//Direct Live Streaming
		public static const REQUEST_AUTHORISATION : String = "MediaProviderEvent.REQUEST_AUTHORISATION";
		public var data : Object;

		public function MediaProviderEvent(type : String, data : Object = null) {
			super(type, false, false);
			this.data = data;
		}
		
		public override function clone ():Event {
            return new MediaProviderEvent(type, this.data);
        }
	}
}