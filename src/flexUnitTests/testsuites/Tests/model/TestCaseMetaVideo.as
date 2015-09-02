package flexUnitTests.testsuites.Tests.model {
	import mockolate.nice;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import com.rightster.player.controller.IController;
	import com.rightster.player.model.Config;
	import com.rightster.player.model.MetaPlacement;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.platform.Platforms;
	import com.rightster.utils.StringUtils;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.notNullValue;

	public class TestCaseMetaVideo {
		private static const ARBITRARY_CSV_STRING : String = "foo,bar,saunders";
		private static const ARBITRARY_NUMBER_STRING : String = "125";
		private static const ARBITRARY_STRING : String = "12345678abcde";
		private static const ARBITRARY_PROVIDER : String = "arbitraryProvider";
		private static const PLAYLIST_INDEX : uint = 6;
		private static const ARBITRARY_URL : String = "http://www.rightster.com";
		[Rule]
		public var mockRule : MockolateRule = new MockolateRule();
		[Mock]
		public var mockController : IController;
		[Mock(inject="false")]
		public var mockPlacement : MetaPlacement;
		private var fixtureToTest : MetaVideo;
		private var config : Config;

		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
			config = new Config();
		}

		[After]
		public function tearDown() : void {
			fixtureToTest = null;
			config = null;
			tearDownMocks();
		}

		// [Ignore]
		[Test]
		public function test_mockController_should_not_be_null() : void {
			assertThat(mockController, notNullValue());
		}

		// [Ignore]
		[Test]
		public function test_get_playlistIndex() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.playlistIndex, PLAYLIST_INDEX);
		}

		// [Ignore]
		[Test]
		public function test_get_videoId() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.videoId, ARBITRARY_STRING);
		}

		// [Ignore]
		[Test]
		public function test_get_metaStreams_is_not_null() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertThat(fixtureToTest.metaStreams, notNullValue());
		}

		// [Ignore]
		[Test]
		public function test_constructor_sets_geoblocked_to_false_by_default() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.geoBlocked);
		}

		// [Ignore]
		[Test]
		public function test_constructor_should_set_geoblocked_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.geoblocked = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.geoBlocked);
		}

		[Test]
		public function test_constructor_should_set_geoblocked_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.geoblocked = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.geoBlocked);
		}

		[Test]
		public function test_constructor_should_set_plugins_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.plugins = ARBITRARY_CSV_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.plugins.length, 3);
			assertEquals(fixtureToTest.plugins[0], ARBITRARY_CSV_STRING.split(",")[0]);
			assertEquals(fixtureToTest.plugins[1], ARBITRARY_CSV_STRING.split(",")[1]);
			assertEquals(fixtureToTest.plugins[2], ARBITRARY_CSV_STRING.split(",")[2]);
		}

		[Test]
		public function test_constructor_should_set_playerShareUrl_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.playershareurl = ARBITRARY_URL;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.playerShareUrl, ARBITRARY_URL);
		}

		[Test]
		public function test_constructor_should_set_playlistId_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.playlistid = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.playlistId, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_should_set_playlistName_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.playlistname = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.playlistName, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_mediaProvider_to_default_without_passed_value_flashvars() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.mediaProvider, config.DEFAULT_MEDIA_PROVIDER);
		}

		[Test]
		public function test_constructor_sets_mediaProvider_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.mediaprovider = ARBITRARY_PROVIDER;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.mediaProvider, ARBITRARY_PROVIDER);
		}

		[Test]
		public function test_constructor_sets_pixelLimit_to_default_without_passed_value_flashvars() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.pixelLimit, config.DEFAULT_PIXEL_LIMIT);
		}

		[Test]
		public function test_constructor_sets_pixelLimit_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.pixellimit = 3;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.pixelLimit, 3);
		}

		[Test]
		public function test_constructor_sets_title_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.title = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.title, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_description_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.description = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.description, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_durationStr_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.duration = ARBITRARY_NUMBER_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.durationStr, ARBITRARY_NUMBER_STRING);
		}

		[Test]
		public function test_constructor_sets_duration_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.duration = ARBITRARY_NUMBER_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.duration, Number(ARBITRARY_NUMBER_STRING));
		}

		[Test]
		public function test_constructor_sets_thumbnailImageUrl_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.thumbnailimageurl = ARBITRARY_URL;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.thumbnailImageUrl, ARBITRARY_URL);
		}

		[Test]
		public function test_constructor_sets_startImageUrl_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.startimageurl = ARBITRARY_URL;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.startImageUrl, StringUtils.decodeURIString(ARBITRARY_URL));
		}

		[Test]
		public function test_constructor_sets_contentId_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.contentid = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.contentId, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_projectId_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.projectid = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.projectId, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_projectName_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.projectname = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.projectName, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_tags_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.tags = ARBITRARY_CSV_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			for (var i : int = 0, j : int = fixtureToTest.tags.length; i < j; i += 1) {
				assertStrictlyEquals(fixtureToTest.tags[i], ARBITRARY_CSV_STRING.split(",")[i]);
			}
		}

		[Test]
		public function test_constructor_sets_keywords_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.keywords = ARBITRARY_CSV_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.keywords, StringUtils.decodeURIString(ARBITRARY_CSV_STRING));
		}

		[Test]
		public function test_constructor_sets_readMoreUrl_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.readmoreurl = ARBITRARY_URL;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.readMoreUrl, StringUtils.decodeURIString(ARBITRARY_URL));
		}

		[Test]
		public function test_constructor_sets_omnitureTracking_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.omnituretracking = 1;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.omnitureTracking);
		}

		[Test]
		public function test_constructor_sets_omnitureTracking_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.omnituretracking = 0;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.omnitureTracking);
		}

		[Test]
		public function test_constructor_sets_monetization_to_default_true_without_passed_value_flashvars() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.monetization);
		}

		[Test]
		public function test_constructor_sets_monetization_to_true_with_passed_fetchvast_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.fetchvast = 1;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.monetization);
		}

		[Test]
		public function test_constructor_sets_monetization_to_false_with_passed_fetchvast_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.fetchvast = 0;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.monetization);
		}

		[Test]
		public function test_constructor_sets_zoneId_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.zoneid = 1234;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.zoneId, 1234);
		}

		[Test]
		public function test_constructor_sets_mediaId_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.mediaid = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.mediaId, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_mediaFingerprintId_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.mediafingerprintid = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.mediaFingerprintId, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_lrContent_to_default_without_passed_value_flashvars() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.lrContent, config.DEFAULT_LR_CONTENT);
		}

		[Test]
		public function test_constructor_sets_lrAdMap_to_default_without_passed_value_flashvars() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.lrAdMap, config.DEFAULT_LR_ADMAP);
		}

		[Test]
		public function test_constructor_sets_lrAdMap_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.lradmap = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.lrAdMap, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_adProvider_to_default_without_passed_value_flashvars() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.adProvider, config.DEFAULT_AD_PROVIDER);
		}

		[Test]
		public function test_constructor_sets_adProvider_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.adprovider = ARBITRARY_PROVIDER;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.adProvider, ARBITRARY_PROVIDER);
		}

		[Test]
		public function test_constructor_sets_trackingMode_to_default_without_passed_value_flashvars() : void {
			setUpMocks();
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.trackingMode, config.DEFAULT_TRACKING_MODE);
		}

		[Test]
		public function test_constructor_sets_trackingMode_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.trackingmode = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.trackingMode, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_trackingMode_with_logmode_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.logmode = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.trackingMode, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_trackingPing_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.trackingping = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.trackingPing);
		}

		[Test]
		public function test_constructor_sets_trackingPing_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.trackingping = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.trackingPing);
		}

		[Test]
		public function test_constructor_sets_shareFBEnabled_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.enablesharefb = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.shareFBEnabled);
		}

		[Test]
		public function test_constructor_sets_shareFBEnabled_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.enablesharefb = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.shareFBEnabled);
		}

		[Test]
		public function test_constructor_sets_shareFBLink_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.sharefblink = ARBITRARY_URL;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.shareFBLink, ARBITRARY_URL);
		}

		[Test]
		public function test_constructor_sets_shareFBCaption_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.sharefbcaption = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.shareFBCaption, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_shareFBDescription_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.sharefbdescription = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.shareFBDescription, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_shareTwitterMessage_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.twittersharetext = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.shareTwitterMessage, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_shareTwitterUseUrl_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.twittershareuseurl = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.shareTwitterUseUrl);
		}

		[Test]
		public function test_constructor_sets_shareTwitterUseUrl_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.twittershareuseurl = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.shareTwitterUseUrl);
		}

		[Test]
		public function test_constructor_sets_isEmail_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.isemail = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.isEmail);
		}

		[Test]
		public function test_constructor_sets_isEmail_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.isemail = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.isEmail);
		}

		[Test]
		public function test_constructor_sets_emailSubject_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.emailsubject = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.emailSubject, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_emailBody_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.emailbody = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.emailBody, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_googlePlusShare_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.googleplusshare = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.googlePlusShare);
		}

		[Test]
		public function test_constructor_sets_googlePlusShare_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.googleplusshare = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.googlePlusShare);
		}

		[Test]
		public function test_constructor_sets_enableShareTumblr_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.enablesharetumblr = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.enableShareTumblr);
		}

		[Test]
		public function test_constructor_sets_enableShareTumblr_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.enablesharetumblr = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.enableShareTumblr);
		}

		[Test]
		public function test_constructor_sets_tumblrCaptionTxt_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.tumblrcaptiontxt = ARBITRARY_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.tumblrCaptionTxt, ARBITRARY_STRING);
		}

		[Test]
		public function test_constructor_sets_omnitureXMLPath_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.omniturexmlpath = ARBITRARY_URL;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.omnitureXMLPath, ARBITRARY_URL);
		}

		[Test]
		public function test_constructor_sets_isSkipAds_to_true_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.isskipads = "1";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertTrue(fixtureToTest.isSkipAds);
		}

		[Test]
		public function test_constructor_sets_isSkipAds_to_false_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.isskipads = "0";
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertFalse(fixtureToTest.isSkipAds);
		}

		[Test]
		public function test_constructor_sets_skipAdDuration_with_passed_value_flashvars() : void {
			var flashVars : Object = {};
			flashVars.skipadduration = ARBITRARY_NUMBER_STRING;
			setUpMocksWithFlashVars(flashVars);
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			assertEquals(fixtureToTest.skipAdDuration, Number(ARBITRARY_NUMBER_STRING));
		}

		[Test]
		public function test_constructor_sets_skipAdDuration_default_without_passed_value_flashvars() : void {
			setUpMocks();
			 var defaultValue:Number = 5;
			fixtureToTest = new MetaVideo(mockController, ARBITRARY_STRING, PLAYLIST_INDEX);
			 assertEquals(fixtureToTest.skipAdDuration, defaultValue);
			
		}

		/*	
		 * HELPER METHODS
		 * 
		 */
		private function  setUpMocks() : void {
			// generic stubs
			stub(mockController).getter("flashVars").returns({});
			setUpGenericMocks();
		}

		private function tearDownMocks() : void {
			mockPlacement = null;
		}

		private function setUpMocksWithFlashVars(obj : Object) : void {
			stub(mockController).getter("flashVars").returns(obj);
			setUpGenericMocks();
		}

		private function setUpGenericMocks() : void {
			
			// generic stubs
			stub(mockController).getter("config").returns(config);
			stub(mockController).method("error").throws(new Error("Mock Controller Error Method Invoked"));

			// placement
			mockPlacement = nice(MetaPlacement, "mockPlacement", [mockController]);
			mockPlacement.playlistVersion = 1;
			mockPlacement.forceHTTPS = false;
			mockPlacement.platform = Platforms.TWOGA;
			stub(mockController).getter("placement").returns(mockPlacement);
		}
	}
}
