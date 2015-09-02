package com.rightster.player.skin {
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.events.PlayerStateEvent;
	import flash.events.MouseEvent;
	import com.rightster.player.view.Colors;
	import flash.display.Sprite;
	import com.rightster.player.controller.IController;
	import flash.display.MovieClip;

	/**
	 * @author Rightster
	 */
	public class SocialMedia extends MovieClip {
		private static const BG_ASSET : String = "bg_mc";
		private static const BASE_WIDTH : Number = 44;
		private var controller : IController;
		private var bgAsset : Sprite;
		
		private var socialMediaHolder : Sprite;
		private var shareFB             : ShareFB;
		private var shareTwitter		: ShareTwitter;
		private var emailShare          : EmailShare;
		
		private var shareList          	: Array;
		private var _enabled : Boolean = false;
		
		public function SocialMedia(controller : IController) {
			this.controller = controller;
			
			_enabled = false;
			toggle();
			
			buttonMode = true;
			mouseChildren = true;
			
			bgAsset = this[BG_ASSET];
			
			setStyle();
			
			socialMediaHolder = new Sprite();
			
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			
			shareFB	= new ShareFB(controller);
			shareFB.visible = false;
			socialMediaHolder.addChild(shareFB);
			
			shareTwitter = new ShareTwitter(controller);
			shareTwitter.visible = false;
			socialMediaHolder.addChild(shareTwitter);
			
			emailShare = new EmailShare(controller);
			emailShare.visible = false;
			socialMediaHolder.addChild(emailShare);
			
			shareList = [];
			shareList.push(shareTwitter);
			shareList.push(shareFB);
			shareList.push(emailShare);
			
			this.addChild(socialMediaHolder);
		}
		
		private function stateChange(e : PlayerStateEvent = null) : void {
			if(controller != null){
				switch (controller.playerState) {
					case PlayerState.VIDEO_READY :
					default:
						_enabled = true;
						toggle();
					break;
				}
			}
		}
		
		private function toggle() : void {
			if (_enabled) {
				super.visible = true;
			} else {
				super.visible = false;
			}
		}
		
		public function positionShareIcons() : void {
			var height : Number = 0;
			for(var i:int=0; i< shareList.length; i++){
				shareList[i].y = i == 0 ? 0 : shareList[i-1].y + shareList[i-1].height;
				height = height + shareList[i].height;			
			}
			if(height <= 0){
				this.visible = false;
				this.width = 0;
			}else{
				this.visible = true;
				this.width = BASE_WIDTH;
			}
			socialMediaHolder.graphics.clear();
			socialMediaHolder.graphics.beginFill(0x2B2B2B,0.6);
			socialMediaHolder.graphics.drawRect(0, 0, BASE_WIDTH, height);
			socialMediaHolder.graphics.endFill();
			socialMediaHolder.y = -(height);
			socialMediaHolder.visible = false;
		}
		
		public function setShareListOnOff($flag : Boolean) : void {
			for(var i:int=0; i<shareList.length; i++){
				shareList[i].visible = $flag;
			}
		}
		
		private function setStyle() : void {
			bgAsset.transform.colorTransform = Colors.baseCT;	
			bgAsset.alpha = Colors.highlightOffAlpha;
		}
		
		private function overHandler(e : MouseEvent) : void {
			socialMediaHolder.visible = true;
			bgAsset.transform.colorTransform = Colors.highlightCT;	
			bgAsset.alpha = Colors.highlightAlpha;
		}

		private function outHandler(e : MouseEvent) : void {
			socialMediaHolder.visible = false;
			bgAsset.transform.colorTransform = Colors.baseCT;	
			bgAsset.alpha = Colors.highlightOffAlpha;
		}
		
		public function dispose() : void {		
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			for(var i:int=0; i<shareList.length; i++){
				shareList[i].dispose();
				shareList[i] = null;
			}
			
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			
			controller = null;
		}
		
		
		
	}
}
