package flexUnitTests.testsuites.Tests.model {
	import com.rightster.player.model.MetaError;

	import flexunit.framework.Assert;

	public class TestCaseMetaError {
		private static const CODE : int = 1234;
		private static const MESSAGE : String = "foo bar";
		private var fixtureToTest : MetaError;

		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
			fixtureToTest = new MetaError(CODE, MESSAGE);
		}

		[After]
		public function tearDown() : void {
			fixtureToTest = null;
		}

		[Test]
		public function test_get_code() : void {
			Assert.assertEquals(fixtureToTest.code, CODE);
		}

		[Test]
		public function test_get_messsage() : void {
			Assert.assertEquals(fixtureToTest.message, MESSAGE);
		}

		[Test]
		public function test_toString() : void {
			Assert.assertEquals(fixtureToTest.toString(), "MetaError - " + CODE + " - " + MESSAGE);
		}
	}
}
