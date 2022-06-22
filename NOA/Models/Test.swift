//
//  Test.swift
//  NOA
//
//  Created by wi_seong on 2022/04/13.
//

import Foundation

protocol LectureType {
    var id: String { get }
    var number: String { get }
    var name: String { get }
    var classfyName: String { get }
    var middleClassfyName: String? { get }
    var courseImage: String { get }
    var courseImageLarge: String { get }
    var shortDescription: String { get }
    var orgName: String { get }
    var start: Date { get }
    var end: Date { get }
    var teachers: String { get }
    var overview: String? { get }
}

protocol LectureListType {
    var count: Int { get }
    var numPages: Int { get }
    var previous: String? { get }
    var next: String { get }
    var lectures: [Lecture] { get }
}

struct Lecture: Codable, LectureType {
    let id: String                 // 아이디
    let number: String             // 강좌번호
    let name: String               // 강좌명
    let classfyName: String        // 강좌분류
    let middleClassfyName: String? // 강좌분류2
    let courseImage: String        // 강좌 썸네일 (media>image>small)
    let courseImageLarge: String   // 강좌 이미지 (media>image>large)
    let shortDescription: String   // 짧은 설명
    let orgName: String            // 운영기관
    let start: Date                // 운영기간 시작
    let end: Date                  // 운영기간 종료
    let teachers: String           // 교수진
    let overview: String?          // 상제정보(html)
    
    enum CodingKeys: String, CodingKey {
        case id
        case number
        case name
        case classfyName = "classfy_name"
        case middleClasssfyName = "middle_classfy_name"
        case courseImage = "small"
        case courseImageLarge = "large"
        case shortDescription = "short_description"
        case orgName = "org_name"
        case start
        case end
        case teachers
        case overview

        // 중첩된 JSON Object에 접근하기 위한 키
        case media
        case image
    }
    
    init(id: String,
         number: String,
         name: String,
         classfyName: String,
         middleClassfyName: String?,
         courseImage: String,
         courseImageLarge: String,
         shortDescription: String,
         orgName: String,
         start: Date,
         end: Date,
         teachers: String,
         overview: String?
    ) {
        self.id = id
        self.number = number
        self.name = name
        self.classfyName = classfyName
        self.middleClassfyName = middleClassfyName
        self.courseImage = courseImage
        self.courseImageLarge = courseImageLarge
        self.shortDescription = shortDescription
        self.orgName = orgName
        self.start = start
        self.end = end
        self.teachers = teachers
        self.overview = overview
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.number = try container.decode(String.self, forKey: .number)
        self.name = try container.decode(String.self, forKey: .name)
        self.classfyName = try container.decode(String.self, forKey: .classfyName)
        self.middleClassfyName = try? container.decode(String.self, forKey: .middleClasssfyName)
        self.shortDescription = try container.decode(String.self, forKey: .shortDescription)
        self.orgName = try container.decode(String.self, forKey: .orgName)
        self.start = DateUtil.parseDate(try container.decode(String.self, forKey: .start))
        self.end = DateUtil.parseDate(try container.decode(String.self, forKey: .end))
        self.teachers = try container.decode(String.self, forKey: .teachers)
        self.overview = try? container.decode(String.self, forKey: .overview)
        
        // media 키 안의 JSON Object에 대한 컨테이너를 가져온다.
        let mediaContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .media)
        // image 키 안의 JSON Object에 대한 컨테이너를 가져온다.
        let imageContainer = try mediaContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .image)
        self.courseImage = try imageContainer.decode(String.self, forKey: .courseImage)
        self.courseImageLarge = try imageContainer.decode(String.self, forKey: .courseImageLarge)
    }
    
    func encode(to encoder: Encoder) throws {
        // encode code
    }
}

extension Lecture {
    static let EMPTY = Lecture(id: "", number: "", name: "", classfyName: "", middleClassfyName: "", courseImage: "", courseImageLarge: "", shortDescription: "", orgName: "", start: Date(), end: Date(), teachers: "", overview: "")
}
extension Lecture: Equatable {
    static func == (lhs: Lecture, rhs: Lecture) -> Bool {
        return lhs.id == rhs.id && lhs.number == rhs.number && lhs.name == rhs.name && lhs.classfyName == rhs.classfyName && lhs.middleClassfyName == rhs.middleClassfyName && lhs.courseImage == rhs.courseImage && lhs.courseImageLarge == rhs.courseImageLarge && lhs.shortDescription == rhs.shortDescription && lhs.orgName == rhs.orgName && lhs.start == rhs.start  && lhs.end == rhs.end && lhs.teachers == rhs.teachers && lhs.overview == rhs.overview
    }
}
struct LectureList: Codable, LectureListType {
    let count: Int
    let numPages: Int
    var previous: String?
    let next: String
    var lectures: [Lecture]
    
    enum CodingKeys: String, CodingKey {
        case count
        case numPages = "num_pages"
        case previous
        case next
        case lectures
        
        // 중첩된 JSON Object에 접근하기 위한 키
        case pagination
        case results
    }
    
    init(count: Int,
         numPages: Int,
         previous: String,
         next: String,
         lectures: [Lecture]) {
        self.count = count
        self.numPages = numPages
        self.previous = previous
        self.next = next
        self.lectures = lectures
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // pagination 키 안의 JSON Object에 대한 컨테이너를 가져온다.
        let paginationContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pagination)
        self.count = try paginationContainer.decode(Int.self, forKey: .count)
        self.numPages = try paginationContainer.decode(Int.self, forKey: .numPages)
        self.previous = try? paginationContainer.decode(String.self, forKey: .previous)
        self.next = try paginationContainer.decode(String.self, forKey: .next)
        
        // result 키 안의 JSON Object에 대한 컨테이너를 가져온다.
        self.lectures = try container.decode([Lecture].self, forKey: .results)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var paginationContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .pagination)
        try paginationContainer.encode(count, forKey: .count)
        try paginationContainer.encode(numPages, forKey: .numPages)
        try paginationContainer.encode(previous, forKey: .previous)
        try paginationContainer.encode(lectures, forKey: .lectures)
        
        var resultContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .results)
        try resultContainer.encode(lectures, forKey: .lectures)
    }
}

extension LectureList {
    static let EMPTY = LectureList(count: 0, numPages: 0, previous: "", next: "", lectures: [])
}

class DateUtil {
    static func parseDate(_ dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.date(from: dateString) ?? Date()
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        return formatter.string(from: date)
    }
    
    static func dueString(_ start: Date, _ end: Date) -> String{
        return "\(formatDate(start)) ~ \(formatDate(end))"
    }
}
