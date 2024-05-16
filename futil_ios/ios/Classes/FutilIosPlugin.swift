import Flutter
import UIKit

public class FutilIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "github.enuui/futil", binaryMessenger: registrar.messenger())
        let instance = FutilIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "os_name_version":
            result(osNameVersion)
        case "device_id":
            result(venderId)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    lazy var osNameVersion: OsVersion = .init(os: UIDevice.current.systemName, version: UIDevice.current.systemVersion)

    lazy var venderId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
}
