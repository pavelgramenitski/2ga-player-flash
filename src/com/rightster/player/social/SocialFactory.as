package com.rightster.player.social {
	import com.rightster.utils.Log;
	import com.rightster.player.platform.Platforms;

	/**
	 * @author KJR
	 */
	public class SocialFactory {
		private static var currentAdapter : ISocialAdapter;
		private static var type : String ;

		public function SocialFactory() {
			currentAdapter = null;
			type = Platforms.TWOGA;
		}

		static public function getAdapter() : ISocialAdapter {
			if (currentAdapter == null ) {
				Log.write("Adaper has not been set", Log.ERROR);
			}

			return currentAdapter;
		}

		static public function setAdapter(sType : String) : ISocialAdapter {
			switch (sType) {
				case Platforms.TWOGA:
					type = sType;
					currentAdapter = ISocialAdapter(new TwoGaSocialAdapter);
					break;
//				case Platforms.GENESIS:
//					Log.write("SocialFactory.setAdapter *Genesis correct implementation required", Log.ERROR);
//					type = sType;
//					currentAdapter = ISocialAdapter(new GenesisSocialAdapter);
//					break;
//				case Platforms.MARS:
//					Log.write("SocialFactory.setAdapter *Mars correct implementation required", Log.ERROR);
//					type = sType;
//					currentAdapter = ISocialAdapter(new MarsSocialAdapter);
//					break;
//				case Platforms.DIRECT:
//					Log.write("SocialFactory.setAdapter *Direct correct implementation required", Log.ERROR);
//					type = sType;
//					currentAdapter = ISocialAdapter(new DirectSocialAdapter);
//					break;
				default:
					type = Platforms.TWOGA;
					currentAdapter = ISocialAdapter(new TwoGaSocialAdapter);
			}

			return currentAdapter;
		}
	}
}
