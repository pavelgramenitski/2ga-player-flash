package flexUnitTests.testsuites.Tests.view {
	import flexunit.framework.Assert;

	import com.rightster.player.view.BaseColors;

	public class TestCaseBaseColors {
		private var baseColors : BaseColors;
		// defaults must match the values in base colors
		private const PRIMARY : Number = 0xFFFFFF;
		private const BASE : Number = 0x2b2b2b;
		private const OVERLAY : Number = 0x2b2b2b;
		private const INACTIVE : Number = 0x707070;
		private const HIGHLIGHT : Number = 0x0092d4;
		private const SELECTED : Number = 0x20648A;
		private const BACKGROUND : Number = 0x1D1D1D;
		private const ADVERT : Number = 0xFBBA3F;
		private const CLOCK_INACTIVE : Number = 0x828383;
		private const BASE_ALPHA : Number = 0.6;
		private const OVERLAY_ALPHA : Number = 0.8;
		private const HIGHLIGHT_ALPHA : Number = 1;
		private const HIGHLIGHT_OFF_ALPHA : Number = 0;

		[BeforeClass]
		public static function construct() : void {
		}

		[AfterClass]
		public static function destroy() : void {
		}

		[Before]
		public function setUp() : void {
			baseColors = new BaseColors();
			baseColors.initialize();
		}

		[After]
		public function tearDown() : void {
			baseColors = null;
		}

		[Test]
		public function test_initialize_sets_primary() : void {
			Assert.assertEquals(PRIMARY, baseColors.primaryColor);
			Assert.assertEquals(PRIMARY, baseColors.primaryCT.color);
		}

		[Test]
		public function test_initialize_sets_base() : void {
			Assert.assertEquals(BASE, baseColors.baseColor);
			Assert.assertEquals(BASE, baseColors.baseCT.color);
		}

		[Test]
		public function test_initialize_sets_overlay() : void {
			Assert.assertEquals(OVERLAY, baseColors.overlayColor);
			Assert.assertEquals(OVERLAY, baseColors.overlayCT.color);
		}

		[Test]
		public function test_initialize_sets_inactive() : void {
			Assert.assertEquals(INACTIVE, baseColors.inactiveColor);
			Assert.assertEquals(INACTIVE, baseColors.inactiveCT.color);
		}

		[Test]
		public function test_initialize_sets_highlight() : void {
			Assert.assertEquals(HIGHLIGHT, baseColors.highlightColor);
			Assert.assertEquals(HIGHLIGHT, baseColors.highlightCT.color);
		}

		[Test]
		public function test_initialize_sets_selected() : void {
			Assert.assertEquals(SELECTED, baseColors.selectedColor);
			Assert.assertEquals(SELECTED, baseColors.selectedCT.color);
		}

		[Test]
		public function test_initialize_sets_background() : void {
			Assert.assertEquals(BACKGROUND, baseColors.backgroundColor);
			Assert.assertEquals(BACKGROUND, baseColors.backgroundCT.color);
		}

		[Test]
		public function test_initialize_sets_advert() : void {
			Assert.assertEquals(ADVERT, baseColors.advertColor);
			Assert.assertEquals(ADVERT, baseColors.advertCT.color);
		}

		[Test]
		public function test_initialize_sets_clockInactive() : void {
			Assert.assertEquals(CLOCK_INACTIVE, baseColors.clockInactiveColor);
			Assert.assertEquals(CLOCK_INACTIVE, baseColors.clockInactiveCT.color);
		}

		[Test]
		public function test_initialize_sets_baseAlpha() : void {
			Assert.assertEquals(BASE_ALPHA, baseColors.baseAlpha);
		}

		[Test]
		public function test_initialize_sets_overlayAlpha() : void {
			Assert.assertEquals(OVERLAY_ALPHA, baseColors.overlayAlpha);
		}

		[Test]
		public function test_initialize_sets_highlightAlpha() : void {
			Assert.assertEquals(HIGHLIGHT_ALPHA, baseColors.highlightAlpha);
			Assert.assertEquals(HIGHLIGHT_OFF_ALPHA, baseColors.highlightOffAlpha);
		}

		[Test]
		public function test_reinitialization_does_not_reset_default_primaryColor() : void {
			baseColors.primaryColor = 0xffcc00;
			baseColors.initialize();
			Assert.assertEquals(0xffcc00, baseColors.primaryColor);
		}

		[Test]
		public function test_set_get_primaryColor() : void {
			baseColors.primaryColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.primaryColor);
			Assert.assertEquals(0xffcc00, baseColors.primaryCT.color);
		}

		[Test]
		public function test_set_get_baseColor() : void {
			baseColors.baseColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.baseColor);
			Assert.assertEquals(0xffcc00, baseColors.baseCT.color);
		}

		[Test]
		public function test_set_get_inactiveColor() : void {
			baseColors.inactiveColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.inactiveColor);
			Assert.assertEquals(0xffcc00, baseColors.inactiveCT.color);
		}

		[Test]
		public function test_set_get_highlightColor() : void {
			baseColors.highlightColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.highlightColor);
			Assert.assertEquals(0xffcc00, baseColors.highlightCT.color);
		}

		[Test]
		public function test_set_get_selectedColor() : void {
			baseColors.selectedColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.selectedColor);
			Assert.assertEquals(0xffcc00, baseColors.selectedCT.color);
		}

		[Test]
		public function test_set_get_backgroundColor() : void {
			baseColors.backgroundColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.backgroundColor);
			Assert.assertEquals(0xffcc00, baseColors.backgroundCT.color);
		}

		[Test]
		public function test_set_get_advertColor() : void {
			baseColors.advertColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.advertColor);
			Assert.assertEquals(0xffcc00, baseColors.advertCT.color);
		}

		[Test]
		public function test_set_get_clockInactiveColor() : void {
			baseColors.clockInactiveColor = 0xffcc00;
			Assert.assertEquals(0xffcc00, baseColors.clockInactiveColor);
			Assert.assertEquals(0xffcc00, baseColors.clockInactiveCT.color);
		}

		[Test]
		public function test_set_get_baseAlpha() : void {
			baseColors.baseAlpha = 0.5;
			Assert.assertEquals(0.5, baseColors.baseAlpha);
		}

		[Test]
		public function test_set_get_highlightAlpha() : void {
			baseColors.highlightAlpha = 0.5;
			Assert.assertEquals(0.5, baseColors.highlightAlpha);
		}

		[Test]
		public function test_set_get_highlightOffAlpha() : void {
			baseColors.highlightOffAlpha = 0.5;
			Assert.assertEquals(0.5, baseColors.highlightOffAlpha);
		}
	}
}
