package flexUnitTests.testsuites {
	import flexUnitTests.testsuites.Tests.social.TestCaseTwoGaSocialAdapter;
	import flexUnitTests.testsuites.Tests.social.TestCaseSocialFactory;

	/**
	 * @author KJR
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuiteSocial {
		public var testCaseSocialFactory : TestCaseSocialFactory;
		public var testCaseTwoGaSocialAdapter : TestCaseTwoGaSocialAdapter;
	}
}
