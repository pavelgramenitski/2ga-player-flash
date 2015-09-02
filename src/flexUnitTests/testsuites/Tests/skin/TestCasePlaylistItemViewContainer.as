package flexUnitTests.testsuites.Tests.skin {
	import org.fluint.uiImpersonation.UIImpersonator;
	import org.hamcrest.object.hasPropertyWithValue;

	import com.rightster.player.skin.PlaylistItemViewContainer;

	import org.hamcrest.object.equalTo;

	import flash.events.MouseEvent;

	import mockolate.stub;

	import com.rightster.player.view.BaseColors;
	import com.rightster.player.skin.PlaylistItem;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.notNullValue;

	import com.rightster.player.controller.IController;

	import mockolate.runner.MockolateRule;

	public class TestCasePlaylistItemViewContainer {
		private const PADDING : Number = 83;
		
		
		[Rule]
		public var mockRule : MockolateRule = new MockolateRule();
		[Mock]
		public var mockController : IController;
		public var fixtureToTest : PlaylistItemViewContainer;
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
			fixtureToTest = new PlaylistItemViewContainer(mockController);
		}

		[After]
		public function tearDown() : void {
			fixtureToTest = null;
			colors = null;
		}

		[Test]
		public function test_mockController_should_not_be_null() : void {
			assertThat(mockController, notNullValue());
		}

		[Test]
		public function test_constructor_createsChildren() : void {
			var expectedNumber : int = 3;
			assertThat(fixtureToTest, hasPropertyWithValue("numChildren", expectedNumber));
		}
		
		[Ignore]
		[Test]
		public function test_determine_numCols() : void {
			//var expectedNumber : int = 3;
			//assertThat(fixtureToTest, hasPropertyWithValue("numChildren", expectedNumber));
			UIImpersonator.addChild(fixtureToTest);
			fixtureToTest.width = 800;
			fixtureToTest.height = 400;
			fixtureToTest.show();
			
			trace('fixtureToTest.numColumns');
			trace(fixtureToTest.numColumns);
			
		}
		
		
		

		private function  setUpMocks() : void {
			// stubs
			stub(mockController).getter("colors").returns(colors);
			stub(mockController).method("getPlaylist").returns(colors);
			stub(mockController).method("error").throws(new Error("Mock Controller Error Method Invoked"));
		}
	}
}
