package flexUnitTests.testsuites.Tests.utils {
	import org.flexunit.runners.Parameterized;

	import flexunit.framework.Assert;

	import com.rightster.utils.BooleanUtils;

	[RunWith("org.flexunit.runners.Parameterized")]
	public class TestCaseBooleanUtils {
		private var fixtureToTest : Parameterized;
		[Parameters]
		public static var testTrue : Array = [[true, true], ['true', true], ['TRUE', true], ['yes', true], ['YES', true], ['on', true], ['ON', true], [1, true]];
		public static var testFalse : Array = [[false, false], ['false', false], ['FALSE', false], ['no', false], ['NO', false], ['off', false], ['OFF', false], ['', false], [0, false], [-1, false], [22, false]];

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

		[Test(dataProvider="testTrue")]
		public function test_should_be_true(value : *, expected : Boolean) : void {
			Assert.assertEquals(BooleanUtils.booleanValue(value), expected);
		}

		[Test(dataProvider="testFalse")]
		public function test_should_be_false(value : *, expected : Boolean) : void {
			Assert.assertEquals(BooleanUtils.booleanValue(value), expected);
		}

		private var _value : *;
		private var _expected : Boolean;

		public function TestCaseBooleanUtils(param1 : *, param2 : Boolean) : void {
			_value = param1;
			_expected = param2;
		}
		// [Test(dataProvider="testFalse")]
		// public function test_should_be_false(value:*) : void {
		// Assert.assertEquals(BooleanUtils.booleanValue(value), false);
		// }

		// [Test]
		// public function test_string_should_be_true() : void {
		// Assert.assertEquals(BooleanUtils.booleanValue("1"), true);
		// Assert.assertEquals(BooleanUtils.booleanValue("YES"), true);
		// Assert.assertEquals(BooleanUtils.booleanValue("yes"), true);
		// Assert.assertEquals(BooleanUtils.booleanValue("ON"), true);
		// Assert.assertEquals(BooleanUtils.booleanValue("on"), true);
		// Assert.assertEquals(BooleanUtils.booleanValue("TRUE"), true);
		// Assert.assertEquals(BooleanUtils.booleanValue("true"), true);
		// }
		//
		// public function test_string_should_be_false() : void {
		// Assert.assertEquals(BooleanUtils.booleanValue("0"), false);
		// Assert.assertEquals(BooleanUtils.booleanValue("NO"), false);
		// Assert.assertEquals(BooleanUtils.booleanValue("no"), false);
		// Assert.assertEquals(BooleanUtils.booleanValue("OFF"), false);
		// Assert.assertEquals(BooleanUtils.booleanValue("off"), false);
		// Assert.assertEquals(BooleanUtils.booleanValue("false"), false);
		// Assert.assertEquals(BooleanUtils.booleanValue("false"), false);
		// Assert.assertEquals(BooleanUtils.booleanValue(null), false);
		// Assert.assertEquals(BooleanUtils.booleanValue({}), false);
		// Assert.assertEquals(BooleanUtils.booleanValue([]), false);
		// }
	}
}
