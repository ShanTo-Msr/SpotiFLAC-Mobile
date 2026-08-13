import AVFoundation

/// iOS Internal Audio Player with 10-band Equalizer using AVAudioEngine
class IOSAudioPlayer: NSObject {
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private let eqNode = AVAudioUnitEQ(numberOfBands: 10)
    private let playerNode = AVAudioPlayerNode()
    
    // EQ band frequencies (Hz)
    private let bandFrequencies: [Float] = [31, 62, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    
    override init() {
        super.init()
        setupAudioEngine()
    }
    
    // MARK: - Setup
    
    private func setupAudioEngine() {
        // Attach nodes to audio engine
        audioEngine.attach(playerNode)
        audioEngine.attach(eqNode)
        
        // Set up EQ bands
        setupEQBands()
        
        // Connect nodes: playerNode -> eqNode -> audioEngine.mainMixerNode
        let audioFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        audioEngine.connect(playerNode, to: eqNode, format: audioFormat)
        audioEngine.connect(eqNode, to: audioEngine.mainMixerNode, format: audioFormat)
        
        // Start audio engine
        do {
            try audioEngine.start()
        } catch {
            print("Error starting audio engine: \(error)")
        }
    }
    
    private func setupEQBands() {
        // Configure 10-band parametric EQ
        guard eqNode.bands.count >= 10 else { return }
        
        for (index, frequency) in bandFrequencies.enumerated() {
            let band = eqNode.bands[index]
            band.frequency = frequency
            band.bandwidth = 1.0
            band.bypass = false
            band.gain = 0.0
        }
    }
    
    // MARK: - Playback Control
    
    func playAudio(filePath: String) {
        do {
            let url = URL(fileURLWithPath: filePath)
            audioFile = try AVAudioFile(forReading: url)
            
            guard let audioFile = audioFile else {
                print("Failed to load audio file")
                return
            }
            
            // Attach audio file to player node
            playerNode.stop()
            audioEngine.attach(playerNode)
            
            // Schedule audio buffer
            playerNode.scheduleFile(audioFile, at: nil)
            
            // Start playback
            if !playerNode.isPlaying {
                do {
                    try audioEngine.start()
                    playerNode.play()
                } catch {
                    print("Error starting playback: \(error)")
                }
            }
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    func stop() {
        playerNode.stop()
    }
    
    func pause() {
        playerNode.pause()
    }
    
    func resume() {
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }
    
    // MARK: - EQ Control
    
    func setEQBandGain(bandIndex: Int, gain: Float) {
        guard bandIndex >= 0 && bandIndex < eqNode.bands.count else { return }
        let clampedGain = max(-12.0, min(12.0, gain))
        eqNode.bands[bandIndex].gain = clampedGain
    }
    
    func setEQPreamp(gain: Float) {
        let clampedGain = max(-6.0, min(6.0, gain))
        audioEngine.mainMixerNode.outputVolume = pow(10.0, clampedGain / 20.0)
    }
    
    func setEQEnabled(enabled: Bool) {
        for band in eqNode.bands {
            band.bypass = !enabled
        }
    }
    
    func resetEQ() {
        for band in eqNode.bands {
            band.gain = 0.0
            band.bypass = false
        }
        audioEngine.mainMixerNode.outputVolume = 1.0
    }
    
    func applyEQSettings(
        gains: [Float],
        preamp: Float,
        enabled: Bool
    ) {
        // Apply all gains
        for (index, gain) in gains.enumerated() {
            if index < eqNode.bands.count {
                setEQBandGain(bandIndex: index, gain: gain)
            }
        }
        
        // Apply preamp
        setEQPreamp(gain: preamp)
        
        // Enable/disable EQ
        setEQEnabled(enabled: enabled)
    }
    
    deinit {
        audioEngine.stop()
    }
}
