
# How to make a "hello world" in Ocsigen?

Here it is\! The famous "**Hello World**" for a client/server Eliom application:


###

```ocaml
open Eliom_content
open Html.D
open Eliom_parameter

module Example =
  Eliom_registration.App
    (struct
      let application_name = "example"
     end)

let main =
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get unit)
    ()

let _ =

  Example.register
    ~service:main
    (fun () () ->
      Lwt.return
	(html
	   (head (title (txt "Hello World of Ocsigen")) [])
	   (body [h1 [txt "Hello World!"];
		  p [txt "Welcome to my first Ocsigen website."]])))

```

###

- To *understand* this code, have a look at [How does a page's source code look?](./how-does-a-page-s-source-code-look.md)
- Or directly continue by compiling this code: [How to compile my Ocsigen pages?](./how-to-compile-my-ocsigen-pages.md)

### Links

- [Tutorial to write a client/server application](./application.md)
- `Tutorial to write a server side web site`