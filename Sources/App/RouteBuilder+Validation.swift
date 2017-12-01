//
//  RouteBuilder+BodyValidation.swift
//  VaporTodoApp2
//
//  Created by D'Alberti, Luca on 7/29/17.
//
//

import Vapor

public typealias ValidatedRouteHandler<BodyType: ValidBody> = (BodyType, Request) throws -> ResponseRepresentable

public extension RouteBuilder {
    public func post<BodyType: ValidBody>(_ segments: String..., handler: @escaping ValidatedRouteHandler<BodyType>) {
        register(method: .post, path: segments) {
            let bodyValidator = BodyValidator<BodyType>()
            let validatedBody = try bodyValidator.validate($0)
            return try handler(validatedBody, $0).makeResponse()
        }
    }
}

