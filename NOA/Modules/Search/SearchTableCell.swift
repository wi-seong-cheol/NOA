//
//  SearchTableCell.swift
//  NOA
//
//  Created by wi_seong on 2022/05/02.
//

import Foundation
import UIKit
import RxSwift

class SearchTableCell: UITableViewCell {
    static let identifier = "SearchTableCell"
    
    private let cellDisposeBag = DisposeBag()
    @IBOutlet weak var word: UILabel!
    
    var disposeBag = DisposeBag()
    let onData: AnyObserver<Search>
    
    required init?(coder aDecoder: NSCoder) {
        let data = PublishSubject<Search>()

        onData = data.asObserver()
        
        super.init(coder: aDecoder)
        
        data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] search in
                self?.word.text = search.post_title ?? ""
            })
            .disposed(by: cellDisposeBag)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}

