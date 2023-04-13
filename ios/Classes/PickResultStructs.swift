//
//  PickResultStructs.swift
//  kang_image_picker
//
//  Created by kangkang on 2023/3/6.
//

import Foundation

struct PhotoPickResult: CustomStringConvertible {
    var id: String
    var path: String
    var width: Int
    var height: Int
    var filename: String?
    var mimeType: String?
    var size: Int

    func toMap() -> [String: Any?] {
        var map = [String: Any?]()
        map["id"] = id
        map["path"] = path
        map["width"] = width
        map["height"] = height
        map["filename"] = filename
        map["mimeType"] = mimeType
        map["size"] = size
        return map
    }

    var description: String {
        return """
        PhotoPickResult{
            id:\(id)
            path:\(path)
            width:\(width)
            height:\(height)
            filename:\(String(describing: filename))
            mimeType:\(String(describing: mimeType))
            size:\(String(describing: size))
        }
        """
    }
}

struct VideoPickResult: CustomStringConvertible {
    var videoPath: String
    var videoFilename: String
    var duration: Double
    var thumbnailPath: String
    var thumbnailFilename: String
    var thumbnailWidth: Int
    var thumbnailHeight: Int
    var size: Int

    func toMap() -> [String: Any?] {
        var map = [String: Any?]()
        map["videoPath"] = videoPath
        map["videoFilename"] = videoFilename
        map["duration"] = duration
        map["thumbnailPath"] = thumbnailPath
        map["thumbnailFilename"] = thumbnailFilename
        map["thumbnailWidth"] = thumbnailWidth
        map["thumbnailHeight"] = thumbnailHeight
        map["size"] = size
        return map
    }

    var description: String {
        return """
        VideoPickResult{
            videoPath:\(videoPath)
            videoFilename:\(videoFilename)
            duration:\(duration)
            thumbnailPath:\(String(describing: thumbnailPath))
            thumbnailWidth:\(String(describing: thumbnailWidth))
            thumbnailHeight:\(String(describing: thumbnailHeight))
            size:\(String(describing: size))
        }
        """
    }
}
