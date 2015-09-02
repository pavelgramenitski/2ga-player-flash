package com.rightster.player.skin {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;

	/**
	 * @author KJR
	 */
	public class TextureAtlas {
		private static const  packageName : String = "com.rightster.player.skin.";
		private static const suffix : String = "Class";
		/*
		 * PlayPauseReplay - small multistate button
		 */
		// play icon
		public static const PlayIcon : String = "PlayIcon";
		public static const PlayIconSmall : String = "PlayIconSmall";
		public static const PlayIconLarge : String = "PlayIconLarge";
		[Embed(source="/assets/play_icon.svg", mimeType="image/svg")]
		private static const PlayIconClass : Class;
		registerAlias("PlayIconClass", PlayIconClass);
		// pause icon
		public static const PauseIcon : String = "PauseIcon";
		public static const PauseIconSmall : String = "PauseIconSmall";
		public static const PauseIconLarge : String = "PauseIconLarge";
		[Embed(source="/assets/pause_icon.svg", mimeType="image/svg")]
		private static const PauseIconClass : Class;
		registerAlias("PauseIconClass", PauseIconClass);
		// replay icon
		public static const ReplayIcon : String = "ReplayIcon";
		public static const ReplayIconSmall : String = "ReplayIconSmall";
		public static const ReplayIconLarge : String = "ReplayIconLarge";
		[Embed(source="/assets/replay_icon.svg", mimeType="image/svg")]
		private static const ReplayIconClass : Class;
		registerAlias("ReplayIconClass", ReplayIconClass);
		/*
		 * Fullscreen - small multistate button
		 */
		// fullscreen enter icon
		public static const FullScreenEnterIcon : String = "FullScreenEnterIcon";
		[Embed(source="/assets/fullscreen_enter_icon.svg", mimeType="image/svg")]
		private static const FullScreenEnterIconClass : Class;
		registerAlias("FullScreenEnterIconClass", FullScreenEnterIconClass);
		// fullscreen exit icon
		public static const FullScreenExitIcon : String = "FullScreenExitIcon";
		[Embed(source="/assets/fullscreen_exit_icon.svg", mimeType="image/svg")]
		private static const FullScreenExitIconClass : Class;
		registerAlias("FullScreenExitIconClass", FullScreenExitIconClass);
		/*
		 * Quality - control
		 */
		// quality icon
		public static const QualityIcon : String = "QualityIcon";
		[Embed(source="/assets/quality_icon.svg", mimeType="image/svg")]
		private static const QualityIconClass : Class;
		registerAlias("QualityIconClass", QualityIconClass);
		/*
		 * Volume - controls
		 */
		// volume icon on - standard
		public static const VolumeSpeakerIcon : String = "VolumeSpeakerIcon";
		[Embed(source="/assets/volume_speaker_icon.svg", mimeType="image/svg")]
		private static const VolumeSpeakerIconClass : Class;
		registerAlias("VolumeSpeakerIconClass", VolumeSpeakerIconClass);
		// volume icon on - for adverts
		public static const VolumeSpeakerAdvertOnIcon : String = "VolumeSpeakerAdvertOnIcon";
		[Embed(source="/assets/volume_speaker_icon_advert_on.svg", mimeType="image/svg")]
		private static const VolumeSpeakerAdvertOnIconClass : Class;
		registerAlias("VolumeSpeakerAdvertOnIconClass", VolumeSpeakerAdvertOnIconClass);
		// volume icon muted - for adverts
		public static const VolumeSpeakerAdvertMutedIcon : String = "VolumeSpeakerAdvertMutedIcon";
		[Embed(source="/assets/volume_speaker_icon_advert_muted.svg", mimeType="image/svg")]
		private static const VolumeSpeakerAdvertMutedIconClass : Class;
		registerAlias("VolumeSpeakerAdvertMutedIconClass", VolumeSpeakerAdvertMutedIconClass);
		/*
		 * Skip - button
		 */
		// skip icon on - standard
		public static const SkipIcon : String = "SkipIcon";
		[Embed(source="/assets/skip_icon.svg", mimeType="image/svg")]
		private static const SkipIconClass : Class;
		registerAlias("SkipIconClass", SkipIconClass);
		/*
		 * Social sharing
		 */
		// email icon - standard
		public static const EmailIcon : String = "EmailIcon";
		[Embed(source="/assets/email_icon.svg", mimeType="image/svg")]
		private static const EmailIconClass : Class;
		registerAlias("EmailIconClass", EmailIconClass);
		// embed icon - standard
		public static const EmbedIcon : String = "EmbedIcon";
		[Embed(source="/assets/embed_icon.svg", mimeType="image/svg")]
		private static const EmbedIconClass : Class;
		registerAlias("EmbedIconClass", EmbedIconClass);
		// social icon - standard
		public static const SocialIcon : String = "SocialIcon";
		[Embed(source="/assets/social_icon.svg", mimeType="image/svg")]
		private static const SocialIconClass : Class;
		registerAlias("SocialIconClass", SocialIconClass);
		// readmore icon - standard
		public static const PermalinkIcon : String = "PermalinkIcon";
		[Embed(source="/assets/permalink_icon.svg", mimeType="image/svg")]
		private static const PermalinkIconClass : Class;
		registerAlias("PermalinkIconClass", PermalinkIconClass);
		// facebook icon - standard
		public static const FacebookIcon : String = "FacebookIcon";
		[Embed(source="/assets/facebook_icon.svg", mimeType="image/svg")]
		private static const FacebookIconClass : Class;
		registerAlias("FacebookIconClass", FacebookIconClass);
		// gplus icon - standard
		public static const GplusIcon : String = "GplusIcon";
		[Embed(source="/assets/gplus_icon.svg", mimeType="image/svg")]
		private static const GplusIconClass : Class;
		registerAlias("GplusIconClass", GplusIconClass);
		// twitter icon - standard
		public static const TwitterIcon : String = "TwitterIcon";
		[Embed(source="/assets/twitter_icon.svg", mimeType="image/svg")]
		private static const TwitterIconClass : Class;
		registerAlias("TwitterIconClass", TwitterIconClass);
		/*
		 * PlaylistBar
		 */
		public static const PlaylistBarNavigationIcon : String = "PlaylistBarNavigationIcon";
		[Embed(source="/assets/playlistbar_navigation_icon.svg", mimeType="image/svg")]
		private static const PlaylistBarNavigationIconClass : Class;
		registerAlias("PlaylistBarNavigationIconClass", PlaylistBarNavigationIconClass);
		public static const PlaylistIcon : String = "PlaylistIcon";
		[Embed(source="/assets/playlist_icon.svg", mimeType="image/svg")]
		private static const PlaylistIconClass : Class;
		registerAlias("PlaylistIconClass", PlaylistIconClass);
		public static const PlaylistLoopIcon : String = "PlaylistLoopIcon";
		[Embed(source="/assets/playlist_loop_icon.svg", mimeType="image/svg")]
		private static const PlaylistLoopIconClass : Class;
		registerAlias("PlaylistLoopIconClass", PlaylistLoopIconClass);
		public static const PlaylistLoopVideoIcon : String = "PlaylistLoopVideoIcon";
		[Embed(source="/assets/playlist_loop_video_icon.svg", mimeType="image/svg")]
		private static const PlaylistLoopVideoIconClass : Class;
		registerAlias("PlaylistLoopVideoIconClass", PlaylistLoopVideoIconClass);
		/*
		 * PlaylistView
		 */
		public static const PlayAllButtonBackground : String = "PlayAllButtonBackground";
		[Embed(source="/assets/play_all_btn_bg.svg", mimeType="image/svg")]
		private static const PlayAllButtonBackgroundClass : Class;
		registerAlias("PlayAllButtonBackgroundClass", PlayAllButtonBackgroundClass);
		public static const PlaylistNavigationIcon : String = "PlaylistNavigationIcon";
		[Embed(source="/assets/playlist_navigation_icon.svg", mimeType="image/svg")]
		private static const PlaylistNavigationIconClass : Class;
		registerAlias("PlaylistNavigationIconClass", PlaylistNavigationIconClass);
		/*
		 * Generic
		 */
		// close icon
		public static const CloseIcon : String = "CloseIcon";
		[Embed(source="/assets/close_icon.svg", mimeType="image/svg")]
		private static const CloseIconClass : Class;
		registerAlias("CloseIconClass", CloseIconClass);
		// tick icon
		public static const TickIcon : String = "TickIcon";
		[Embed(source="/assets/tick_icon.svg", mimeType="image/svg")]
		private static const TickIconClass : Class;
		registerAlias("TickIconClass", TickIconClass);
		/*
		 * PUBLIC METHODS
		 * 
		 */
		public static function getBitmapTextureByName(name : String, clone : Boolean = false) : Bitmap {
			var bitmapData : BitmapData = getBitmapDataByClassName(name);
			var bitmap : Bitmap = (clone) ? new Bitmap(bitmapData.clone()) : new Bitmap(bitmapData);
			return bitmap;
		}

		public static function getNewTextureClassByName(name : String) : Class {
			var ClassReference : Class = getClassByAlias(packageName + name + suffix) as Class;
			return ClassReference;
		}

		public static function getTextureClassDimensionsByName(name : String) : Rectangle {
			var dimensions : Rectangle = getDimensionsByName(name);
			return dimensions;
		}

		/*
		 * PRIVATE METHODS
		 * 
		 */
		private static function getBitmapDataByClassName(name : String) : BitmapData {
			var ClassReference : Class = getClassByAlias(packageName + name + suffix) as Class;
			var bitmapData : BitmapData = (new ClassReference() as Bitmap).bitmapData;
			return bitmapData;
		}

		private static function registerAlias(name : String, targetClass : Class) : void {
			registerClassAlias("com.rightster.player.skin." + name, targetClass);
		}

		private static function getDimensionsByName(name : String) : Rectangle {
			var rect : Rectangle = new Rectangle();
			switch(name) {
				case QualityIcon:
					rect.width = rect.height = 15;
					break;
				case FacebookIcon:
					rect.width = rect.height = 18;
					break;
				case TwitterIcon:
					rect.width = 21;
					rect.height = 17;
					break;
				case SocialIcon:
					rect.width = 14;
					rect.height = 15;
					break;
				case VolumeSpeakerIcon:
					rect.width = 8;
					rect.height = 13;
					break;
				case VolumeSpeakerAdvertOnIcon:
				case VolumeSpeakerAdvertMutedIcon:
					rect.width = 13;
					rect.height = 13;
					break;
				case PlayIconSmall:
					rect.width = 13;
					rect.height = 15;
					break;
				case PlayIconLarge:
					rect.width = 30;
					rect.height = 34;
					break;
				case PauseIconSmall:
					rect.width = 12;
					rect.height = 15;
					break;
				case PauseIconLarge:
					rect.width = 29;
					rect.height = 34;
					break;
				case ReplayIconSmall:
					rect.width = 15;
					rect.height = 15;
					break;
				case ReplayIconLarge:
					rect.width = 33;
					rect.height = 33;
					break;
				case SkipIcon:
					rect.width = 12;
					rect.height = 11;
					break;
				case CloseIcon:
					rect.width = 16;
					rect.height = 16;
					break;
				case TickIcon:
					rect.width = 11;
					rect.height = 11;
					break;
				case EmailIcon:
					rect.width = 22;
					rect.height = 15;
					break;
				case GplusIcon:
					rect.width = 17;
					rect.height = 17;
					break;
				case EmbedIcon:
					rect.width = 24;
					rect.height = 12;
					break;
				case PermalinkIcon:
					rect.width = 18;
					rect.height = 18;
					break;
				case FullScreenEnterIcon:
				case FullScreenExitIcon:
					rect.width = 19;
					rect.height = 15;
					break;
				case PlaylistIcon:
					rect.width = 15;
					rect.height = 12;
					break;
				case PlaylistLoopIcon:
				case PlaylistLoopVideoIcon:
					rect.width = 15;
					rect.height = 15;
					break;
				case PlayAllButtonBackground:
					rect.width = 66;
					rect.height = 24;
					break;
				case PlaylistBarNavigationIcon:
					rect.width = 7;
					rect.height = 10;
					break;
				case PlaylistNavigationIcon:
					rect.width = 18;
					rect.height = 26;
					break;
			}

			return rect;
		}
	}
}
