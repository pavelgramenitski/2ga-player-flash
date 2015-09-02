package flexUnitTests.testsuites {
	import flexUnitTests.testsuites.Tests.skin.TestCasePlaylistItemViewContainer;
	import flexUnitTests.testsuites.Tests.skin.TestCasePlaylistViewPageCalculator;
	import flexUnitTests.testsuites.Tests.skin.TestCasePlaylistItem;

	/**
	 * @author KJR
	 */
	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class TestSuiteSkin {
		
		public var testCasePlaylistViewPageCalculator : TestCasePlaylistViewPageCalculator;
		public var testCasePlaylistBar : TestCasePlaylistItem;
		public var testCasePlaylistItemViewContainer:TestCasePlaylistItemViewContainer;
	}
}
