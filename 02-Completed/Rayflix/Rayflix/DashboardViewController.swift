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


import UIKit
import Charts

class DashboardViewController: UIViewController {
  
  @IBOutlet weak var totalStreamersLabel: UILabel!
  
  @IBOutlet weak var totalStreamersLineChartView: LineChartView!
  @IBOutlet weak var newStreamersBarChartView: BarChartView!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    totalStreamersLabel.text = formatter.string(from: NSNumber(value: Streamer.totalStreamers))
    
    configureDefaults(forChart: totalStreamersLineChartView)
    configureLineChart()
    
    configureDefaults(forChart: newStreamersBarChartView)
    configureBarChart()
  }
  
  private func configureDefaults(forChart chart: BarLineChartViewBase) {
    chart.chartDescription?.enabled = false
    chart.legend.enabled = false
    chart.backgroundColor = .clear
    chart.isUserInteractionEnabled = false
    
    chart.xAxis.drawAxisLineEnabled = false
    chart.xAxis.drawGridLinesEnabled = false

    chart.leftAxis.drawAxisLineEnabled = false
    chart.leftAxis.drawGridLinesEnabled = false
    chart.leftAxis.labelTextColor = .white
    
    chart.rightAxis.enabled = false
  }
  
  private func configureLineChart() {
    totalStreamersLineChartView.xAxis.drawLabelsEnabled = false
    totalStreamersLineChartView.leftAxis.valueFormatter = LargeValueFormatter()
    totalStreamersLineChartView.data = totalStreamersData()
  }
  
  private func totalStreamersData() -> LineChartData {
    let entries = Streamer.aggregateTotalStreamers.enumerated().map { ChartDataEntry(x: Double($0), y: $1) }
    
    let dataSet = LineChartDataSet(values: entries, label: nil)
    dataSet.colors = [.white]
    dataSet.drawCirclesEnabled = false
    dataSet.fillAlpha = 1.0
    dataSet.drawFilledEnabled = true
    dataSet.fillColor = .white
    
    let data = LineChartData(dataSets: [dataSet])
    data.setDrawValues(false)
    
    return data
  }
  
  private func configureBarChart() {
    newStreamersBarChartView.xAxis.valueFormatter = DayNameFormatter()
    newStreamersBarChartView.xAxis.labelPosition = .bottom
    newStreamersBarChartView.xAxis.labelTextColor = .white
    newStreamersBarChartView.data = newStreamersData()
  }
  
  private func newStreamersData() -> BarChartData {
    let entries = Streamer.last7DaysNewStreamers.enumerated().map { BarChartDataEntry(x: Double($0), y: $1.count) }
    
    let dataSet = BarChartDataSet(values: entries, label: nil)
    dataSet.drawValuesEnabled = false
    dataSet.colors = [.white]
    
    return BarChartData(dataSets: [dataSet])
  }
}

