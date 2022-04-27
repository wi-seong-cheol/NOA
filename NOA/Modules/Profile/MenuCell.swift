//
//  MenuCell.swift
//  NOA
//
//  Created by wi_seong on 2022/04/27.
//

import Foundation
import PagingKit

class MenuCell: PagingMenuViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override public var isSelected: Bool {
        didSet {
            if isSelected {
                titleLabel.textColor = UIColor(red: 229, green:  102, blue: 90)
            } else {
                titleLabel.textColor = UIColor(red: 203, green: 203, blue: 203)
            }
        }
    }
}
