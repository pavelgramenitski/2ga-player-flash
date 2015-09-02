package flexUnitTests.testsuites.Tests.model {
	import com.rightster.player.model.MetaQuality;

	import org.flexunit.asserts.assertStrictlyEquals;
	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.assertThat;
	import org.hamcrest.object.notNullValue;

	public class TestCaseMetaQuality {
		private static const LABEL : String = "Auto";
		private static const QUALITY : String = "standardHDS";
		private var fixtureToTest : MetaQuality;

		[Before]
		public function setUp() : void {
			fixtureToTest = new MetaQuality(QUALITY, LABEL);
		}

		[After]
		public function tearDown() : void {
			fixtureToTest = null;
		}
		
		[Test]
		public function test_get_quality() : void {
			assertEquals(fixtureToTest.quality, QUALITY);
		}

		[Test]
		public function test_get_label() : void {
			assertEquals(fixtureToTest.label, LABEL);
		}
	}
}
