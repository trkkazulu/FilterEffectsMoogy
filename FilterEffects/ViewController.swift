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
//import AVFoundation

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
    var player: AKPlayer!
    var myFile: AKAudioFile!
    var input: AKMicrophone!
    var bands = AVAudioUnitEQ.init(numberOfBands: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        //MARK: Create the AVFoundation player for testing
        
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
        
        
        //MARK: Create the AK player for testing
        
        
        if let file = try? AKAudioFile(readFileName: "bassClipCR.wav") {
            player = AKPlayer(audioFile: file)
            player.completionHandler = { Swift.print("completion callback has been triggered!") }
            
            
            
            
            
            //MARK: PROCESSES
            
            filter = AKMoogLadder(player, cutoffFrequency: 1100.0, resonance: 0.5)
            filterMixer = AKDryWetMixer(player, filter)
            filterMixer.balance = 0.5
            
            dist = AKDistortion(filter, delay: 0.0, decay: 0.0, delayMix: 0.0, decimation: 0.0, rounding: 0.0, decimationMix: 0.0, linearTerm: 1.0, squaredTerm: 1.0, cubicTerm: 1.0, polynomialMix: 1.0, ringModFreq1: 700.0, ringModFreq2: 350.0, ringModBalance: 0.5, ringModMix: 0.0, softClipGain: 0.0, finalMix: 1.0)
            
            distMixer = AKDryWetMixer(filterMixer, dist)
            distMixer.balance = 0.5
            
            booster = AKBooster(distMixer)
            
            booster.gain = 0.0
            
            AudioKit.output = booster
            
            do {
                try AudioKit.start()
                print("AuddioKit started")
            } catch {
                AKLog("AudioKit did not start!")
            }
            
            Audiobus.start()
            player.isLooping = true
            player.buffering = .always
            player.play()
        }
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
        stackView.spacing = 20
        
        // create sliders
        stackView.addArrangedSubview(AKSlider(
            property: "Filter Frequency",
            value: self.filter.cutoffFrequency,
            range: 30 ... 1100,
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
            range: 0 ... 0.99,
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
        
        
        //MARK: Add Views
        
        view.addSubview(stackView)
        
        stackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.9).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.9).isActive = true
        
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
    }
}


