//
//  QuoteViewModel.swift
//  QuoteGenerator(Combine_MVVM)
//
//  Created by Pusuluru Sree Lakshman on 28/03/24.
//

import Foundation
import Combine

class QuoteViewModel {
    
    enum Input {
        case viewDidAppear
        case didTapRefreshButton
    }
    
    enum Output {
        case quoteFetchFail(error: Error)
        case quoteFetchSuccess(quote: Quote)
        case buttonEnable(isEnabled: Bool)
    }
    
    private let quoteServiceType: QuoteServiceType
    private let output: PassthroughSubject<Output, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    
    
    init(quoteServiceType: QuoteServiceType = QuoteService()) {
        self.quoteServiceType = quoteServiceType
    }
    
    func transform(input: AnyPublisher<Input, Never>) -> AnyPublisher<Output, Never> {
        input.sink { [weak self] event in
            switch event {
            case .viewDidAppear, .didTapRefreshButton:
                self?.handleGetRandomQuote()
            }
        }.store(in: &cancellables)
        return output.eraseToAnyPublisher()
    }
    
    func handleGetRandomQuote() {
        output.send(.buttonEnable(isEnabled: false))
        quoteServiceType.getRandomQuote().sink { [weak self] completion in
            self?.output.send(.buttonEnable(isEnabled: true))
            if case .failure(let error) = completion {
                self?.output.send(.quoteFetchFail(error: error))
            }
        } receiveValue: { [weak self] quote in
            self?.output.send(.quoteFetchSuccess(quote: quote))
        }.store(in: &cancellables)
    }
}
