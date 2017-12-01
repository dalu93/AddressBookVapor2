//
//  BodyValidator.swift
//  VaporTodoApp2
//
//  Created by D'Alberti, Luca on 7/29/17.
//
//

import Vapor

public class BodyValidator<BodyType: ValidBody> {

    public func validate(_ request: Request) throws -> BodyType {
        return try BodyType(request: request)
    }
}

