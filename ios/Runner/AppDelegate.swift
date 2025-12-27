import UIKit
import Flutter
import GoogleMaps // 1. Burayı ekleyin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 2. Buraya API anahtarınızı ekleyin
    GMSServices.provideAPIKey("AIzaSyA0WxAQxdNmSeckrGvaS2hSJgVFgUVJOIU")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}