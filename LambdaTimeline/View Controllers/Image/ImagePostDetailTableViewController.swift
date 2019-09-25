//
//  ImagePostDetailTableViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/14/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

class ImagePostDetailTableViewController: UITableViewController, AudioCommentTableViewCellDelegate, AVAudioPlayerDelegate {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else { return }
        
        title = post?.title
        
        imageView.image = image
        
        titleLabel.text = post.title
        authorLabel.text = post.author.displayName
    }
    
    // MARK: - Table view data source
    
    @IBAction func createComment(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add a comment", message: "Write your comment below:", preferredStyle: .alert)
        
        var commentTextField: UITextField?
        
        alert.addTextField { (textField) in
            textField.placeholder = "Comment:"
            commentTextField = textField
        }
        
        let addCommentAction = UIAlertAction(title: "Add Comment", style: .default) { (_) in
            
            guard let commentText = commentTextField?.text else { return }
            
            self.postController.addComment(with: commentText, to: &self.post!)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        //adding an audio comment option to go to another VC so user can record comments
        let addAudioCommentAction = UIAlertAction(title: "Or Add Audio Comment", style: .default) { (_) in
            self.performSegue(withIdentifier: "ToAddAudioComment", sender: self)
        }
        
        let addVideoCommentAction = UIAlertAction(title: "Or Add Video Comment", style: .default) { (_) in
            
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                self.showCamera()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granter) in
                    if granter {
                        DispatchQueue.main.async {
                            self.showCamera()
                        }
                    }
                }
            case .denied:
                return
            case .restricted:
                return
            default:
                return
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addCommentAction)
        alert.addAction(addAudioCommentAction)
        alert.addAction(addVideoCommentAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showCamera() {
        performSegue(withIdentifier: "ToAddVideoComment", sender: self)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (post?.comments.count ?? 0) - 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let comment = post?.comments[indexPath.row + 1]
        
        if comment?.audioURL == nil {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            cell.textLabel?.text = comment?.text
            cell.detailTextLabel?.text = comment?.author.displayName
            return cell
            
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioCommentCell", for: indexPath) as? AudioCommentsTableViewCell else {
                return AudioCommentsTableViewCell()}
            
            cell.comment = comment
            //assign delegate to self here
            cell.delegate = self
            
            self.loadAudio(for: cell, forItemAt: indexPath)
            return cell
        }
    }
    
    
    func loadAudio(for audioCommentCell: AudioCommentsTableViewCell, forItemAt indexPath: IndexPath) {
        
        guard let comment = audioCommentCell.comment else { return }
        
        if let audioData = cache.value(for: comment) {
            audioCommentCell.audioData = audioData
            return
        }
        
        let fetchAudioOp = FetchAudioOperation(comment: comment, postController: postController)
        
        let cacheOp = BlockOperation {
            if let audioData = fetchAudioOp.audioData {
                self.cache.cache(value: audioData, for: comment)
                DispatchQueue.main.async {
                    audioCommentCell.audioData = audioData
                }
            }
        }
        
        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: comment) }
            
            if let currentIndexPath = self.tableView?.indexPath(for: audioCommentCell),
                currentIndexPath != indexPath {
                print("Got image for now-reused cell")
                return
            }
            
            if let audioData = fetchAudioOp.audioData {
                audioCommentCell.audioData = audioData
            }
        }
        
        cacheOp.addDependency(fetchAudioOp)
        completionOp.addDependency(fetchAudioOp)
        
        audioFetchQueue.addOperation(fetchAudioOp)
        audioFetchQueue.addOperation(cacheOp)
        
        OperationQueue.main.addOperation(completionOp)
    }
    
    //delegate function
    func playRecodrig(for cell: AudioCommentsTableViewCell) {
        guard let data = cache.value(for: cell.comment) else { return }
        
        do {
            player = try AVAudioPlayer(data: data)
            player.delegate = self
            player.prepareToPlay()
            player.play()
        } catch {
            NSLog("Error playing recording: \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToAddAudioComment" {
            guard let destVC = segue.destination as? AudioCommentViewController else{return}
            destVC.postController = self.postController
            destVC.post = self.post
        }
    }
    
    private let audioFetchQueue = OperationQueue()
    private var operations = [Comment: Operation]()
    private let cache = Cache<Comment, Data>()
    
    var post: Post!
    var postController: PostController!
    var imageData: Data?
    var player: AVAudioPlayer!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var imageViewAspectRatioConstraint: NSLayoutConstraint!
}
