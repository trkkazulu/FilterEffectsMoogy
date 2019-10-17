//
//  ViewController.swift
//  FilterEffects
//
//  Created by Aurelius Prochazka, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit
import AudioKitUI
import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var delay: AKVariableDelay!
    var delayMixer: AKDryWetMixer!
    var reverb: AKCostelloReverb!
    var reverbMixer: AKDryWetMixer!
    var booster: AKBooster!
    var dist: AKDistortion!
    var distMixer: AKDryWetMixer!
    var filter: AKMoogLadder!
    var filterMixer: AKDryWetMixer!
    var player: AVAudioPlayer!
    var myFile: AVAudioFile!
    var input: AKMicrophone!
    var bands = AVAudioUnitEQ.init(numberOfBands: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Create an equalizer
        
        var audioEngine: AVAudioEngine = AVAudioEngine()
        var equalizer: AVAudioUnitEQ!
        var audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
        // var audioFile: AVAudioFile!
        
        equalizer = AVAudioUnitEQ(numberOfBands: 3)
        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(equalizer)
        var bands = equalizer.bands
        let freqs = [60, 230, 600]
        audioEngine.connect(audioPlayerNode, to: equalizer, format: nil)
        audioEngine.connect(equalizer, to: audioEngine.outputNode, format: nil)
        
        for i in 0...(bands.count - 1) {
            
            bands[i].frequency = Float(freqs[i])
            bands[i].bypass = false
            bands[i].filterType = .parametric
        }
        
        bands[0].gain = -10.0
        bands[0].filterType = .lowPass
        bands[1].gain = -10.0
        bands[1].filterType = .lowShelf
        bands[2].gain = -10.0
        bands[2].filterType = .lowShelf
        
        
        
        
        //MARK: Create the player for testing
        
        //        let path = Bundle.main.path(forResource: "bassClipCR.wav", ofType:nil)!
        //        let url = URL(fileURLWithPath: path)
        //
        //        do {
        //            player = try AVAudioPlayer(contentsOf: url)
        //            player?.numberOfLoops = -1
        //            player?.play()
        //        } catch {
        //            print("Couldn't load file") // couldn't load file :(
        //      }
        
        
        do {
            if let filepath = Bundle.main.path(forResource: "bassClipCR", ofType: "wav") {
                let filepathURL = NSURL.fileURL(withPath: filepath)
                myFile = try AVAudioFile(forReading: filepathURL)
                audioEngine.prepare()
                try audioEngine.start()
                audioPlayerNode.scheduleFile(myFile, at: nil, completionHandler: nil)
                audioPlayerNode.play()
            }
        } catch _ {}
            
            //MARK: PROCESSES
            
            filter = AKMoogLadder(input, cutoffFrequency: 500.0, resonance: 0.5)
            filterMixer = AKDryWetMixer(input, filter)
            
            dist = AKDistortion(filterMixer, delay: 0.0, decay: 0.0, delayMix: 0.0, decimation: 0.0, rounding: 0.0, decimationMix: 0.0, linearTerm: 1.0, squaredTerm: 1.0, cubicTerm: 1.0, polynomialMix: 1.0, ringModFreq1: 0.0, ringModFreq2: 0.0, ringModBalance: 0.0, ringModMix: 0.0, softClipGain: -3.0, finalMix: 1.0)
            distMixer = AKDryWetMixer(filterMixer, dist)
            
            booster = AKBooster(distMixer)
            
            booster.gain = 0.0
            
            AudioKit.output = booster
            
//            do {
//                try AudioKit.start()
//                print("AuddioKit started")
//            } catch {
//                AKLog("AudioKit did not start!")
//            }
            
         //   Audiobus.start()
            
            setupUI()
        }
        
        
        //MARK: UI SETUP
        
        func setupUI() {
            
            //set up stackView
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .fill
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.spacing = 10
            
            // create sliders
            stackView.addArrangedSubview(AKSlider(
                property: "Filter Frequency",
                value: self.filter.cutoffFrequency,
                format: "%0.2f s") { sliderValue in
                    self.filter.cutoffFrequency = sliderValue
            })
            
            stackView.addArrangedSubview(AKSlider(
                property: "Filter Resonance",
                value: self.filter.resonance,
                range: 0 ... 0.99,
                format: "%0.2f") { sliderValue in
                    self.filter.resonance = sliderValue
            })
            
            stackView.addArrangedSubview(AKSlider(
                property: "Filter Mix",
                value: self.filterMixer.balance,
                format: "%0.2f") { sliderValue in
                    self.filterMixer.balance = sliderValue
            })
            
            stackView.addArrangedSubview(AKSlider(
                property: "Distortion",
                value: self.dist.softClipGain,
                range: 0 ... 0.99,
                format: "%0.2f") { sliderValue in
                    self.dist.softClipGain = sliderValue
            })
            
            stackView.addArrangedSubview(AKSlider(
                property: "Dist Mix",
                value: self.distMixer.balance,
                format: "%0.2f") { sliderValue in
                    self.distMixer.balance = sliderValue
            })
            
            stackView.addArrangedSubview(AKSlider(
                property: "Output Volume",
                value: self.booster.gain,
                range: 0 ... 2,
                format: "%0.2f") { sliderValue in
                    self.booster.gain = sliderValue
            })
            
            stackView.addArrangedSubview(AKSlider(property: "Band Gain", value: Double(bands.globalGain), range: -96...24, taper: 0.0, format: "%0.2f") {sliderValue in self.bands.globalGain = Float(sliderValue)})
            
            //MARK: Add Views
            
            view.addSubview(stackView)
            
            stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
            stackView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.9).isActive = true
            
            stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        }
}


