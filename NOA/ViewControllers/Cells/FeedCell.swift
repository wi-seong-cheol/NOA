//
//  FeedCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import UIKit

class FeedCell: UITableViewCell {
    static let identifier = "FeedCell"

    @IBOutlet var thumbnail: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var orgName: UILabel!
    @IBOutlet var duration: UILabel!

    var feed: Feed?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with feed: Feed) {
//        if let l = self.lecture, l.id == lecture.id { return }
//        
//        self.lecture = lecture
//        
//        thumbnail.image = nil
//        name.text = lecture.classfyName
//        orgName.text = lecture.orgName
//        duration.text = DateUtil.dueString(lecture.start, lecture.end)
//        
//        ImageLoader.loadImage(url: lecture.courseImage) { [weak self] image in
//            self?.thumbnail.image = image
//        }
    }
}
