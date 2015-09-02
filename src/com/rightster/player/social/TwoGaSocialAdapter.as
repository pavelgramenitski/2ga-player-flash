package com.rightster.player.social {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.GenericTrackerEvent;
	import com.rightster.player.platform.Platforms;
	import com.rightster.utils.Log;
	import com.rightster.utils.Protocol;

	/**
	 * @author KJR
	 */
	public class TwoGaSocialAdapter implements ISocialAdapter {
		private static const FB_SHARE_URL : String = "https://www.facebook.com/sharer/sharer.php?u=";
		private static const FB_WIN_PROPERTIES : String = "width=400,height=400,left=10,top=10";
		private static const TWITTER_WIN_PROPERTIES : String = "width=500,height=500,left=10,top=10";
		private static const TWITTER_SHARE_URL : String = "https://www.twitter.com/intent/tweet?text=";
		private var controller : IController;

		public function initialize(controller : IController) : void {
			this.controller = controller;
		}

		public function shareTwitter() : void {
			socialMediaClicked();
			var protocol : Protocol = Protocol.PROTOCOL_TYPE_HTTPS;
			var link : String = controller.video.shareTwitterLink;
			var urlStr : String = protocol.value + ":" + link;

			Log.write("TwoGaSocialAdapter.shareTwitter * urlStr: " + urlStr);

			// extended string possible usage
			// window.open("https://twitter.com/share?url="+url+"tweet-button&via=twitterdev&related=twitterapi%2Ctwitter& hashtags=example%2Cdemo&text="+url);

			var requestString : String = TWITTER_SHARE_URL + urlStr;
			Log.write("TwoGaSocialAdapter.shareTwitter * requestString: " + requestString);

			if (controller.jsApi.available) {
				controller.jsApi.openNewWindow(requestString, TWITTER_WIN_PROPERTIES);
			} else {
				Log.write("TwoGaSocialAdapter.shareTwitter * ExternalInterface.NOT available", Log.ERROR);
			}

			this.controller.dispatchEvent(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "twitter_"));
		}

		public function shareFacebook() : void {
			socialMediaClicked();
			var protocol : String = controller.currentProtocol;
			var link : String = controller.video.shareFBLink;
			var urlStr : String = protocol + ":" + link;

			Log.write("TwoGaSocialAdapter.shareFacebook * urlStr: " + urlStr);
			var requestString : String = FB_SHARE_URL + urlStr;
			Log.write("TwoGaSocialAdapter.shareFacebook * requestString: " + requestString);

			if (controller.jsApi.available) {
				controller.jsApi.openNewWindow(requestString, FB_WIN_PROPERTIES);
			} else {
				Log.write("TwoGaSocialAdapter.shareFacebook * ExternalInterface.NOT available", Log.ERROR);
			}

			this.controller.dispatchEvent(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "facebook_"));
		}

		public function shareTumblr() : void {
			Log.write("TwoGaSocialAdapter.shareTumblr ");
			Log.write("TwoGaSocialAdapter.shareTumblr * PLATFORM IMPLEMENTATION REQUIRED", Log.ERROR);
			socialMediaClicked();
		}

		public function shareEmail() : void {
			Log.write("TwoGaSocialAdapter.shareEmail");
			Log.write("TwoGaSocialAdapter.shareEmail * PLATFORM IMPLEMENTATION REQUIRED", Log.ERROR);
			socialMediaClicked();
		}

		public function shareGPlus() : void {
			Log.write("TwoGaSocialAdapter.shareGPlus");
			Log.write("TwoGaSocialAdapter.shareGPlus * PLATFORM IMPLEMENTATION REQUIRED", Log.ERROR);
			socialMediaClicked();
			// this.controller.dispatchEvent(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "gplus_"));
		}

		public function get type() : String {
			return Platforms.TWOGA;
		}

		/*
		 * Private Methods
		 * 
		 */
		private function socialMediaClicked() : void {
			controller.fullScreen = false;
			controller.pauseVideo();
		}
	}
}
