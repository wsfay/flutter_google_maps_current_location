# Screenshots
![App demo](/screenshots/demo.gif)

# Plugins
Plugins that are used:
  - google_maps_flutter
  - location
  - geocoder
  - google_maps_webservice
  - flutter_google_places
  - shared_preferences    

# Get Started

To run this project:
1. Go to [Google cloude platform](https://console.cloud.google.com/)
2. Create a project
3. Go to [API](https://console.cloud.google.com/google/maps-apis/api-list), 
   In the **Additional APIs** you can enable those APIs:
   - Geocoding API
   - Geolocation API
   - Maps SDK for Android
   - Places API 
   - Maps SDK for iOS

   ![Enable APIs](/screenshots/enable_apis.png)

4. Go to the [credentials](https://console.cloud.google.com/apis/credentials)
   
   Click on **CREATE CREDENTIALS** then **API key**
   From the **API key created** dialog click **RESTRICT KEY**


   ![credentials](/screenshots/credentials.png)  


   In the **Application restrictions**, select **Android apps**  
   In the **Restrict usage to your Android apps** click on **ADD AN ITEM** then 
   enter the package name of your app: `com.example.flutter_google_maps_current_location`
   For the `SHA-1 certificate fingerprint`   
   Go to your app directory and generate it, for linux:  
    `keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android`, then copy and paste **SHA1** .  

   In the **API restrictions** select **Restrict key**  and select all APIs you already added above:  
     - Geocoding API
     - Geolocation API
     - Maps SDK for Android
     - Places API 
     - Maps SDK for iOS


   Click on **SAVE**  



5. Copy the API key :

 ![api key](/screenshots/api_key.png)

 Add it to `AndroidManifest.xml` below the `application` tag:

 `<meta-data android:name="com.google.android.geo.API_KEY"
        android:value="YOUR_API_KEY"/>`   

 ![api key AndroidManifest](/screenshots/api_key_manifest.png)
