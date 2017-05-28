## Introduction

**Jessy**  
Hey, what's up everybody, this is Jessy. In today's screencast I'm going to introduce you to a really popular charting framework aptly named `Charts`.

**Catie**  
> look at camera

I'm Catie, and this time around, I'll be learning along with you! What is Charts?

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
@IBOutlet var totalStreamersLineChartView: LineChartView!
```

Finally, I just need to connect the outlet to the view in the storyboard:

> Open Main.storyboard, and drag from the outlet to `LineChartView` to connect them. Then build and run.

Building and running, I see see that the line chart is working: it's displaying the default "no chart data available" message. 

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

To keep things tidy, I'm going to configure `totalStreamersLineChartView` in its `didSet` observer. IBOutlets gets assigned the values you connected using Interface Builder, just before `viewDidLoad`. I'll use a closure to assign its data property. To start off with, I'll return nil, to avoid having errors as I put the data together.

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
          Streamer.aggregateTotalStreamers
          .enumerated()
          .map{
          	dayIndex, total in ChartDataEntry(
          		x: Double(index), y: total
          	)
          }
        
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
            .map{dayIndex, total in ChartDataEntry(x: Double(index), y: total)},
          label: nil
        )
```

**Catie**  
And then, can you use that data set to initialize the `ChartData` that you need?

**Jessy**  
Basically. I can create an instance of `LineChartData` using this dataset (and return that, now that we've got something better than the nil placeholder). 

```swift
label: nil
        )

😺let data = LineChartData(dataSets: [dataSet])
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
Now I can build and run, with a line charted!

> Build and run, and demonstrate how the chart is now populated with the streaming data

## Interlude
> Put chart in middle of on-camera screen

**Catie**  
It seems to be _working_ great, but not really _looking_ so great.

**Jessy**  
While I don't disagree in the slightest, that is a topic for _another_ screencast. At this point, why don't _you_ have a go at implementing the bar chart? It's a very similar process.

## Demo

**Catie**  
Alright! First, I'll set the class for the **New Streamers Chart** view in the **Identity Inspector**, to be `BarChartView`. Then, drag over an outlet to the view controller. I'll call it `newStreamersBarChartView`.

```swift
@IBOutlet var newStreamersBarChartView: BarChartView!
```

Then, I set its data in its `didSet` observer.

```swift
  @IBOutlet var newStreamersBarChartView: BarChartView! {
    didSet {
      newStreamersBarChartView.data = {
        
      }()
    }
  }   
```
You used a `LineChartDataSet` above. I'm thinking maybe a `BarChartDataSet` might be in order here?

**Jessy**  
Yes it is! Its initializer has the same parameters.

```swift
      newStreamersBarChartView.data = {
        let dataSet = BarChartDataSet(
          values:
          ,
          label: nil
        )
      }()
```

**Catie**  
Where is the data I need for the `ChartDataEntry`s?

**Jessy**  

```swift
       let dataSet = BarChartDataSet(
          values:
            Streamer.last7DaysNewStreamers
            .enumerated()
            .map{
              dayIndex, newStreamers in BarChartDataEntry(
                x: Double(dayIndex),
                y: newStreamers.count
              )
            },
          label: nil
        )
```
We want the bar chart to display the daily number of new streamers of the Rayflix service for the past seven days, so once again I've created a static property in `Streamer` to grab that. And this time around, there's a specific `BarChartDataEntry` subclass to use, that does some extra setup.

The `dayIndex` will work the same, but unlike `aggregateTotalStreamers`, `last7DaysNewStreamers` returns an array of tuples with named parameters `day` and `count`. We need to make sure to pass the `count` value of the tuple for the `y` values of the entries.

**Catie**  
I'm going to try using that set directly, using a `BarChartData`.

```swift
        return BarChartData(dataSets: [dataSet])
```

## Closing

**Catie**  
It worked!

**Jessy**  
That's enough to get you up and running.

At this point you should understand how to create `Charts` views within your storyboard, and how to provide them with data to render using data entries and data sets.

**Catie**  
In another screencast, we'll be showing you how to customize the appearance of your charts. It's very unlikely you'll want to stick with the defaults.

**Jessy**  
Until then, feel free to check out the GitHub repo, here.
>point  
[github.com/danielgindi/Charts](github.com/danielgindi/Charts) 

It's **off** the charts!

**Catie**  
Thanks for watching!



