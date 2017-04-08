//
//  CommentParser.swift
//  CHCSVParser
//
//  Created by Dave DeLong on 9/20/16.
//
//

import Foundation

internal struct CommentParser: Parser {
    
    func parse(_ state: ParserState) -> CSVParsingDisposition {
        let stream = state.characterIterator
        
        guard stream.next() == Character.Octothorpe else {
            fatalError("Implementation flaw; starting to parse comment with no leading #")
        }
        
        var comment = "#"
        var sanitized = ""
        
        var isBackslashEscaped = false
        
        while let next = stream.peek() {
            if isBackslashEscaped == false {
                if next == Character.Backslash && state.configuration.recognizeBackslashAsEscape {
                    isBackslashEscaped = true
                    comment.append(next)
                    _ = stream.next()
                    
                } else if state.configuration.recordTerminators.contains(next) {
                    // consume the record terminator
                    _ = stream.next()
                    break
                    
                } else {
                    comment.append(next)
                    sanitized.append(next)
                    _ = stream.next()
                }
            } else {
                isBackslashEscaped = false
                sanitized.append(next)
                comment.append(next)
                _ = stream.next()
            }
        }
        
        if isBackslashEscaped == true {
            // technically this should only happen if the final character of the stream is a backslash, and we're allowing backslashes
            let error = CSVParserError(kind: .incompleteField, line: state.currentLine, field: 0, progress: stream.progress())
            return .error(error)
        }
        
        let field = state.configuration.sanitizeFields ? sanitized : comment
        let final = state.configuration.trimWhitespace ? field.trimmingCharacters(in: .whitespacesAndNewlines) : field
        
        let disposition = state.configuration.onReadComment(final, stream.progress())
        
        return disposition
        
    }
    
}
