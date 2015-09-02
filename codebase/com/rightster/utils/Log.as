package com.rightster.utils {
	import flash.utils.getTimer;
	import net.hires.debug.Stats;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 	@author Daniel Sedlacek
	  	Copyright (C) 2009 wikiBudgets
		
		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
	 */
	public class Log extends Sprite {
		
		public static const BAR_SIZE : Number = 20;
		public static const NET : String = "log_net";
		public static const TRACKING : String = "log_tracking";
		public static const DATA : String = "log_data";
		public static const ERROR : String = "log_error";
		public static const NORMAL : String = "log_normal";
		public static const SYSTEM : String = "log_system";
		
		// if true dupicates all logs to native trace() method.
		public static var verbatim : Boolean = true;
		
		private static const REVEAL_COMBINATION : String = 'LOG';
		private static const FONT : String = 'Verdana';
		private static const NORMAL_COLOR : Number = 0x3333cc;
		private static const DATA_COLOR : Number = 0x666666;
		private static const NET_COLOR : Number = 0x33cc33;
		private static const TRACKING_COLOR : Number = 0xcc33cc;
		private static const ERROR_COLOR : Number = 0xff0000;
		private static const SYSTEM_COLOR : Number = 0xcc9900;
		private static const ABOUT : String = "Log console * ver: 2.0\n";
		
		private static var instance : Log;
		private static var container : Sprite;
		private static var logTxt : TextField;
		private static var backup : Array;
		private static var stats : Stats;
		private static var resizeBar : Sprite;
		private static var resizing : Boolean;
		private static var dragBar : Sprite;
		private static var draging : Boolean;
		private static var minBar : Sprite;
		private static var minimised : Boolean;
		
		private var _x : Number;
		private var _y : Number;		
		private var keyString : String = "";

		override public function set width(n : Number) : void {
		}

		override public function set height(n : Number) : void {
		}
		
		public static function resetTime() : void {
			//
		}
		
		public static function time(s : String) : void {
			//
		}

		public function minimise() : void {
			logTxt.visible = false;
			resizeBar.visible = false;
			stats.visible = false;
		}

		public function maximise() : void {
			logTxt.visible = true;
			resizeBar.visible = true;
			stats.visible = true;
		}

		public function resize(w : Number, h : Number) : void {
			dragBar.width = w;
			minBar.x = w - minBar.width;
			logTxt.width = w;
			logTxt.height = h - dragBar.height;
			resizeBar.x = w - resizeBar.width;
			resizeBar.y = h - resizeBar.height;
			
			stats.x = w - stats.width - 5;
			stats.y = dragBar.height + 5;
		}

		public static function exportLog() : Array {
			return backup;
		}

		public static function importLog(a : Array) : void {
			for (var i : int = 0; i < a.length; i++) {
				Log.write.apply(instance, a[i]);
			}
		}
		
		public static function getInstance() : Log {
			if (instance == null) instance = new Log(new PrivateConstructorEnforcer());
			return instance;
		}

		public function Log(enforcer : PrivateConstructorEnforcer) {
			enforcer;

			instance = this;
			backup = [];
			
			container = new Sprite();
			addChild(container);
			container.filters = [new DropShadowFilter(1)];

			var format : TextFormat = new TextFormat();
			format.size = 9;
			format.color = NORMAL_COLOR;
			format.font = FONT;

			dragBar = new Sprite();
			with (dragBar.graphics) {
				beginFill(0xDDDDDD);
				drawRect(0, 0, BAR_SIZE, BAR_SIZE);
			}
			container.addChild(dragBar);

			minBar = new Sprite();
			with (minBar.graphics) {
				beginFill(0xBBBBBB);
				drawRect(0, 0, BAR_SIZE, BAR_SIZE);
			}
			container.addChild(minBar);
			
			logTxt = new TextField();
			logTxt.embedFonts = false;
			logTxt.multiline = true;
			logTxt.wordWrap = true;

			logTxt.background = true;
			logTxt.selectable = true;
			logTxt.mouseWheelEnabled = true;
			logTxt.defaultTextFormat = format;
			logTxt.text = ABOUT;
			logTxt.y = dragBar.height;
			container.addChild(logTxt);	
			
			stats = new Stats();
			container.addChild(stats);		

			resizeBar = new Sprite();
			with (resizeBar.graphics) {
				beginFill(0xDDDDDD);
				drawRect(0, 0, BAR_SIZE, BAR_SIZE);
			}
			container.addChild(resizeBar);
			
			minBar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownMinimise);
			resizeBar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownResize);
			dragBar.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownDrag);
			this.addEventListener(Event.ADDED_TO_STAGE, stageInit);
			this.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			this.visible = false;
		}

		private function mouseDownMinimise(event : MouseEvent) : void {
			minimised = !minimised;
			if (minimised) minimise();
			else maximise();
		}

		private function stageInit(e : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, stageInit);
			try {
				stage.addEventListener(KeyboardEvent.KEY_DOWN, toggleLog);
				stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			} catch (error : Error) {
				write('Log.stageInit * ERROR: ' + error);
			}
		}

		public static function write(...args) : void {
			if (instance == null) instance = new Log(new PrivateConstructorEnforcer());
			
			backup.push(args);
			
			var format : TextFormat = new TextFormat();
			var arg : String = args.shift();
			arg =  '[' + getTimer() + '] ' + arg;
			args.unshift(arg);
			var lastArg : Object = args.pop();
			var beginIndex : int = logTxt.text.length;
			switch (lastArg) {
				case NET :
					format.color = NET_COLOR;
					break;
				case TRACKING :
					format.color = TRACKING_COLOR;
					break;
				case DATA :
					format.color = DATA_COLOR;
					break;
				case ERROR :
					format.color = ERROR_COLOR;
					break;
				case SYSTEM :
					format.color = SYSTEM_COLOR;
					break;
				case NORMAL:
					format.color = NORMAL_COLOR;
					break;
				default :
					format.color = NORMAL_COLOR;
					args.push(lastArg);
					break;
			}

			logTxt.appendText(args + '\n');
			logTxt.setTextFormat(format, beginIndex, logTxt.text.length - 1);
			logTxt.scrollV = logTxt.maxScrollV;

			if (verbatim) trace(args);
			
		}

		private function toggleLog(keyboardEvent : KeyboardEvent) : void {
			if (keyString.length > 2) keyString = keyString.substr(1, 2);
			keyString = keyString + String.fromCharCode(keyboardEvent.keyCode);

			if (keyString == REVEAL_COMBINATION) {
				trace('\nLog.toggleLog * parent: ' + this.parent.parent + '\n');
				if (!this.visible) maximise();
				this.visible = !this.visible;
			}
		}

		private function mouseMove(event : MouseEvent) : void {
			if (draging) {
				this.x = parent.mouseX - _x;
				this.y = parent.mouseY - _y;
				event.stopPropagation();
			} else if (resizing) {
				resize(this.mouseX + _x, this.mouseY + _y);
				event.stopPropagation();
			}
		}

		private function mouseUp(event : MouseEvent) : void {
			draging = false;
			resizing = false;
		}

		private function mouseDownDrag(event : MouseEvent) : void {
			_x = this.mouseX;
			_y = this.mouseY;
			draging = true;
			event.stopPropagation();
		}

		private function mouseDownResize(event : MouseEvent) : void {
			_x = resizeBar.mouseX;
			_y = resizeBar.mouseY;
			resizing = true;
			event.stopPropagation();
		}

		private function onMouseWheel(event : MouseEvent) : void {
			event.stopPropagation();
		}
	}
}
internal class PrivateConstructorEnforcer {
}
