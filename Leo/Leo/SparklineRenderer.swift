//
//  SparklineRenderer.swift
//  Watch Extension
//
//  Created by Tian Zhang on 5/15/18.
//  Copyright © 2018 Robinhood. All rights reserved.
//

import UIKit

class SparklineRenderer {
    
    private let viewModel: LineChartViewModel
    private let insets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    init(_ viewModel: LineChartViewModel) {
        self.viewModel = viewModel
    }
    
    func draw(in context: CGContext, size: CGSize) {
        let sizeWithInsets = CGSize(
            width: size.width - insets.left - insets.right,
            height: size.height - insets.top - insets.bottom
        )
        
        draw(viewModel.referenceLines, in: context, size: sizeWithInsets)
        draw(viewModel.dataSets, in: context, size: sizeWithInsets)
    }
}

// MARK: - ReferenceLines

extension SparklineRenderer {
    
    private func draw(_ referenceLines: [LineChartReferenceLine], in context: CGContext, size: CGSize) {
        for referenceLine in referenceLines {
            draw(referenceLine, in: context, size: size)
        }
    }
    
    private func draw(_ referenceLine: LineChartReferenceLine, in context: CGContext, size: CGSize) {
        context.setStrokeColor(referenceLine.style.lineColor.cgColor)
        context.setLineWidth(referenceLine.style.lineWidth)
        
        let scaledY = CGFloat((referenceLine.y - viewModel.minY) / viewModel.yRange)
        let adjustedY = size.height - scaledY  * size.height
        
        context.move(to: CGPoint(x: 0, y: adjustedY))
        context.addLine(to: CGPoint(x: size.width, y: adjustedY))
        context.strokePath()
    }
}

// MARK: - Data Sets

extension SparklineRenderer {
    
    private func draw(_ dataSets: [LineChartDataSet], in context: CGContext, size: CGSize) {
        for dataSet in viewModel.dataSets {
            draw(dataSet.segments, in: context, size: size)
        }
    }
    
    private func draw(_ segments: [LineChartDataSegment], in context: CGContext, size: CGSize) {
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        for (index, segment) in segments.filter({ !$0.isEmpty }).enumerated() {
            draw(segment, in: context, size: size)
            
            if let nextSegment = segments[safe: index.advanced(by: 1)] {
                connect(with: nextSegment, in: context, size: size)
            }
        }
    }
    
    private func draw(_ segment: LineChartDataSegment, in context: CGContext, size: CGSize) {
        context.setStrokeColor(segment.lineStyle.lineColor.cgColor)
        context.setLineWidth(segment.lineStyle.lineWidth)
        
        let visualPoints = segment.dataPoints.map { dataPoint in
            visualPoint(from: dataPoint, size: size)
        }
        
        context.move(to: visualPoints.first!)
        
        for visualPoint in visualPoints.dropFirst() {
            context.addLine(to: visualPoint)
        }
        
        context.strokePath()
    }
    
    private func connect(with nextSegment: LineChartDataSegment, in context: CGContext, size: CGSize) {
        guard let firstDataPoint = nextSegment.dataPoints.first else {
            return
        }
        
        context.addLine(
            to: visualPoint(from: firstDataPoint, size: size)
        )
    }
    
    private func visualPoint(from dataPoint: LineChartDataPoint, size: CGSize) -> CGPoint {
        let scaledX: CGFloat = {
            // If this is the only data point, draw it at the beginning of the chart
            guard viewModel.xRange > 0 else {
                return 0
            }
            
            return CGFloat((dataPoint.x - viewModel.minX) / viewModel.xRange)
        }()
        
        let adjustedX = scaledX * size.width
        
        let scaledY: CGFloat = {
            // If this is the only data point, draw it in the vertical center
            guard viewModel.yRange > 0 else {
                return 0.5
            }
            
            return CGFloat((dataPoint.y - viewModel.minY) / viewModel.yRange)
        }()
        
        let adjustedY = size.height - scaledY * size.height
        
        return CGPoint(x: adjustedX, y: adjustedY)
    }
}
