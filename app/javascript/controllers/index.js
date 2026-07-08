// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import ReactiveController from "phlex/reactive/reactive_controller"
application.register("reactive", ReactiveController)
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)
