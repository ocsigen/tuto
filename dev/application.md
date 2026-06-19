<!--wodoc:header-->

# Writing a client/server Eliom application

<!--wodoc:end-->
In this chapter, we will write a [collaborative drawing application](https://ocsigen.org/graffiti/). It is a client/server web application displaying an area where users can draw using the mouse, and see what other users are drawing at the same time and in real-time.

This tutorial is a good starting point if you want a step-by-step introduction to Eliom programming.

The final eliom code is available [for download](https://github.com/ocsigen/graffiti/tree/master/simple).


## Basics

If not already done, install Eliom first:

```
opam install ocsipersist-sqlite eliom ocsigen-ppx-rpc
```
To get started, we recommend using [Eliom distillery](https://ocsigen.org/eliom/latest/workflow-distillery.html), a program which creates scaffolds for Eliom projects. The following command creates a very simple project called `graffiti` in the directory `graffiti`:

```shell
$ eliom-distillery -name graffiti -template client-server.basic -target-directory graffiti
```

### My first page

<!--wodoc:aside class="concepts"-->**Concepts**

Services<br/>Configuration file<br/>Static validation of HTML<!--wodoc:end-->

Our web application consists of a single page for now. Let's start by creating a very basic page. We define the service that will implement this page by the following declaration:

<!--wodoc:@ class=server-->
```ocaml
open%server Eliom.Content.Html.D (* provides functions to create HTML nodes *)

let%server main_service =
  Eliom.Service.create
    ~path:(Eliom.Service.Path ["graff"])
    ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
    ()

let%server () =
  Eliom.Registration.Html.register ~service:main_service
    (fun () () ->
      Lwt.return
        (html
           (head (title (txt "Page title")) [])
           (body [h1 [txt "Graffiti"]])))
```
Annotations `%server` tells the compiler that the code is going to be executed on the server (see later).

Replace the content of file `graffiti.eliom` by the above lines and run:

```shell
$ make test.byte
```
This will compile your application and run `ocsigenserver`.

Your page is now available at URL [`http://localhost:8080/graff`](http://localhost:8080/graff).

<!--wodoc:aside class="concept"-->**Concept: Services**

Unlike typical web programming techniques (CGI, PHP,~ ...), with Eliom you do not need to write one file per URL. The application can be split into multiple files as per the developer's style. What matters is that you eventually produce a single module (\*.cmo or \*.cma) for the whole website.

The module `Eliom.Service` allows to create new entry points to your web site, called *services*. In general, services are attached to a URL and generate a web page. Services are represented by OCaml values, through which you must register a function that will generate a page.

The `~path` parameter corresponds to the URL where you want to attach your service. It is a list of strings. The value

```ocaml
["foo"; "bar"]
```
corresponds to the URL

```ocaml
foo/bar
```
. 

```ocaml
["dir"; ""]
```
corresponds to the URL 

```ocaml
dir/
```
(that is: the default page of the directory 

```ocaml
dir
```
).

<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Configuration file**

In the directory of the project created by the Eliom-distillery, you can find the file `graffiti.conf.in`. This file is used in conjunction with the variables in `Makefile.options` to generate the `ocsigenserver` configuration file.

Once you start up your application via `make test.byte`, the configuration file becomes available at `local/etc/graffiti/graffiti-test.conf`. It contains various directives for Ocsigen server (port, log files, extensions to be loaded, etc.), taken from `Makefile.options`, and something like:

```
<host>
  <static dir="static" />
  <eliommodule module="/path_to/graffiti.cma" />
  <eliom />
</host>
```
`<eliommodule ... />` asks the server to load Eliom module `graffiti.cma`, containing the Eliom application, at startup and attach it to this host (and site).

Extensions `<static ... />` (staticmod) and `<eliom />` are called successively:

- If they exist, files from the directory 
  
  ```ocaml
  /path_to/graffiti/static 
  ```
  will be served,
  
- Otherwise, Server will try to generate pages with Eliom (`<eliom />`),
- Otherwise it will generate a 404 (Not found) error (default).
<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Static validation of HTML**

There are several ways to create pages for Eliom. You can generate pages as strings (as in other web frameworks). However, it is preferable to generate HTML in a way that provides compile-time HTML correctness guarantees. This tutorial achieves this by using the module `Eliom.Content.Html.D`, which is implemented using the [TyXML](https://ocsigen.org/tyxml/latest/) library. The module defines a construction function for each HTML tag.

*Note that it is also possible to use the usual HTML syntax directly in OCaml, cf. `Pa_tyxml`.*

The TyXML library (and thus `module
Eliom.Content.Html.D`) is very strict and compels you to respect HTML standard (with some limitations). For example if you write:

```ocaml
(html
   (head (title (txt "")) [txt ""])
   (body [txt "Hallo"]))
```
You will get an error message similar to the following, referring to the end of line 2:

```
Error: This expression has type ([> `TXT ] as 'a) Html.elt
       but an expression was expected of type
         Html_types.head_content_fun Html.elt
       Type 'a is not compatible with type Html_types.head_content_fun =
           [ `Base
           | `Command
           | `Link
           | `Meta
           | `Noscript of [ `Link | `Meta | `Style ]
           | `Script
           | `Style ]
       The second variant type does not allow tag(s) `TXT
```
where `Html_types.head_content_fun` is the type of content allowed inside `<head>` (`<base>`, `<command>`, `<link>`, `<meta>`, etc.). Notice that ``TXT` (i.e. raw text) is not included in this polymorphic variant type, which means that `<head>` cannot contain raw text.

Most functions take as parameter the list representing its contents. See other examples below. Each of them take an optional `?a` parameter for optional HTML attributes. Mandatory HTML attributes correspond to mandatory OCaml parameters. See below for examples.

<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Lwt**

**Important warning:** All the functions you write must be written in a cooperative manner using Lwt. Lwt is a convenient way to implement concurrent programs in OCaml, and is now also widely used for applications unrelated to Ocsigen.

For now we will just use the `Lwt.return` function as above. We will come back to Lwt programming later. You can also have a look at the [Lwt programming guide](https://ocsigen.org/lwt/latest/).

<!--wodoc:end-->

### Execute parts of the program on the client

<!--wodoc:aside class="concepts"-->**Concepts**

Service sending an application<br/> Client and server code<br/> Compiling a Web application with server and client parts<br/> Calling JavaScript methods with Js\_of\_ocaml<br/> <!--wodoc:end-->

To create our first service, we used the function `Eliom.Registration.Html.create`, as all we wanted to do was return HTML. But we actually want a service that corresponds to a full application with client and server parts. To do so, we need to create our own registration module by using the functor `Eliom.Registration.App`:

<!--wodoc:@ class=server-->
```ocaml
module Graffiti_app =
  Eliom.Registration.App (struct
      let application_name = "graffiti"
      let global_data_path = None
    end)
```
It is now possible to use module `Graffiti_app` for registering our main service (now at URL `/`):

<!--wodoc:@ class=server-->
```ocaml
let%server main_service =
  Eliom.Service.create
    ~path:(Eliom.Service.Path [""])
    ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
    ()

let%server () =
  Graffiti_app.register ~service:main_service
    (fun () () ->
      Lwt.return
        (html
           (head (title (txt "Graffiti")) [])
           (body [h1 [txt "Graffiti"]]) ) )
```
We can now add some OCaml code to be executed by the browser. For this purpose, Eliom provides a syntax extension to distinguish between server and client code in the same file. We start by a very basic program, that will display a message to the user by calling the JavaScript function `alert`. Add the following lines to the program:

<!--wodoc:@ class=client-->
```ocaml
let%client _ = Eliom.Lib.alert "Hello!"
```
After running again `make test.byte`, and visiting [http://localhost:8080/](http://localhost:8080/), the browser will load the file `graffiti.js`, and open an alert-box.

<!--wodoc:aside class="concept"-->**Concept: Splitting the code into server and client parts**

At the very toplevel of your source file (i.e. *not* inside modules or other server- /client-parts), you can use the following constructs to indicate which side the code should run on.

- `let%client`, `let%server`, `let%shared`: same as above for a single definition.
- other syntaxes like `module%server`, `open%client`, `type%shared` ...
- `[%%client ... ]`: the list of enclosed definitions is client-only code (similarly for `[%%server ... ]`). With `[%%shared ... ]`, the code is used both on the server and client.
- `[%%client.start]`, `[%%server.start]`, `[%%shared.start]`: these set the default location for all definitions that follow, and which do not use the preceding constructs.
If no location is specified, the code is assumed to be for the server.

The above constructs are implemented by means of PPX, OCaml's new mechanism for implementing syntax extensions. See `Ppx_eliom` for details.

**Client parts are executed once, when the client side process is launched.** The client process is not restarted after each page change.

The Makefile created by `eliom-distillery` automatically splits the code into client and server parts, compiles the server part as usual, and compile the client part to a JavaScript program using `js_of_ocaml`.

<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Client values on the server**

Additionally, it is possible to create client values within the server code by the following quotation:

<!--wodoc:@ class=server-->
```ocaml
  [%client (expr : typ) ]
```
where `typ` is the type of an expression `expr` on the client. Note, that such a client value is abstract on the server, but becomes concrete, once it is received by the client.

(The `typ` can be ommitted if it can be inferred from the usage of the client value in the server code.)

**Client values are executed on the client after the service returns.** You can use client values when a service wants to ask the client to run something, for example binding some event handler on some element produced by the service.

<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Js\_of\_ocaml**

The client-side parts of the program are compiled to JavaScript by `js_of_ocaml`. (Technically, `js_of_ocaml` compiles OCaml bytecode to JavaScript.) It is easy [to bind JavaScript libraries](https://ocsigen.org/js_of_ocaml/latest/js_of_ocaml/bindings.html) so that OCaml programs can call JavaScript functions. In the example, we are using the `Js_of_ocaml.Dom_html` module, which is a binding that allows the manipulation of an HTML page.

Js\_of\_ocaml is using a syntax extension to call JavaScript methods:

- `obj##m a b c` to call the method `m` of object `obj` with parameters `a`, `b`, `c`,
- `obj##.m` to get a property,
- `obj##.m := e` to set a property, and
- `new%js constr a b c` to call a JavaScript constructor.
More information can be found in the Js\_of\_ocaml manual, in module `Ppx_js`.

<!--wodoc:end-->

### Accessing server side variables on client side code

<!--wodoc:aside class="concepts"-->**Concepts**

Executing client side code after loading a page<br/> Sharing server side values<br/> Converting an HTML value to a portion of page (a.k.a. Dom node)<br/> Manipulating HTML node 'by reference' <!--wodoc:end-->

The client side process is not strictly separated from the server side. We can access some server variables from the client code. For instance:

<!--wodoc:@ class=client-->
```ocaml
open%client Js_of_ocaml
```
<!--wodoc:@ class=server-->
```ocaml

let%server count = ref 0

let%server main_service =
  Eliom.Service.create
    ~path:(Eliom.Service.Path [""])
    ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
    ()

let%server () =
  Graffiti_app.register ~service:main_service
    (fun () () ->
       let c = incr count; !count in
       let text = Printf.sprintf "You came %i times to this page" in
       ignore [%client
         (Dom_html.window##alert
            (Js.string @@ Printf.sprintf "You came %i times to this page" ~%c)
          : unit)
       ];
       Lwt.return
         (html
            (head (title (txt "Graffiti")) [])
            (body [h1 [txt @@ text c]])))
```
Here, we are increasing the reference `count` each time the page is accessed. When the page is loaded and the document is in-place, the client program initializes the value inside `[%client ... ]`, and thus triggers an alert window. More specifically, the variable `c`, in the scope of the client value on the server is made available to the client value using the syntax extension `~%c`. In doing so, the server side value `c` is displayed in a message box on the client.

<!--wodoc:aside class="concept"-->**Concept: Injections: Using server side values in client code**

Client side code can reference copies of server side values using the `~%variable` syntax. Values sent that way are weakly type checked: the name of the client side type must match the server side one. If you define a type and want it to be available on both sides, declare it in `[%%shared ... ]`. The Eliom manual provides more information on the `Eliom's syntax extension` and its [compilation process](https://ocsigen.org/eliom/latest/workflow-configuration.html#compilation).

The value of an injection into a `let%client` section is sent only once when starting the application in the browser. In contrast, the values of injections into client values which are created during a request are sent alongside the next response.

<!--wodoc:end-->

## Collaborative drawing application


### Drawing on a canvas

<!--wodoc:aside class="concepts"-->**Concepts**

Canvas

<!--wodoc:end-->
We now want to draw something on the page using an HTML canvas. The drawing primitive is defined in the client-side function called `draw` that just draws a line between two given points in a canvas.

To start our collaborative drawing application, we define another client-side function `init_client`, which just draws a single line for now.

Here is the (full) new version of the program:

<!--wodoc:@ class=server-->
```ocaml
open%server Eliom.Content
open%server Eliom.Content.Html.D
```
<!--wodoc:@ class=client-->
```ocaml
open%client Js_of_ocaml
```
<!--wodoc:@ class=server-->
```ocaml
module%server Graffiti_app =
  Eliom.Registration.App (
    struct
      let application_name = "graffiti"
      let global_data_path = None
    end)
```
<!--wodoc:@ class=server-->
```ocaml
let%server width  = 700
let%server height = 400
```
<!--wodoc:@ class=client-->
```ocaml
let%client draw ctx ((r, g, b), size, (x1, y1), (x2, y2)) =
  let color = CSS.Color.string_of_t (CSS.Color.rgb r g b) in
  ctx##.strokeStyle := (Js.string color);
  ctx##.lineWidth := float size;
  ctx##beginPath;
  ctx##(moveTo (float x1) (float y1));
  ctx##(lineTo (float x2) (float y2));
  ctx##stroke
```
<!--wodoc:@ class=server-->
```ocaml
let%server canvas_elt =
  Html.D.canvas ~a:[Html.D.a_width width; Html.D.a_height height]
    [Html.D.txt "your browser doesn't support canvas"]

let%server page () =
  html
     (head (title (txt "Graffiti")) [])
     (body [h1 [txt "Graffiti"];
            canvas_elt])
```
<!--wodoc:@ class=client-->
```ocaml
let%client init_client () =
  let canvas = Eliom.Content.Html.To_dom.of_canvas ~%canvas_elt in
  let ctx = canvas##(getContext (Dom_html._2d_)) in
  ctx##.lineCap := Js.string "round";
  draw ctx ((0, 0, 0), 12, (10, 10), (200, 100))
```
<!--wodoc:@ class=server-->
```ocaml
let%server main_service =
  Eliom.Service.create
    ~path:(Eliom.Service.Path ["graff"])
    ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
    ()

let%server () =
  Graffiti_app.register
    ~service:main_service
    (fun () () ->
       (* Cf. section "Client side side-effects on the server" *)
       let _ = [%client (init_client () : unit) ] in
       Lwt.return (page ()))
```
<!--wodoc:aside class="concept"-->**Concept: JavaScript datatypes in OCaml**

Here we use the function `val
Js_of_ocaml.Js.string` from Js\_of\_ocaml's library to convert an OCaml string into a JS string.

<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Client side side-effect on the server**

If a client value is created while processing a request, it will be evaluated on the client once it receives the response and the document is created; the corresponding side effects are then executed. For example, the line

```ocaml
  let _ = [%client (init_client () : unit) ] in
  ...
```
creates a client value for the sole purpose of performing side effects on the client. The client value can also be named (as opposed to ignored via `_`), thus enabling server-side manipulation of client-side values (see below). <!--wodoc:end-->


### Single user drawing application

<!--wodoc:aside class="concepts"-->**Concepts**

Lwt<br/> Mouse events with Lwt <!--wodoc:end-->

We now want to catch mouse events to draw lines with the mouse like with the *brush* tools of any classical drawing application. One solution would be to mimic typical JavaScript code in OCaml; for example by using the function `val
Js_of_ocaml.Dom_events.listen` that is the Js\_of\_ocaml's equivalent of `addEventListener`. However, this solution is at least as verbose as the JavaScript equivalent, hence not satisfactory. Js\_of\_ocaml's library provides a much easier way to do that with the help of Lwt.

To use this, add the following line on top of your file: <!--wodoc:@ class=client-->

```ocaml
open%client Js_of_ocaml_lwt
```
Then, replace the `init_client` of the previous example by the following piece of code, then compile and draw\!

<!--wodoc:@ class=client-->
```ocaml
let%client init_client () =

  let canvas = Eliom.Content.Html.To_dom.of_canvas ~%canvas_elt in
  let ctx = canvas##(getContext (Dom_html._2d_)) in
  ctx##.lineCap := Js.string "round";

  let x = ref 0 and y = ref 0 in

  let set_coord ev =
    let x0, y0 = Dom_html.elementClientPosition canvas in
    x := ev##.clientX - x0; y := ev##.clientY - y0
  in

  let compute_line ev =
    let oldx = !x and oldy = !y in
    set_coord ev;
    ((0, 0, 0), 5, (oldx, oldy), (!x, !y))
  in

  let line ev = draw ctx (compute_line ev); Lwt.return () in

  Lwt.async (fun () ->
    let open Lwt_js_events in
    mousedowns canvas
      (fun ev _ ->
         set_coord ev;
         let%lwt () = line ev in
         Lwt.pick
           [mousemoves Dom_html.document (fun x _ -> line x);
            let%lwt ev = mouseup Dom_html.document in line ev]))
```
We use two references `x` and `y` to record the last mouse position. The function `set_coord` updates those references from mouse event data. The function `compute_line` computes the coordinates of a line from the initial (old) coordinates to the new coordinates--the event data sent as a parameter.

The last four lines of code implement the event-handling loop. They can be read as follows: for each `mousedown` event on the canvas, do `set_coord`, then `line` (this will draw a dot), then behave as the `first` of the two following lines that terminates:

- For each mousemove event on the document, call `line` (never terminates)
- If there is a mouseup event on the document, call `line`.
<!--wodoc:aside class="concept"-->**Concept: More on Lwt**

Functions in Eliom and Js\_of\_ocaml which do not implement just a computation or direct side effect, but rather wait for user activity, or file system access, or need a unforseeable amount of time to return are defined *with Lwt*; instead of returning a value of type `a` they return an Lwt thread of type `a Lwt.t`.

The only way to use the result of such functions (ones that return values in the *Lwt monad*), is to use `Lwt.bind`.

```ocaml
Lwt.bind : 'a Lwt.t -> ('a -> 'b Lwt.t) -> 'b Lwt.t
```
It is convenient to define an infix operator like this:

```ocaml
 let (>>=) = Lwt.bind
```
Then the code

```ocaml
 f () >>= fun x -> 
```
is conceptually similar to

```ocaml
 let x = f () in
```
but only for functions returning a value in the Lwt monad.

For more clarity, there is a syntax extension for Lwt, defining `let%lwt` to be used instead of `let` for Lwt functions:

```ocaml
 let%lwt x = f () in
```
`Lwt.return` creates a terminated thread from a value: 

```ocaml
 Lwt.return : 'a -> 'a Lwt.t
```
Use it when you must return something in the Lwt monad (for example in a service handler, or often after a `Lwt.bind`).


##### Why Lwt?

An Eliom application is a cooperative program, as the server must be able to handle several requests at the same time. Ocsigen is using cooperative threading instead of the more widely used preemptive threading paradigm. It means that no scheduler will interrupt your functions whenever it wants. Switching from one thread to another is done only when there is a *cooperation point*.

We will use the term *cooperative functions* to identify functions implemented in cooperative way, that is: if something takes (potentially a long) time to complete (for example reading a value from a database), they insert a cooperation point to let other threads run. Cooperative functions return a value in the Lwt monad (that is, a value of type `'a Lwt.t` for some type `'a`).

`Lwt.bind` and `Lwt.return` do not introduce cooperation points.

In our example, the function `Lwt_js_events.mouseup` may introduce a cooperation point, because it is unforseeable when this event happens. That's why it returns a value in the Lwt monad.

Using cooperative threads has a huge advantage: given that you know precisely where the cooperation points are, *you need very few mutexes* and you have *very low risk of deadlocks*\!

Using Lwt is very easy and does not cause trouble, provided you never use *blocking functions* (non-cooperative functions). *Blocking functions can cause the entre server to hang\!* Remember:

- Use the functions from module `Lwt_unix` instead of module `Unix`,
- Use cooperative database libraries (like PG'Ocaml for Lwt),
- If you want to use a non-cooperative function, detach it in another preemptive thread using `val
Lwt_preemptive.detach`,
- If you want to launch a long-running computation, manually insert cooperation points using `Lwt_unix.yield`,
- `Lwt.bind` does not introduce any cooperation point.
<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Handling events with Lwt**

Module `Js_of_ocaml_lwt.Lwt_js_events` allows easily defining event listeners using Lwt. For example, `Js_of_ocaml_lwt.Lwt_js_events.click` takes a DOM element and returns an Lwt thread that will wait until a click occures on this element.

Functions with an ending "s" (`val
Js_of_ocaml_lwt.Lwt_js_events.clicks`, `val
Js_of_ocaml_lwt.Lwt_js_events.mousedowns`, ...) start again waiting after the handler terminates.

`Lwt.pick` behaves as the first thread in the list to terminate, and cancels the others.

<!--wodoc:end-->

### Collaborative drawing application

<!--wodoc:aside class="concepts"-->**Concepts**

Client server communication <!--wodoc:end-->

In order to see what other users are drawing, we now want to do the following:

- Send the coordinates to the server when the user draw a line, then
- Dispatch the coordinates to all connected users.
We first declare a type, shared by the server and the client, describing the color (as RGB values) and coordinates of drawn lines.

<!--wodoc:@ class=shared-->
```ocaml
type%shared messages =
    ((int * int * int) * int * (int * int) * (int * int))
    [@@deriving json]
```
We annotate the type declaration with `[@@deriving json]` to allow type-safe deserialization of this type. Eliom forces you to use this in order to avoid server crashes if a client sends corrupted data. This is defined using a JSON plugin for [ppx\_deriving](https://github.com/whitequark/ppx_deriving), which you need to install. You need to do that for each type of data sent by the client to the server. This annotation can only be added on types containing exclusively basic types, or other types annotated with `[@@deriving json]`.

Then we create an Eliom bus to broadcast drawing events to all client with the function `val
Eliom.Bus.create`. This function take as parameter the type of values carried by the bus.

<!--wodoc:@ class=server-->
```ocaml
let%server bus = Eliom.Bus.create [%json: messages]
```
To write draw commands into the bus, we just replace the function `line` in `init_client` by:

<!--wodoc:@ class=client-->
```ocaml
let line ev =
  let v = compute_line ev in
  let _ = Eliom.Bus.write ~%bus v in
  draw ctx v;
  Lwt.return ()
in
```
Finally, to interpret the draw orders read on the bus, we add the following line at the end of function `init_client`:

<!--wodoc:@ class=client-->
```ocaml
  Lwt.async (fun () ->
    Lwt_stream.iter (draw ctx) (Eliom.Bus.stream ~%(bus : (messages, messages) Eliom.Bus.t)))
```
Now you can try the program using two browser windows to see that the lines are drawn on both windows.

<!--wodoc:aside class="concept"-->**Concept: Communication channels**

Eliom provides multiple ways for the server to send unsolicited data to the client:

- Module `Eliom.Notif` (or `Os.Notif` if you are using Ocsigen Start) provides a very simple way to send messages to clients. It's probably the solution you will use most of the times.
- You can use `Eliom.Bus.t` instead, as in this example, in the particular case when you need to broadcast data to all connected clients. Buses are broadcasting channels where client and server can participate (see also `Eliom.Bus.t` in the client API).
- `module
Eliom_react` allows sending [React events](http://erratique.ch/software/react/doc/React) from the server to the client, and conversely.
- `type
Eliom.Comet.Channel.t` are one-way communication channels allowing finer-grained control. It allows sending `Lwt_stream` to the client. `Eliom_react` and `Eliom.Bus` are implemented over `Eliom.Comet`.
It is possible to control the idle behaviour with module `module
Eliom.Comet.Configuration`.

<!--wodoc:end-->

### Color and size of the brush

<!--wodoc:aside class="concepts"-->**Concepts**

Widgets with Ocsigen Toolkit<br/> Functional Reactive Programming<br/> <!--wodoc:end-->

In this section, we add a color picker and slider to choose the size of the brush. For the colorpicker we used a widget available in [Ocsigen Toolkit](https://ocsigen.org/ocsigen-toolkit/latest/intro.html).

To install Ocsigen Toolkit, do:

```
opam install ocsigen-toolkit
```
Add package `ocsigen-toolkit.server` to the `libraries` section of your `dune` file, and `ocsigen-toolkit.client` to the `libraries` section of your `client/dune` file.

```
  (libraries ... ocsigen-toolkit.server)
```
```
  (libraries ... ocsigen-toolkit.client)
```
In `Makefile.options`, created by Eliom's distillery, add `ocsigen-toolkit.server` to the `SERVER_PACKAGES`. This will be used to regenerate Ocsigen Server's configuration file.

```makefile
SERVER_PACKAGES := ... ocsigen-toolkit.server
```
To create the widget, we replace `page` by :

<!--wodoc:@ class=server-->
```ocaml
let%server page () =
  let colorpicker, cp_sig =
    Ot.Color_picker.make ~a:[Html.D.a_class ["colorpicker"]] ()
  in
  ( Html.D.html
      (Html.D.head
         (Html.D.title (Html.D.txt "Graffiti")) [])
      (Html.D.body [h1 [txt "Graffiti"]
                   ; canvas_elt
                   ; colorpicker])
  , cp_sig )
```
Replace the registration of `main_service` by:

<!--wodoc:@ class=server-->
```ocaml
let%server () =
  Graffiti_app.register ~service:main_service
    (fun () () ->
       (* Cf. section "Client side side-effects on the server" *)
      let page, cp_sig = page () in
       let _ = [%client (init_client ~cp_sig:~%cp_sig () : unit) ] in
       Lwt.return page)
```
We subsequently add a simple HTML slider to change the size of the brush. Near the `canvas_elt` definition, simply add the following code:

<!--wodoc:@ class=server-->
```ocaml
let%server slider =
  Eliom.Content.Html.D.Form.input
    ~a:
      [ Html.D.a_id "slider"
      ; Html.D.a_class ["slider"]
      ; Html.D.a_input_min (`Number 1)
      ; Html.D.a_input_max (`Number 80)
      ; Html.D.a_value "22" ]
    ~input_type:`Range Html.D.Form.int
```
`Form.int` is a typing information telling that this input takes an integer value. This kind of input can only be associated to services taking an integer as parameter.

We then add the slider to the page body, between the canvas and the colorpicker.

To change the size and the color of the brush, we add parameter `~cp_sig` to `init_client` and modify function `compute_line`:

<!--wodoc:@ class=client-->
```ocaml
let%client init_client ~cp_sig () =
...
  let compute_line ev =
    let oldx = !x and oldy = !y in
    set_coord ev;
    let size_slider = Eliom.Content.Html.To_dom.of_input ~%slider in
    let size = int_of_string (Js.to_string size_slider##.value) in
    let h, s, v = Eliom.Shared.React.S.value cp_sig in
    let r, g, b = Ot.Color_picker.hsv_to_rgb h s v in
    let rgb = int_of_float r, int_of_float g, int_of_float b in
    (rgb, size, (oldx, oldy), (!x, !y))
  in
...
```
Finally, we need to add a stylesheet in the headers of our page with function `Eliom.Tools.D.css_link`:

<!--wodoc:@ class=server-->
```ocaml
let%server page () =
  let colorpicker, cp_sig =
    Ot.Color_picker.make ~a:[Html.D.a_class ["colorpicker"]] ()
  in
  ( html
      (head
         (title (Html.D.txt "Graffiti"))
         [ css_link
             ~uri:
               (Html.D.make_uri
                  ~service:(Eliom.Service.static_dir ())
                  ["css"; "graffiti.css"])
             ()
         ; css_link
             ~uri:
               (make_uri
                  ~service:(Eliom.Service.static_dir ())
                  ["css"; "ot_color_picker.css"])
             () ])
      (body [canvas_elt; slider; colorpicker])
  , cp_sig )
```
You need to install the corresponding stylesheets and images into your project. The stylesheet files should go to the directory `static/css`. Download file `graffiti.css` from [here](files/tutorial/static/css/graffiti.css). Copy file `ot_color_picker.css` from directory `~/.opam/<version>/share/ocsigen-toolkit/css` into `static/css`.

You can then test your application (`make test.byte`).

<!--wodoc:aside class="concept"-->**Concept: Ocsigen Toolkit**

Ocsigen Toolkit is a Js\_of\_ocaml library providing useful client-server widgets for your Eliom applications. You can use it for building complex user interfaces. The full documentation is available ([Ocsigen Toolkit](https://ocsigen.org/ocsigen-toolkit/latest/)).

<!--wodoc:end-->
<!--wodoc:aside class="concept"-->**Concept: Functional Reactive Programming**

Ocsigen Toolkit is using *Functional Reactive Programming* to simplify and automatize page changes, through Daniel Bünzli's React library.

For example, `Ot.Color_picker.make` returns both the element and a *reactive signal* on which you can bind other computations or other page elements, that would be updated automatically when the signal value changes.

Eliom makes it possible to create reactive (client side) page elements from server side, through module Eliom.Shared.

This basic program does not show the full power of reactive programming, however. See [this tutorial](./tutoreact.md) for a better introduction to reactive programming with Eliom.

<!--wodoc:end-->

### Sending the initial image

<!--wodoc:aside class="concepts"-->**Concepts**

Services sending other data types<!--wodoc:end-->

To finish the first part of the tutorial, we want to save the current drawing on server side and send the current image when a new user arrives. To do that, we will use the [Cairo binding](https://github.com/Chris00/ocaml-cairo) for OCaml.

For using Cairo, first, make sure that it is installed (it is available as `cairo2` via OPAM). Second, add it to the `libraries` section in your `dune` file.

Second, add it to the SERVER\_PACKAGES in your Makefile.options:

```makefile
SERVER_PACKAGES := ... cairo2
```
The `draw_server` function below is the equivalent of the `draw` function on the server side and the `image_string` function outputs the PNG image in a string.

<!--wodoc:@ class=server-->
```ocaml
let%server draw_server, image_string =
  let rgb_ints_to_floats (r, g, b) =
    float r /. 255., float g /. 255., float b /. 255.
  in
  (* needed by cairo *)
  let surface = Cairo.Image.create Cairo.Image.ARGB32 ~w:width ~h:height in
  let ctx = Cairo.create surface in
  ( (fun (rgb, size, (x1, y1), (x2, y2)) ->
      (* Set thickness of brush *)
      let r, g, b = rgb_ints_to_floats rgb in
      Cairo.set_line_width ctx (float size);
      Cairo.set_line_join ctx Cairo.JOIN_ROUND;
      Cairo.set_line_cap ctx Cairo.ROUND;
      Cairo.set_source_rgb ctx r g b;
      Cairo.move_to ctx (float x1) (float y1);
      Cairo.line_to ctx (float x2) (float y2);
      Cairo.Path.close ctx;
      (* Apply the ink *)
      Cairo.stroke ctx)
  , fun () ->
      let b = Buffer.create 10000 in
      (* Output a PNG in a string *)
      Cairo.PNG.write_to_stream surface (Buffer.add_string b);
      Buffer.contents b )

let%server _ = Lwt_stream.iter draw_server (Eliom.Bus.stream bus)
```
We also define a service that sends the picture:

<!--wodoc:@ class=server-->
```ocaml
let%server imageservice =
  Eliom.Service.create
    ~path:(Eliom.Service.Path ["image"])
    ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
    ()

let%server () =
  Eliom.Registration.String.register ~service:imageservice
    (fun () () -> Lwt.return (image_string (), "image/png"))
```
<!--wodoc:aside class="concept"-->**Concept: Eliom.Registration**

The module `Eliom.Registration` defines several modules with registration and creation functions for a variety of data types. We have already seen `Eliom.Registration.Html` and `Eliom.Registration.App`. The module `Eliom.Registration.String` sends arbitrary byte output (represented by an OCaml string). The handler function must return a pair consisting of the content and the content-type.

There are also several other output modules, for example:

- `Eliom.Registration.File` to send static files
- `Eliom.Registration.Redirection` to create a redirection towards another page
- `Eliom.Registration.Any` to create services that decide late what they want to send
- `Eliom.Registration.Ocaml` to send any OCaml data to be used in a client side program
- `Eliom.Registration.Action` to create service with no output (the handler function just performs a side effect on the server) and reload the current page (or not). We will see an example of actions in the next chapter.
<!--wodoc:end-->
We now want to load the initial image once the canvas is created. Add the following lines just after the creation of the canvas context in `init_client`:

<!--wodoc:@ class=server-->
```ocaml
(* The initial image: *)
let img = Eliom.Content.Html.To_dom.of_img
    (img ~alt:"canvas"
       ~src:(make_uri ~service:~%imageservice ())
       ())
in
img##.onload := Dom_html.handler (fun _ev ->
  ctx##drawImage img 0. 0.; Js._false);
```
As we are now using `Eliom.Content.Html.D` in both client and server sections, we need to open it in a shared section:

<!--wodoc:@ class=shared-->
```ocaml
open%shared Eliom.Content.Html.D
```
Finally, we can add a new canvas where we would draw a visualisation of the current size of the brush. The complete code of this application can be found [here](https://github.com/ocsigen/graffiti/tree/master/simple).

The `Makefile` from the distillery automatically adds the packages defined in `SERVER_PACKAGES` as an extension in your configuration file `local/etc/graffiti/graffiti-test.conf`:

```xml
<extension findlib-package="cairo2" />
```
The first version of the program is now complete.

<!--wodoc:div class="exercices"-->

#### Exercises

- Add a button that allows download the current image, and saving it to the hard disk (reuse the service `imageservice`).
- Add a button with a color picker to select a color from the drawing. Pressing the button changes the mouse cursor, and disables current mouse events until the next mouse click event on the document. Then the color palette changes to the color of the pixel clicked. (Use the function `Dom_html.pixel_get`).
<!--wodoc:end-->
If you want to continue learning client-server programming with Eliom and build your first application, we suggest to read [the tutorial about Ocsigen Start](./start.md).
