//
//  Array+Only.swift
//  Memorize
//
//  Created by 김수환 on 2020/07/31.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
