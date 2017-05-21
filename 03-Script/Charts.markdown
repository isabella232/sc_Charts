## Introduction

**Jessy**  
Hey, what's up everybody, this is Jessy. In today's screencast I'm going to introduce you to a really popular charting framework aptly named `Charts`.

**Catie**  
> look at camera
I'm Catie and I'll be learning along with you.

**Jessy** 
As the name might imply, `Charts` is an open source charting framework, written in Swift by Daniel Cohen Gindi. It's heavily inspired by the `MPAndroidCharts` library for Android, and as such shares an almost identical API. This is great if you're working cross-platform, since the learning curve is reduced and productivity increased.

The framework provides 8 different chart types out-of-the-box, has full support for pinching and panning, is highly configurable, and even provides build-up animations for both axes. 

But the easiest—and most enjoyable!—way to understand `Charts` is to begin using it!

**Catie**  
So let’s dive in!

## Demo

> Open Podfile

**Jessy**  
I've gone ahead and installed `Charts` using Cocoapods, and will therefore be working in the Xcode workspace rather than the project.

> Open Rayflix.xcworkspace, and then open Main.storyboard

As you can see I've already got my view controller laid out, including two views, one for each of the charts I'll add. I'm going to render a line chart in the upper view, and a bar chart in the lower view.

The first thing I need to do is set the custom class for the upper view. To do that, I select the **Total Streamers Chart** from the Document Outline, and then in the **Identity Inspector** set **Class** to `LineChartView` from the **Charts** module.

Next, I need to hook this view up to an outlet in the view controller.

> Open DashboardViewController.swift

I'll start by importing the `Charts` framework so that I have access to its classes and protocols:

```
import Charts
```

And then I declare an outlet for the view I just configured in the storyboard. The type needs to be the same as what I set in the **Identity Inspector**, which, again, is `LineChartView`.

```
@IBOutlet weak var totalStreamersLineChartView: LineChartView!
```

Finally, I just need to connect the outlet to the view in the storyboard:

> Open Main.storyboard, and drag from the outlet to `LineChartView` to connect them. Then build and run.

All has gone well, so I see the line chart is working. It's displaying the default "no chart data available" message. 

**Catie**  
A chart without data is like a donut without sugar. You should fix that!

## Interlude

**Jessy**  
In order to work effectively with the `Charts` framework, you need to understand the class heirarchy and how all the pieces fit together. The developers have done a really good job of pulling out the fundamental pieces of a chart into their own classes, but this can make it a touch overwhelming when first using the framework.

**Catie**
How's the documentation?

**Jessy**    
It provides really good coverage, I won't go too deep into in this screencast. The main things to remember are that a chart requires data, data is made up from one or more data sets, and a data set is a collection of data entries, which in turn represent the x and y values of a plot on a chart. 

**Catie**  
Sounds simple enough!

## Demo

> Open DashboardViewController.swift

To keep things tidy, I'm going to configure `totalStreamersLineChartView` in its `didSet` observer, which is called when it's assigned the value you connected in Interface Builder. I'll use a closure to assign its data property. To start off with, I'll return nil, to avoid having errors as I put the data together.

```swift
  @IBOutlet var totalStreamersLineChartView: LineChartView! {
    😺didSet {
      totalStreamersLineChartView.data = {
        return nil
      }()
    }🏁
  }
```
This closure is about to encapsulate the entire process of creating the data entries, the data set, and finally the data itself.

To create the data entries I'll use a static property on the `Streamer` model type that returns an array of the total number of streamers per day for the past two weeks. 

```swift
	Streamer.aggregateTotalStreamers
```

I'll use the `enumerated` method, as I need both the indices _and_ values of that array, as I pipe them into `map`, creating instances of `ChartDataEntry`. The indices are the `x` values, but they needed to be converted to `Double`s first. The streamer counts are already `Double`s so they can be used as the `y` values directly.

```swift
        let entries =
          Streamer.aggregateTotalStreamers
          .enumerated()
          .map{index, total in ChartDataEntry(x: Double(index), y: total)}
        
        return nil
```

**Catie**  
Now you have the data *entries*. You said that you need to put them into data *sets*.

