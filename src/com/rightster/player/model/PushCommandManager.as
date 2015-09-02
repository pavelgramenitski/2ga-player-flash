package com.rightster.player.model {
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.events.PushDataEvent;
	import com.rightster.player.events.ModelEvent;
	import com.rightster.player.media.NetStreamCodes;
	import com.rightster.player.media.NetConnectionCodes;
	import com.rightster.player.controller.IController;
	import com.rightster.utils.Log;
	
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.ObjectEncoding;
	import flash.events.NetStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.AsyncErrorEvent;	
	import flash.events.TimerEvent;
	import flash.events.ErrorEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;	
	
	/**
	 * @author Arun
	 */
	public class PushCommandManager {
		private const DEFAULT_CONNECTION 		: String = "rtmp://fml.232A.edgecastcdn.net/20232A/";
		private const MAX_SUBSCRIBE_RETRY 		: uint = 5;
		private const SUBSCRIBE_TIMER 			: Number = 1000;
		private const FC_SUBSCRIBE 				: String = "FCSubscribe";
		
		private var controller : IController;
		private var connection : NetConnection;
		private var stream : NetStream;
		private var streamUrl : String;
		private var subscribeRetry : uint;
		private var subscribeTimer : Timer;
		private var pubnubPushCommandManager : PushCommandManagerPubnub;
		
		public function PushCommandManager(controller : IController) : void {
			Log.write("PushCommandManager.constructor");
			this.controller = controller;
			
			controller.addEventListener(ModelEvent.VIDEO_DATA_COMPLETE, onVideoDataComplete);
			pubnubPushCommandManager = new PushCommandManagerPubnub(controller);
		}
		
		private function onVideoDataComplete(event : ModelEvent) : void {
			Log.write("PushCommandManager.onVideoDataComplete : " + controller.placement.livePlaylist);
			
			if (controller.placement.playlistVersion == 2 || controller.placement.livePlaylist) {				
				controller.addEventListener(MediaProviderEvent.CUE_POINT, cuePointHandler);
				
				pubnubPushCommandManager.connectControlStream();
				
				if (controller.placement.playlistVersion == 2) {
					connectControlStream();
				}
			}
		}
		
		private function connectControlStream() : void {
			Log.write("PushCommandManager.connectControlStream");
			subscribeRetry = 0;
			streamUrl = String(controller.placement.initialId).substr(0, 8);
		
			connection = new NetConnection();
			connection.objectEncoding = ObjectEncoding.DEFAULT;
			connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			connection.client = this;
							
			subscribeTimer = new Timer(SUBSCRIBE_TIMER, 1);
			subscribeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, callFCSubscribe);				
			
			connect();
		}
		
		private function connect(command : String = null) : void {
			Log.write("PushCommandManager.connect");
			
			if (connection && !connection.connected) {
				try {
					connection.connect(command != null ? command : DEFAULT_CONNECTION);
				}
				catch (e : Error) {
					error("Error loading stream: Could not connect to server");
				}
			}
		}
		
		private function setStream() : void {
			Log.write("PushCommandManager.setStream");
			
			stream = new NetStream(connection);
			stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			stream.client = this;
			stream.play(streamUrl);
		}
		
		private function netStatusHandler(event : NetStatusEvent) : void {
			Log.write("PushCommandManager.netStatusHandler * code : " + event.info.code);
			
			switch (event.info.code) {
				case NetConnectionCodes.CONNECT_SUCCESS: 
					callFCSubscribe();
					break;
				
				case NetConnectionCodes.CONNECT_CLOSED:
				case NetConnectionCodes.CONNECT_IDLETIMEOUT:
					connect();
					break;
				
				case NetConnectionCodes.CONNECT_REJECTED:
					if (event.info.ex.code == 302) {
						setTimeout(connect, 100, event.info.ex.redirect);
					}
					else {
						error("Error loading stream: connectio attempt did not have permission to access application");
					}
				case NetConnectionCodes.CONNECT_FAILED:
					error("Error loading stream: Could not connect to server");
					break;
					
				case NetConnectionCodes.CONNECT_INVALIDAPP:
					error("Error loading stream: application name specified during connect is invalid");
					break;
					
				case NetStreamCodes.SEEK_FAILED:
				case NetStreamCodes.FAILED:
				case NetStreamCodes.PLAY_STREAMNOTFOUND:
					error("Error loading stream: stream not found on server");
					break;
			}
		}
		
		private function callFCSubscribe() : void {
			Log.write("PushCommandManager.callFCSubscribe");
			
			if (++subscribeRetry <= MAX_SUBSCRIBE_RETRY) {
				connection.call(FC_SUBSCRIBE, null, streamUrl);
			}
			else {
				error("stream not found");
			}			
		}
		
		private function errorHandler(event : ErrorEvent) : void {
			error(event.text);
		}
		
		private function error(msg : String) : void {
			Log.write("PushCommandManager.error : " + msg , Log.ERROR);
		}
		
		private function handleCommands(command : String, data : Object = null) : void {
			Log.write("PushCommandManager.handleCommands * command : " + command);
			
			controller.dispatchEvent(new PushDataEvent(PushDataEvent.COMMAND_RECIEVED, command, data));
		}
		
		public function onFCSubscribe(... rest):void {
			var info : Object = rest[0];
			Log.write("PushCommandManager.onFCSubscribe * code : " + info.code + ", description : " + info.description);
			
			switch(info.code)
			{
				case NetStreamCodes.PLAY_START:
					setStream();
					break;
				case NetStreamCodes.PLAY_STREAMNOTFOUND:
					subscribeTimer.start();
					break;
			}
		}
		
		public function pushData(cmd : String, data : Object) : void {
			Log.write("PushCommandManager.dataHandler * command : " + cmd + ", data : " + data.toString());
			
			var newData : Object = new Object();
			
			if (cmd == PushCommands.UPDATE_TIME) {
				var dataArr : Array = data.data.split("#");
				newData["index"] = dataArr[0];
				newData["starttime"] = dataArr[1];
				newData["endtime"] = dataArr[2];
			}
			else {
				newData = data;
			}
			
			handleCommands(cmd, newData);
		}
		
		private function cuePointHandler(event : MediaProviderEvent) : void {			
			Log.write("PushCommandManager.cuePointHandler * name=" + event.data.name);
			
			handleCommands(event.data.name, event.data.parameters);
		}
	}
}