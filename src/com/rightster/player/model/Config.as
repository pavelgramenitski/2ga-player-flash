package com.rightster.player.model {
	import com.rightster.player.media.MediaProvider;
	import com.rightster.player.platform.Platforms;

	/**
	 * @author Daniel
	 */
	public class Config {
		public const PLAYER_NAME : String = "Rightster Player";
		public const PLAYER_TYPE : String = "flash";
		// *** plugins ***
		public const DEFAULT_PATH : String = "http://player.rightster.com/";
		public const DEFAULT_VOD_MEDIA : String = "plugins/DefaultVodMedia.swf";
		public const DEFAULT_LIVE_MEDIA : String = "plugins/DefaultLiveMedia.swf";
		public const AKAMAI_LIVE_MEDIA : String = "plugins/AkamaiLiveStream.swf";
		public const COMSCORE_TRACKER : String = "plugins/ComScoreTracker.swf";
		public const DEFAULT_SKIN : String = "skins/default.swf";
		
		public const TRACKING_SERVICE_TWOGA : String = "plugins/TwoGATracker.swf";
		public const TRACKING_SERVICE_GA : String = "plugins/GaTracker.swf";
		public const LIVERAIL_MONETISATION : String = "plugins/LiveRailMonetisation.swf";
		public const GOOGLE_MONETISATION : String = "plugins/GoogleMonetisation.swf";
	
		public const QUANTCAST : String = "plugins/Quantcast.swf";
		public const OMNITURE_TRACKER : String = "plugins/OmnitureTracker.swf";
		// ** Error Screens ***
		public const ERROR_SCREEN_DEFAULT : String = "assets/error_screen_default.swf";
		public const ERROR_SCREEN_GEO : String = "assets/error_screen_geo.swf";
		public const ERROR_SCREEN_PLAYLIST : String = "assets/error_screen_playlist.swf";
		// *** Video ***
		public const BUFFER_TIME : Number = 1;
		public const FAST_START_BUFFER_TIME : Number = 0.5;
		public const STREAM_LATENCY : Number = 0;
		public const DEFAULT_ASPECT_RATIO : Number = 16 / 9;
		public const DEFAULT_PIXEL_LIMIT : Number = -1;
		public const DEFAULT_VOLUME : Number = 50;
		public const AUTO : String = "Auto";
		//-1 unlimited
		public const DEFAULT_STARTING_BITRATE : Number = -1;
		public const DEFAULT_MAXIMUM_BITRATE : Number = -1;
		// *** Services ***
		public const DEFAULT_PLATFORM : String = Platforms.TWOGA;
		public const DEFAULT_MEDIA_PROVIDER : String = MediaProvider.VIDEO_MEDIA_PROVIDER;
		public const DEFAULT_TRACKING_MODE : String = TrackingModes.TWOGA;
		public const DEFAULT_AD_PROVIDER : String = AdProviders.LIVERAIL;
		// *** GENESIS ***
		//public const DEFAULT_GENESIS_ORIGIN : String = "vds_dyn";
		public const DEFAULT_LOGMODE : String = "r";
		public const DEFAULT_PLAYLIST_TITLE : String = "Playlist";
		public const DEFAULT_PCODE_VALUE : String = "p-_x2tnEw-0UsKn";
		public const DEFAULT_LR_CONTENT : String = "1";
		public const DEFAULT_LR_ADMAP : String = "in::0%;ov::10,25;in::100%";
	

		public function Config() {
			//
		}
	}
}