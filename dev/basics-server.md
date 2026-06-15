
# Server-side website programming guide

While Eliom is well known for its unique client-server programming model, it is also perfectly suited to programming more traditional websites. This page describes how you can generate Web pages in OCaml, and handle links, forms, page parameters, sessions, etc. You will see that you can get very quickly a working Web site without having to learn innovative concepts and this might be enough for your needs.

You will then learn how Eliom is simplifying the programming of very common behaviours by introducing innovative concepts like scoped sessions or continuation-based Web programming.

Programming with Eliom will make your website ready for future evolutions by allowing you to introduce progressively client-side features like event handlers, fully in OCaml. You will even be able to turn your website into a [distributed client-server Web app](basics.html), and even a mobile app if needed in the future, without having to rewrite anything.

<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## OCaml

<!--wodoc:end-->
This programming guide assumes you know the *OCaml* language. Many resources and books are available online.

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Lwt

<!--wodoc:end-->
*Lwt* is a concurrent programming library for OCaml, initially written by Jérôme Vouillon in 2001 for the [Unison](https://github.com/bcpierce00/unison) file synchronizer. It provides an alternative to the more usual preemptive threads approach for programming concurrent applications, that avoids most problems of concurrent data access and deadlocks. It is used by Ocsigen Server and Eliom and has now become one of the standard ways to implement concurrent applications in OCaml. All your Web sites must be written in Lwt-compatible way\!

<!--wodoc:div class="focused"-->

### How it works

Instead of calling blocking functions, like `Unix.sleep` or `Unix.read`, that could block the entire program, replace them by their cooperative counterparts (`Lwt_unix.sleep`, `Lwt_unix.read`, etc.). Instead of taking time to execute, they always return immediately a *promise* of the result, of type `'a Lwt.t`. This type is abstract, and the only way to use the result is to *bind* a function to the promise. `Lwt.bind p f` means: "when promise `p` is completed, give its result to function `f`".

Syntax `let%lwt x = p in e` is equivalent to `Lwt.bind p (fun x -> e)` and makes it very natural to sequentialize computations without blocking the rest of the program. <!--wodoc:end-->

To learn Lwt, read this [short tutorial](lwt.html), or its [user manual](https://ocsigen.org/lwt/latest/).

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Ocsigen Server: A full featured extensible Web server in OCaml

<!--wodoc:end--> Ocsigen Server can be used either as a library for you OCaml programs, or as an executable, taking its configuration from a file (and with dynamic linking).

Extensions add features to the server. For example, Staticmod makes it possible to serve static files, Deflatemod to compress the output, Redirectmod to configure redirections etc.

Install Ocsigen Server with:

```
opam install ocsigenserver
```

### Use as a library

Let's create a new OCaml project with Dune:

```
dune init project mysite
```
To include a Web server in your OCaml program, just add package `ocsigenserver` to your Dune file, together with all the extensions you need. For example, modify file `bin/dune` like this:

```
(executable
 (public_name mysite)
 (name main)
 (libraries
  ocsigenserver
  ocsigenserver.ext.staticmod))
```
The following command will launch a server, serving static files from directory `static`:

```ocaml
let () = 
  Ocsigen.Server.start [ Ocsigen.Server.host [Staticmod.run ~dir:"static" ()]]
```
Put this in file `bin/main.ml`, and run `dune exec mysite`.

By default, the server runs on port 8080\. Create a `static` directory with some files and try to fetch them using your Web browser.


### Use as an executable

Alternatively, you can run command `ocsigenserver` with a configuration file:

```
ocsigenserver -c mysite.conf
```
The following configuration file corresponds to the program above:

```
<ocsigen>
  <server>
    <port>8080</port>
    <extension findlib-package="ocsigenserver.ext.staticmod"/>
    <host>
      <static dir="static" />
    </host>
  </server>
</ocsigen>
```
<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Eliom: Services

<!--wodoc:end--> The following code shows how to create a service that answers for requests at URL `http://.../aaa/bbb`, by invoking an Ocaml function `f` of type:

```ocaml

 f : (string * string) list -> unit -> string Lwt.t

```
Function `f` generates HTML as a string, taking as first argument the list of URL parameters (GET parameters), and as second argument the list of POST parameters (here none).

```ocaml

let f _ () =
  Lwt.return "<html><head><title>Hello world</title></head><body>Welcome</body></html>"

let myservice =
  Eliom.Service.create
    ~path:(Eliom.Service.Path ["aaa"; "bbb"])
    ~meth:(Eliom.Service.Get Eliom.Parameter.any)
    ()

let () =
  Eliom.Registration.Html_text.register
    ~service:myservice
    f
```
`Eliom.Service.Get Eliom.Parameter.any` means that the service uses the GET HTTP method and takes any GET parameter. The first parameter of function `f` is an association list of GET parameters.

Module `Eliom.Registration.Html_text` is used to register a service sending HTML as strings. But we recommend to used typed-HTML instead (see below).

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Compiling

<!--wodoc:end-->
In this section, we will show how to compile and run a *server-side only* Web site by creating your project manually.


### Build an executable

This section shows how to create a static executable for you program (without configuration file).

Run the following command:

```
opam install ocsipersist-sqlite-config eliom
dune init project --kind=executable mysite
cd mysite
```
Create the directories will we use for data (logs, etc.):

```
mkdir -p local/var/log/mysite
mkdir -p local/var/data/mysite
mkdir -p local/var/run
```
Add packages `ocsipersist-sqlite` and `eliom.server` to file `bin/dune`, in the "libraries" section.

Copy the definition and registration of service `myservice` at the beginning of file `bin/main.ml`, and replace the call to `Ocsigen.Server.start` by the following lines:

```ocaml
let () = 
  Ocsigen.Server.start
    ~command_pipe:"local/var/run/mysite-cmd"
    ~logdir:"local/var/log/mysite"
    ~datadir:"local/var/data/mysite"
    [
      Ocsigen.Server.host
       [ Staticmod.run ~dir:"local/var/www/mysite" ()
       ; Eliom.App.run () ]
    ]
```
Build and execute the program with:

```
dune exec mysite
```
Open URL `http://localhost:8080/aaa/bbb` with your browser.


### Use with ocsigenserver

Alternatively, you can decide to build your Eliom app as a library and load it dynamically into ocsigenserver using a configuration file.

```
opam install ocsipersist-sqlite-config eliom
dune init proj --kind=lib mysite
cd mysite
```
Add `(libraries eliom.server)` into file `lib/dune`.

Create the directories will we use for data (logs, etc.):

```
mkdir -p local/var/log/mysite
mkdir -p local/var/data/mysite
mkdir -p local/var/run
```
Create your `.ml` files in directory `lib`. For example, copy the definition and registration of service `myservice` above.

Compile:

```
dune build
```
Create a configuration file `mysite.conf` with this content on your project root directory:

```
<ocsigen>
  <server>
    <port>8080</port>

    <logdir>local/var/log/mysite</logdir>
    <datadir>local/var/data/mysite</datadir>
    <charset>utf-8</charset>

    <commandpipe>local/var/run/mysite-cmd</commandpipe>
    <extension findlib-package="ocsigenserver.ext.staticmod"/>
    <extension findlib-package="ocsipersist-sqlite-config"/>
    <extension findlib-package="eliom.server"/>
    <host hostfilter="*">
      <static dir="local/var/www/mysite" />
      <eliommodule module="_build/default/lib/mysite.cma" />
      <eliom/>
    </host>
  </server>
</ocsigen>
```
Launch the application:

```
ocsigenserver -c mysite.conf
```
Open URL `http://localhost:8080/aaa/bbb` with your browser. <!--wodoc:end-->

<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## TyXML: typing HTML

<!--wodoc:end-->
TyXML statically checks that your OCaml functions will never generate wrong HTML. For example a program that could generate a paragraph containing another paragraph will be rejected at compile time.

Example of use:

```ocaml
let open Eliom.Content.Html.F in
html
  (head (title (txt "Ex")) [])
  (body [h1 ~a:[a_id "toto"; a_class ["blah"; "blih"]]
           [txt "Hallo!"]])
```
<!--wodoc:div class="focused"-->

### How it works

TyXML builds the page as an OCaml data-structure using a construction function for each HTML tag. These functions take as parameters and return nodes of type `'a elt` where `'a` is a polymorphic variant type added in the module signature to constrain usage (phantom type). <!--wodoc:end-->


### Example of typing error

```ocaml
p [p [txt "Aïe"]]
   ^^^^^^^^^^^^^
Error: This expression has type
         ([> Html_types.p ] as 'a) Eliom.Content.Html.F.elt =
           'a Eliom.Content.Html.elt
       but an expression was expected of type
         ([< Html_types.p_content_fun ] as 'b) Eliom.Content.Html.F.elt =
           'b Eliom.Content.Html.elt
       Type 'a = [> `P ] is not compatible with type
         'b =
           [< `A of Html_types.phrasing_without_interactive
            | `Abbr
            | `Audio of Html_types.phrasing_without_media
            ...
            | `Output
            | `PCDATA
            | `Progress
            | `Q
            ...
            | `Wbr ]
       The second variant type does not allow tag(s) `P
```
Read more about TyXML in this [short tutorial](html.html) or in its [user manual](https://ocsigen.org/tyxml/latest/).

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Eliom: Service returning typed HTML

<!--wodoc:end-->
To use typed HTML, just replace module `Eliom.Registration.Html_text` by `Eliom.Registration.Html`:

```ocaml

let f _ () =
  Lwt.return
    Eliom.Content.Html.F.(html (head (title (txt "")) [])
                               (body [h1 [txt "Hello"]]))

let myservice =
  Eliom.Service.create
    ~path:(Eliom.Service.Path ["aaa"; "bbb"])
    ~meth:(Eliom.Service.Get Eliom.Parameter.any)
    ()

let () =
  Eliom.Registration.Html.register
    ~service:myservice
    f
```

### Outputs

Services can return a typed HTML page as in the example above, but also any other kind of result. To choose the return type, use the register function from the corresponding submodule of `Eliom.Registration`:

<!--wodoc:div-->
| --- | --- |
| `Html` | Services returning typed HTML pages |
| `Html_text` | Services returning untyped HTML pages as strings |
| `App` | Apply this functor to generate registration functions for services belonging to an Eliom client/server application. These services also return typed HTML pages, but Eliom will automatically add the client-side program as a JS file, and all the data needed (values of all injections, etc.) |
| `Flow` | Services returning portions of HTML pages. |
| `Action` | Services performing actions (server side effects) with or without reloading the page (e.g. login, logout, payment, modification of user information...) |
| `Files` | Serve files from the server hard drive |
| `Ocaml` | Services returning OCaml values to be sent to a client side OCaml program (this kind of services is used as low level interface for server functions \-- see below) |
| `String` | Services returning any OCaml string (array of byte) |
| `Redirection` | Services returning an HTTP redirection to another service |
| `Any` | To be used to make the service chose what it sends. Call function `send` from the corresponding module to choose the output. |
| `Customize` | Apply this functor to define your own registration module |
<!--wodoc:end--> <!--wodoc:end-->

<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Eliom: Typing page parameters

<!--wodoc:end-->
Instead of taking GET parameters as an untyped `string * string` association list, you can ask Eliom to decode and check parameter types automatically.

For example, the following code defines a service at URL `/foo`, that will use GET HTTP method, and take one parameter of type `string`, named `s`, and one of type `int`, named `i`. <!--wodoc:@ class=server-->

```ocaml
let myservice =
  Eliom.Service.create
    ~path:(Eliom.Service.Path ["foo"])
    ~meth:(Eliom.Service.Get (Eliom.Parameter.(string "s" ** int "i")))
    ()
```
Then register an OCaml function as handler on this service:

<!--wodoc:@ class=server-->
```ocaml
let () =
  Eliom.Registration.Html.register ~service:myservice
    (fun (s, i) () ->
      Lwt.return
         Eliom.Content.Html.F.(html (head (title (txt "")) [])
                                    (body [h1 [txt (s^string_of_int i)]])))
```
The handler takes as first parameter the GET page parameters, typed according to the parameter specification given while creating the service. The second parameter is for POST parameters (see below).

Recompile you program, and to to URL `http://localhost:8080/foo?s=hello&i=22` to see the result.


### Parameters

Module `Eliom.Parameter` is used to describe the type of service parameters.

Examples:

```ocaml
Eliom.Parameter.(int "i" ** (string "s" ** bool "b"))
   (* /path?i=42&s=toto&b=on *)

Eliom.Parameter.(int "i" ** opt (string "s"))
   (* An integer named i, and an optional string named s *)

Eliom.Parameter.(int "i" ** any)
   (* An integer named i, and any other parameters, as an association list
      of type (string * string) list *)

Eliom.Parameter.(set string "s")
   (* /path?s=toto&s=titi&s=bobo *)

Eliom.Parameter.(list "l" (int "i"))
   (* /path?l[0]=11&l[1]=2&l[2]=42 *)

Eliom.Parameter.(suffix (int "year" ** int "month"))
   (* /path/2012/09 *)

Eliom.Parameter.(suffix_prod (int "year" ** int "month") (int "a"))
   (* /path/2012/09?a=4 *)

```
<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Eliom: POST services

<!--wodoc:end-->
To define a service with POST parameters, just change the `~meth` parameter. For example the following example takes the same GET parameters as the service above, plus one POST parameter of type string, named "mypostparam". <!--wodoc:@ class=server-->

```ocaml
~meth:(Eliom.Service.Post (Eliom.Parameter.((string "s" ** int "i"),
                                            (string "mypostparam"))))
```
<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Eliom: Other kinds of services

<!--wodoc:end-->
The detailed explanation of services can be found in [Eliom's manual](https://ocsigen.org/eliom/latest/server-services.html). Here is a summary:


### Pathless services

Pathless services are not identified by the path in the URL, but by a name given as parameter, regardless of the path. Use this to make a functionality available from all pages (for example: log-in or log-out actions, add something in a shopping basket ...). The name can be specified manually using the `~name` optional parameter, otherwise, a random name is generated automatically. This is also used to implement server functions (see below). If you are programming a client-server Eliom app, you will often prefer remote procedure calls (\`let%rpc\`).

<!--wodoc:@ class=server-->
```ocaml
let pathless_service =
  Eliom.Service.create
    ~name:"pathless_example"
    ~path:Eliom.Service.No_path
    ~meth:(Eliom.Service.Get (Eliom.Parameter.(int "i")))
    ()
```
More information [in the manual](https://ocsigen.org/eliom/latest/server-services.html#pathless).


### Attached services

It is also possible to create services identified by both a path and a special parameter, using functions `Eliom.Service.create_attached_get` or `Eliom.Service.create_attached_post`. They take a regular service (with a path) as parameter (`~fallback`).

It is also possible to attach an existing pathless service to the URL of another service, with function `Eliom.Service.attach`. This allows for example to create a link towards a pathless service, but on another path.


### External services

Use `Eliom.Service.extern` to create links or forms towards external Web sites as if they were Eliom services.


### Predefined services

Use service `(Eliom.Service.static_dir ())` to create links towards static files (see example below for images).

Use service `Eliom.Service.reload_action` and its variants to create links or forms towards the current URL (reload the page). From a client section, you can also call `Os.Lib.reload` to reload the page and restart the client-side program.

[Full documentation about services](https://ocsigen.org/eliom/latest/server-services.html), [a tutorial about traditional service based Web programming](interaction.html), API documentation of modules `Eliom.Service` and `Eliom.Registration`.

This example shows how to insert an image using `static_dir`:

```ocaml
img
  ~alt:"blip"
  ~src:(Eliom.Content.Html.F.make_uri
         (Eliom.Service.static_dir ())
         ["dir" ; "image.jpg"])
  ()
```
<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Forms and links

<!--wodoc:end-->
Function `Eliom.Content.Html.F.a` creates typed links to services with their parameters. For example, if `home_service` expects no parameter and `other_service` expects a string and an optional int:

```ocaml
Eliom.Content.Html.F.a ~service:home_service [txt "Home"] ()
Eliom.Content.Html.F.a ~service:other_service [txt "Other"] ("hello", Some 4)
```
Module `Eliom.Content.Html.F` defines the form's elements with the usual typed interface from TyXML. Use this for example if you have a client side program and want to manipulate the form's content from client side functions (for example do a server function call with the form's elements' content).

In contrast, module `Eliom.Content.Html.F.Form` defines a typed interface for form elements. Use this for links (see above), or if you program traditional server-side Web interaction (with or without client-side program). This will statically check that your forms match the services. Example:

```ocaml
let open Eliom.Content.Html.F in
Form.post_form
 ~service:connection_service
   (fun (name, password) ->
     [fieldset
       [label ~a:[a_label_for "loginname"] [txt "Name: "];
        Form.input ~a:[a_id "loginname"] ~input_type:`Text ~name Form.int;
        br ();
        Form.input
          ~a:[a_placeholder "Password"]
          ~input_type:`Password
          ~name:password
          Form.string;
        br ();
        Form.input ~input_type:`Submit ~value:"Connect" Form.string
      ]]) ()

```
As you can see, function `Eliom.Content.Html.F.Form.post_form` is used to create a form sending parameters using the POST HTTP method (and similarly, `get_form` for GET method). It takes the service as first parameter, and a function that will generate the form. This function takes the names of the GET or POST parameters as arguments.

Form elements (like inputs) are also built from using the `Eliom.Content.Html.F.Form` module. They take the names as parameters, and a last parameter (like `Form.int` or `Form.string`) to match the expected type.

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Sessions

<!--wodoc:end-->
Session data is saved on server side in *Eliom references*.

The following Eliom reference will count the number of visits of a user on a page:

<!--wodoc:@ class=server-->
```ocaml
let%server count_ref =
  Eliom.Reference.eref
    ~scope:Eliom.Common.default_session_scope
    0 (* default value for everyone *)
```
And somewhere in your service handler, increment the counter: <!--wodoc:@ class=server-->

```ocaml
let%lwt count = Eliom.Reference.get count_ref in
Eliom.Reference.set count_ref (count + 1);
Lwt.return ()
```
With function `Eliom.Reference.eref_from_fun`, you can create Eliom references without initial value. The initial value is computed for the session the first time you use it.

An Eliom reference can be persistant (value saved on hard drive) or volatile (in memory).


### Scopes

Sessions are relative to a browser, and implemented using browser cookies. But Eliom allows to create Eliom references with other *scopes* than session:

| --- | --- |
| `global_scope` | Global value for all the Web server |
| `site_scope` | Global value for the Eliom app in that subsite of the Web site |
| `default_group_scope` | Value for a group of sessions. For example Ocsigen Start defines a group of session for each user, making it possible to save server side data for all sessions of a user. |
| `default_session_scope` | The usual session data, based on browser cookies |
| `default_process_scope` | Server side data for a given client-side process (a tab of the browser or a mobile app). This is available only with a client-server Eliom app. |
Applications based on Ocsigen Start use these scopes for user management. Session or client process data are discarded when a user logs in or out. But Ocsigen Start also defines scopes `Os.Session.user_indep_session_scope` and `Os.Session.user_indep_process_scope` which remain even if a user logs in or out.

When session group is not set (for example the user is not connected), you can still use the group session scope: in that case, the group contains only one session.

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Browser events

<!--wodoc:end--> By default, event handlers on HTML elements are given as OCaml functions, but it works only if you have a client-server Eliom program. If not, you want to give a javascript expression (as a string) instead. To so that, use attributes functions from module `Raw`. For example `Eliom.Content.Html.F.Raw.a_onclick` instead of `Eliom.Content.Html.F.a_onclick`.

Example: <!--wodoc:@ class=server-->

```ocaml
Eliom.Content.Html.F.(button ~a:[Raw.onclick "alert(\"beep\");"] [txt "click"])
```
<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Database access

<!--wodoc:end-->
You can use your favourite database library with Ocsigen. Ocsigen Start's template uses [PG'OCaml](https://github.com/darioteixeira/pgocaml) (typed queries for Postgresql using a PPX syntax extension).

Here is an example, taken from Ocsigen Start's demo: <!--wodoc:@ class=server-->

```ocaml
let get () =
  full_transaction_block (fun dbh ->
    [%pgsql dbh "SELECT lastname FROM ocsigen_start.users"])
```
<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Continuation-based Web programming

<!--wodoc:end-->
Eliom allows the dynamic creation of temporary services. This is equivalent to a programming pattern known as "continuation-based Web programming". While present in very few Web frameworks, it is a very powerful feature that can save you a lot of time when programming a server-side website. A typical use case is when you have a series of pages, each of which depending on the entries made on the previous pages, for example a multi-step train ticket booking.

Implementing that without continuation-based Web programming is tedious: you must store the data previously sent by the user and find a way to get it for each step of the interaction. It is not possible to save it as session data, as you want for example to be able to have several different interactions in different tabs of your browser, or to press the back button of your browser to go back in the past. This is known as "the back button problem".

With Eliom, you just need to create new temporary services especially for one user, that will depend on previous interaction with them. The form data will be recorded in the closure of the service handler function. In our example, you can implement a first page with a form (departure, destination, date, first name, last name ...). The form sends this data to another service. This second service will display a list of train tickets, each with a link to buy the ticket. Each of these links corresponds to a service that has been specifically created for this user and train, which will display the payment page for this ticket.

To implement temporary services, we usually use pathless or attached services (see above). To avoid a memory leak, you can make them temporary using optional parameters of the service creation function (`?max_use` or `?timeout`).

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Internationalisation

<!--wodoc:end-->
[Ocsigen i18n](https://github.com/besport/ocsigen-i18n) is an internationalisation library for your OCaml programs.

Create a .tsv file with, on each line, a key and the text in several languages:

```
welcome_message Welcome everybody!        Bienvenue à tous !      Benvenuti a tutti !
```
and Ocsigen i18n will automatically generate functions like this one: <!--wodoc:@ class=shared-->

```ocaml
let%shared welcome_message ?(lang = get_language ()) () () =
  match lang with
  | En -> [txt "Welcome everybody!"]
  | Fr -> [txt "Bienvenue à tous !"]
  | It -> [txt "Benvenuti a tutti !"]
```
Ocsigen i18n also defines a syntax extension to use these functions: <!--wodoc:@ class=shared-->

```ocaml
  Eliom.Content.Html.F.h1 [%i18n welcome_message]
```
Ocsigen i18n offers many other features:

- Text can be inserted as a TyXML node (as in the example above) or as a string (ex: `[%i18n S.welcome_message]`),
- Text can be parametrizable, or contain holes (ex: `[%i18n welcome ~capitalize:true ~name:"William"]`)
- .tsv file can be split into several modules
Have a look at the [README file](https://github.com/besport/ocsigen-i18n) to see the full documentation, and see examples in [Ocsigen Start's template](https://github.com/ocsigen/ocsigen-start/blob/master/template.distillery/demo_i18n.eliom).

<!--wodoc:end-->
<!--wodoc:section class="docblock"--> <!--wodoc:header-->


## Ocsigen Server

<!--wodoc:end-->
*Ocsigen Server* is a full featured Web server.

It is now based on [Cohttp](https://github.com/mirage/ocaml-cohttp).

It has a powerful extension mechanism that makes it easy to plug your own OCaml modules for generating pages. Many extensions are already written: ;[Staticmod](https://ocsigen.org/ocsigenserver/latest/staticmod.html) : to serve static files. ;[Eliom](https://ocsigen.org/eliom/latest/) : to create reliable client/server Web applications or Web sites in OCaml using advanced high level concepts. ;[Extendconfiguration](https://ocsigen.org/ocsigenserver/latest/extendconfiguration.html) : allows for more options in the configuration file. ;[Accesscontrol](https://ocsigen.org/ocsigenserver/latest/accesscontrol.html) : restricts access to the sites from the config file (to requests coming from a subnet, containing some headers, etc.). ;[Authbasic](https://ocsigen.org/ocsigenserver/latest/authbasic.html) : restricts access to the sites from the config file using Basic HTTP Authentication. ;CGImod : serves CGI scripts. It may also be used to serve PHP through CGI. ;[Deflatemod](https://ocsigen.org/ocsigenserver/latest/deflatemod.html) : used to compress data before sending it to the client. ;[Redirectmod](https://ocsigen.org/ocsigenserver/latest/redirectmod.html) : sets redirections towards other Web sites from the configuration file. ;[Revproxy](https://ocsigen.org/ocsigenserver/latest/revproxy.html) : a reverse proxy for Ocsigen Server. It allows to ask another server to handle the request. ;[Rewritemod](https://ocsigen.org/ocsigenserver/latest/rewritemod.html) : changes incoming requests before sending them to other extensions. ;[Outputfilter](https://ocsigen.org/ocsigenserver/latest/outputfilter.html) : rewrites some parts of the output before sending it to the client. ;[Userconf](https://ocsigen.org/ocsigenserver/latest/userconf.html) : allows users to have their own configuration files. ;Comet : facilitates server to client communications.

Ocsigen Server has a [sophisticated configuration](https://ocsigen.org/ocsigenserver/latest/config.html) file mechanism allowing complex configurations of sites.

<!--wodoc:end-->