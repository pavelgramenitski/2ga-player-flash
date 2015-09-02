package flexUnitTests.testsuites.Tests.plugins.mediaproviders {
	import org.flexunit.Assert;

	import flash.events.TimerEvent;
	import flash.utils.Timer;

	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.media.AkamaiLiveStream;
	import com.rightster.player.model.Config;
	import com.rightster.player.model.MetaPlacement;
	import com.rightster.player.model.MetaQuality;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.player.platform.Platforms;

	import org.flexunit.async.Async;
	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.object.notNullValue;

	import flash.events.Event;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class TestCaseAkamaiLiveStream {
		public static var data : Array = [[{foo:"bar"}], [{foo:"saunders"}]];
		public static const VALID_QUALITY : String = "standardHDS";
		public static const INVALID_QUALITY : String = "invalidQuality";
		public static const TEST_VIDEO_URI : String = "http://multiplatform-f.akamaihd.net/z/multi/april11/hdworld/hdworld_,512x288_450_b,640x360_700_b,768x432_1000_b,1024x576_1400_m,1280x720_1900_m,1280x720_2500_m,1280x720_3500_m,.mp4.csmil/manifest.f4m";
		public static const CDN_AKAMAI : String = "akamai";
		public var mockFixture : AkamaiLiveStream;
		public var metaQuality : MetaQuality;
		public var metaStream : MetaStream;
		private static const ASYNC_TIMEOUT : int = 2000;
		private var fixtureToTest : AkamaiLiveStream;
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
			fixtureToTest = new AkamaiLiveStream();
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

		[Test]
		public function test_mockPlacement_should_not_be_null() : void {
			assertThat(mockPlacement, notNullValue());
		}

		[Test]
		public function test_mockVideo_should_not_be_null() : void {
			assertThat(mockVideo, notNullValue());
		}

		/*
		 * PUBLIC GENERIC PLUGIN API
		 * 
		 */
		// [Ignore]
		[Test]
		public function test_constructor_sets_loaded() : void {
			assertTrue(fixtureToTest.loaded);
		}

		// [Ignore]
		[Test]
		public function test_constructor_sets_zIndex() : void {
			assertEquals(fixtureToTest.zIndex, PluginZindex.NONE);
		}

		// [Ignore]
		[Test]
		public function test_initialize_without_parameterized_data_should_succeed() : void {
			fixtureToTest.initialize(mockController, null);
			assertTrue(fixtureToTest.initialized);
		}

		// [Ignore]
		[Test]
		public function test_initialize_with_parameterized_data_should_succeed() : void {
			fixtureToTest.initialize(mockController, data);
			assertTrue(fixtureToTest.initialized);
		}

		// [Ignore]
		[Test]
		public function test_run_should_succeed_if_initialized() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.run({});
			assertTrue(fixtureToTest.initialized);
		}

		// [Ignore]
		[Test(expects="Error")]
		public function test_run_expect_error_if_not_initialized() : void {
			fixtureToTest.run({});
			assertFalse(fixtureToTest.initialized);
		}

		// [Ignore]
		[Test]
		public function test_close_should_succeed_if_initialized() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.close();
		}

		// [Ignore]
		[Test]
		public function test_close_should_not_remain_initialized() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.close();
			assertFalse(fixtureToTest.initialized);
		}

		// [Ignore]
		[Test(expects="Error")]
		public function test_close_expect_error_if_not_initialized() : void {
			fixtureToTest.close();
		}

		/*
		 * PUBLIC SPECIFIC API
		 * 
		 */
		// [Ignore]
		[Test]
		public function test_getVideoBytesLoaded_should_return_zero_if_no_netstream() : void {
			fixtureToTest.initialize(mockController, {});
			assertEquals(0, fixtureToTest.getVideoBytesLoaded());
		}

		// [Ignore]
		[Test]
		public function test_getVideoBytesTotal_should_return_zero_if_no_netstream() : void {
			fixtureToTest.initialize(mockController, {});
			assertEquals(0, fixtureToTest.getVideoBytesTotal());
		}

		// [Ignore]
		[Test]
		public function test_getVideoStartBytes_should_return_zero() : void {
			fixtureToTest.initialize(mockController, {});
			assertEquals(0, fixtureToTest.getVideoStartBytes());
		}

		// [Ignore]
		[Test(expects="Error")]
		public function test_setPlaybackQuality_expect_error_with_invalid_quality() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.setPlaybackQuality(INVALID_QUALITY);
		}

		// [Ignore]
		[Test]
		public function test_setPlaybackQuality_should_set_correct_value_with_valid_quality() : void {
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.setPlaybackQuality(VALID_QUALITY);
			assertEquals(VALID_QUALITY, fixtureToTest.getPlaybackQuality());
		}

		// [Ignore]
		[Test]
		public function test_setPlaybackQuality_should_dispatch_PlaybackQualityEvent_CHANGE() : void {
			stub(mockController).method("dispatchEvent").dispatches(new PlaybackQualityEvent(PlaybackQualityEvent.CHANGE));
			eventType = PlaybackQualityEvent.CHANGE;
			registerEventListener(eventType);
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.setPlaybackQuality(VALID_QUALITY);
			assertTrue(eventDidDispatch);
		}

		// [Ignore]
		[Test]
		public function test_playVideo_should_dispatch_MediaProviderEvent_PLAYING_if_PlayerState_VIDEO_PAUSED() : void {
			stub(mockController).getter("playerState").returns(PlayerState.VIDEO_PAUSED);
			stub(mockController).method("dispatchEvent").dispatches(new MediaProviderEvent(MediaProviderEvent.PLAYING));
			eventType = MediaProviderEvent.PLAYING;
			registerEventListener(eventType);
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.setPlaybackQuality(VALID_QUALITY);
			fixtureToTest.playVideo();
			assertTrue(eventDidDispatch);
		}

		// [Ignore]
		[Test]
		public function test_playVideo_should_dispatch_MediaProviderEvent_PLAYING_if_PlayerState_AD_ENDED() : void {
			stub(mockController).getter("playerState").returns(PlayerState.AD_ENDED);
			stub(mockController).method("dispatchEvent").dispatches(new MediaProviderEvent(MediaProviderEvent.PLAYING));
			eventType = MediaProviderEvent.PLAYING;
			registerEventListener(eventType);
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.setPlaybackQuality(VALID_QUALITY);
			fixtureToTest.playVideo();
			assertTrue(eventDidDispatch);
		}

		// [Ignore]
		[Test]
		public function test_pauseVideo_should_dispatch_MediaProviderEvent_PAUSED_if_PlayerState_VIDEO_PLAYING() : void {
			stub(mockController).getter("playerState").returns(PlayerState.VIDEO_PLAYING);
			stub(mockController).method("dispatchEvent").dispatches(new MediaProviderEvent(MediaProviderEvent.PAUSED));
			eventType = MediaProviderEvent.PAUSED;
			registerEventListener(eventType);
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.pauseVideo();
			assertTrue(eventDidDispatch);
		}

		// [Ignore]
		[Test]
		public function test_pauseVideo_should_dispatch_MediaProviderEvent_PAUSED_if_PlayerState_PLAYER_BUFFERING() : void {
			stub(mockController).getter("playerState").returns(PlayerState.PLAYER_BUFFERING);
			stub(mockController).method("dispatchEvent").dispatches(new MediaProviderEvent(MediaProviderEvent.PAUSED));
			eventType = MediaProviderEvent.PAUSED;
			registerEventListener(eventType);
			fixtureToTest.initialize(mockController, {});
			fixtureToTest.pauseVideo();
			assertTrue(eventDidDispatch);
		}

		[Ignore]
		[Test]
		public function test_stopVideo() : void {
		}

		[Test(async, description="Async test to verify that a valid netstream is created when play() is invoked")]
		public function test_async_playVideo_has_netstream() : void {
			var passThroughData : Object = {};

			fixtureToTest.initialize(mockController, {});
			fixtureToTest.setPlaybackQuality(VALID_QUALITY);
			fixtureToTest.playVideo();
			passThroughData.propertyName = "netStream";
			passThroughData.expectedValue = notNullValue();

			var asyncHandler : Function = Async.asyncHandler(this, handleAsyncTimerComplete, ASYNC_TIMEOUT, passThroughData, handleAsyncTimeout);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, asyncHandler, false, 0, true);
			timer.start();
		}

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
			stub(mockController).getter("geoblocked").returns(false);
			stub(mockController).getter("flashVars").returns({geoblocked:"1"});
			stub(mockController).getter("config").returns(config);
			stub(mockController).method("error").throws(new Error("Mock Controller Error Method Invoked"));

			// placement
			mockPlacement = nice(MetaPlacement, "mockPlacement", [mockController]);
			mockPlacement.playlistVersion = 1;
			mockPlacement.forceHTTPS = false;
			mockPlacement.platform = Platforms.TWOGA;
			stub(mockController).getter("placement").returns(mockPlacement);

			// meta quality
			metaQuality = new MetaQuality(VALID_QUALITY, "Auto");

			// metastream
			metaStream = new MetaStream(VALID_QUALITY);
			metaStream.uri = TEST_VIDEO_URI;
			metaStream.cdn = CDN_AKAMAI;

			// meta video
			mockVideo = nice(MetaVideo, "mockVideo", [mockController, "videoId", 0]);
			mockVideo.metaQualities.push(metaQuality);
			mockVideo.metaStreams[VALID_QUALITY] = metaStream;

			stub(mockController).getter("video").returns(mockVideo);
		}

		private function tearDownMocks() : void {
			metaQuality = null;
			metaStream = null;
			mockVideo = null;
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
	}
}
