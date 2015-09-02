package com.rightster.player.media {
	/**
	 * @author Arun
	 */
	public class NetConnectionCodes {
		/* "status" connection was closed successfully */ 
		public static const CONNECT_CLOSED : String = "NetConnection.Connect.Closed";
		
		/* "error" connection attempt failed */
		public static const CONNECT_FAILED : String = "NetConnection.Connect.Failed";
		
		/* "status" connection attempt succeded */
		public static const CONNECT_SUCCESS : String = "NetConnection.Connect.Success";
		
		/* "error" connection attempt did not have permission to access application */
		public static const CONNECT_REJECTED : String = "NetConnection.Connect.Rejected";
		
		/* "error" application name specified during conect is invalid */
		public static const CONNECT_INVALIDAPP : String = "NetConnection.Connect.InvalidApp";
		
		/* "error" connection has been idle for too long */
		public static const CONNECT_IDLETIMEOUT : String = "NetConnection.Connect.IdleTimeOut";
	}
}
