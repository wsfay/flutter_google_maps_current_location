# flutter_google_maps_current_location

A new Flutter project.

## Getting Started

* Get an API key at <https://cloud.google.com/maps-platform/>.
  * https://console.cloud.google.com/projectselector2/home/dashboard
  * Go to the APIs & Services > Credentials page.
  * On the Credentials page, click Create credentials > API key.
The API key created dialog displays your newly created API key.

  > AIzaSyC0XMnr_ahJOSUkMQdaBwAYKS-lf9sQC0c

  * Click on `Restrict Key`, set the following restrictions:
    * Under `Application restrictions` select `Android apps`
    * Under `Restrict usage to your Android apps`:
      Click `Add AN ITEM` to add your package name and SHA-1 signing-certificate fingerprint to restrict usage to your Android apps:
 
      `keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android`

    * Under `API restrictions` select `Restrict key`, then in the `Select sAPI` drop down menu, choose `Maps SDK for Android`.
    > (If the Maps SDK for Android is not listed, you need to enable it.)
    Go to: https://console.cloud.google.com/apis/library?filter=category:maps
    Click the API or SDK you want to enable.
    `Maps SDK for Android`
    Then click on `Enable` button


    * SAVE
      
* You can also find detailed steps to get start with Google Maps Platform [here](https://developers.google.com/maps/gmp-get-started).


* Specify your API key in the application manifest `android/app/src/main/AndroidManifest.xml`:
> <manifest ...
  <application ...
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>