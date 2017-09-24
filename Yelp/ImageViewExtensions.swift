//
//  ImageViewExtensions.swift
//  Yelp
//
//  Created by Hetang.Shah on 9/23/17.
//  Copyright © 2017 Hetang Shah. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension UIImageView {
    func setImageUrl(url: String, radius: CGFloat = 0.0) {
        let imageCache = AutoPurgingImageCache()
        if let cachedImage = imageCache.image(withIdentifier: url) {
            self.image = cachedImage.af_imageRounded(withCornerRadius: radius)
        } else {
            Alamofire.request(url).responseImage { response in
                if let image = response.result.value {
                    imageCache.add(image, withIdentifier: url)
                    self.alpha = 0.0
                    self.image = image.af_imageRounded(withCornerRadius: radius)
                    UIView.animate(withDuration: 0.5, animations: { () -> Void in
                        self.alpha = 1.0
                    })
                }
            }
        }
    }
}
