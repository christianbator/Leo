//
//  ViewController.swift
//  Leo
//
//  Created by Christian Bator on 5/25/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var slider: UISlider!
    @IBOutlet var segmentSelectorView: UIStackView!
    @IBOutlet var oneDayLabel: UILabel!
    @IBOutlet var threeMonthLabel: UILabel!
    @IBOutlet var allTimeLabel: UILabel!
    
    private var lineChartView: LineChartView!
    
    private var firstStyledDataSet: StyledLineChartDataSet!
    private var secondStyledDataSet: StyledLineChartDataSet!
    private var thirdStyledDataSet: StyledLineChartDataSet!
    
    private var firstStyledReferenceLine: StyledLineChartReferenceLine!
    private var thirdStyledReferenceLine: StyledLineChartReferenceLine!
    
    private var finishedInitialLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = Style.backgroundColor
        slider.value = LineChartView.Constants.animationDurationPercentage
        
        oneDayLabel.layer.cornerRadius = 8
        oneDayLabel.layer.masksToBounds = true
        oneDayLabel.textColor = Style.textColor
        
        threeMonthLabel.layer.cornerRadius = 8
        threeMonthLabel.layer.masksToBounds = true
        threeMonthLabel.textColor = Style.textColor.withAlphaComponent(0.6)
        
        allTimeLabel.layer.cornerRadius = 8
        allTimeLabel.layer.masksToBounds = true
        allTimeLabel.textColor = Style.textColor.withAlphaComponent(0.6)
        
        updateTintColor(Style.nonNegativeColor)
        
        lineChartView = LineChartView()
        view.addSubview(lineChartView)
        constrainLineChartView()
        
        setupInteraction()
        
        firstStyledDataSet = LineChartDataSetProvider.styledDataSet(
            startingAt: CGPoint(x: 0, y: 41),
            endingAt: CGPoint(x: 67, y: 17),
            numberOfPoints: 59,
            numberOfSegments: 3,
            lineColor: Style.nonNegativeColor
        )
        
        firstStyledReferenceLine = StyledLineChartReferenceLine(
            referenceLine: LineChartReferenceLine(y: 25),
            lineStyle: LineStyle(lineWidth: 2, lineColor: Style.gray, lineDashPattern: [0.0001, 4])
        )
        
        secondStyledDataSet = LineChartDataSetProvider.styledDataSet(
            startingAt: CGPoint(x: 0, y: 32),
            endingAt: CGPoint(x: 100, y: 68),
            numberOfPoints: 90,
            numberOfSegments: 3,
            lineColor: Style.nonNegativeColor
        )
        
        thirdStyledDataSet = LineChartDataSetProvider.styledDataSet(
            startingAt: CGPoint(x: 0, y: 36),
            endingAt: CGPoint(x: 80, y: 30),
            numberOfPoints: 30,
            numberOfSegments: 3,
            lineColor: Style.nonNegativeColor
        )
        
        thirdStyledReferenceLine = StyledLineChartReferenceLine(
            referenceLine: LineChartReferenceLine(y: 32),
            lineStyle: LineStyle(lineWidth: 1, lineColor: Style.gray)
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !finishedInitialLayout else {
            return
        }
        
        lineChartView.configure(with: viewModel(from: firstStyledDataSet, and: firstStyledReferenceLine))
        
        finishedInitialLayout = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - View Model Configuration

extension ViewController {
    
    private func viewModel(from styledDataSet: StyledLineChartDataSet, and styledReferenceLine: StyledLineChartReferenceLine?) -> LineChartViewModel {
        let viewModel = LineChartViewModel(
            minX: 0,
            maxX: 100,
            minY: 0,
            maxY: 100,
            styledDataSet: styledDataSet,
            styledReferenceLine: styledReferenceLine
        )
        
        return viewModel
    }
}

// MARK: - Constraints

extension ViewController {
    
    private func constrainLineChartView() {
        lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        lineChartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: segmentSelectorView.topAnchor, constant: -80).isActive = true
    }
}

// MARK: - Interaction

extension ViewController {
    
    private func setupInteraction() {
        let oneDayTap = UITapGestureRecognizer(target: self, action: #selector(oneDayTapped))
        oneDayLabel.addGestureRecognizer(oneDayTap)
        
        let threeMonthTap = UITapGestureRecognizer(target: self, action: #selector(threeMonthTapped))
        threeMonthLabel.addGestureRecognizer(threeMonthTap)
        
        let allTimeTap = UITapGestureRecognizer(target: self, action: #selector(allTimeTapped))
        allTimeLabel.addGestureRecognizer(allTimeTap)
    }
    
    @objc private func oneDayTapped() {
        oneDayLabel.textColor = Style.textColor
        threeMonthLabel.textColor = Style.secondaryTextColor
        allTimeLabel.textColor = Style.secondaryTextColor
        
        lineChartView.configure(with: viewModel(from: firstStyledDataSet, and: firstStyledReferenceLine))
    }
    
    @objc private func threeMonthTapped() {
        oneDayLabel.textColor = Style.secondaryTextColor
        threeMonthLabel.textColor = Style.textColor
        allTimeLabel.textColor = Style.secondaryTextColor
        
        lineChartView.configure(with: viewModel(from: secondStyledDataSet, and: nil))
    }
    
    @objc private func allTimeTapped() {
        oneDayLabel.textColor = Style.secondaryTextColor
        threeMonthLabel.textColor = Style.secondaryTextColor
        allTimeLabel.textColor = Style.textColor
        
        lineChartView.configure(with: viewModel(from: thirdStyledDataSet, and: thirdStyledReferenceLine))
    }
    
    private func updateTintColor(_ tintColor: UIColor) {
        oneDayLabel.layer.backgroundColor = tintColor.cgColor
        threeMonthLabel.layer.backgroundColor = tintColor.cgColor
        allTimeLabel.layer.backgroundColor = tintColor.cgColor
        slider.tintColor = tintColor
    }
    
    @IBAction func sliderValueChanged() {
        LineChartView.Constants.currentAnimationDuration = LineChartView.Constants.animationDuration(withPercentage: slider.value)
    }
}
