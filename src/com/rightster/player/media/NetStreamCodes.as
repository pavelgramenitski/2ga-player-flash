package com.rightster.player.media {
	/**
	 * @author Arun
	 */
	public class NetStreamCodes {
		/* "status"	data is not being received quickly enough to fill the buffer. */
		public static const BUFFER_EMPTY					: String = "NetStream.Buffer.Empty";
		
		/* "status"	buffer is full and the stream will begin playing. */
		public static const BUFFER_FULL						: String = "NetStream.Buffer.Full";
		
		/* "status"	data has finished streaming, and the remaining buffer will be emptied. */
		public static const BUFFER_FLUSH					: String = "NetStream.Buffer.Flush";
		
		/* "error" Flash Media Server only. An error has occurred for a reason other than those listed in other event codes. */
		public static const FAILED							: String = "NetStream.Failed";
		
		/* "status"	Playback has started. */
		public static const PLAY_START 						: String = "NetStream.Play.Start";
		
		/* "status"	Playback has stopped.*/
		public static const PLAY_STOP 						: String = "NetStream.Play.Stop";
		
		/** "error"	An error has occurred in playback for a reason 
		 * other than those listed elsewhere in class, such as the subscriber not having read access. */
		public static const PLAY_FAILED						: String = "NetStream.Play.Failed";
		
		/* "error" The FLV passed to the play() method can't be found. */
		public static const PLAY_STREAMNOTFOUND				: String = "NetStream.Play.StreamNotFound";
		
		/* "status"	Caused by a play list reset.*/
		public static const PLAY_RESET						: String = "NetStream.Play.Reset";
		
		/* "warning"	
		 * Flash Media Server only. The client does not have sufficient bandwidth to play the data at normal speed. */
		public static const PLAY_INSUFFICIENTBW				: String = "NetStream.Play.InsufficientBW";
		
		/* "error"	
		 * The application detects an invalid file structure and will not try to play this type of file.*/
		public static const PLAY_FILESTRUCTUREINVALID		: String = "NetStream.Play.FileStructureInvalid"; 
		
		/* "error"	
		 * The application does not detect any supported tracks (video, audio or data) and 
		 * will not try to play the file.*/
		public static const PLAY_NOSUPPORTEDTRACKFOUND		: String = "NetStream.Play.NoSupportedTrackFound";
		
		/* "status"	stream is paused.*/
		public static const PAUSE_NOTIFY					: String = "NetStream.Pause.Notify"; 
		
		/* "status"	The initial publish to a stream is sent to all subscribers. */
		public static const PLAY_PUBLISH_NOTIFY				: String = "NetStream.Play.PublishNotify";
		
		/* "status"	An unpublish from a stream is sent to all subscribers.*/
		public static const PLAY_UNPUBLISH_NOTIFY			: String = "NetStream.Play.UnpublishNotify"; 
		
		/* "status"	The stream is resumed. */
		public static const UNPAUSE_NOTIFY		: String = "NetStream.Unpause.Notify";
		
		/* "error" The seek fails, which happens if the stream is not seekable. */
		public static const SEEK_FAILED						: String = "NetStream.Seek.Failed";
		
		/* "error"	For video downloaded with progressive download */
		public static const SEEK_INVALIDTIME				: String = "NetStream.Seek.InvalidTime";
		
		/* "status"	The seek operation is complete.*/
		public static const SEEK_NOTIFY						: String = "NetStream.Seek.Notify"; 
		
		/* "status"	Playback has completed. Fires only for streaming connections.*/
		public static const PLAY_COMPLETE					: String = "NetStream.Play.Complete"; 
		
		/* "status"	The seek operation is started.*/
		public static const SEEK_START						: String = "NetStream.Seek.Start"; 
	}
}
