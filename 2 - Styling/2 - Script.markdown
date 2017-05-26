## Introduction

**Jessy**  
Hey everybody, I'm Jessy. In a previous screencast, I introduced you and Catie to the `Charts` framework. 

**Catie**  
This time, I'm going to show you how to format your charts, and add style.

**Jessy** 
Once again, many thanks to Mic Pringle for the supporting materials for this screencast. What state is that project in at this point?

**Catie**  
There's a line chart, and bar chart, accurately rendering the Rayflix streamers data, but its appearance leaves much to be desired—the mundane coloring, the cramped numbers, and what's with all those grid lines? 

For whatever reason, _every_ visual feature is enabled by default. Luckily the developers have made all those features configurable. 

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
isUserInteractionEnabled = false

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

**Jessy**  
Last time, we set up the data for the charts in their `didSet` observers. Should we put the call to `configureDefaults` there as well? 

**Catie**  
Yes. I'll just do it for the line chart to start with, so we can see how much of a difference it makes. 

```swift
    didSet {
      totalStreamersLineChartView.configureDefaults()
      totalStreamersLineChartView.data = {
```

Also, unlike the bar chart, I want to disable the line chart's x axis labels.

```swift
totalStreamersLineChartView.configureDefaults()
      totalStreamersLineChartView.xAxis.drawLabelsEnabled = false
      totalStreamersLineChartView.data = {
```

## Interlude

> show onscreen again

**Jessy**  
That looks cleaner! But it would look far better if those ghastly circles were removed, a solid color was drawn under the curve, and if the chart values were hidden. How do you configure how the data itself is rendered?

**Catie**  
I wondered that myself. After a quick read through the documentation, I was able to find the necessary methods and properties to achieve exactly the look you're talking about!

It turns out that you use `LineChartDataSet` to configure the appearance of the data, which in hindsight makes perfect sense. 

## Demo

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

> Build & Run; show that in the middle of the screen.

**Jessy**  
That looks _much_ better! But something needs to be done about the formatting of the y axis values.

**Catie**  
When a chart is rendered, the `Charts` framework will attempt to determine what values are shown on each visible axis based on the data it's plotting. However, these values will always be numeric because you can only provide instances of `Double` as the `x` and `y` values.

To workaround this limitation, `Charts` provides the concept of an axis value formatter, by way of the `IAxisValueFormatter` protocol. 

**Jessy**  
"I" as a prefix for "interface": not very Swifty! As I mentioned last time, the `Charts` framework is actually a port of the popular Android charting library `MPAndroidChart`, and you will occasionally come across stray Java-isms, such as this.

**Catie**  
Regardless, it gets the job done!
When a chart is about to be rendered, it will call through to any provided axis value formatters, passing the numeric value, and rendering a returned string in its place.

For example, we'll be using this mechanism to convert a set of numbers between 1 and 7 into days of the week.

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

The protocol requires a single method that receives a value and an optional instance of `AxisBase`, and returns a string. For the purposes of this screencast I'm really only interested in the value; I'll make that clear by using an underscore for the internal parameter label. 

```swift
func stringForValue(
	_ value: Double, 
	axis _: AxisBase?
) -> String {

}
```

Now the values that are passed to this method aren't from my data; rather, they're the values that display along the axis the formatter is attached to. For this vertical axis, I simply want to format the numbers so they're prettier and easier to read in such a confined space. For that, I initialize a `String` with a scaled value, formatted with truncation at the decimal point.

```swift
   return String(
      format: "%.0fk",
      arguments: [value / 1000]
    )
```

Now I tell the left Y axis of my line chart to use an instance of this formatter.

```swift
totalStreamersLineChartView.leftAxis.valueFormatter = LargeValueFormatter()
```

> Build and run, and demonstrate how the axis is now using prettier, more legible values


## Interlude
**Jessy**  
The values are legible. I think the line chart looks good. Onto the bar chart?

**Catie**  
Sure! As you'll see, I'll be able to reuse a lot of what I've already implemented for the line chart, a testament to the great work done on the API by the developers of `Charts` and `MPAndroidChart`.

## Demo

I'll begin by configuring `newStreamersBarChartView`'s defaults.

```swift
newStreamersBarChartView.configureDefaults()
```

Just as with the line chart, I want the values hidden and the color of the bars to be white. Both charts will share the same design language.

```swift
let dataSet = BarChartDataSet(values: entries, label: nil)
dataSet.drawValuesEnabled = false
dataSet.colors = [.white]
```

Now I'll configure two more properties specific to the bar chart—I want the x axis to appear under the graph rather than above it, and I want the labels on that axis to be white so they're legible against the green background.

```swift
newStreamersBarChartView.xAxis.labelPosition = .bottom
newStreamersBarChartView.xAxis.labelTextColor = .white
```

## Interlude

**Jessy**  
You choose the position of the axis labels with just an enumeration value. `Charts` offers some really cool configuration options.

**Catie**  
The bar chart would look great, if not for those `0` to `6` indices along the x axis.

**Jessy**  
Last time, I introduced the `last7DaysNewStreamers` array, which includes provides corresponding day names in an array. Surely I can use that, with another axis value formatter…

## Demo
> Open DayNameFormatter.swift

I'll work in this `DayNameFormatter` class, which is set up just like `LargeValueFormatter`. The `Charts` framework is imported, the class definition declares conformance to the `IAxisValueFormatter` protocol, and its method requirement is stubbed out, returning an empty String.

The `value` being passed to this method is one of those day indices from the x axis. I can use it to locate the corresponding tuple in the array I'm plotting, and then return its `day` property.

```
return Streamer.last7DaysNewStreamers[Int(value)].day
```
Now I just need to jump back to the view controller and tell the x axis of the bar chart to use this class as its value formatter, then build and run?

> Open DashboardViewController.swift and add the following

```swift
newStreamersBarChartView.xAxis.valueFormatter = DayNameFormatter()
```

> Build and run, and demonstrate how the bar chart is now populated with the new streamers data, and how the day names are shown along the x axis

## Closing

**Catie**  
That's it. There are the days. Very nice! 

And that's everything I'd like to cover in this screencast. Now you know how to enable and disable various visual features of your charts, and how to provide custom value formatters for their axes.

**Jessy**  
There's a lot more to `Charts` than we've been able to demonstrate in this screencast, including 6 other chart types, various interaction features, multiple data sets, combined graphs, animation, and more.

>point  
[github.com/danielgindi/Charts](github.com/danielgindi/Charts) 

**Catie**  
We've really just scratched the surface. And we look forward to seeing all the beautiful and informative charts you all start displaying in your apps. 

**Jessy**  
Might I suggest going with …Chart-reuse?
