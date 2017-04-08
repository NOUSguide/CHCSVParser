//
//  DocumentParser.swift
//  CHCSVParser
//
//  Created by Dave DeLong on 9/19/15.
//
//

import Foundation

internal struct DocumentParser: Parser {
    let recordParser = RecordParser()
    
    func parse(_ state: ParserState) -> CSVParsingDisposition {
        let stream = state.characterIterator
        
        var disposition = state.configuration.onBeginDocument()
        
        while disposition == .continue && stream.peek() != nil {
            disposition = recordParser.parse(state)
            
            // if there are more characters to be read, make sure it's a record terminator
            if disposition == .continue && stream.peek() != nil {
                state.currentLine += 1 // move to the next 0-based line
            }
        }
        
        state.configuration.onEndDocument(stream.progress(), disposition.error)
        return disposition
    }
}
