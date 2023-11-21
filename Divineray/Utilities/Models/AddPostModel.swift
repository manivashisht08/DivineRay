//
//  AddPostModel.swift
//  Divineray
//
//  Created by dr mac on 15/11/23.
//  Copyright © 2023 Dharmani Apps. All rights reserved.
//

import Foundation
struct AddPostModel: Codable {
    var status: Int?
    var message: String?
    var data: [Datum]?
    var params: Params?
    var dataFiles: DataFiles?
}

// MARK: - Datum
struct Datum: Codable {
    var id, tagID, videoID: String?

    enum CodingKeys: String, CodingKey {
        case id
        case tagID = "tagId"
        case videoID = "videoId"
    }
}

// MARK: - DataFiles
struct DataFiles: Codable {
    var postImage, postVideo: Post?
}

// MARK: - Post
struct Post: Codable {
    var name, type, tmpName: String?
    var error, size: Int?

    enum CodingKeys: String, CodingKey {
        case name, type
        case tmpName = "tmp_name"
        case error, size
    }
}

// MARK: - Params
struct Params: Codable {
    var userID, title, description, tags: String?
    var postHeight, postWidth, musicID, type: String?
    var isGroupPost: String?

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case title, description, tags, postHeight, postWidth
        case musicID = "musicId"
        case type, isGroupPost
    }
}
