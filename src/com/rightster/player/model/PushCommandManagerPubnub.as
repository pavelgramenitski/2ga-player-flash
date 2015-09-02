package com.rightster.player.model {
	import com.rightster.player.events.PushDataEvent;
	import com.pubnub.PubNub;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.utils.Log;
	import com.rightster.player.controller.IController;
	/**
	 * @author Ravi Thapa
	 */
	public class PushCommandManagerPubnub {
		
		private var controller : IController;
		private var pubnub:PubNub;
		
		public function PushCommandManagerPubnub(controller : IController){
			Log.write("PushCommandManagerPubnub.constructor");
			this.controller = controller;
		}
		
		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // Receive Each Message
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
		private function message(message:Object, channel:String, timetoken:String, age:Number, data:*) : void {
			if(!message){
				Log.write("PushCommandManagerPubnub.message * push command Object is Null",Log.ERROR);
			}else{
				for(var i:String in message){
					/// In case for debugging push command Receive object 
					Log.write("PushCommandManagerPubnub.message * param name:- " + i + " param value:- " + message[i] ,Log.SYSTEM);
				}
				Log.write("PushCommandManagerPubnub.message * Receive Message Success",Log.SYSTEM);
				controller.dispatchEvent(new PushDataEvent(PushDataEvent.COMMAND_RECIEVED, String(message.command), message));
			}
			
		}
		
		public function connectControlStream() : void {
			// Setup
            pubnub = new PubNub( {
				subscribe_key : controller.placement.pubNubSubscribeID,              ///subscribe_key : "sub-c-e2fa8856-21eb-11e4-885e-02ee2ddab7fe",              // Subscribe Key
			    drift_check   : 60000,               // Re-calculate Time Drift (ms)
			    ssl           : false,               // SSL ?
			    message       : message,             // onMessage Receive
			    idle          : idle,                // onPing Idle
			    connect       : connect,             // onConnect
			    reconnect     : reconnect,           // onReconnect
			    disconnect    : disconnect 
			});
			
			// Add Channels
            pubnub.subscribe({ channels : [ String(controller.placement.initialId).substr(0, 8), 'b', 'c' ] });
		}

		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // Handle each message
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
		private function handleCommands(command : String, data : Object = null) : void {
			Log.write("PushCommandManagerPubnub.handleCommands * command : " + command , Log.SYSTEM);
			controller.dispatchEvent(new PushDataEvent(PushDataEvent.COMMAND_RECIEVED, command, data));
		}
		
		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // Network Connection Established (Ready to Receive)
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private function connect():void {
            Log.write("PushCommandManagerPubnub.connect * connected ", Log.SYSTEM);
        }
		
		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // All Network Activity
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private function activity(url:String):void {
            Log.write("PushCommandManagerPubnub.activity * activity:-  " + url, Log.NET);
        }
		
		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // Network Timetoken (Good) Sent by PubNub Upstream
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private function idle(timetoken:String):void {
             Log.write("PushCommandManagerPubnub.idle * idle:-  " + timetoken, Log.SYSTEM);
        }
		
		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // Error Details
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private function error(reason:String):void {
            Log.write("PushCommandManagerPubnub.error * name= " + reason, Log.ERROR);
        }
		
		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // Disconnected (No Data)
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private function disconnect(event:Object):void {
            Log.write("PushCommandManagerPubnub.disconnect * DISCONNECTED!!!!!!!!!= " + event , Log.SYSTEM);
        }
		
		// =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        // Reconnected (And we are Back!)
        // =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        private function reconnect():void {
            Log.write("PushCommandManagerPubnub.reconnect * reconnected ",Log.SYSTEM);
        }
		
		private function cuePointHandler(event : MediaProviderEvent) : void {			
			Log.write("PushCommandManagerPubnub.cuePointHandler * name= " + event.data.name, Log.SYSTEM);
			handleCommands(event.data.name, event.data.parameters);
		}
	}
}
