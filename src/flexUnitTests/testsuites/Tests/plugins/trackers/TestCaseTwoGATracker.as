package flexUnitTests.testsuites.Tests.plugins.trackers {
	//import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.object.notNullValue;
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertTrue;

	import com.rightster.analytics.TwoGATracker;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.player.controller.IController;

	import mockolate.runner.MockolateRule;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class TestCaseTwoGATracker {
		public static var data : Array = [[{foo:"bar"}], [{foo:"saunders"}]];
		[Rule]
		public var mockRule : MockolateRule = new MockolateRule();
		[Mock]
		public var mockController : IController;
		private var fixtureToTest : TwoGATracker;

		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
			fixtureToTest = new TwoGATracker();
		}

		[After]
		public function tearDown() : void {
			fixtureToTest.dispose();
			fixtureToTest = null;
		}

		[Test]
		public function test_mockController_should_not_be_null() : void {
			assertThat(mockController, notNullValue());
		}

		/*
		 * PUBLIC API
		 * 
		 */
		[Test]
		public function test_constructor_sets_loaded() : void {
			assertTrue(fixtureToTest.loaded);
		}

		[Test]
		public function test_constructor_sets_zIndex() : void {
			assertEquals(fixtureToTest.zIndex, PluginZindex.NONE);
		}

		[Test]
		public function test_initialize_without_parameterized_data_should_succeed() : void {
			fixtureToTest.initialize(mockController, {});
			assertTrue(fixtureToTest.initialized);
		}

		[Test(dataProvider="data")]
		public function test_initialize_with_parameterized_data_should_succeed(obj : Object) : void {
			fixtureToTest.initialize(mockController, obj);
			assertTrue(fixtureToTest.initialized);
		}

		[Test]
		public function test_run_should_succeed_if_initialized() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.run({});
			assertTrue(fixtureToTest.initialized);
		}

		[Test(expects="Error")]
		public function test_run_expect_error_if_not_initialized() : void {
			fixtureToTest.run({});
		}

		[Test]
		public function test_close_should_succeed_if_initialized() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.close();
		}

		[Test]
		public function test_close_should_remain_initialized() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.close();
			assertTrue(fixtureToTest.initialized);
		}

		[Test(expects="Error")]
		public function test_close_expect_error_if_not_initialized() : void {
			fixtureToTest.close();
		}
		
		/*
		 * PRIVATE API
		 * 
		 */
	}
}
