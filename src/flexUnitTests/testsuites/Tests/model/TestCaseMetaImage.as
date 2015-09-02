package flexUnitTests.testsuites.Tests.model {
	import com.rightster.player.model.MetaImage;

	import flexunit.framework.Assert;

	public class TestCaseMetaImage {
		private static const WIDTH : Number = 1234;
		private static const HEIGHT : Number = 5678;
		private static const URI : String = "http://www.rightster.com";
		private static const QUALITY : String = "standardHDS";
		private var fixtureToTest : MetaImage;

		
		[Before]
		public function setUp() : void {
			fixtureToTest = new MetaImage(URI, QUALITY, WIDTH, HEIGHT);
		}

		[After]
		public function tearDown() : void {
			fixtureToTest = null;
		}

		[Test]
		public function test_get_uri() : void {
			Assert.assertEquals(fixtureToTest.uri, URI);
		}

		[Test]
		public function test_get_quality() : void {
			Assert.assertEquals(fixtureToTest.quality, QUALITY);
		}

		[Test]
		public function test_get_width() : void {
			Assert.assertEquals(fixtureToTest.width, WIDTH);
		}

		[Test]
		public function test_get_height() : void {
			Assert.assertEquals(fixtureToTest.height, HEIGHT);
		}
	}
}
