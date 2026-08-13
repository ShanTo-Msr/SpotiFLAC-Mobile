import Flutter

public class IOSAudioPlayerPlugin: NSObject, FlutterPlugin {
    private static var audioPlayer: IOSAudioPlayer?
    
    public static func dummy(methodCall: FlutterMethodCall) {}
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.spotififlac/ios_audio_player",
            binaryMessenger: registrar.messenger()
        )
        let instance = IOSAudioPlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func dummyMethodToEnforceBundling() {
        // This method is called to enforce Flutter to bundle this plugin
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Lazy initialize audio player on first call
        if IOSAudioPlayerPlugin.audioPlayer == nil {
            IOSAudioPlayerPlugin.audioPlayer = IOSAudioPlayer()
        }
        
        guard let player = IOSAudioPlayerPlugin.audioPlayer else {
            result(FlutterError(
                code: "NOT_INITIALIZED",
                message: "Audio player not initialized",
                details: nil
            ))
            return
        }
        
        switch call.method {
        case "initializePlayer":
            result(nil)
            
        case "playAudio":
            guard let args = call.arguments as? [String: Any],
                  let filePath = args["filePath"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "filePath is required",
                    details: nil
                ))
                return
            }
            player.playAudio(filePath: filePath)
            result(nil)
            
        case "stop":
            player.stop()
            result(nil)
            
        case "pause":
            player.pause()
            result(nil)
            
        case "resume":
            player.resume()
            result(nil)
            
        case "setEQBandGain":
            guard let args = call.arguments as? [String: Any],
                  let bandIndex = args["bandIndex"] as? Int,
                  let gain = args["gain"] as? Double else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "bandIndex and gain are required",
                    details: nil
                ))
                return
            }
            player.setEQBandGain(bandIndex: bandIndex, gain: Float(gain))
            result(nil)
            
        case "setEQPreamp":
            guard let args = call.arguments as? [String: Any],
                  let gain = args["gain"] as? Double else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "gain is required",
                    details: nil
                ))
                return
            }
            player.setEQPreamp(gain: Float(gain))
            result(nil)
            
        case "setEQEnabled":
            guard let args = call.arguments as? [String: Any],
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "enabled is required",
                    details: nil
                ))
                return
            }
            player.setEQEnabled(enabled: enabled)
            result(nil)
            
        case "resetEQ":
            player.resetEQ()
            result(nil)
            
        case "applyEQSettings":
            guard let args = call.arguments as? [String: Any],
                  let gains = args["gains"] as? [Double],
                  let preamp = args["preamp"] as? Double,
                  let enabled = args["enabled"] as? Bool else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "gains, preamp, and enabled are required",
                    details: nil
                ))
                return
            }
            let floatGains = gains.map { Float($0) }
            player.applyEQSettings(gains: floatGains, preamp: Float(preamp), enabled: enabled)
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}
