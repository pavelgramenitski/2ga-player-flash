package flexUnitTests.testsuites.Tests.model {
	import flexunit.framework.Assert;
	import mockolate.runner.MockolateRule;
	import mockolate.stub;

	import com.rightster.player.controller.IController;
	import com.rightster.player.model.Config;
	import com.rightster.player.model.MetaPlacement;

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.notNullValue;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class TestCaseMetaPlacement {
		public static var testTrue : Array = [[true, true], ['true', true], ['TRUE', true], ['yes', true], ['YES', true], ['on', true], ['ON', true], [1, true]];
		public static var testFalse : Array = [[false, false], ['false', false], ['FALSE', false], ['no', false], ['NO', false], ['off', false], ['OFF', false], ['', false], [0, false], [-1, false], [22, false]];
		public static var qualities : Array = [[{defaultquality:"high"}], [{defaultquality:"med."}], [{defaultquality:"low"}]];
		public static var invalidQualities : Array = [[{defaultquality:"higher"}], [{defaultquality:"medium"}], [{defaultquality:"lowest"}]];
		private static const ARBITRARY_CSV_STRING : String = "foo,bar,saunders";
		private static const ARBITRARY_NUMBER_STRING : String = "125";
		private static const ARBITRARY_STRING : String = "12345678abcde";
		private static const DEFAULT_QUALITY : String = "standardHDS";
		private static const ARBITRARY_URL : String = "http://www.rightster.com";
		[Rule]
		public var mockRule : MockolateRule = new MockolateRule();
		[Mock]
		public var mockController : IController;
		private var fixtureToTest : MetaPlacement;
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
			setUpMocks();
			fixtureToTest = new MetaPlacement(mockController);
		}

		[After]
		public function tearDown() : void {
			fixtureToTest = null;
			config = null;
			tearDownMocks();
		}

		[Test]
		public function test_mockController_should_not_be_null() : void {
			assertThat(mockController, notNullValue());
		}

		[Test]
		public function test_init_should_set_loaderInfoURL() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			assertEquals(fixtureToTest.loaderInfoURL, ARBITRARY_URL);
		}

		[Test]
		public function test_init_sets_platform_by_default() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			assertEquals(fixtureToTest.platform, config.DEFAULT_PLATFORM);
		}

		[Test]
		public function test_init_sets_platform_with_passed_infoObj() : void {
			var infoObj : Object = {};
			infoObj.platform = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.platform, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_playlistTitle_by_default() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			assertEquals(fixtureToTest.playListTitle, config.DEFAULT_PLAYLIST_TITLE);
		}

		[Test]
		public function test_init_sets_authValue_with_passed_infoObj() : void {
			var infoObj : Object = {};
			infoObj.auth = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.authValue, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_cueVideos_with_passed_infoObj() : void {
			var infoObj : Object = {};
			infoObj.cuevideos = ARBITRARY_CSV_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.cueVideos.length, 3);
			assertEquals(fixtureToTest.cueVideos[0], ARBITRARY_CSV_STRING.split(",")[0]);
			assertEquals(fixtureToTest.cueVideos[1], ARBITRARY_CSV_STRING.split(",")[1]);
			assertEquals(fixtureToTest.cueVideos[2], ARBITRARY_CSV_STRING.split(",")[2]);
		}

		[Test]
		public function test_init_sets_cuePlaylists_with_passed_infoObj() : void {
			var infoObj : Object = {};
			infoObj.cueplaylists = ARBITRARY_CSV_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.cuePlaylists.length, 3);
			assertEquals(fixtureToTest.cuePlaylists[0], ARBITRARY_CSV_STRING.split(",")[0]);
			assertEquals(fixtureToTest.cuePlaylists[1], ARBITRARY_CSV_STRING.split(",")[1]);
			assertEquals(fixtureToTest.cuePlaylists[2], ARBITRARY_CSV_STRING.split(",")[2]);
		}

		[Test]
		public function test_init_sets_showPlaylist_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.playlist = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.showPlaylist);
		}

		[Test]
		public function test_init_sets_showPlaylist_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.playlist = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.showPlaylist);
		}

		[Test]
		public function test_init_sets_initialId_with_passed_video_id_in_infoObj() : void {
			var infoObj : Object = {};
			infoObj.video_id = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.initialId, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_initialId_with_passed_placementid_in_infoObj() : void {
			var infoObj : Object = {};
			infoObj.placementid = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.initialId, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_autoBitrateSwitching_to_false_by_default() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			assertFalse(fixtureToTest.autoBitrateSwitching);
		}

		[Test]
		public function test_init_sets_autoBitrateSwitching_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.autobitrateswitching = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.autoBitrateSwitching);
		}

		[Test]
		public function test_init_sets_autoBitrateSwitching_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.autobitrateswitching = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.autoBitrateSwitching);
		}

		[Test]
		public function test_init_sets_noControlsWhileAds_to_false_by_default() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			assertFalse(fixtureToTest.noControlsWhileAds);
		}

		[Test]
		public function test_init_sets_noControlsWhileAds_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.nocontrolswhileads = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.noControlsWhileAds);
		}

		[Test]
		public function test_init_sets_noControlsWhileAds_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.nocontrolswhileads = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.noControlsWhileAds);
		}

		[Test]
		public function test_constructs_sets_defaultQuality() : void {
			assertEquals(fixtureToTest.defaultQuality, DEFAULT_QUALITY);
		}

		[Test(dataProvider="qualities")]
		public function test_init_sets_defaultQuality_with_passed_value_infoObj(infoObj : Object) : void {
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.defaultQuality, upperCaseFirst(infoObj["defaultquality"]));
		}

		[Test(dataProvider="invalidQualities")]
		public function test_init_sets_defaultQuality_to_default_with_invalid_passed_values_infoObj(infoObj : Object) : void {
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.defaultQuality, DEFAULT_QUALITY);
		}

		[Test]
		public function test_init_sets_playerId_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.playerid = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.playerId, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_publisherName_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.publishername = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.publisherName, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_publisherId_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.publisherid = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.publisherId, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_autoPlay_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.autoplay = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.autoPlayOnMouseOver);
			assertTrue(fixtureToTest.autoPlay);
		}

		[Test]
		public function test_init_sets_autoPlay_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.autoplay = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.autoPlayOnMouseOver);
			assertFalse(fixtureToTest.autoPlay);
		}

		[Test]
		public function test_init_sets_autoPlayOnMouseOver_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.autoplay = "3";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.autoPlayOnMouseOver);
			assertFalse(fixtureToTest.autoPlay);
		}

		[Test]
		public function test_init_sets_startMuted_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.startmuted = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.startMuted);
		}

		[Test]
		public function test_init_sets_startMuted_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.startmuted = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.startMuted);
		}

		[Test]
		public function test_init_sets_autoPlay_and_mouseOverContentUnmute_to_true_if_startMuted_and_autoPlayOnMouseOver() : void {
			var infoObj : Object = {};
			infoObj.startmuted = "1";
			infoObj.autoplay = "3";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.autoPlay);
			assertTrue(fixtureToTest.mouseOverContentUnmute);
		}

		[Test]
		public function test_init_sets_relatedVideos_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.relatedvideos = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.relatedVideos);
		}

		[Test]
		public function test_init_sets_relatedVideos_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.relatedvideos = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.relatedVideos);
		}

		[Test]
		public function test_init_sets_forceDisableSharing_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.forcedisablesharing = 1;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.forceDisableSharing);
		}

		[Test]
		public function test_init_sets_forceDisableSharing_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.forcedisablesharing = 0;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.forceDisableSharing);
		}

		[Test]
		public function test_init_sets_jsApi_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.jsapi = 1;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.jsApi);
		}

		[Test]
		public function test_init_sets_jsApi_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.jsapi = 0;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.jsApi);
		}

		[Test]
		public function test_init_sets_livePlaylist_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.liveplaylist = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.livePlaylist);
		}

		[Test]
		public function test_init_sets_livePlaylist_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.liveplaylist = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.livePlaylist);
		}

		[Test]
		public function test_init_sets_playlistVersion_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.playlistversion = ARBITRARY_NUMBER_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.playlistVersion, Number(ARBITRARY_NUMBER_STRING));
		}

		[Test]
		public function test_init_sets_forceHTTPS_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.forcehttps = "1";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.forceHTTPS);
		}

		[Test]
		public function test_init_sets_forceHTTPS_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.forcehttps = "0";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.forceHTTPS);
		}

		[Test]
		public function test_init_sets_pcodeValue_by_default() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			assertEquals(fixtureToTest.pcodeValue, config.DEFAULT_PCODE_VALUE);
		}

		[Test]
		public function test_init_sets_pcodeValue_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.pcode = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.pcodeValue, mockController.flashVars["pcode"]);
		}

		[Test]
		public function test_init_sets_initLogMode_by_default() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			assertEquals(fixtureToTest.initLogMode, config.DEFAULT_LOGMODE);
		}

		[Test]
		public function test_init_sets_initLogMode_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.logmode = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.initLogMode, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_embedPageTitle_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.embedpagetitle = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.embedPageTitle, ARBITRARY_STRING);
		}

		[Test]
		public function test_init_sets_embedPageUrl_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.embedpageurl = ARBITRARY_URL;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertEquals(fixtureToTest.embedPageUrl, ARBITRARY_URL);
		}

		[Test]
		public function test_init_sets_playbackAuthorisation_to_true_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.playbackauthorisation = true;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.playbackAuthorisation);
		}

		[Test]
		public function test_init_sets_playbackAuthorisation_to_false_with_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.playbackauthorisation = false;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.playbackAuthorisation);
		}

		[Test]
		public function test_reset_sets_showPlaylist_to_false() : void {
			fixtureToTest.init({}, ARBITRARY_URL);
			fixtureToTest.showPlaylist = true;
			fixtureToTest.reset();
			assertFalse(fixtureToTest.showPlaylist);
		}

		[Test]
		public function test_init_sets_randomize_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.randomize = "YES";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.randomize);
		}

		[Test]
		public function test_init_sets_shouldMonetize_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.monetization = "NO";
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertFalse(fixtureToTest.shouldMonetize);
		}
		
		[Test(dataProvider="testTrue")]
		public function test_init_sets_startMuted_is_true_passed_value_infoObj(value : *, expected : Boolean) : void {
			var infoObj : Object = {};
			infoObj.startmuted = value;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			Assert.assertEquals(fixtureToTest.startMuted, expected);
		}
		
		[Test(dataProvider="testFalse")]
		public function test_init_sets_startMuted_is_false_passed_value_infoObj(value : *, expected : Boolean) : void {
			var infoObj : Object = {};
			infoObj.startmuted = value;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			Assert.assertEquals(fixtureToTest.startMuted, expected);
		}
		
		[Test(dataProvider="testTrue")]
		public function test_init_sets_pagePlayer_is_true_passed_value_infoObj(value : *, expected : Boolean) : void {
			var infoObj : Object = {};
			infoObj.pageplayer = value;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			Assert.assertEquals(fixtureToTest.pagePlayer, expected);
		}
		
		[Test(dataProvider="testFalse")]
		public function test_init_sets_pagePlayer_is_false_passed_value_infoObj(value : *, expected : Boolean) : void {
			var infoObj : Object = {};
			infoObj.pageplayer = value;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			Assert.assertEquals(fixtureToTest.pagePlayer, expected);
		}
		
		[Test]
		public function test_init_sets_displayStyle_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.displaystyle = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.displayStyle);
		}
		
		[Test]
		public function test_init_sets_listStyle_passed_value_infoObj() : void {
			var infoObj : Object = {};
			infoObj.liststyle = ARBITRARY_STRING;
			fixtureToTest.init(infoObj, ARBITRARY_URL);
			assertTrue(fixtureToTest.listStyle);
		}

		/*	
		 * HELPER METHODS
		 * 
		 */
		private function  setUpMocks() : void {
			// generic stubs
			// stub(mockController).getter("flashVars").returns({});
			setUpGenericMocks();
		}

		private function tearDownMocks() : void {
			// mockPlacement = null;
		}

		// private function setUpMocksWithFlashVars(obj : Object) : void {
		// stub(mockController).getter("flashVars").returns(obj);
		// setUpGenericMocks();
		// }
		private function setUpGenericMocks() : void {
			// generic stubs
			// stub(mockController).setter("loopMode").arg(true);
			stub(mockController).getter("flashVars").returns({pcode:ARBITRARY_STRING});
			stub(mockController).getter("config").returns(config);
			stub(mockController).method("error").throws(new Error("Mock Controller Error Method Invoked"));
		}

		private function upperCaseFirst(str : String) : String {
			return str.substr(0, 1).toUpperCase() + str.substr(1, str.length);
		}
	}
}
