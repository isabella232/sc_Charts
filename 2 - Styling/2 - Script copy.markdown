## Introduction

**Jessy**  
Hey, what's up everybody, this is Jessy. In today's screencast I'm going to introduce you to a really popular charting framework aptly named `Charts`.

**Catie**  
> look at camera

I'm Catie, and this time around, I'll be learning along with you! What's Charts?

**Jessy** 
As the name might imply, `Charts` is an open source charting framework, written in Swift by Daniel Cohen Gindi. It's heavily inspired by the `MPAndroidCharts` library for Android, and as such shares an almost identical API, which is great if you're working cross-platform.

The framework provides 8 different chart types out-of-the-box, has full support for pinching and panning, is highly configurable, and even provides build-up animations for both axes. 

**Catie** 
We'd both like to give a big thanks to Mic Pringle for putting together the materials we'll be using in this screencast. Let’s dive in!

## Demo

> Open Podfile

**Jessy**  
I've gone ahead and installed `Charts` using Cocoapods, and will therefore be working in the Xcode workspace rather than the project.

> Open Rayflix.xcworkspace, and then open Main.storyboard

As you can see I've already got my view controller laid out, including two views: one for each of the charts I'll add. I'm going to render a line chart in the upper view, and a bar chart in the lower view.

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
It provides really good coverage, I won't go too deep into it in this screencast. The main things to remember are that a chart requires data, data is made up from one or more data sets, and a data set is a collection of data entries, which in turn represent the x and y values of a plot on a chart. 

**Catie**  
Sounds simple enough!

## Demo

> Open DashboardViewController.swift

To keep things tidy, I'm going to configure `totalStreamersLineChartView` in its `didSet` observer, which is called just before `viewDidLoad`, when it's assigned the value you connected in Interface Builder. I'll use a closure to assign its data property. To start off with, I'll return nil, to avoid having errors as I put the data together.

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

I'll use the `enumerated` method, as I need both the indices _and_ values of that array, as I pipe them into `map`, creating instances of `ChartDataEntry`. The indices are the `x` values, but they need to be converted to `Double`s first. The streamer counts are already `Double`s so they can be used as the `y` values directly.

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
The chart would look far better if those ghastly circles were removed, a solid color was drawn under the curve, and if the chart values were hidden. How do you configure how the data itself is rendered?

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

In order to render the chart with a fill, instead of as a thin line, I need to tell the data set to draw that fill, and provide a color and an alpha value for it.

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
That looks much better! But something needs to be done about the formatting of the y axis values.

---
# Part 2

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

I've already created an empty Swift class that'll act as my Y axis value formatter for the line chart. 

> Open Value Formatters/LargeValueFormatter.swift

In order to be able to use this class as a value formatter, I'll first import the `Charts` framework so that I can access its protocols. (Charts comes along with Foundation so I don't need both, here.)

```swift
import Charts //instead of Foundation
```

And then I'll declare that `LargeValueFormatter` conforms to `IAxisValueFormatter`. Additionally, it must derive from NSObject.

```
class LargeValueFormatter: NSObject, IAxisValueFormatter
```

That protocol requires a single method that receives a value and an optional instance of `AxisBase`, and returns a string. For the purposes of this screencast I'm really only interested in the value; I'll make that clear by using an underscore for the internal parameter label. 

```swift
func stringForValue(
	_ value: Double, 
	axis _: AxisBase?
) -> String {

}
```

The values that are passed to this method aren't from my data; rather, they're the values that display along the axis the formatter is attached to. For this vertical axis, I simply want to format the numbers so they're prettier and easier to read in such a confined space. For that, I initialize a `String` with a scaled value, formatted with truncation at the decimal point.

```swift
   return String(
      format: "%.0fk",
      arguments: [value / 1000]
    )
```

Now I tell the left Y axis of my line chart to use this formatter.

```swift
totalStreamersLineChartView.leftAxis.valueFormatter = LargeValueFormatter()
```

> Build and run, and demonstrate how the axis is now using prettier, more legible values

## Interlude

**Catie**  
The line chart's looking great!

**Jessy**  
And in general, working great! So, at this point I'm going to shift focus and implement the bar chart. As you'll see, I'm able to reuse a lot of what I've already implemented for the line chart, a testament to the great work done on the API by the developers of `Charts` and `MPAndroidChart`.

## Demo

Before I jump into the storyboard I'll first declare the outlet, this time of type `BarChartView`, so that I can set the custom class _and_ connect the outlet at the same time.

> Open DashboardViewController.swift, and add the following below the existing outlets

```
@IBOutlet var newStreamersBarChartView: BarChartView!
```

> Open Main.storyboard

I need to set the the custom class first so I select the **New Streamers Chart**, and then in the **Identity Inspector** set Class to `BarChartView`.

After that, I can connect the outlet.

