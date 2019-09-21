//
//  AudioCommentViewController.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/21/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class AudioCommentViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: RECORDING
    
    private var recorder: AVAudioRecorder?
    
    private var recordingURL: URL?
    
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        defer {updateButtons()}
        
        guard !isRecording else {
            recorder?.stop()
            return
        }
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!

            recorder = try AVAudioRecorder(url: self.newRecordingURL(), format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording: \(error)")
        }
    }
    
    private func newRecordingURL() -> URL {
        let fm = FileManager.default
        let documentsDirectory = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent("caf")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recordingURL = recorder.url
        self.recorder = nil
        self.updateButtons()
    }
    
    
    //MARK: PLAYING
    private var player: AVAudioPlayer?
    
    private var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    @IBAction func playRecordedFile(_ sender: Any) {
        defer{updateButtons()}
        
        guard let url = self.recordingURL else {return}
        
        guard !isPlaying else {
            player?.stop()
            return
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()
        } catch {
            NSLog("Unable to start playing: \(error)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player = nil
        self.updateButtons()
    }
    
    
    //MARK: CANCEL
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //updateButtons for both of recording and playing
    private func updateButtons() {
        let playButtonString = self.isPlaying ? "Stop Playing" : "Play"
        self.sendButton.setTitle(playButtonString, for: .normal)
        
        let recordButtonString = self.isRecording ? "Stop Recording" : "Record"
        self.recordButton.setTitle(recordButtonString, for: .normal)
    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
}
