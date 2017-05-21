/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation


enum Streamer {
  typealias DailyEntry = (day: String, count: Double)
  
  private static let newStreamerValues = [70.0, 110.0, 96.0, 64.0, 81.0, 89.0, 77.0]
  private static let baseValue = 100000.0
  private static let totalValues = [887.0, 930.0, 1131.0, 5930.0, 11181.0, 2171.0, 6123.0, 3145.0, 2771.0, 1171.0, 2019.0, 1101.0, 2881.0, 1743.0]
  
  static var totalStreamers: Double {
    return totalValues.reduce(baseValue, +)
  }
  
  static var last7DaysNewStreamers: [DailyEntry] {
    return Array(
      zip(
        DateFormatter().shortWeekdaySymbols.map{$0.uppercased()},
        newStreamerValues.reversed()
      )
    )
  }
  
  static var aggregateTotalStreamers: [Double] {
    return totalValues.reduce([baseValue]){
      aggregate, value in aggregate + [aggregate.last! + value]
    }
  }
}
