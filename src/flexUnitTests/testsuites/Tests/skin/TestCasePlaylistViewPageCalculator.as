package flexUnitTests.testsuites.Tests.skin {
	import com.rightster.player.skin.PlaylistViewPageCalculator;

	import flexunit.framework.Assert;

	public class TestCasePlaylistViewPageCalculator {
		public var calculator : PlaylistViewPageCalculator;

		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
			calculator = new PlaylistViewPageCalculator();
		}

		[After]
		public function tearDown() : void {
			calculator = null;
		}

		[Test]
		public function testProtocolValueIsZeroWithNine() : void {
			Assert.assertEquals(calculator.calculateIndex(0, 9), 0);
			Assert.assertEquals(calculator.calculateIndex(8, 9), 0);
		}

		[Test]
		public function testProtocolValueIsOneWithNine() : void {
			Assert.assertEquals(calculator.calculateIndex(9, 9), 1);
			Assert.assertEquals(calculator.calculateIndex(17, 9), 1);
		}

		[Test]
		public function testProtocolValueIsTwoWithNine() : void {
			Assert.assertEquals(calculator.calculateIndex(18, 9), 2);
			Assert.assertEquals(calculator.calculateIndex(26, 9), 2);
		}

		[Test]
		public function testProtocolValueIsZeroWithFour() : void {
			Assert.assertEquals(calculator.calculateIndex(0, 4), 0);
			Assert.assertEquals(calculator.calculateIndex(3, 4), 0);
		}

		[Test]
		public function testProtocolValueIsOneWithFour() : void {
			Assert.assertEquals(calculator.calculateIndex(4, 4), 1);
			Assert.assertEquals(calculator.calculateIndex(7, 4), 1);
		}

		[Test]
		public function testProtocolValueIsTwoWithFour() : void {
			Assert.assertEquals(calculator.calculateIndex(8, 4), 2);
			Assert.assertEquals(calculator.calculateIndex(11, 4), 2);
		}
	}
}
