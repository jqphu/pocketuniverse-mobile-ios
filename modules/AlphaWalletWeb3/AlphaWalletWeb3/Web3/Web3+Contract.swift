//  Web3+ContractV1.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation 
import BigInt

extension Web3 {
    enum ABIError: Error {
        case abiInvalid
        case constructorNotFound
        case methodNotFound(String)
        case encodeParamFailure([AnyObject])
        case methodNotSupported
    }

    enum ContractError: Error {
        case gasLimitNotFound
        case gasPriceNotFound
        case toNotFound
        case abiError(ABIError)
    }

    public class Contract {
        let contract: ContractProtocol
        let web3: Web3

        public var options: Web3Options?
        
        public init(web3: Web3, abiString: String, at: EthereumAddress? = nil, options: Web3Options? = nil) throws {
            self.web3 = web3
            self.options = web3.options

            var contract: ContractProtocol
            do {
                contract = try ContractV2(abi: abiString, address: at)
            } catch {
                contract = try ContractV1(abi: abiString, address: at)
            }

            var mergedOptions = Web3Options.merge(self.options, with: options)
            if at != nil {
                contract.address = at
                mergedOptions?.to = at
            } else if let addr = mergedOptions?.to {
                contract.address = addr
            }

            self.contract = contract
            self.options = mergedOptions
        }
        
        public func deploy(bytecode: Data, parameters: [AnyObject] = [], extraData: Data = Data(), options: Web3Options? = nil) throws -> TransactionIntermediate {
            let mergedOptions = Web3Options.merge(self.options, with: options)
            var transaction = try contract.deploy(bytecode: bytecode, parameters: parameters, extraData: extraData, options: mergedOptions)
            transaction.chainID = web3.chainID

            return TransactionIntermediate(transaction: transaction, web3: web3, contract: contract, method: "fallback", options: mergedOptions)
        }
        
        public func method(_ method: String = "fallback", parameters: [AnyObject] = [], extraData: Data = Data(), options: Web3Options? = nil) throws -> TransactionIntermediate {
            let mergedOptions = Web3Options.merge(self.options, with: options)
            var transaction = try contract.method(method, parameters: parameters, extraData: extraData, options: mergedOptions)
            transaction.chainID = web3.chainID

            return TransactionIntermediate(transaction: transaction, web3: web3, contract: contract, method: method, options: mergedOptions)
        }

        public func parseEvent(_ eventLog: EventLog) -> (eventName: String?, eventData: [String: Any]?) {
            return contract.parseEvent(eventLog)
        }
        
        public func createEventParser(_ eventName: String, filter: EventFilter?) -> EventParserProtocol? {
            return EventParser(web3: web3, eventName: eventName, contract: contract, filter: filter)
        }

        public func decodeReturnData(_ method: String, data: Data) -> [String: Any]? {
            contract.decodeReturnData(method, data: data)
        }

        public func decodeInputData(_ method: String, data: Data) -> [String: Any]? {
            contract.decodeInputData(method, data: data)
        }

        public func decodeInputData(_ data: Data) -> [String: Any]? {
            contract.decodeInputData(data)
        }

        public func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool? {
            contract.testBloomForEventPrecence(eventName: eventName, bloom: bloom)
        }
    }
}
