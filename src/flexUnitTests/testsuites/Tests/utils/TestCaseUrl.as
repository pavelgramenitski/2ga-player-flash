package flexUnitTests.testsuites.Tests.utils {
	import com.rightster.utils.Url;

	import flexunit.framework.Assert;

	public class TestCaseUrl {
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
		public function testProtocolValueIsHttps() : void {
			var url1 : Url = new Url("https://platform.qa2.rightster.com");
			Assert.assertEquals(url1.protocol.value, "https");
			url1 = null;
		}

		[Test]
		public function testProtocolValueIsHttp() : void {
			var url2 : Url = new Url("http://platform.qa2.rightster.com");
			Assert.assertEquals(url2.protocol.value, "http");
			url2 = null;
		}

		[Test]
		public function testProtocolValueIsFile() : void {
			var url3 : Url = new Url("file://platform.qa2.rightster.com");
			Assert.assertEquals(url3.protocol.value, "file");
			url3 = null;
		}
	}
}
