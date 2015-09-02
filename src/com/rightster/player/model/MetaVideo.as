package com.rightster.player.model {
	import com.rightster.player.controller.IController;
	import com.rightster.utils.Log;
	import com.rightster.utils.StringUtils;

	import flash.utils.Dictionary;

	/**
	 * @author Daniel
	 */
	public class MetaVideo {
		private var _videoId : String = "";
		// aka eventId
		private var _playlistIndex : uint;
		// general
		public var dataLoaded : Boolean;
		public var geoBlocked : Boolean;
		public var errorText : String;
		public var metaPlugins : Array = [];
		public var plugins : Array = [];
		public var playerShareUrl : String = "";
		// playlist
		public var playlistId : String = "";
		public var playlistName : String = "";
		// media
		public var mediaProvider : String = "";
		// public var videoQualityUrls : Array = [];
		public var qualities : Array = [];
		public var metaQualities : Array = [];
		public var metaStreams : Dictionary;
		public var pixelLimit : Number = 0;
		// public var aspectRatio : Number = 0;
		public var defaultStreamLatency : Number = 0;
		public var playbackQuality : String;
		// video metadata
		public var title : String = "";
		public var description : String = "";
		public var durationStr : String = "";
		public var duration : Number = 0;
		public var thumbnailImageUrl : String = "";
		public var startImageUrl : String = "";
		public var isLive : Boolean = false;
		public var isLiveStarted : Boolean = false;
		public var isLiveCompleted : Boolean = false;
		public var contentId : String = "";
		public var projectId : String = "";
		public var projectName : String = "";
		public var tags : Array = [];
		public var keywords : String = "";
		public var width : Number;
		public var height : Number;
		// timed playlist
		public var startTime : Number;
		// values in seconds
		public var endTime : Number;
		// values in seconds
		// monetization
		public var monetization : Boolean;
		public var adProvider : String = "";
		public var zoneId : Number = 0;
		// TODO: this is plugin parameter, not video parameter, in the future move it to plugin
		public var mediaId : String = "";
		// TODO: this is plugin parameter, not video parameter, in the future move it to plugin
		public var mediaFingerprintId : String = "";
		// TODO: this is plugin parameter, not video parameter, in the future move it to plugin
		public var lrContent : String;
		public var lrAdMap : String;
		public var contentOwner : String;
		public var contentCreator : String;
		// tracking
		public var trackingMode : String = "";
		public var trackingPing : Boolean;
		// TODO: this is plugin parameter, not video parameter, in the future move it to plugin
		public var omnitureTracking : Boolean = false;
		public var trackingInterval : uint = 5;
		// perma link || read more
		public var readMoreUrl : String;
		public var images : Dictionary = new Dictionary();
		// FB share
		public var shareFBEnabled : Boolean;
		public var shareFBLink : String;
		public var shareFBCaption : String = "";
		public var shareFBDescription : String = "";
		public var shareFBAppId : String;
		// TW share
		public var shareTwitterMessage : String = "";
		public var shareTwitterLink : String = "";
		public var shareTwitterUrl : String = "";
		public var shareTwitterUseUrl : Boolean;
		// email share
		public var isEmail : Boolean;
		public var emailSubject : String = "";
		public var emailBody : String = "";
		// gplus
		public var googlePlusShare : Boolean = false;
		// embed
		public var isEmbed : Boolean = false;
		// tumblr
		public var enableShareTumblr : Boolean;
		public var tumblrCaptionTxt : String = "Just watched [TITLE]!";
		public var omnitureXMLPath : String = "";
		// Mars
		public var playbackAuthorised : Boolean = false;
		public var eventType : String = "";
		public var isSkipAds : Boolean = false;
		public var skipAdDuration : Number = 5;

		public function get videoId() : String {
			return _videoId;
		}

		public function get playlistIndex() : uint {
			return _playlistIndex;
		}

		public function set playlistIndex(index : uint) : void {
			_playlistIndex = index;
		}

		public function MetaVideo(controller : IController, _videoId : String, _playlistIndex : uint) {
			// Log.write("MetaVideo constructor * " + controller.flashVars + " : " + _videoId + " : " + _playlistIndex);

			this._playlistIndex = _playlistIndex;
			this._videoId = _videoId;
			metaStreams = new Dictionary();

			// general
			if (controller.flashVars.hasOwnProperty("geoblocked")) geoBlocked = controller.flashVars["geoblocked"] == "1" ? true : false;
			if (controller.flashVars.hasOwnProperty("plugins")) plugins = String(controller.flashVars["plugins"]).split(",");
			if (controller.flashVars.hasOwnProperty("playershareurl")) playerShareUrl = controller.flashVars["playershareurl"];

			// playlist
			if (controller.flashVars.hasOwnProperty("playlistid")) playlistId = controller.flashVars["playlistid"];
			if (controller.flashVars.hasOwnProperty("playlistname")) playlistName = controller.flashVars["playlistname"];

			// media
			if (controller.flashVars.hasOwnProperty("mediaprovider")) {
				mediaProvider = controller.flashVars["mediaprovider"];
			} else {
				mediaProvider = controller.config.DEFAULT_MEDIA_PROVIDER;
			}

			var directVideoQualityUrls : Array = [];
			var directVideoQualityLevels : Array = [];
			if (controller.flashVars.hasOwnProperty("videoqualityurls")) directVideoQualityUrls = String(controller.flashVars["videoqualityurls"]).split(",");
			if (controller.flashVars.hasOwnProperty("videoqualitylevels")) directVideoQualityLevels = String(controller.flashVars["videoqualitylevels"]).split(",");

			if (controller.placement.platform == "direct") {
				for (var i : int = 0; i < directVideoQualityUrls.length; i++) {
					var metaStream : MetaStream;
					if (directVideoQualityLevels[i] == null || directVideoQualityLevels[i] == "") {
						metaStream = new MetaStream(String(i));
					} else {
						metaStream = new MetaStream(directVideoQualityLevels[i]);
					}

					metaStream.uri = String(directVideoQualityUrls[i]);
					metaStream.quality = String(directVideoQualityLevels[i]);
					if (controller.flashVars.hasOwnProperty("aspectratio")) {
						metaStream.aspectRatio = Number(controller.flashVars["aspectratio"]);
					} else {
						metaStream.aspectRatio = controller.config.DEFAULT_ASPECT_RATIO;
					}
					if (directVideoQualityLevels[i] == null || directVideoQualityLevels[i] == "") {
						metaStreams[i] = metaStream;
						qualities.push(String(i));
					} else {
						metaStreams[directVideoQualityLevels[i]] = metaStream;
						qualities.push(String(directVideoQualityLevels[i]));
					}
				}
			}

			if (controller.flashVars.hasOwnProperty("pixellimit")) {
				pixelLimit = Number(controller.flashVars["pixellimit"]);
			} else {
				pixelLimit = controller.config.DEFAULT_PIXEL_LIMIT;
			}

			// video metadata
			if (controller.flashVars.hasOwnProperty("title")) title = controller.flashVars["title"];
			if (controller.flashVars.hasOwnProperty("description")) description = StringUtils.decodeURIString(String(controller.flashVars["description"]));
			if (controller.flashVars.hasOwnProperty("duration")) durationStr = controller.flashVars["duration"];
			if (controller.flashVars.hasOwnProperty("duration")) duration = Number(controller.flashVars["duration"]);
			if (controller.flashVars.hasOwnProperty("thumbnailimageurl")) thumbnailImageUrl = controller.flashVars["thumbnailimageurl"];
			if (controller.flashVars.hasOwnProperty("startimageurl")) startImageUrl = StringUtils.decodeURIString(String(controller.flashVars["startimageurl"]));
			if (controller.flashVars.hasOwnProperty("contentid")) contentId = controller.flashVars["contentid"];
			if (controller.flashVars.hasOwnProperty("projectid")) projectId = controller.flashVars["projectid"];
			if (controller.flashVars.hasOwnProperty("projectname")) projectName = controller.flashVars["projectname"];
			if (controller.flashVars.hasOwnProperty("tags")) tags = String(controller.flashVars["tags"]).split(",");
			if (controller.flashVars.hasOwnProperty("keywords")) keywords = StringUtils.decodeURIString(String(controller.flashVars["keywords"]));
			if (controller.flashVars.hasOwnProperty("readmoreurl")) readMoreUrl = controller.flashVars["readmoreurl"];
			if (controller.flashVars.hasOwnProperty("omnituretracking")) omnitureTracking = (controller.flashVars["omnituretracking"] == 1) ? true : false;

			// monetization
			if (controller.flashVars.hasOwnProperty("fetchvast")) {
				monetization = controller.flashVars["fetchvast"] == "1" ? true : false;
			} else {
				monetization = true;
			}
			if (controller.flashVars.hasOwnProperty("adprovider")) {
				adProvider = controller.flashVars["adprovider"];
			} else {
				adProvider = controller.config.DEFAULT_AD_PROVIDER;
			}

			if (controller.flashVars.hasOwnProperty("zoneid")) zoneId = Number(controller.flashVars["zoneid"]);
			if (controller.flashVars.hasOwnProperty("mediaid")) mediaId = controller.flashVars["mediaid"];
			if (controller.flashVars.hasOwnProperty("mediafingerprintid")) mediaFingerprintId = controller.flashVars["mediafingerprintid"];

			lrContent = controller.config.DEFAULT_LR_CONTENT;
			lrAdMap = (controller.flashVars.hasOwnProperty("lradmap")) ? String(controller.flashVars["lradmap"]) : controller.config.DEFAULT_LR_ADMAP;

			// tracking
			if (controller.flashVars.hasOwnProperty("trackingmode")) {
				trackingMode = controller.flashVars["trackingmode"];
			} else if (controller.flashVars.hasOwnProperty("logmode")) {
				trackingMode = controller.flashVars["logmode"];
			} else {
				trackingMode = controller.config.DEFAULT_TRACKING_MODE;
			}
			if (controller.flashVars.hasOwnProperty("trackingping")) trackingPing = controller.flashVars["trackingping"] == "1" ? true : false;

			// FB share
			if (controller.flashVars.hasOwnProperty("enablesharefb")) shareFBEnabled = (controller.flashVars["enablesharefb"] == "1") ? true : false;
			if (controller.flashVars.hasOwnProperty("sharefblink")) shareFBLink = StringUtils.decodeURIString(String(controller.flashVars["sharefblink"]));
			if (controller.flashVars.hasOwnProperty("sharefbcaption")) shareFBCaption = StringUtils.decodeURIString(String(controller.flashVars["sharefbcaption"]));
			if (controller.flashVars.hasOwnProperty("sharefbdescription")) shareFBDescription = StringUtils.decodeURIString(String(controller.flashVars["sharefbdescription"]));

			// TW share
			if (controller.flashVars.hasOwnProperty("twittersharetext")) shareTwitterMessage = StringUtils.decodeURIString(String(controller.flashVars["twittersharetext"]));
			if (controller.flashVars.hasOwnProperty("twittershareuseurl")) shareTwitterUseUrl = controller.flashVars["twittershareuseurl"] == "1" ? true : false;

			// email share
			if (controller.flashVars.hasOwnProperty("isemail")) isEmail = controller.flashVars["isemail"] == "1" ? true : false;
			if (controller.flashVars.hasOwnProperty("emailsubject")) emailSubject = controller.flashVars["emailsubject"];
			if (controller.flashVars.hasOwnProperty("emailbody")) emailBody = controller.flashVars["emailbody"];

			// gplus share
			if (controller.flashVars.hasOwnProperty("googleplusshare")) googlePlusShare = controller.flashVars["googleplusshare"] == "1" ? true : false;

			// tumblr
			if (controller.flashVars.hasOwnProperty("enablesharetumblr")) enableShareTumblr = (controller.flashVars["enablesharetumblr"] == "1") ? true : false;
			if (controller.flashVars.hasOwnProperty("tumblrcaptiontxt")) tumblrCaptionTxt = String(controller.flashVars["tumblrcaptiontxt"]);

			// omniture XML path
			if (controller.flashVars.hasOwnProperty("omniturexmlpath")) omnitureXMLPath = controller.flashVars["omniturexmlpath"];

			// advs
			if (controller.flashVars.hasOwnProperty("isskipads")) isSkipAds = controller.flashVars["isskipads"] == "1" ? true : false;
			if (controller.flashVars.hasOwnProperty("skipadduration")) skipAdDuration = Number(controller.flashVars["skipadduration"]);

			Log.write(toString());

			// DEV: KJR force here
			// googlePlusShare = true;
			// isEmail = true;
			// enableShareTumblr = true;
		}

		public function toString() : String {
			return "MetaVideo - " + _videoId + " - " + title;
		}
	}
}