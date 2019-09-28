//
//  Post+Mapping.swift
//  LambdaTimeline
//
//  Created by Dongwoo Pae on 9/27/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import Foundation
import MapKit

extension Post: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return geotag
    }
    var subtitle: String? {
        return author.displayName
    }
}
