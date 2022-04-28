//
//  MenuCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import PagingKit

class MenuCell: PagingMenuViewCell {
    @IBOutlet weak var category: UIImageView!
    
    
    override public var isSelected: Bool {
        didSet {
            if isSelected {
                category.tintColor = .black
            } else {
                category.tintColor = UIColor(red: 203, green: 203, blue: 203)
            }
        }
    }
}
