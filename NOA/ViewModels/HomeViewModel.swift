//
//  HomeViewModel.swift
//  NOA
//
//  Created by wi_seong on 2022/04/09.
//

import Foundation
import RxSwift

class HomeViewModel: NSObject {
//    @IBOutlet var service: NoaRepository!

    private var feedList: FeedResult = FeedResult.EMPTY
    private var loading = false
    
    var loadingStarted: () -> Void = { }
    var loadingEnded: () -> Void = { }
    var lectureListUpdated: () -> Void = { }
    
    func feedsCount() -> Int {
        return 3//feedList.list.count
    }

    func lecture(at index: Int) -> Feed {
        return feedList.list[index]
    }

    func list() {
//        loading = true
//        loadingStarted()
//        service.list {
//            self.lectureList = $0
//            self.lectureListUpdated()
//            self.loadingEnded()
//            self.loading = false
//        }
    }

    func next() {
//        if loading { return }
//        loading = true
//        loadingStarted()
//        service.next(currentPage: lectureList) {
//            var lectureList = $0
//            lectureList.lectures.insert(contentsOf: self.lectureList.lectures, at: 0)
//            self.lectureList = lectureList
//            self.lectureListUpdated()
//            self.loadingEnded()
//            self.loading = false
//        }
    }
}