**Jessy**  
Exactly. I can initialize a `LineChartDataSet` using these entries, and `nil` for the label argument. The chart won't be displaying a legend so a label's not needed.

```swift
        let dataSet = LineChartDataSet(
          values:
            Streamer.aggregateTotalStreamers
            .enumerated()
            .map{index, total in ChartDataEntry(x: Double(index), y: total)},
          label: nil
        )

```

**Catie**  
And then, can you use that data set to initialize the `ChartData` that you need?

**Jessy**  
Basically. I can create an instance of `LineChartData` using this dataset (and return that, now that we've got something better than the nil placeholder). 

```swift
let data = LineChartData(dataSets: [dataSet])
return data
```

But, note how the initializer necessitates an array. That's because a chart can display multiple data sets at once. In this case I'm just passing a single-element array. 

```
let data = LineChartData(dataSets: [dataSet])
return data
```

<!--With the data set up, I'll now add a second method responsible for configuring the line chart.

```
private func configureLineChart() {
  
}
```-->
Now I can build and run!

> Build and run, and demonstrate how the chart is now populated with the streaming data

## Interlude
> Put chart in middle of on-camera screen

**Catie**  
At this point the line chart is accurately rendering the Rayflix streamers data, but its appearance leaves much to be desired—the mundane coloring, the cramped numbers, and what's with all those grid lines? 

**Jessy**  
I'm not sure whether or not this is a holdover from the framework's roots in Android, but the developers have decided to enable _every_ visual feature by default. Luckily they've also made all those features configurable. 

## Demo

> Open DashboardViewController.swift

There are certain features that I want to disable for both charts, so to avoid repetition I'll do that in a fileprivate extension method on `BarLineChartViewBase`—the parent class of both the line and bar chart.

```swift
//MARK:- BarLineChartViewBase
private extension BarLineChartViewBase {
  func configureDefaults() {
  }
}
```

I'll begin by disabling some top level objects such as the description and legend, as well as setting the chart's background color and whether or not it's interactive.

```swift
chartDescription?.enabled = false
legend.enabled = false
backgroundColor = .clear
isUserInteractionEnabled = false
```

Next I want to disable some of the superfluous grid lines the chart renders by default, so it will more closely align with the overall aesthetics of the Rayflix app. I'll apply the same changes to the horizontal "`xAxis`", and the vertical "`leftAxis`"…

```  
    for axis in [xAxis, leftAxis] {
      axis.drawAxisLineEnabled = false
      axis.drawGridLinesEnabled = false
    }
```

…whose labelTextColor I'll set to white, for better legibility.

```
leftAxis.labelTextColor = .white
```

And as I don't want either chart to display a second Y axis on the right, I'll just disable that one.

```  
rightAxis.enabled = false
```

**Catie**  
And now you add a call to this `configureDefaults` method in the didSet observer for `totalStreamersLineChartView`. 

**Jessy**  
Right!

```swift
    didSet {
      totalStreamersLineChartView.configureDefaults()
      totalStreamersLineChartView.data = {
```

Also, unlike the bar chart I'll be setting up next, I want to disable the line chart x axis labels. I'll do that here too.

```swift
totalStreamersLineChartView.configureDefaults()
      totalStreamersLineChartView.xAxis.drawLabelsEnabled = false
      totalStreamersLineChartView.data = {
```

## Interlude

> show onscreen again

**Catie**  
The chart would look far better if those ghastly circles were removed, a solid color was drawn under the curve, and if the chart values were hidden. How can you configure how the data itself is rendered?

**Jessy**  
As you've already seen the `Charts` framework is highly configurable, so after a quick read through the documentation I was able to find the necessary methods and properties to achieve exactly the look you're talking about!

It turns out that you use `LineChartDataSet` to configure the appearance of the data, which in hindsight makes perfect sense. 

## Demo

Now I'll add the configuration to the `LineChartDataSet` I created.

To set the color of the line I use a `UIColor` array.

```
dataSet.colors = [.white]
```

An array is used because I can assign a different color to each data point. If there are more data points than there are colors in the array, the array will be cycled. As I'm only passing a single color it'll be used by every point.

Disabling those ghastly circles is easy enough.

```
dataSet.drawCirclesEnabled = false
```

In order to render the chart with a fill, instead of as a thin line, I need to tell the data set that to draw that fill, and provide a color and an alpha value for it.

```
dataSet.drawFilledEnabled = true
dataSet.fillColor = .white
dataSet.fillAlpha = 1.0
```

Lastly, the option to display the data values is on `LineChartData`, not `LineChartDataSet`.

```swift
let data = LineChartData(dataSets: [dataSet])
data.setDrawValues(false)
return data
```

## Interlude

**Catie**  
Hang on, that doesn't look like Swift.

**Jessy**   
But perhaps suspiciously …like a Java setter method!? As I mentioned earlier the `Charts` framework is actually a port of the popular Android charting library `MPAndroidChart`, and you will occasionally come across a stray Java-like method such as this one. But rest assured that the developers are working hard to make the entire framework as Swift-y as possible while still maintaining its roots.

Here's what happens if I build and run now!

> show that in the middle of the screen

**Catie**  
The looks much better! But something needs to be done about the formatting of the y axis values.

**Jessy**  
When a chart is rendered, the `Charts` framework will attempt to determine what values are shown on each visible axis based on the data it's plotting. However, these values will always be numeric because you can only provide instances of `Double` as the `x` and `y` values.

To workaround this limitation, `Charts` provides the concept of an axis value formatter, by way of the `IAxisValueFormatter` protocol. 

**Catie**  
"I" as a prefix for interface? Again, not very Swifty!
> shakes head

**Jessy**  
But it gets the job done! When a chart is about to be rendered it will call through to any provided axis value formatters, passing the numeric value, and rendering the returned string in its place.

This mechanism can be used to convert a set of numbers between 1 and 7 into days of the week, for example.

## Demo

I've already created an empty Swift class that'll act as my x axis value formatter for the line chart. 

> Open Value Formatters/LargeValueFormatter.swift

In order to be able to use this class as a value formatter, I'll first import the `Charts` framework so that I can access its protocols.

```
import Charts
```

And then I'll declare the class conforms to the `IAxisValueFormatter` protocol.

```
class LargeValueFormatter: NSObject, IAxisValueFormatter
```

The `IAxisValueFormatter` protocol declares a single method that receives a value and an optional instance of `AxisBase`, and returns a string. For the purposes of this screencast I'm really only interested in the value.

```
func stringForValue(_ value: Double, axis: AxisBase?) -> String {

}
```

The value that's passed to this method isn't the data value, but rather the value that represents that data on the axis the formatter is attached to. For this axis I simply want to format the numbers so they're prettier and easier to read is such a confined space. And I can use `String` for that.

```
return String(format: "%.0fk", arguments: [value/1000.0])
```

Now I tell the y, or left axis of my line chart to use this formatter.

> The following line is to be added to the top of  `configureLineChart()` in `DashboardViewController`

```
totalStreamersLineChartView.leftAxis.valueFormatter = LargeValueFormatter()
```

> Build and run, and demonstrate how the axis is now using prettier, more legible values

## Interlude

The line chart is now looking and working great, so at this point I'm going to shift focus and implement the bar chart. As you'll see I'm able to reuse a lot of what I've already shown through implementing the line chart, and this is testament to the great work done on the API by the developers of `Charts` and `MPAndroidChart`. 

## Demo

Before I jump into the storyboard I'll first declare the outlet, this time of type `BarChartView`, so that I can set the custom class _and_ connect the outlet at the same time.

> Open DashboardViewController.swift, and add the following below the existing outlets

```
@IBOutlet weak var newStreamersBarChartView: BarChartView!
```

> Open Main.storyboard

I need to set the the custom class first so I select the **New Streamers Chart** from the scene explorer, and then in the **Identity Inspector** set Class to `BarChartView`.

And now I can connect the outlet.

> Drag from the outlet to BarChartView to connect them, then re-open DashboardViewController.swift

I'll follow the same routine as I did with the line chart, beginning with adding a method to return the bar charts data.

```
private func newStreamersData() -> BarChartData {
    
}
```

This time the return type is `BarChartData`. As I mentioned previously each chart has its own set of data classes, but they all do descend from the same parent classes.

I want the bar chart to display the daily number of new streamers of the Rayflix service for the past seven days, so once again I use a static property in `Streamer` to grab that. Unlike `aggregateTotalStreamers`, this property returns an array of tuples with named parameters `day` and `count`. When I create instances of `BarChartDataEntry` I neeed to make sure to pass the `count` value of the tuple as the `y` value of the entry.

```
let entries = Streamer.last7DaysNewStreamers.enumerated().map { BarChartDataEntry(x: Double($0), y: $1.count) }
```

With the data entries created, I can now create the data set. Just as with the line chart I want the values hidden and the color of the bars to be white, so both charts share the same design language.

```
let dataSet = BarChartDataSet(values: entries, label: nil)
dataSet.drawValuesEnabled = false
dataSet.colors = [.white]
```

Now I need to return an instance of `BarChartData`, and do so directly rather than using a variable because I don't need to set any properties in the data like I did earlier.

```
return BarChartData(dataSets: [dataSet])
```

> Still working in DashboardViewController.swift

I’ll now add a method whose responsibility will be to configure the bar chart.

```
private func configureBarChart() {

}
```

And from within it I'll set the data property on `newStreamersBarChartView` using `newStreamersData()` that I just added.

```
newStreamersBarChartView.data = newStreamersData()
```

I call this from the bottom of `viewDidLoad` to make sure the chart get configured correctly prior to being displayed.

> Add to the bottom of `viewDidLoad`

```
configureBarChart()
```

Just above that, I'll add a call to `configureDefaults(forChart:)` and pass the bar chart view to make sure those defaults inherited from `BarLineChartViewBase` get set and the two charts appear consistent. 

```
configureDefaults(forChart: newStreamersBarChartView)
```

I'll jump back to `configureBarChart()` so I can configure two properties specific to the bar chart—I want the x axis to appear under the graph rather than above it, and I want the labels on that axis to be white so they're legible against the green background.

> Add to the top of `configureBarChart()`

```
newStreamersBarChartView.xAxis.labelPosition = .bottom
newStreamersBarChartView.xAxis.labelTextColor = .white
```

This once again demonstrates just how configurable `Charts` is—how cool is it that you can choose the position of the axis labels!? 

If I were to build and run now, the bar chart would look great, but with one small exception—the `x` value I passed when creating instances of `BarChartDataEntry` is the index of the enumeration, so in this case a value between `0` and `6`. What I actually want to display as the values on the x axis is the `day` value from the corresponding tuple in the `last7DaysNewStreamers` array, so I'll create another axis value formatter.

I've already created an empty Swift class, so I'll open that up and import the `Charts` framework.

> Open DayNameFormatter.swift

```
import Charts
```

I'll now update the class definition to declare the `IAxisValueFormatter` protocol conformance.

```
class DayNameFormatter: NSObject, IAxisValueFormatter
```

Next I'll add the required method that accepts a value and an optional instance of `AxisBase`, and returns a string.

```
func stringForValue(_ value: Double, axis: AxisBase?) -> String {

}
```

Remember the value being passed to this method is the value from the x axis, not the value being plotted. As the value in this case is the index of the array enumeration I can use it to locate the corresponding tuple in the array, and then return the `day` value.

```
return Streamer.last7DaysNewStreamers[Int(value)].day
```

Now I just need to jump back to the view controller and tell the x axis of the bar chart to use this class as its value formatter.

> Open DashboardViewController.swift and add the following to the top of `configureBarChart`

```
newStreamersBarChartView.xAxis.valueFormatter = DayNameFormatter()
```

> Build and run, and demonstrate how the bar chart is now populated with the new streamers data, and how the day names are shown along the x axis

## Closing

Alright, that's everything we'd like to cover in this screencast.

At this point you should understand how to create `Charts` views within your storyboard, how to provide them with data to render using data entries and data sets, how to enable and disable various visual features, and how to provide custom value formatters for you charts' axis.

There's a lot more to `Charts` than we've been able to demonstrate in this screencast, including 6 other chart types, various interaction features, multiple data sets, combined graphs, animation, and more. We highly recommend you check out the GitHub repo at [github.com/danielgindi/Charts](github.com/danielgindi/Charts) for more information as we really have just scratched the surface. 

Thanks for watching—and we look forward to seeing all the beautiful and informative charts you guys start displaying in your apps. We're out!