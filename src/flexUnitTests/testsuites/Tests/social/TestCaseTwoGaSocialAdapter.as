package flexUnitTests.testsuites.Tests.social {
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import com.rightster.player.controller.IController;
	import com.rightster.player.events.GenericTrackerEvent;
	import com.rightster.player.model.Config;
	import com.rightster.player.model.MetaPlacement;
	import com.rightster.player.model.MetaQuality;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.model.RLoader;
	import com.rightster.player.platform.Platforms;
	import com.rightster.player.social.TwoGaSocialAdapter;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.notNullValue;

	import flash.events.Event;
	import flash.utils.Timer;

	public class TestCaseTwoGaSocialAdapter {
		private static const ARBITRARY_STRING : String = "HTEHDJHKUSMBXMB12878734gdgdh";
		private static const ARBITRARY_URL : String = "http://www.rightster.com";
		public static const VALID_QUALITY : String = "standardHDS";
		public static const INVALID_QUALITY : String = "invalidQuality";
		public static const TEST_VIDEO_URI : String = "http://multiplatform-f.akamaihd.net/z/multi/april11/hdworld/hdworld_,512x288_450_b,640x360_700_b,768x432_1000_b,1024x576_1400_m,1280x720_1900_m,1280x720_2500_m,1280x720_3500_m,.mp4.csmil/manifest.f4m";
		public static const CDN_AKAMAI : String = "akamai";
		private static const ASYNC_TIMEOUT : int = 2000;
		public var metaQuality : MetaQuality;
		public var metaStream : MetaStream;
		[Rule]
		public var mockRule : MockolateRule = new MockolateRule();
		[Mock]
		public var mockController : IController;
		[Mock(inject="false")]
		public var mockPlacement : MetaPlacement;
		[Mock(inject="false")]
		public var mockVideo : MetaVideo;
		private var fixtureToTest : TwoGaSocialAdapter;
		private var config : Config;
		private var eventDidDispatch : Boolean;
		private var pauseVideoInvoked : Boolean;
		private var eventType : String;
		private var timer : Timer;

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
			fixtureToTest = new TwoGaSocialAdapter();
			fixtureToTest.initialize(mockController);
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
			fixtureToTest = null;
			config = null;
			pauseVideoInvoked = false;
			tearDownMocks();
		}

		[Test]
		public function test_mockController_should_not_be_null() : void {
			assertThat(mockController, notNullValue());
		}

		[Test]
		public function test_has_type() : void {
			assertThat(fixtureToTest, hasPropertyWithValue("type", Platforms.TWOGA));
		}
		
		[Ignore]
		[Test]
		public function test_shareTwitter() : void {
			stub(mockController).method("dispatchEvent").dispatches(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "twitter_"));
			eventType = GenericTrackerEvent.TRACK;
			registerEventListener(eventType);
			fixtureToTest.shareTwitter();
			assertThat(eventDidDispatch, equalTo(true));
			assertThat(pauseVideoInvoked, equalTo(true));
		}
		
		[Ignore]
		[Test]
		public function test_shareFacebook() : void {
			stub(mockController).method("dispatchEvent").dispatches(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "facebook_"));
			eventType = GenericTrackerEvent.TRACK;
			registerEventListener(eventType);
			fixtureToTest.shareFacebook();
			assertThat(eventDidDispatch, equalTo(true));
			assertThat(pauseVideoInvoked, equalTo(true));
		}

		[Test]
		public function test_shareTumblr() : void {
			stub(mockController).method("dispatchEvent").dispatches(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "tumblr_"));
			eventType = GenericTrackerEvent.TRACK;
			registerEventListener(eventType);
			fixtureToTest.shareTumblr();
			// TODO:implement
			// assertThat(eventDidDispatch, equalTo(true));
			assertThat(pauseVideoInvoked, equalTo(true));
		}

		[Test]
		public function test_shareEmail() : void {
			stub(mockController).method("dispatchEvent").dispatches(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "email"));
			eventType = GenericTrackerEvent.TRACK;
			registerEventListener(eventType);
			fixtureToTest.shareEmail();
			// TODO:implement
			// assertThat(eventDidDispatch, equalTo(true));
			assertThat(pauseVideoInvoked, equalTo(true));
		}

		[Test]
		public function test_shareGPlus() : void {
			stub(mockController).method("dispatchEvent").dispatches(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "gplus_"));
			eventType = GenericTrackerEvent.TRACK;
			registerEventListener(eventType);
			fixtureToTest.shareGPlus();
			// TODO:implement
			// assertThat(eventDidDispatch, equalTo(true));
			assertThat(pauseVideoInvoked, equalTo(true));
		}

		/*	
		 * HELPER METHODS
		 * 
		 */
		private function  setUpMocks() : void {
			// stubs
			stub(mockController).getter("geoblocked").returns(false);
			stub(mockController).getter("flashVars").returns({geoblocked:"1"});
			stub(mockController).getter("config").returns(config);
			// stub(mockController).method("error").throws(new Error("Mock Controller Error Method Invoked"));
			stub(mockController).getter("currentProtocol").returns("http");
			stub(mockController).method("pauseVideo").calls(function() : void {
				pauseVideoInvoked = true;
			});

			// placement
			mockPlacement = nice(MetaPlacement, "mockPlacement", [mockController]);
			mockPlacement.playlistVersion = 1;
			mockPlacement.forceHTTPS = false;
			mockPlacement.platform = Platforms.TWOGA;
			stub(mockController).getter("placement").returns(mockPlacement);

			// loader
			stub(mockController).getter("loader").returns(new RLoader(mockController, mockPlacement.forceHTTPS));

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
			mockVideo.shareTwitterLink = ARBITRARY_URL;
			mockVideo.shareTwitterMessage = ARBITRARY_STRING;
			mockVideo.shareTwitterUrl = "www.twitter.com";
			mockVideo.shareFBLink = ARBITRARY_URL;
			mockVideo.shareFBAppId = ARBITRARY_STRING;

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
			trace(event["customAction"]);
		}
	}
}
