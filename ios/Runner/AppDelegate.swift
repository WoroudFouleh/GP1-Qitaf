import UIKit
import Flutter
import GoogleMaps // أضف هذا السطر

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // أضف مفتاح Google Maps API هنا
    GMSServices.provideAPIKey("AIzaSyAnyO6dwaSxhkal_COd59PbwYUg8z6hvu0") // استبدل YOUR_API_KEY بمفتاحك
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}