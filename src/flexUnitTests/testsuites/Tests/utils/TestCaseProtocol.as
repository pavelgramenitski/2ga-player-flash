package flexUnitTests.testsuites.Tests.utils {
	import com.rightster.utils.Protocol;
	

	import flexunit.framework.Assert;

	public class TestCaseProtocol {
		
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
		public function testContructorIsFile() : void {
			var protocol:Protocol = new Protocol(1, "file");
			Assert.assertEquals(protocol.type, 1);
			Assert.assertEquals(protocol.value, "file");
			protocol = null;
			
		}

	
		
		[Test]
		public function testContructorIsHttp() : void {
			var protocol:Protocol = new Protocol(2, "http");
			Assert.assertEquals(protocol.type, 2);
			Assert.assertEquals(protocol.value, "http");
			protocol = null;
			
		}

		
		
		[Test]
		public function testContructorIsHttps() : void {
			var protocol:Protocol = new Protocol(3, "https");
			Assert.assertEquals(protocol.type, 3);
			Assert.assertEquals(protocol.value, "https");
			protocol = null;
			
		}

		
		
	}
}
