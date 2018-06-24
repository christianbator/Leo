//
//  LineChartDataSetProvider.swift
//  Leo
//
//  Created by Christian Bator on 5/26/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

class LineChartDataSetProvider {
    
    static func styledDataSet(startingAt start: CGPoint,
                              endingAt end: CGPoint,
                              numberOfPoints: Int,
                              numberOfSegments: Int,
                              lineColor: UIColor) -> StyledLineChartDataSet {
        
        let dataPoints = createPoints(
            startingAt: start,
            endingAt: end,
            numberOfPoints: numberOfPoints
        )
        
        let segments = dataPoints
            .split(into: numberOfSegments)
            .map { segmentDataPoints in
                return LineChartDataSegment(dataPoints: segmentDataPoints)
            }
        
        return StyledLineChartDataSet(
            dataSet: LineChartDataSet(
                segments: segments
            ),
            lineStyle: LineStyle(
                lineWidth: 2,
                lineColor: lineColor
            )
        )
    }
}

// MARK: - Creating Data Points

extension LineChartDataSetProvider {
    
    private static func createPoints(startingAt start: CGPoint, endingAt end: CGPoint, numberOfPoints: Int) -> [LineChartDataPoint] {
        let delta = end.y - start.y
        let interval = (end.x - start.x) / CGFloat(numberOfPoints)
        
        var points = [LineChartDataPoint(x: start.x, y: start.y)]
        for i in 1..<numberOfPoints {
            let x = start.x + (CGFloat(i) * interval)
            let linearY = start.y + CGFloat(i) / CGFloat(numberOfPoints) * delta
            let y = linearY + ((2 * CGFloat(drand48()) - 1) * delta / 2)
            points.append(LineChartDataPoint(x: x, y: y))
        }
        
        return points
    }
}

// MARK: - Array+Segments

extension Array {
    
    func split(into numberOfSegments: Int) -> [[Element]] {
        let numberOfElementsPerSegment = Int(ceil(Double(count) / Double(numberOfSegments)))
        
        return (0 ..< numberOfSegments).map { segmentIndex in
            let segmentStartIndex = segmentIndex * numberOfElementsPerSegment
            let segmentEndIndex = Swift.min(segmentStartIndex + numberOfElementsPerSegment, endIndex)
            return Array(self[segmentStartIndex ..< segmentEndIndex])
        }
    }
}
