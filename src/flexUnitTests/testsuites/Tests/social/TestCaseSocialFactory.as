package flexUnitTests.testsuites.Tests.social {
	import com.rightster.player.platform.Platforms;
	import com.rightster.player.social.ISocialAdapter;
	import com.rightster.player.social.SocialFactory;
	import com.rightster.player.social.TwoGaSocialAdapter;

	import org.hamcrest.assertThat;
	import org.hamcrest.core.both;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.hasPropertyWithValue;

	public class TestCaseSocialFactory {
		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
		}

		[After]
		public function tearDown() : void {
		}

		[Test]
		public function test_setAdapter_returns_class_TwoGaSocialAdapter() : void {
			var adapter : ISocialAdapter = SocialFactory.setAdapter(Platforms.TWOGA);
			assertThat(adapter, both(isA(TwoGaSocialAdapter)).and(hasPropertyWithValue("type", Platforms.TWOGA)));
			adapter = null;
		}
	}
}
