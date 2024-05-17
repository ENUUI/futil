import Flutter
import UIKit

public class FutilIosPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FutilIosPlugin()
        MessagesSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
    }

    lazy var osNameVersion: [String: String] = ["os": UIDevice.current.systemName, "version": UIDevice.current.systemVersion]

    lazy var venderId: String = UIDevice.current.identifierForVendor?.uuidString ?? ""
}

extension FutilIosPlugin: Messages {
    func sdkInt(completion: @escaping (Result<Int64, Error>) -> Void) {
        completion(Result.success(1))
    }
    
    func isHarmonyOs(completion: @escaping (Result<Bool, Error>) -> Void) {
        completion(Result.success(false))
    }
    
    func osVersion(completion: @escaping (Result<[String : String]?, Error>) -> Void) {
        completion(Result.success(osNameVersion))
    }
    
    func deviceId(completion: @escaping (Result<String, Error>) -> Void) {
        completion(Result.success(venderId))
    }
}
 
