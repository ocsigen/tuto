open Lwt
open Eliom_parameter
open Eliom_content.Html5.D
open Eliom_registration.Html5

let main_service =
  register_service ~path:["graff"] ~get_params:unit
    (fun () () -> return (html (head (title (pcdata "")) [])
                               (body [h1 [pcdata "Graffiti"]])))

