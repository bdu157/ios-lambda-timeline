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
    
    var post: Post!
    var postController: PostController!
    
    var session: AVAudioSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVAudioSession.sharedInstance()
        
        do {
            
            try session.setCategory(.playAndRecord, mode: .default, options: [])
            try session.setActive(true)
            session.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                    } else {
                        self.presentInformationalAlertController(title: "Unable to record audio", message: "Audio recording permissions not granted")
                    }
                }
            }
        } catch {
            NSLog("Error with audio record permissions: \(error)")
            self.presentInformationalAlertController(title: "Unable to record audio", message: "Audio recording failed. Try again.")
        }
    }
    
    
    //MARK: RECORDING
    
    private var recorder: AVAudioRecorder?
    
    private var recordingURL: URL?
    
    private var isRecording: Bool {
        return recorder?.isRecording ?? false
    }
    
    
    //record button
    @IBAction func recordButtonTapped(_ sender: Any) {
        defer {updateButtons()}
        
        guard !isRecording else {
            recorder?.stop()
            return
        }
        
        guard let fileURL = self.fileURL else {return}
        
        do {
            let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!

            recorder = try AVAudioRecorder(url: fileURL, format: format)
            recorder?.delegate = self
            recorder?.record()
        } catch {
            NSLog("Unable to start recording: \(error)")
        }
    }
    
    var fileURL: URL? {
        let fm = FileManager.default
        let documentsDirectory = try! fm.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent("caf")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        self.recordingURL = recorder.url
        self.recorder = nil
        self.updateButtons()
    }
    //MARK: DONE button
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if let fileURL = fileURL,
            let data = try? Data(contentsOf: fileURL),
            let post = post {
            
            let alert = UIAlertController(title: "do you want to send the comment or cancel the recording?", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "Send", style: .default) { (_) in
                self.postController.addComment(with: data, to: post) {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
                self.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(action)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
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
        navigationController?.popViewController(animated: true)
        
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
