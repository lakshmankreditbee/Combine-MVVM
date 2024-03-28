//
//  QuoteViewController.swift
//  QuoteGenerator(Combine_MVVM)
//
//  Created by Pusuluru Sree Lakshman on 28/03/24.
//

import UIKit
import Combine

class QuoteViewController: UIViewController {
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    
    private let vm = QuoteViewModel()
    private let input: PassthroughSubject<QuoteViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        input.send(.viewDidAppear)
    }
    
    func bind() {
        let output = vm.transform(input: input.eraseToAnyPublisher())
        output
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                switch event {
                case .quoteFetchFail(error: let error):
                    self?.quoteLabel.text = error.localizedDescription
                case .quoteFetchSuccess(quote: let quote):
                    self?.quoteLabel.text = quote.content
                    self?.authorLabel.text = "~ \(quote.author)"
                case .buttonEnable(isEnabled: let isEnabled):
                    self?.refreshButton.isEnabled = isEnabled
                }
            }.store(in: &cancellables)
    }
    
    @IBAction func tapRefreshButton(_ sender: Any) {
        input.send(.didTapRefreshButton)
    }
}

