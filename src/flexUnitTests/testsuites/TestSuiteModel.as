package flexUnitTests.testsuites {
	import flexUnitTests.testsuites.Tests.model.TestCaseMetaPlacement;
	import flexUnitTests.testsuites.Tests.model.TestCaseMetaVideo;
	import flexUnitTests.testsuites.Tests.model.TestCaseMetaQuality;
	import flexUnitTests.testsuites.Tests.model.TestCaseMetaPlugin;
	import flexUnitTests.testsuites.Tests.model.TestCaseMetaImage;
	import flexUnitTests.testsuites.Tests.model.TestCaseMetaError;

	;
	/**
	 * @author KJR
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuiteModel {
		public var testCaseMetaError : TestCaseMetaError;
		public var testCaseMetaImage : TestCaseMetaImage;
		public var testCaseMetaPlugin : TestCaseMetaPlugin;
		public var testCaseMetaQuality : TestCaseMetaQuality;
		public var testCaseMetaVideo : TestCaseMetaVideo;
		public var testCaseMetaPlacement : TestCaseMetaPlacement;
	}
}
