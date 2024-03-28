//
//  QuoteService.swift
//  QuoteGenerator(Combine_MVVM)
//
//  Created by Pusuluru Sree Lakshman on 28/03/24.
//

import Foundation
import Combine

protocol QuoteServiceType {
    func getRandomQuote() -> AnyPublisher<Quote, Error>
}

class QuoteService: QuoteServiceType {
    
    func getRandomQuote() -> AnyPublisher<Quote, Error> {
        let url = URL(string: "https://api.quotable.io/random")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .catch { error in
                return Fail(error: error).eraseToAnyPublisher()
            }
            .map({ $0.data })
            .decode(type: Quote.self, decoder: JSONDecoder()).eraseToAnyPublisher()
    }
}
