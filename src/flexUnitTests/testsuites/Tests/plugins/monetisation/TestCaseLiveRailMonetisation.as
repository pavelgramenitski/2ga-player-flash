package flexUnitTests.testsuites.Tests.plugins.monetisation {
	import com.rightster.player.model.RLoader;

	import mockolate.nice;

	import com.rightster.player.platform.Platforms;
	import com.rightster.player.liveRail.LiveRailMonetisation;

	import org.flexunit.Assert;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.model.Config;
	import com.rightster.player.model.MetaPlacement;
	import com.rightster.player.model.MetaQuality;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;

	import org.flexunit.async.Async;
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.object.notNullValue;

	import flash.events.Event;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class TestCaseLiveRailMonetisation {
		public static var data : Array = [[{foo:"bar"}], [{foo:"saunders"}]];
		public var mockFixture : LiveRailMonetisation;
		public var metaQuality : MetaQuality;
		public var metaStream : MetaStream;
		private static const ASYNC_TIMEOUT : int = 2000;
		private var fixtureToTest : LiveRailMonetisation;
		private var config : Config;
		private var eventDidDispatch : Boolean;
		private var eventType : String;
		private var timer : Timer;
		[Rule]
		public var mockRule : MockolateRule = new MockolateRule();
		[Mock]
		public var mockController : IController;
		[Mock(inject="false")]
		public var mockPlacement : MetaPlacement;
		[Mock(inject="false")]
		public var mockVideo : MetaVideo;

		[Mock(inject="false")]
		
		
		
		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
			timer = new Timer(ASYNC_TIMEOUT, 1);
			config = new Config();
			setUpMocks();
			fixtureToTest = new LiveRailMonetisation();
		}

		[After]
		public function tearDown() : void {
			if (timer) {
				timer.stop();
			}
			timer = null;

			if (eventType) {
				unregisterEventListener(eventType);
			}
			eventDidDispatch = false;

			fixtureToTest.dispose();
			fixtureToTest = null;
			tearDownMocks();
		}

		[Test]
		public function test_mockController_should_not_be_null() : void {
			assertThat(mockController, notNullValue());
		}

		/*
		 * PUBLIC GENERIC PLUGIN API
		 * 
		 */
		[Test]
		public function test_constructor_sets_loaded() : void {
			assertTrue(fixtureToTest.loaded);
		}

		[Test]
		public function test_constructor_sets_zIndex() : void {
			assertEquals(fixtureToTest.zIndex, PluginZindex.BELOW_CHROME);
		}

		[Test(async, description="Async test to verify that initialization occurs with parameterized data")]
		public function test_async_initialize_with_parameterized_data_should_succeed() : void {
			var passThroughData : Object = {};
			fixtureToTest.initialize(mockController, getLRTestDataObject());
			passThroughData.propertyName = "initialized";
			passThroughData.expectedValue = true;

			var asyncHandler : Function = Async.asyncHandler(this, handleAsyncTimerComplete, ASYNC_TIMEOUT, passThroughData, handleAsyncTimeout);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}

		[Test(async, description="Async test to verify that initialization occurs without parameterized data")]
		public function test_async_initialize_without_parameterized_data_should_succeed() : void {
			var passThroughData : Object = {};
			fixtureToTest.initialize(mockController, {});
			passThroughData.propertyName = "initialized";
			passThroughData.expectedValue = true;

			var asyncHandler : Function = Async.asyncHandler(this, handleAsyncTimerComplete, ASYNC_TIMEOUT, passThroughData, handleAsyncTimeout);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}

		[Test(async, description="Async test to verify that initialization occurs without parameterized data")]
		public function test_async_run_should_succeeed_if_initialized() : void {
			var callback : Function = function() : void {
				fixtureToTest.run({});
				assertTrue(fixtureToTest.initialized);
			};
			fixtureToTest.initialize(mockController, {});

			var asyncHandler : Function = Async.asyncHandler(this, handleAsyncTimerCompleteWithCallback, ASYNC_TIMEOUT, callback, handleAsyncTimeoutWithCallback);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}

		[Test(expects="Error")]
		public function test_run_expect_error_if_not_initialized() : void {
			fixtureToTest.run({});
			assertFalse(fixtureToTest.initialized);
		}

		[Test]
		public function test_close_should_remain_initialized() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.close();
			assertTrue(fixtureToTest.initialized);
		}

		[Test(async, description="Async test to verify that initialization remains true after close")]
		public function test_async_close_should_remain_initialized() : void {
			var callback : Function = function() : void {
				fixtureToTest.close();
				assertTrue(fixtureToTest.initialized);
			};

			fixtureToTest.initialize(mockController, {});

			var asyncHandler : Function = Async.asyncHandler(this, handleAsyncTimerCompleteWithCallback, ASYNC_TIMEOUT, callback, handleAsyncTimeoutWithCallback);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}

		[Test(expects="Error")]
		public function test_close_expect_error_if_not_initialized() : void {
			fixtureToTest.close();
		}

		/*
		 * PUBLIC SPECIFIC API
		 * 
		 */
		/*
		 * PRIVATE API
		 * 
		 */
		/*	
		 * HELPER METHODS	
		 * 
		 */
		private function  setUpMocks() : void {
			// stubs
			stub(mockController).getter("config").returns(config);
			stub(mockController).method("error").throws(new Error("Mock Controller Error Method Invoked"));

			// placement
			mockPlacement = nice(MetaPlacement, "mockPlacement", [mockController]);
			mockPlacement.playlistVersion = 1;
			mockPlacement.forceHTTPS = false;
			mockPlacement.platform = Platforms.TWOGA;
			mockPlacement.pcodeValue = config.DEFAULT_PCODE_VALUE;
			stub(mockController).getter("placement").returns(mockPlacement);

			// loader
			stub(mockController).getter("loader").returns(new RLoader(mockController, mockPlacement.forceHTTPS));
		}

		private function tearDownMocks() : void {
			mockPlacement = null;
		}

		private function registerEventListener(type : String) : void {
			mockController.addEventListener(type, handleEventDispatched);
		}

		private function unregisterEventListener(type : String) : void {
			mockController.removeEventListener(type, handleEventDispatched);
		}

		private function handleEventDispatched(event : Event) : void {
			eventDidDispatch = true;
		}

		private function handleAsyncTimerCompleteWithCallback(event : TimerEvent, callback : Function) : void {
			callback.apply();
		}

		private function handleAsyncTimeoutWithCallback(callback : Function) : void {
			Assert.fail("handleAsyncTimeoutWithCallback");
		}

		private function handleAsyncTimerComplete(event : TimerEvent, passThroughData : Object) : void {
			var propertyName : String = passThroughData.propertyName;
			var expectedValue : * = passThroughData.expectedValue;
			var actualValue : * = fixtureToTest[propertyName];
			assertThat(actualValue, expectedValue);
		}

		private function handleAsyncTimeout(passThroughData : Object) : void {
			var propertyName : String = passThroughData.propertyName;
			var expectedValue : * = passThroughData.expectedValue;
			var actualValue : * = fixtureToTest[propertyName];
			Assert.fail("handleAsyncTimeout * expected: " + expectedValue + " * actual: " + actualValue);
		}

		private function getLRTestDataObject() : Object {
			var obj : Object = {LR_CONTENT:1, LR_DESCRIPTION:"Descrizion", LR_PARTNERS:"764812", LR_PUBLISHER_ID:77713, LR_TAGS:"acc_cp_new_non_rightster_account_1420443346,typ_vod,deal_6f90f79f-3d1c-4669-a235-a45fd181c0ca,pl_1e9529aa-f8d3-4657-acdf-002a1817e736,kw_mahak,lbl_cp_0c245e97-8635-40b1-a472-91daf11b0fe9,lbl_pub_0c245e97-8635-40b1-a472-91daf11b0fe9", LR_TITLE:"Test Video 02", LR_VERTICALS:"7-12 Education", LR_VIDEO_AMID:"8a4e17b1-a981-4f1e-affb-eb7c7a269618", LR_VIDEO_ID:"d3a459c4-15fa-452d-afe5-42cb2ea715e1"};
			return obj;
		}

//		private function getDevQuantcastObject() : Object {
//			var obj : Object = {pcode:"p-HwGPLc4uL3_8t"};
//			return obj;
//		}
	}
}
