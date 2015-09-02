package flexUnitTests.testsuites.Tests.skin {
	import org.hamcrest.object.equalTo;
	import flash.events.MouseEvent;
	import mockolate.stub;

	import com.rightster.player.view.BaseColors;
	import com.rightster.player.skin.PlaylistItem;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.notNullValue;

	import com.rightster.player.controller.IController;

	import mockolate.runner.MockolateRule;

	public class TestCasePlaylistItem {
		[Rule]
		public var mockRule : MockolateRule = new MockolateRule();
		[Mock]
		public var mockController : IController;
		public var fixtureToTest : PlaylistItem;
		public var colors : BaseColors;

		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
			colors = new BaseColors();
			colors.initialize();
			setUpMocks();
			fixtureToTest = new PlaylistItem(mockController);
		}

		[After]
		public function tearDown() : void {
			fixtureToTest.dispose();
			fixtureToTest = null;
			colors = null;
		}

		[Test]
		public function test_mockController_should_not_be_null() : void {
			assertThat(mockController, notNullValue());
		}
		
		[Test]
		public function test_constructor_adds_eventListener_MouseEvent_CLICK() : void {
			assertThat(fixtureToTest.hasEventListener(MouseEvent.CLICK), equalTo(true));
		}
		
		[Test]
		public function test_constructor_adds_eventListener_MouseEvent_MOUSE_OVER() : void {
			assertThat(fixtureToTest.hasEventListener(MouseEvent.MOUSE_OVER), equalTo(true));
		}
		
		[Test]
		public function test_constructor_adds_eventListener_MouseEvent_MOUSE_OUT() : void {
			assertThat(fixtureToTest.hasEventListener(MouseEvent.MOUSE_OUT), equalTo(true));
		}
		
		[Test]
		public function test_dispose_removes_eventListener_MouseEvent_CLICK() : void {
			fixtureToTest.dispose();
			assertThat(fixtureToTest.hasEventListener(MouseEvent.CLICK), equalTo(false));
		}
		
		[Test]
		public function test_dispose_removes_eventListener_MouseEvent_MOUSE_OVER() : void {
			fixtureToTest.dispose();
			assertThat(fixtureToTest.hasEventListener(MouseEvent.MOUSE_OVER), equalTo(false));
		}
		
		[Test]
		public function test_dispose_removes_eventListener_MouseEvent_MOUSE_OUT() : void {
			fixtureToTest.dispose();
			assertThat(fixtureToTest.hasEventListener(MouseEvent.MOUSE_OUT), equalTo(false));
		}
		
		private function  setUpMocks() : void {
			// stubs
			stub(mockController).getter("colors").returns(colors);
			stub(mockController).method("error").throws(new Error("Mock Controller Error Method Invoked"));
		}
	}
}
