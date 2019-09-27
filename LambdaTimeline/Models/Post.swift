//
//  Post.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/11/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreLocation

enum MediaType: String {
    case image
}

class Post: NSObject {
    
    init(title: String, mediaURL: URL, ratio: CGFloat? = nil, author: Author, timestamp: Date = Date(), geotag: CLLocationCoordinate2D) {
        self.mediaURL = mediaURL
        self.ratio = ratio
        self.mediaType = .image
        self.author = author
        self.comments = [Comment(text: title, author: author)]
        self.timestamp = timestamp
        self.geotag = geotag
        
    }
    
    init?(dictionary: [String : Any], id: String) {
        guard let mediaURLString = dictionary[Post.mediaKey] as? String,
            let mediaURL = URL(string: mediaURLString),
            let mediaTypeString = dictionary[Post.mediaTypeKey] as? String,
            let mediaType = MediaType(rawValue: mediaTypeString),
            let authorDictionary = dictionary[Post.authorKey] as? [String: Any],
            let author = Author(dictionary: authorDictionary),
            let timestampTimeInterval = dictionary[Post.timestampKey] as? TimeInterval,
            let captionDictionaries = dictionary[Post.commentsKey] as? [[String: Any]],
            let longitude = dictionary[Post.longitudeKey] as? Double,
            let latitude = dictionary[Post.latitudeKey] as? Double
            else { return nil }
        
        self.mediaURL = mediaURL
        self.mediaType = mediaType
        self.ratio = dictionary[Post.ratioKey] as? CGFloat
        self.author = author
        self.timestamp = Date(timeIntervalSince1970: timestampTimeInterval)
        self.comments = captionDictionaries.compactMap({ Comment(dictionary: $0) })
        self.id = id
        self.geotag = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var dictionaryRepresentation: [String : Any] {
        var dict: [String: Any] = [Post.mediaKey: mediaURL.absoluteString,
                Post.mediaTypeKey: mediaType.rawValue,
                Post.commentsKey: comments.map({ $0.dictionaryRepresentation }),
                Post.authorKey: author.dictionaryRepresentation,
                Post.timestampKey: timestamp.timeIntervalSince1970,
                Post.longitudeKey: geotag.longitude,
                Post.latitudeKey: geotag.latitude]
        
        guard let ratio = self.ratio else { return dict }
        
        dict[Post.ratioKey] = ratio
        
        return dict
    }
    
    var mediaURL: URL
    let mediaType: MediaType
    let author: Author
    let timestamp: Date
    var comments: [Comment]
    var id: String?
    var ratio: CGFloat?
    
    var geotag: CLLocationCoordinate2D
    
    var title: String? {
        return comments.first?.text
    }
    
    static private let mediaKey = "media"
    static private let ratioKey = "ratio"
    static private let mediaTypeKey = "mediaType"
    static private let authorKey = "author"
    static private let commentsKey = "comments"
    static private let timestampKey = "timestamp"
    static private let idKey = "id"
    static private let longitudeKey = "longitude"
    static private let latitudeKey = "latitude"
}


/*

for location to be pushed into firebase when posting an image
 
updated
 -init()
 self.geotag = geotag
 
 -init?()
 let longitude = dictionary[Post.longitudeKey] as? Double,
 let latitude = dictionary[Post.latitudeKey] as? Double
 
 self.geotag = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
 
 -dictionaryRepresentation
 Post.longitudeKey: geotag.longitude,
 Post.latitudeKey: geotag.latitude]
 
 -Post: NSObject
 var geotag: CLLocationCoordinate2D
 
 -static private properties for dictionary keys
 static private let longitudeKey = "longitude"
 static private let latitudeKey = "latitude"
 
 -added Post+Mapping
 -update postController for createPost and Post
 -updated imagePostViewController to get current latitude and longitude and pass them into createPost and Post
*/
