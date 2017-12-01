import Vapor

fileprivate let userController = UserController()
fileprivate let contactController = ContactController()

extension Droplet {
    func setupRoutes() throws {
        try _setupUserRoutes()
        try _setupContactRoutes()
    }
}

private extension Droplet {
    func _setupUserRoutes() throws {
        group("users") {
            $0.post("login") { validatedBody, _ in
                return try userController.loginUser(using: validatedBody)
            }

            $0.post("register") { validatedBody, _ in
                return try userController.registerUser(using: validatedBody)
            }
        }
    }

    func _setupContactRoutes() throws {
        grouped(UserMiddleware()).group("contacts") {
            $0.get() { request in
                return try contactController.getAll(for: request)
            }

            $0.get(Int.parameter) { request in
                let contactId = try request.parameters.next(Int.self)
                return try contactController.getContact(for: request, contactId: Identifier(contactId))
            }

            $0.post() { validatedBody, _ in
                return try contactController.create(using: validatedBody)
            }
        }
    }
}
