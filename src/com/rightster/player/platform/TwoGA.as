package com.rightster.player.platform {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ModelEvent;
	import com.rightster.player.media.MediaProvider;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlaylist;
	import com.rightster.player.model.MetaError;
	import com.rightster.player.model.MetaImage;
	import com.rightster.player.model.MetaPlugin;
	import com.rightster.player.model.MetaQuality;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.view.ColorOverrides;
	import com.rightster.utils.AssetLoader;
	import com.rightster.utils.BooleanUtils;
	import com.rightster.utils.Environment;
	import com.rightster.utils.Log;
	import com.rightster.utils.Protocol;
	import com.rightster.utils.Url;

	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	/**
	 * @author Daniel
	 */
	public class TwoGA implements IPlatform {
		private const THUMB_IMAGE_KEY : String = "128";
		private const START_IMAGE_KEY : String = "576";
		private const SERVICE_URL_SUFFIX : String = ".rightster.com/api/v1/assembly.player";
		private const AUTO_QUALITY : String = "auto";
		private const HIGHEST_QUALITY : String = "HIGHEST_QUALITY";
		private const LOWEST_QUALITY : String = "LOWEST_QUALITY";
		private var controller : IController;
		private var dataJson : Object;
		private var _playlistD : Dictionary;
		private	var request : URLRequest;
		private var serviceUrl : String;
		private var retainedEnviron : String;

		public function TwoGA(controller : IController) : void {
			this.controller = controller;
			_playlistD = new Dictionary();
		}

		public function dispose() : void {
			controller.loader.reset();
			controller = null;
		}

		public function _loadGUID() : void {
		}

		public function loadGUID() : void {
		}

		public function requestPlaybackAuth() : void {
		}

		public function getServiceUrl() : String {
			Log.write("TwoGa.getServiceUrl");
			var environ : String;
			var platform : String;
			var env : Environment = new Environment();
			var str : String = (controller.placement.href && controller.placement.href != "") ? controller.placement.href : env.referrer;
			var url : Url = new Url(str);
			var protocol : String;

			if (url.protocol != Protocol.PROTOCOL_TYPE_NONE) {
				protocol = url.protocol.value;
				Log.write("Using protocol: " + protocol, Log.SYSTEM);
			} else {
				Log.write("WARN: Protocol warning - enforcing https", Log.SYSTEM);
				protocol = "https";
			}

			// determine env and platform
			environ = getEnviron(str);
			platform = getPlatform(str);

			// deal with demo
			var list : Array = controller.placement.path.split(".");
			for (var i : int = 0; i < list.length; i++) {
				if (String(list[i]).toLowerCase() == "demo") {
					environ = 'demo';
					break;
				}
			}

			// deal with an iframe embed
			if (!environ) {
				Log.write("WARN: environ is null, using loaderInfoURL");
				str = controller.placement.loaderInfoURL;
				environ = getEnviron(str);
				platform = getPlatform(str);
				url = new Url(str);
				protocol = url.protocol.value;
			}

			if (!retainedEnviron) {
				retainedEnviron = environ;
			} else {
				environ = retainedEnviron;
			}

			controller.currentProtocol = protocol;

			return protocol + "://" + platform + "." + environ + SERVICE_URL_SUFFIX;
		}

		public function loadPlaylist(id : String = "") : void {
			Log.write('TwoGa.loadPlaylist');
			serviceUrl = getServiceUrl() + ".getConfig?placementId=" + controller.placement.initialId + "&playerType=" + controller.config.PLAYER_TYPE;
			Log.write('**serviceUrl: ' + serviceUrl);
			request = new URLRequest(serviceUrl);
			controller.loader.load(request, AssetLoader.TYPE_TEXT, null, true, ErrorCode.ASSET_LOADING_ERROR, "TwoGA.loadPlaylist * ", configComplete);
		}

		public function get playlist() : IPlaylist {
			return (controller != null) ? controller.getPlaylist() : null;
		}

		private function getEnviron(str : String) : String {
			var environ : String;

			if (str.indexOf('.devint.') > -1) {
				environ = 'devint';
			} else if (str.indexOf('.partnerint.') > -1) {
				environ = 'partnerint';
			} else if (str.indexOf('.qa1.') > -1) {
				environ = 'qa1';
			} else if (str.indexOf('.qa2.') > -1) {
				environ = 'qa2';
			} else if (str.indexOf('.qa3.') > -1) {
				environ = 'qa3';
			} else if (str.indexOf('.qa4.') > -1) {
				environ = 'qa4';
			} else if (str.indexOf('.qa5.') > -1) {
				environ = 'qa5';
			} else if (str.indexOf('.nft.') > -1) {
				environ = 'nft';
			} else if (str.indexOf('.demo.') > -1) {
				environ = 'demo';
			} else if (str.indexOf('.staging.') > -1) {
				environ = 'staging';
			} else if (str.indexOf('.my.') > -1) {
				environ = 'my';
			} else if (str.indexOf('.devlocal.') > -1) {
				environ = 'devlocal';
			}

			return environ;
		}

		private function getPlatform(str : String) : String {
			var platform : String ;

			if (str.indexOf('platform.') > -1) {
				platform = 'platform';
			} else {
				platform = 'platformplayer';
			}

			return platform;
		}

		private function configComplete(result : String) : void {
			Log.write("\nTwoGA.configComplete: " + result + "\n", Log.DATA);
			var metaError : MetaError;
			var willBlock : Boolean = false;

			try {
				dataJson = JSON.parse(result);
			} catch (err : Error) {
				controller.error(ErrorCode.XML_PARSING_ERROR, "TwoGA.configComplete * " + err.message + " * url: " + request.url, true);
				return;
			}

			if (dataJson.hasOwnProperty("errors") && dataJson["errors"] is Object) {
				if (dataJson["errors"].hasOwnProperty("code")) {
					metaError = new MetaError(dataJson["errors"]["code"], dataJson["errors"]["message"]);

					if (metaError.code != 0) {
						Log.write("Errors detected in config payload * code " + metaError.code, Log.ERROR);
						switch (metaError.code) {
							case 8:
								controller.jsApi.shouldInitialize();
								controller.error(ErrorCode.CONTENT_UNAVAILABLE, "TwoGA.configComplete * " + metaError.message + " * url: " + request.url, true);
								willBlock = true;
								break;
							case 9:
								controller.jsApi.shouldInitialize();
								controller.error(ErrorCode.CONTENT_GEOBLOCKED, "TwoGA.configComplete * " + metaError.message + " * url: " + request.url, true);
								willBlock = true;
								break;
						}
					}
				}
			}

			if (willBlock) {
				// TODO: handle platform error messages appropriately
				return;
			}

			if (dataJson.configuration is Object) {
				controller.placement.autoPlay = dataJson.configuration.autoPlay as Boolean;

				// precedence?

				if (dataJson.configuration.hasOwnProperty('startVolume')) {
					Log.write("setting startVolume to: " + controller.placement.startVolume);
					controller.placement.startVolume = dataJson.configuration.startVolume;
					controller.placement.startMuted = dataJson.configuration.startVolume == 0 ? true : false;
				}

				controller.placement.publisherId = dataJson.configuration.publisherId;

				controller.placement.href = (!dataJson.configuration.referrer) ? controller.placement.href : dataJson.configuration.referrer;
				controller.placement.env = dataJson.configuration.env;
				controller.placement.env = dataJson.configuration.env;

				controller.placement.jsApi = BooleanUtils.booleanValue(dataJson.configuration.apiEnabled);
				if (controller.placement.jsApi) {
					controller.jsApi.initialize();
				}

				if (dataJson.hasOwnProperty('monetization')) {
					controller.placement.shouldMonetize = BooleanUtils.booleanValue(dataJson['monetization']);
				}

				if (dataJson.hasOwnProperty('randomize')) {
					controller.placement.randomize = BooleanUtils.booleanValue(dataJson['randomize']);
				}

				if (controller.placementValuesAreDirty) {
					controller.applyDirtyPlacementValues();
				}

				if (!controller.placement.userId) {
					controller.placement.userId = dataJson.configuration.userId;
				}
				if (!controller.placement.userSession) {
					controller.placement.userSession = dataJson.configuration.userSession;
				} else {
					var num : uint = controller.placement.userSession + 1;
					controller.placement.userSession = num;
				}

				if (dataJson.configuration.hasOwnProperty('livestream')) {
					controller.placement.liveStream = BooleanUtils.booleanValue(dataJson.configuration['livestream']);
				}

				Log.write('controller.placement.liveStream: ' + controller.placement.liveStream);
				Log.write('controller.placement.userId: ' + controller.placement.userId);
				Log.write('controller.placement.userSession: ' + controller.placement.userSession);

				parseCustomContent();
			}

			if (dataJson.playlist is Object) {
				if (dataJson.playlist.hasOwnProperty("title")) {
					controller.placement.playListTitle = dataJson.playlist.title;
				}

				for (var i : int = 0; i < dataJson.playlist.index.length; i++) {
					try {
						parsePlaylist(dataJson.playlist.index[i]);
					} catch (e : Error) {
						Log.write('TwoGA.parsePlaylist ' + e.message, Log.ERROR);
					}
				}
				try {
					parseContent(dataJson.playlist.content);
				} catch (e : Error) {
					Log.write('TwoGA.parseContent ' + e.message, Log.ERROR);
				}
			}

			if (controller.placement.randomize) {
				Log.write("TwoGA.configComplete * asserting randomized playlist");
				controller.getPlaylist().randomize();
				controller.dispatchEvent(new ModelEvent(ModelEvent.PLAYLIST_COMPLETE));
			} else {
				controller.dispatchEvent(new ModelEvent(ModelEvent.PLAYLIST_COMPLETE));
			}
		}

		private function parsePlaylist(content : Object) : void {
			Log.write('TwoGA.parsePlaylist');
			var video : MetaVideo = new MetaVideo(controller, content.contentViewId, controller.getPlaylist().length);
			controller.getPlaylist().insertItem(video);
			_playlistD[video.videoId] = video;

			video.title = content.title;
			video.durationStr = content.duration;
			video.duration = Number(content.duration);

			// Log.write(' parsePlaylist 2');
			for (var j : int = 0; j < content.images.length; j++) {
				var image : MetaImage = new MetaImage(content.images[j].uri, content.images[j].quality, content.images[j].width, content.images[j].height);
				video.images[image.quality] = image;
			}

			// if (content.hasOwnProperty("title")) {
			// controller.placement.playListTitle = content["title"];
			// }

			// Log.write(' parsePlaylist 4');
			// TODO: map correctly 1080,720,576,360,128,42

			video.thumbnailImageUrl = getImageUrlForTypeFromVideo(THUMB_IMAGE_KEY, video);
		}

		private function parseCustomContent() : void {
			Log.write('TwoGa.parseCustomContent');
			// Check for custom content
			if (dataJson.configuration.custom is Array && dataJson.configuration.custom.length > 0) {
				// check for colorScheme

				var isColorScheme : Function = function(element : *, index : int, arr : Array) : void {
					if (element.colorScheme is Object) {
						var colorOverrides : ColorOverrides = new ColorOverrides(controller, element.colorScheme);
						colorOverrides.dispose();
					}
				};

				var arr : Array = dataJson.configuration.custom as Array;
				arr.forEach(isColorScheme);
			}
		}

		public function loadVideo(id : String) : void {
			Log.write('TwoGa.loadVideo @ id =' + id);
			serviceUrl = getServiceUrl() + ".getContent?contentViewId=" + id + "&placementId=" + controller.placement.initialId + "&playerType=" + controller.config.PLAYER_TYPE;
			request = new URLRequest(serviceUrl);
			controller.loader.load(request, AssetLoader.TYPE_TEXT, null, true, ErrorCode.ASSET_LOADING_ERROR, "TwoGA.loadVideo * ", contentComplete);
		}

		private function contentComplete(result : String) : void {
			Log.write("TwoGa.contentComplete: " + result + "\n", Log.DATA);
			var metaError : MetaError;
			var willBlock : Boolean = false;

			try {
				dataJson = JSON.parse(result);
			} catch (err : Error) {
				controller.error(ErrorCode.XML_PARSING_ERROR, "TwoGA.contentComplete * " + err.message + " * url: " + request.url, true);
				return;
			}

			if (dataJson.hasOwnProperty("errors") && dataJson["errors"] is Object) {
				if (dataJson["errors"].hasOwnProperty("code")) {
					metaError = new MetaError(dataJson["errors"]["code"], dataJson["errors"]["message"]);

					if (metaError.code != 0) {
						Log.write("Errors detected in content payload * code " + metaError.code, Log.ERROR);
						switch (metaError.code) {
							case 8:
								controller.error(ErrorCode.CONTENT_UNAVAILABLE, "TwoGA.contentComplete * " + metaError.message + " * url: " + request.url, true);
								willBlock = true;
								break;
							case 9:
								controller.error(ErrorCode.CONTENT_GEOBLOCKED, "TwoGA.contentComplete * " + metaError.message + " * url: " + request.url, true);
								willBlock = true;
								break;
						}
					}
				}
			}

			if (willBlock) {
				return;
			}

			for (var it : String in dataJson) {
				Log.write(it + " - " + dataJson[it]);
			}

			if (dataJson.content is Object) {
				parseContent(dataJson.content);
			}

			controller.dispatchEvent(new ModelEvent(ModelEvent.VIDEO_DATA_COMPLETE));
		}

		private function parseContent(content : Object) : void {
			Log.write('TwoGa.parseContent');
			var video : MetaVideo = _playlistD[content.metadata.contentViewId];
			try {
				video.dataLoaded = true;
				video.metaPlugins.push(new MetaPlugin('Default Skin', controller.config.DEFAULT_SKIN));

				if (content.metadata is Object) {
					video.title = (content.metadata.hasOwnProperty("title")) ? content.metadata.title : "";
					video.description = (content.metadata.hasOwnProperty("description")) ? content.metadata.description : "";
					video.durationStr = (content.metadata.hasOwnProperty("duration")) ? content.metadata.duration : "0";
					video.duration = (content.metadata.hasOwnProperty("duration")) ? content.metadata.duration : 0;
					video.startImageUrl = (content.metadata.hasOwnProperty("startImage")) ? content.metadata.startImage : "";
					video.contentOwner = (content.metadata.hasOwnProperty("contentOwner")) ? content.metadata.contentOwner : "";
					video.contentCreator = (content.metadata.hasOwnProperty("contentCreator")) ? content.metadata.contentCreator : "";
					video.keywords = (content.metadata.hasOwnProperty("keywords")) ? content.metadata.keywords : "";

					if (content.metadata.social.facebook is Object) {
						if (facebookSharingIsValid(content.metadata.social.facebook)) {
							video.shareFBEnabled = true;
							video.shareFBLink = content.metadata.social.facebook.link;
						}
					}

					if (content.metadata.social.twitter is Object) {
						if (twitterSharingIsValid(content.metadata.social.twitter)) {
							video.shareTwitterLink = content.metadata.social.twitter.link;
						}
					}

					// ENG-3918 Permalink - commented out pending clarification
					if (content.metadata.social.readMore is String) {
						// video.readMoreUrl = content.metadata.social.readMore;
					}
				}
			} catch (err1 : Error) {
				Log.write('err1: ' + err1.toString());
			}

			try {
				if (content.assets.videos is Object) {
					for (var j : int = 0; j < content.assets.videos.length; j++) {
						var metaQuality : MetaQuality = new MetaQuality(content.assets.videos[j].quality, content.assets.videos[j].qualityLabel);
						var stream : MetaStream = new MetaStream(content.assets.videos[j].quality);
						stream.uri = content.assets.videos[j].uri;

						// DEVELOPER: override uri here to force test
						// stream.uri = "http://liveplayer-lh.akamaihd.net/z/img_fashion@344827/manifest.f4m";
						// ==== end override

						stream.cdn = content.assets.videos[j].cdn;
						stream.aspectRatio = content.assets.videos[j].width / content.assets.videos[j].height;
						stream.metaQuality = metaQuality;

						video.metaStreams[stream.quality] = stream;
						video.qualities.push(stream.quality);
						video.metaQualities.push(metaQuality);
						video.width = content.assets.videos[j].width;
						video.height = content.assets.videos[j].height;

						switch (stream.cdn) {
							case "akamai":
								video.mediaProvider = MediaProvider.AKAMAI_LIVE;
								break;
							case "ec":
							default:
								video.mediaProvider = MediaProvider.VIDEO_MEDIA_PROVIDER;
								break;
						}

						// This is specified by the platform as akamai...
						video.mediaProvider = MediaProvider.AKAMAI_LIVE;
						
						
						Log.write('MetaStream: ', stream.toString());
					}

					Log.write('Media Provider: ', video.mediaProvider, stream.cdn);
					switch (video.mediaProvider) {
						case MediaProvider.VIDEO_MEDIA_PROVIDER:
							video.metaPlugins.push(new MetaPlugin(MediaProvider.VIDEO_MEDIA_PROVIDER, controller.config.DEFAULT_VOD_MEDIA));
							break;
						case MediaProvider.LIVE_MEDIA_PROVIDER:
							video.metaPlugins.push(new MetaPlugin(MediaProvider.LIVE_MEDIA_PROVIDER, controller.config.DEFAULT_LIVE_MEDIA));
							break;
						case MediaProvider.AKAMAI_LIVE:
							video.metaPlugins.push(new MetaPlugin(MediaProvider.AKAMAI_LIVE, controller.config.AKAMAI_LIVE_MEDIA));
							break;
					}

					video.eventType = "vod";
				}
			} catch (err2 : Error) {
				Log.write('err2: ' + err2.toString());
			}

			// TODO: improve the adding of metaplugins via a managed registry to avoid adding the same object multiple times
			if (content.plugins is Object) {
				if (content.plugins.LiveRail is Object && content.plugins.LiveRail.hasOwnProperty('params')) {
					video.metaPlugins.push(new MetaPlugin("LiveRail", controller.config.LIVERAIL_MONETISATION, content.plugins.LiveRail.params));
				} else if (content.plugins.Google is Object) {
					// video.metaPlugins.push(new MetaPlugin("Google", controller.config.GOOGLE_MONETISATION/*, content.plugins.Google.params = probably a URL*/));
				}

				if (content.plugins.Quantcast is Object) {
					// TODO: uncomment when Quantcast is available
					// video.metaPlugins.push(new MetaPlugin("Quantcast", controller.config.QUANTCAST, content.plugins.Quantcast.params));
				}

				if (content.plugins.RightsterLogger is Object) {
					video.metaPlugins.push(new MetaPlugin('TwoGA Analytics', controller.config.TRACKING_SERVICE_TWOGA, content.plugins.RightsterLogger));
				}
			}

			// override for testing
			// video.metaPlugins.push(new MetaPlugin("Google", controller.config.GOOGLE_MONETISATION/*, content.plugins.Google.params = probably a URL*/));
			// video.metaPlugins.push(new MetaPlugin("LiveRail", controller.config.LIVERAIL_MONETISATION, getDevLiveRailObject()));
			// video.metaPlugins.push(new MetaPlugin("Quantcast", controller.config.QUANTCAST, getDevQuantcastObject()));

			// TODO:check implementation..can we get playback quality at this point?
			// Log.write("controller.getPlaybackQuality()) :: " + controller.getPlaybackQuality());

			Log.write("video.contentId : " + video.contentId + " * video.metaPlugins.length : " + video.metaPlugins.length);

			video.startImageUrl = getImageUrlForTypeFromVideo(START_IMAGE_KEY, video);
			Log.write('video.startImageUrl: ' + video.startImageUrl);
			video.thumbnailImageUrl = getImageUrlForTypeFromVideo(THUMB_IMAGE_KEY, video);
			Log.write('video.startImageUrl: ' + video.startImageUrl);
		}

		private function getImageUrlForTypeFromVideo(type : String, video : MetaVideo) : String {
			Log.write('TwoGa.getImageUrlForTypeFromVideo: *type' + type);
			var uri : String = "";
			var obj : MetaImage;
			var key : String;

			try {
				if (type == START_IMAGE_KEY) {
					var metaQuality : MetaQuality = video.metaQualities[0] as MetaQuality;

					// get matching width or next highest for auto
					if (metaQuality.label.toLowerCase() == AUTO_QUALITY) {
						// look for  matching width
						for (key in video.images) {
							obj = video.images[key] as MetaImage;
							if (Number(obj.width) == video.width) {
								return obj.uri;
							}
						}

						// no match get highest quality
						obj = getQualityImageOfType(HIGHEST_QUALITY, video);
						return obj.uri;
					} else {
						// not auto, look for match on quality
						for (key in video.images) {
							obj = video.images[key] as MetaImage;

							// NOTE: can there be an array of videos in the config? - if so and when, decide how to use
							if (String(obj.quality).toLowerCase() == metaQuality.label.toLowerCase()) {
								return obj.uri;
							}
						}

						// no match, get highest quality
						obj = getQualityImageOfType(HIGHEST_QUALITY, video);
						uri = obj.uri;
					}
				} else {
					// thumb - get lowest quality
					obj = getQualityImageOfType(LOWEST_QUALITY, video);
					uri = obj.uri;
				}
			} catch (error : Error) {
				controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "TwoGA.getImageUrlForTypeFromVideo * error.message: " + error.message + "* type: " + type + "* video:" + video.toString(), false);
			}

			return uri;
		}

		private function getQualityImageOfType(qualityType : String, metaVideo : MetaVideo) : MetaImage {
			var array : Array = [];

			for (var key : String in metaVideo.images) {
				var metaImage : MetaImage = metaVideo.images[key];
				array.push(metaImage);
			}

			if (qualityType == HIGHEST_QUALITY) {
				array.sortOn("quality", Array.DESCENDING | Array.CASEINSENSITIVE);
			} else {
				array.sortOn("quality", Array.NUMERIC);
			}

			metaImage = array[0] as MetaImage;

			return metaImage;
		}

		private function facebookSharingIsValid(obj : Object) : Boolean {
			return  (obj.hasOwnProperty("link") && obj.link != "") ? true : false;
		}

		private function twitterSharingIsValid(obj : Object) : Boolean {
			return  (obj.hasOwnProperty("link") && obj.link != "") ? true : false;
		}
	}
}