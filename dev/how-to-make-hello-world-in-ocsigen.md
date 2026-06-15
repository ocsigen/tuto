
# How to make a "hello world" in Ocsigen?

Here it is\! The famous "**Hello World**" for a client/server Eliom application:


###

```ocaml
open Eliom.Content
open Html.D
open Eliom.Parameter

module Example =
  Eliom.Registration.App
    (struct
      let application_name = "example"
     end)

let main =
  Eliom.Service.create
    ~path:(Eliom.Service.Path [])
    ~meth:(Eliom.Service.Get unit)
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

- To *understand* this code, have a look at [How does a page's source code look?](how-does-a-page-s-source-code-look.html)
- Or directly continue by compiling this code: [How to compile my Ocsigen pages?](how-to-compile-my-ocsigen-pages.html)

### Links

- [Tutorial to write a client/server application](application.html)
- [Tutorial to write a server side web site](interaction.html)