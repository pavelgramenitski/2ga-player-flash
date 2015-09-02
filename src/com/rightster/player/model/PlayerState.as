package com.rightster.player.model {
	
	/**
	 * @author Daniel
	 */
	public class PlayerState {
		
		public static const PLAYER_BLOCKED		: int = -3;
		public static const PLAYER_ERROR		: int = -2;
		public static const PLAYER_UNSTARTED 	: int = -1;
		public static const PLAYER_BUFFERING 	: int = 0;
		public static const PLAYER_READY 		: int = 1;
		public static const VIDEO_READY 		: int = 2;
		public static const VIDEO_CUED 			: int = 3;
		public static const VIDEO_STARTED 		: int = 4;
		public static const VIDEO_PLAYING 		: int = 5;
		public static const VIDEO_PAUSED 		: int = 6;
		public static const VIDEO_ENDED 		: int = 7;
		public static const PLAYLIST_ENDED 		: int = 8;
		public static const AD_STARTED 			: int = 9;
		public static const AD_PLAYING 			: int = 10;
		public static const AD_PAUSED 			: int = 11;
		public static const AD_ENDED 			: int = 12;
	}
}