> Drag from the outlet to BarChartView to connect them, then re-open DashboardViewController.swift

I'll follow the same routine as I did with the line chart, beginning by configuring `newStreamersBarChartView`'s defaults, and assigning its data with a `nil` placeholder, in its `didSet` observer.

```swift
  @IBOutlet var newStreamersBarChartView: BarChartView! {
    didSet {
      newStreamersBarChartView.configureDefaults()
      newStreamersBarChartView.data = {
        return nil
      }()
    }
  }   
```

I want the bar chart to display the daily number of new streamers of the Rayflix service for the past seven days, so once again I use a static property in `Streamer` to grab that. Unlike `aggregateTotalStreamers`, this property returns an array of tuples with named parameters `day` and `count`. When I create instances of `BarChartDataEntry` I need to make sure to pass the `count` value of the tuple as the `y` value of the entry.

```swift
      Streamer.last7DaysNewStreamers
      .enumerated()
      .map{index, newStreamers in BarChartDataEntry(
        x: Double(index),
        y: newStreamers.count
      )}

```

With the data entries created, I can now create the data set. 

```swift
       let dataSet = BarChartDataSet(
          values:
          Streamer.last7DaysNewStreamers
            .enumerated()
            .map{index, newStreamers in BarChartDataEntry(
              x: Double(index),
              y: newStreamers.count
            )},
          label: nil
        )
```

Just as with the line chart I want the values hidden and the color of the bars to be white. Both charts will share the same design language.

```swift
let dataSet = BarChartDataSet(values: entries, label: nil)
dataSet.drawValuesEnabled = false
dataSet.colors = [.white]
```

Now I need to return an instance of `BarChartData`, and I do so directly rather than using a variable because I don't need to set any properties in the data like I did for the `LineChartData`.

```swift
return BarChartData(dataSets: [dataSet])
```
Now I'll configure two more properties specific to the bar chart—I want the x axis to appear under the graph rather than above it, and I want the labels on that axis to be white so they're legible against the green background.

```swift
newStreamersBarChartView.xAxis.labelPosition = .bottom
newStreamersBarChartView.xAxis.labelTextColor = .white
```

## Interlude

This once again demonstrates just how configurable `Charts` is.

**Catie**  
You choose the position of the axis labels with just an enumeration value. How cool is that? 

**Jessy**  
If I were to build and run now, the bar chart would look great, but with one small exception—the `x` value I passed when creating instances of `BarChartDataEntry` is the index of the enumeration, so in this case a value between `0` and `6`. What I actually want to display on the x axis are the `day` values from the corresponding tuple in the `last7DaysNewStreamers` array, so I'll create another axis value formatter.

## Demo
> Open DayNameFormatter.swift

I've already created an empty Swift class for this, so I'll open that up and start similarly to how I did with `LargeValueFormatter`. First, I import the `Charts` framework.

```
import Charts
```

And, update the class definition to declare the `IAxisValueFormatter` protocol conformance.

```
class DayNameFormatter: NSObject, IAxisValueFormatter
```

Next I add the same required method as before, totally ignoring the `AxisBase` parameter for this demo.

```swift
  func stringForValue(
    _ value: Double,
    axis _: AxisBase?
  ) -> String {
    <#code#>
  }
```

Remember the value being passed to this method is the value from the x axis, not the value being plotted. As the value in this case is the index of the positions of my data along the x axis, I can use it to locate the corresponding tuple in the array I'm plotting, and then return its `day` property.

```
return Streamer.last7DaysNewStreamers[Int(value)].day
```

Now I just need to jump back to the view controller and tell the x axis of the bar chart to use this class as its value formatter, then build and run.

> Open DashboardViewController.swift and add the following

```swift
newStreamersBarChartView.xAxis.valueFormatter = DayNameFormatter()
```

> Build and run, and demonstrate how the bar chart is now populated with the new streamers data, and how the day names are shown along the x axis

## Closing

**Catie**  
There are the days. Very nice!

**Jessy**  
That's everything I'd like to cover in this screencast.

At this point you should understand how to create `Charts` views within your storyboard, how to provide them with data to render using data entries and data sets, how to enable and disable various visual features, and how to provide custom value formatters for you charts' axes.

**Catie**  
There's a lot more to `Charts` than we've been able to demonstrate in this screencast, including 6 other chart types, various interaction features, multiple data sets, combined graphs, animation, and more. 

**Jessy**  
We highly recommend you check out the GitHub repo , here,
>point  
[github.com/danielgindi/Charts](github.com/danielgindi/Charts) 

for more information as we really have just scratched the surface. 

**Catie**  
Thanks for watching—and we look forward to seeing all the beautiful and informative charts you all start displaying in your apps. 

**Jessy**  
Might I suggest going with …Chart-reuse?

**Catie**  
We're out!
