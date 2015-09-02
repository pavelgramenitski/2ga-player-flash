package flexUnitTests.testsuites.Tests.model {
	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.notNullValue;

	import com.rightster.player.model.MetaPlugin;

	public class TestCaseMetaPlugin {
		private static const DATA : Object = {foo:"bar"};
		private static const URL : String = "http://www.rightster.com";
		private static const NAME : String = "myName";
		private var fixtureToTest : MetaPlugin;

		[Before]
		public function setUp() : void {
			fixtureToTest = new MetaPlugin(NAME, URL);
		}

		[After]
		public function tearDown() : void {
			fixtureToTest = null;
		}

		[Test]
		public function test_get_name() : void {
			assertEquals(fixtureToTest.name, NAME);
		}

		[Test]
		public function test_get_url() : void {
			assertEquals(fixtureToTest.url, URL);
		}

		[Test]
		public function test_get_data_should_not_be_null() : void {
			assertThat(fixtureToTest.data, notNullValue());
		}

		[Test]
		public function test_get_data_should_be_passed_data() : void {
			fixtureToTest = null;
			fixtureToTest = new MetaPlugin(NAME, URL, DATA);
			assertStrictlyEquals(fixtureToTest.data, DATA);
		}
	}
}
