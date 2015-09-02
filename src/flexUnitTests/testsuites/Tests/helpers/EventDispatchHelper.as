package flexUnitTests.testsuites.Tests.helpers {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class EventDispatchHelper extends EventDispatcher {
		public var dispatchedEvent : Event;
		public var expectedType : String;

		public function EventDispatchHelper(target : IEventDispatcher = null) {
			super(target);
		}

		override public function dispatchEvent(event : Event) : Boolean {
			if ( expectedType == null || expectedType == event.type ) {
				dispatchedEvent = event;
			}
			return super.dispatchEvent(event);
		}
	}
}