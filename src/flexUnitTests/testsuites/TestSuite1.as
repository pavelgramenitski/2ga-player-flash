package flexUnitTests.testsuites {
	import flexUnitTests.testsuites.Tests.utils.TestCaseBooleanUtils;
	import flexUnitTests.testsuites.Tests.utils.TestCaseUrl;
	import flexUnitTests.testsuites.Tests.utils.TestCaseProtocol;
	import flexUnitTests.testsuites.Tests.view.TestCaseBaseColors;

	/**
	 * @author KJR
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuite1 {
		public var testCase1 : TestCaseBaseColors;
		public var testCase2 : TestCaseProtocol;
		public var testCase3 : TestCaseUrl;
		public  var testCase4 : TestCaseBooleanUtils;
	}
}
