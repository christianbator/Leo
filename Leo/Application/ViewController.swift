//
//  ViewController.swift
//  Leo
//
//  Created by Christian Bator on 5/25/18.
//  Copyright © 2018 Robinhood Markets Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var segmentSelectorView: UIStackView!
    @IBOutlet var oneDayLabel: UILabel!
    @IBOutlet var threeMonthLabel: UILabel!
    
    private var lineChartView: LineChartView!
    private var firstDataSet: LineChartDataSet!
    private var secondDataSet: LineChartDataSet!
    
    private var finishedInitialLayout = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oneDayLabel.layer.cornerRadius = 8
        oneDayLabel.layer.masksToBounds = true
        
        threeMonthLabel.layer.cornerRadius = 8
        threeMonthLabel.layer.masksToBounds = true
        
        lineChartView = LineChartView()
        view.addSubview(lineChartView)
        constrainLineChartView()
        
        setupInteraction()
        
        firstDataSet = LineChartDataSetProvider.dataSet(
            startingAt: CGPoint(x: 0, y: 400),
            endingAt: CGPoint(x: 300, y: 320),
            numberOfPoints: 55
        )
        
        secondDataSet = LineChartDataSetProvider.dataSet(
            startingAt: CGPoint(x: 5, y: 100),
            endingAt: CGPoint(x: 225, y: 519),
            numberOfPoints: 32
        )
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !finishedInitialLayout else {
            return
        }
        
        lineChartView.configure(with: viewModel(from: firstDataSet))
        
        finishedInitialLayout = true
    }
}

// MARK: - View Model Configuration

extension ViewController {
    
    private func viewModel(from dataSet: LineChartDataSet) -> LineChartViewModel {
        let viewModel = LineChartViewModel(
            insets: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10),
            dataSets: [dataSet]
        )
        
        return viewModel
    }
}

// MARK: - Constraints

extension ViewController {
    
    private func constrainLineChartView() {
        lineChartView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        lineChartView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: segmentSelectorView.topAnchor, constant: -32).isActive = true
    }
}

// MARK: - Interaction

extension ViewController {
    
    private func setupInteraction() {
        let oneDayTap = UITapGestureRecognizer(target: self, action: #selector(oneDayTapped))
        oneDayLabel.addGestureRecognizer(oneDayTap)
        
        let threeMonthTap = UITapGestureRecognizer(target: self, action: #selector(threeMonthTapped))
        threeMonthLabel.addGestureRecognizer(threeMonthTap)
    }
    
    @objc private func oneDayTapped() {
        oneDayLabel.textColor = .white
        threeMonthLabel.textColor = .lightGray
        
        lineChartView.configure(with: viewModel(from: firstDataSet))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.threeMonthTapped()
        }
    }
    
    @objc private func threeMonthTapped() {
        threeMonthLabel.textColor = .white
        oneDayLabel.textColor = .lightGray
        
        lineChartView.configure(with: viewModel(from: secondDataSet))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.oneDayTapped()
        }
    }
}
