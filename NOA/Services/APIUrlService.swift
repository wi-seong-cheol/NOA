//
//  APIService.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation

enum Path: String {
    // MARK: - Auth
    case duplication = "/duplicate-nickname"
    case register = "/regist-user"
    case withdraw = "/withdraw"
    case login = "/login"
    
    // MARK: - User
    case userInfo = "/user-info"
    case changeProfile = "/change-profile"
    case changeDesc = "/change-desc"
    case deleteProfile = "/delete-profile"
    case changeNickname = "/modify-user-nickname"
    case isFriend = "/user-is-friend"
    case friendList = "/user-all-friends"
    case blackList = "/user-blocking-friends"
    case friend = "/friend"
    case blockFriend = "/friend-blocking"
    case blockUser = "/user-blocking"
    case unblockFriend = "/friend-unblocking"
    
    // MARK: - Posting
    case posting = "/posting"
    case deletePosting = "/delete-posting"
    case likePosting = "/post-liked"
    
    // MARK: - Profile
    case userAllPostNum = "/user-all-post-num"
    case userNFTPostNum = "/user-nft-post-num"
    case userNormalPostNum = "/user-normal-post-num"
    
    // MARK: - Chat
    case makeRoom = "/make-chatroom"
    case chatList = "/rooms"
    case messages = "/msg"
    case nonReadMessageCount = "/chat-non-read-count"
    
    // MARK: - Search
    case searchNickname = "/search-by-nickname"
    case searchTag = "/search-by-post-tag"
    case searchTitleContent = "/search-by-title-content"
    case searchResult = "/search-result"
    
    // MARK: - Feed
    case homeFeed = "/home-post"
    case randomFeed = "/random-post"
    case userAllPost = "/user-all-post"
    case userNFTPost = "/user-nft-post"
    case userNormalPost = "/user-normal-post"
    
    // MARK: - Report
    case reportUser = "/report-user"
    case reportFeed = "/report-post"
}

class APIUrlService {
    
    @Inject var readPList: ReadPList
    func serviceUrl(_ path: Path) -> String {
       //개발
        return DBInfo.service_url + path.rawValue
   }
}
