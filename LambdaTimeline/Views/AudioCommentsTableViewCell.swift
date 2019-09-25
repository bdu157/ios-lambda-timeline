//
//  AudioCommentsTableViewCell.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/22/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import AVFoundation

protocol AudioCommentTableViewCellDelegate: class {
    func playRecodrig(for cell: AudioCommentsTableViewCell)
}


class AudioCommentsTableViewCell: UITableViewCell {
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var listenToAudioCommentsLabel: UIButton!
    
    var audioData: Data!
    
    var comment: Comment! {
        didSet {
            self.updateViews()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    var delegate: AudioCommentTableViewCellDelegate?
    
    @IBAction func listenButtonTapped(_ sender: Any) {
        delegate?.playRecodrig(for: self)
    }
    
    func updateViews() {
        guard let comment = comment else {return}
        self.authorLabel.text = comment.author.displayName
    }
    
}
