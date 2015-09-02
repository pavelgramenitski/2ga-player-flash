package com.rightster.player.view {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.model.PushCommands;
	import com.rightster.utils.Log;

	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * @author daniel.sedlacek
	 */
	public class ContextMenuManager{
		
		public static const NAME : String = "context_menu";
		
		private static const PLAYER_VERSION_LABEL : String = "Rightster player ";
		
		private var controller      : IController;
		private var menu            : ContextMenu;
		private var versionMenuItem : ContextMenuItem;
		private var helpButton : ContextMenuItem;

		public function ContextMenuManager(controller : IController, container : Sprite) {
			this.controller = controller;
			
			menu = new ContextMenu();
			menu.hideBuiltInItems();
			
            versionMenuItem = new ContextMenuItem(PLAYER_VERSION_LABEL + controller.version);
            menu.customItems.push(versionMenuItem);
			
            helpButton = new ContextMenuItem("Push Ad");
			helpButton.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pushAd);
           // menu.customItems.push(helpButton);
			
			container.contextMenu = menu;
		}

		private function pushAd(event : ContextMenuEvent) : void {
			Log.write("ContextMenuManager.pushAd");
			controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.CUE_POINT, {name:PushCommands.AD_BREAK}));
		}
	}
}
