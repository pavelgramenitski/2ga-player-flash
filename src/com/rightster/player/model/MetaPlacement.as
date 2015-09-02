package com.rightster.player.model {
	import com.rightster.utils.BooleanUtils;
	import com.rightster.utils.StringUtils;
	import com.rightster.utils.Log;
	import com.rightster.utils.Environment;
	import com.rightster.player.controller.IController;

	/**
	 * @author Daniel
	 */
	public class MetaPlacement {
		private var controller : IController;
		public var platform : String = "";
		public var cueVideos : Array = [];
		public var cuePlaylists : Array = [];
		public var initialId : String = "";
		public var playerId : String = "";
		public var showPlaylist : Boolean = false;
		public var publisherId : String = "";
		public var publisherName : String = "";
		public var _autoPlay : Boolean;
		public var startMuted : Boolean = false;
		public var startVolume : Number;
		public var jsApi : Boolean;
		public var path : String = "";
		public var embedPageTitle : String = "";
		public var embedPageUrl : String;
		public var href : String = "";
		public var referrer : String;
		public var env : String;
		public var randomize : Boolean = false;
		public var shouldMonetize : Boolean = true;
		// rightster environment
		public var relatedVideos : Boolean;
		public var forceDisableSharing : Boolean;
		// public var genesisOrigin : String;
		public var initLogMode : String;
		public var loaderInfoURL : String;
		public var playListTitle : String;
		public var forceHTTPS : Boolean;
		public var authValue : String = "";
		public var pcodeValue : String;
		public var autoBitrateSwitching : Boolean = false;
		public var defaultQuality : String = "standardHDS";
		private var _userId : String;
		private var _userSession : uint;
		// timed playlist
		public var playlistVersion : int = 1;
		public var livePlaylist : Boolean = false;
		// public var unixEpoch : Number;
		public var forceadBreak : Boolean = false;
		// Mars
		// public var streamPlaybackURL : String = "";
		public var playbackAuthorisation : Boolean = false;
		// public var diagnosticsService : String = "";
		// public var accountId : String = "";
		// Optional: account user of the application
		// public var eventId : String = "";
		// From schedule
		public var dealId : String = "";
		// From schedule
		public var applicationId : String = "";
		public var reference : String = "";
		// Optional reference supplied by client
		public var user : String = "";
		// Optional reference supplied by client
		// public var clientIP : String = "";
		// Optional: required only if server initated request
		// public var secret : String = "";
		// public var signature : String = "";
		// public var nonce : String = "";
		// public var timestamp : String = "";
		// public var isDailyMailSkin : Boolean = false;
		public var noControlsWhileAds : Boolean = false;
		public var autoPlayOnMouseOver : Boolean = false;
		public var autoPlayDisableOnUserClick : Boolean = false;
		// pubnub channel
		public var pubNubSubscribeID : String = "sub-c-35e859ba-2964-11e4-8eb2-02ee2ddab7fe";
		// playback options
		public var mouseOverContentUnmute : Boolean = false;
		public var showTitleConditions : int = -1;
		// 0= visible false, 1=visible all time, 2=visible on/off with interval of 3sec
		private var autoPlayIsDirty : Boolean = false;
		// page player
		public var pagePlayer : Boolean = false;
		public var displayStyle : String = "";
		public var listStyle : String = "";
		// livestreaming
		private var _liveStream : Boolean = false;

		public function MetaPlacement(controller : IController) {
			this.controller = controller;
		}

		public function init(initObject : Object, loaderInfoURL : String) : void {
			Log.write("MetaPlacement.init * initObject:" + initObject.toString(), Log.SYSTEM);
			Log.write("MetaPlacement.init * loaderInfoURL:" + loaderInfoURL, Log.SYSTEM);
			initObject = initObject == null ? {} : initObject;

			for (var key : String in initObject) {
				Log.write("key: " + key + " value: " + initObject[key]);
			}

			this.loaderInfoURL = loaderInfoURL;

			// Genesis
			if (initObject.hasOwnProperty("platform")) {
				platform = initObject["platform"];
			} else {
				platform = controller.config.DEFAULT_PLATFORM;
			}

			playListTitle = controller.config.DEFAULT_PLAYLIST_TITLE;

			if (initObject.hasOwnProperty("auth")) {
				authValue = String(initObject["auth"]);
			}

			if (initObject.hasOwnProperty("cuevideos")) {
				cueVideos = String(initObject["cuevideos"]).split(',');
			}
			if (initObject.hasOwnProperty("cueplaylists")) {
				cuePlaylists = String(initObject["cueplaylists"]).split(',');
			}
			if (initObject.hasOwnProperty("playlist")) {
				showPlaylist = BooleanUtils.booleanValue(initObject["playlist"]);
			}
			if (initObject.hasOwnProperty("video_id")) {
				initialId = String(initObject["video_id"]);
			}
			if (initObject.hasOwnProperty("placementid")) {
				initialId = String(initObject["placementid"]);
			}
			if (initObject.hasOwnProperty("autobitrateswitching")) {
				autoBitrateSwitching = BooleanUtils.booleanValue(initObject["autobitrateswitching"]);
			}
			if (initObject.hasOwnProperty("nocontrolswhileads")) {
				noControlsWhileAds = BooleanUtils.booleanValue(initObject["nocontrolswhileads"]);
			}

			if (initObject.hasOwnProperty("show_title")) {
				// No valid value recieved from flashvars
				var temp : int = int(initObject["show_title"]);
				if (temp >= 0 && temp <= 2) {
					showTitleConditions = temp;
				}
				// if(showTitleConditions < 0 || showTitleConditions > 2){
				// showTitleConditions = 0;
				// }
			}

			// TODO: implement this as suggestedQuality
			if (initObject.hasOwnProperty("defaultquality")) {
				var quality : String = initObject["defaultquality"];
				if (quality == 'high' || quality == 'med.' || quality == 'low') {
					defaultQuality = quality.substr(0, 1).toUpperCase() + quality.substr(1, quality.length);
				}
			}

			if (initObject.hasOwnProperty("playerid")) {
				playerId = initObject["playerid"];
			}

			if (initObject.hasOwnProperty("publishername")) {
				publisherName = StringUtils.decodeURIString(String(initObject["publishername"]));
			}

			if (initObject.hasOwnProperty("publisherid")) {
				publisherId = initObject["publisherid"];
			}

			if (initObject.hasOwnProperty("autoplay")) {
				this.autoPlay = BooleanUtils.booleanValue(initObject["autoplay"] == "1");
				// this.autoPlay = BooleanUtils.booleanValue(initObject["autoplay"]);
				autoPlayOnMouseOver = (initObject["autoplay"] == "3") ? true : false;
				autoPlayIsDirty = true;
			}

			if (initObject.hasOwnProperty("startmuted")) {
				startMuted = BooleanUtils.booleanValue(initObject["startmuted"]);
			}

			if (autoPlayOnMouseOver && startMuted) {
				_autoPlay = mouseOverContentUnmute = true;
			}

			if (initObject.hasOwnProperty("relatedvideos")) relatedVideos = initObject["relatedvideos"] == 1 ? true : false;

			if (initObject.hasOwnProperty("forcedisablesharing")) {
				forceDisableSharing = BooleanUtils.booleanValue(initObject["forcedisablesharing"]);
			}

			if (initObject.hasOwnProperty("jsapi")) {
				jsApi = BooleanUtils.booleanValue(initObject["jsapi"]);
			}

			if (initObject.hasOwnProperty("randomize")) {
				randomize = BooleanUtils.booleanValue(initObject["randomize"]);
			}

			if (initObject.hasOwnProperty("monetization")) {
				shouldMonetize = BooleanUtils.booleanValue(initObject["monetization"]);
			}

			if (initObject.hasOwnProperty("liveplaylist")) {
				livePlaylist = BooleanUtils.booleanValue(initObject["liveplaylist"]);
			}

			if (initObject.hasOwnProperty("playlistversion")) {
				playlistVersion = Number(initObject["playlistversion"]);
			}

			if (initObject.hasOwnProperty("forcehttps")) {
				forceHTTPS = BooleanUtils.booleanValue(initObject["forcehttps"]);
			}

			pcodeValue = (initObject.hasOwnProperty("pcode")) ? String(controller.flashVars["pcode"]) : controller.config.DEFAULT_PCODE_VALUE;

			initLogMode = (initObject.hasOwnProperty("logmode")) ? String(initObject["logmode"]) : controller.config.DEFAULT_LOGMODE;

			var env : Environment = new Environment();

			embedPageTitle = initObject.hasOwnProperty("embedpagetitle") ? String(initObject["embedpagetitle"]) : env.title;

			embedPageUrl = initObject.hasOwnProperty("embedpageurl") ? String(initObject["embedpageurl"]) : env.url;

			referrer = initObject.hasOwnProperty("referrer") ? String(initObject["referrer"]) : env.referrer;

			if (referrer != "") {
				href = referrer;
			} else if (embedPageUrl != "") {
				href = embedPageUrl;
			}

			Log.write("Metaplacement.init * autoPlay: " + this.autoPlay.toString());
			Log.write("Metaplacement.init * startMuted: " + this.startMuted.toString());
			Log.write("Metaplacement.init * embedPageUrl: " + embedPageUrl);
			Log.write("Metaplacement.init * referrer: " + referrer);
			Log.write("Metaplacement.init * href: " + href);

			if (initObject["autoplaynext"] == "1" && initObject["loop"] == "1") {
				controller.loopMode = LoopMode.PLAYLIST;
			} else if (initObject["autoplaynext"] == "0") {
				controller.loopMode = LoopMode.VIDEO;
			}

			if (controller.live && !initObject.hasOwnProperty("path")) {
				// path = controller.config.DEFAULT_PATH + controller.version + "/";
				path = loaderInfoURL.substr(0, loaderInfoURL.lastIndexOf('/') + 1);
			} else if (initObject.hasOwnProperty("path")) {
				path = initObject["path"];
			}

			if (initObject.hasOwnProperty("playbackauthorisation")) {
				playbackAuthorisation = initObject["playbackauthorisation"] as Boolean;
			}

			// page player specific
			if (initObject.hasOwnProperty("pageplayer")) pagePlayer = BooleanUtils.booleanValue(initObject["pageplayer"]);
			if (initObject.hasOwnProperty("liststyle")) listStyle = String(initObject["liststyle"]);
			if (initObject.hasOwnProperty("displaystyle")) displayStyle = String(initObject["displaystyle"]);
			
			//livestream
			if (initObject.hasOwnProperty("livestream")) liveStream = BooleanUtils.booleanValue(initObject["livestream"]);
		}

		public function reset() : void {
			showPlaylist = false;
		}

		public function toString() : String {
			return "MetaPlacement * initialId:" + initialId;
		}

		public function get autoPlay() : Boolean {
			return _autoPlay;
		}

		public function set autoPlay(value : Boolean) : void {
			if (!autoPlayIsDirty) {
				_autoPlay = value;
				Log.write("MetaPlacement.set autoPlay * value: " + autoPlay, Log.SYSTEM);
			} else {
				Log.write("MetaPlacement.set autoPlay not updated because is dirty. unchanged value: " + _autoPlay, Log.SYSTEM);
			}
		}

		public function get userId() : String {
			return _userId;
		}

		public function set userId(value : String) : void {
			_userId = value;
		}

		public function get userSession() : uint {
			return _userSession;
		}

		public function set userSession(value : uint) : void {
			_userSession = value;
		}

		public function get liveStream() : Boolean {
			return _liveStream;
		}

		public function set liveStream(value : Boolean) : void {
			_liveStream = value;
		}
	}
}