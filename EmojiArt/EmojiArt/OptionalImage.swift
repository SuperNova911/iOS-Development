//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by 김수환 on 2020/09/26.
//  Copyright © 2020 Suwhan Kim. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
