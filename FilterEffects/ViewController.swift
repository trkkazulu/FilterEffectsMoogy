//
//  ViewController.swift
//  FilterEffectsMoogy
//
/*
 
 It appears that the problem has something to do with the distortion code. So i've fixed it by rewriting the dist. This works
 now. Add the envelope filter. EnvFltr added. I also learned that .AIF files don't work in Xcode.
 
 
 */


import AudioKit
import AudioKitUI
import UIKit

class ViewController: UIViewController {
    
    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!
    var reverb: AKCostelloReverb!
    var reverbMixer: AKDryWetMixer!
    var booster: AKBooster!
   // var dist: AKDistortion!
    var distMixer: AKDryWetMixer!
    var filter: AKMoogLadder!
    var filterMixer: AKDryWetMixer!
    var input = AKMicrophone()
    var player: AKPlayer!
    var lpFilter: AKLowPassFilter!
    var envel: AKAmplitudeEnvelope!
    var octv: AKPitchShifter!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Create the player for testing
        
        if let file = try? AKAudioFile(readFileName: "OLBass.wav") {
            
            player = AKPlayer(audioFile: file)
            player.completionHandler = { Swift.print("completion callback has been triggered!")
                
            }
            
            player.isLooping = true
            print("Player created and looping")
            
        }
        
        
        //MARK: PROCESSES
        
        octv = AKPitchShifter(player, shift: -12.00, windowSize: 1024, crossfade: 512)
        
        let filtOct = AKLowPassFilter(octv, cutoffFrequency: 98.0, resonance: 0.5)
        let squash = AKCompressor(filtOct, threshold: -10.0, headRoom: 0.5, attackDuration: 0.2, releaseDuration: 0.5, masterGain: 3.0)
        
        filter = AKMoogLadder(player, cutoffFrequency: 650.00, resonance: 0.5)
        
        envel = AKAmplitudeEnvelope(filter, attackDuration: 0.3, decayDuration: 0.2, sustainLevel: 0.99, releaseDuration: 0.3)
        
        //let wha = AKAutoWah(filter, wah: 2.0, mix: 1.0, amplitude: 1.0)
        
        envel.start() // envelope must be started or there won't be any sound

        filterMixer = AKDryWetMixer(squash, envel)
        
        filterMixer.balance = 1.0

        
        let dist = AKClipper(filterMixer, limit: 0.8)
//        dist.linearTerm = 0.5
//        dist.squaredTerm = 1.00
//        dist.cubicTerm = 1.00
//        dist.softClipGain = 1.00
        
        
        lpFilter = AKLowPassFilter(dist, cutoffFrequency: 650.00, resonance: 0.5)
        lpFilter.start()
        
        distMixer = AKDryWetMixer(filterMixer, lpFilter)
        
        distMixer.balance = 0.5
        
        booster = AKBooster(distMixer)
        booster.start()
        
        
        booster.gain = 0.0
        
        AudioKit.output = booster
        
          do {
                 try AudioKit.start()
            
             } catch {
                
                 AKLog("AudioKit did not start!")
             }
        
        
        setupUI()
    }
    
    
    //MARK: UI SETUP
    
    func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        
        stackView.addArrangedSubview(AKSlider(
            property: "Filter Frequency",
            value: self.filter.cutoffFrequency,
            range: 0 ... 630,
            format: "%0.2f hz") { sliderValue in
                self.filter.cutoffFrequency = sliderValue
        })

        stackView.addArrangedSubview(AKSlider(
            property: "Filter Resonance",
            value: self.filter.resonance,
            range: 0 ... 0.99,
            format: "%0.2f") { sliderValue in
                self.filter.resonance = sliderValue
        })
        
//        stackView.addArrangedSubview(AKSlider(
//                   property: "Octave Mix",
//                   value: self.octv.crossfade,
//                   range: 0 ... 1.0,
//                   format: "%0.2f") { sliderValue in
//                    self.octv.crossfade = sliderValue
//               })

        stackView.addArrangedSubview(AKSlider(
            property: "Filter Mix",
            value: self.filterMixer.balance,
            range: 0 ... 0.99,
            format: "%0.2f") { sliderValue in
                self.filterMixer.balance = sliderValue
        })
        
//        stackView.addArrangedSubview(AKSlider(
//            property: "Distortion",
//            value: self.dist.decimation,
//            range: 0 ... 1,
//            format: "%0.2f") { sliderValue in
//                self.dist.decimation = sliderValue
//        })
//
        stackView.addArrangedSubview(AKSlider(
            property: "Dist Mix",
            value: self.distMixer.balance,
            range: 0 ... 1.0,
            format: "%0.2f") { sliderValue in
                self.distMixer.balance = sliderValue
        })
        
        stackView.addArrangedSubview(AKSlider(
            property: "Output Volume",
            value: self.booster.gain,
            range: 0 ... 10,
            format: "%0.2f") { sliderValue in
                self.booster.gain = sliderValue
        })
        
        stackView.addArrangedSubview(AKButton(title: "Player Start"){ (button) in
            self.player.play()
        })
        
        
              stackView.addArrangedSubview(AKButton(title: "Player Stop"){ (button) in
                  self.player.stop()
              })
        
        //MARK: Add Views
        
        view.addSubview(stackView)
        
        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.9).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}




