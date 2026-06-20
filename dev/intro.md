
# Introduction

Ocsigen is a complete framework for developing Web and mobile apps using cutting edge techniques. It can be used to write simple server side Web sites, client-side programs, or complex client-server Web and mobile apps. Its main characteristics are:

- The use of a strongly typed language, *OCaml*, and a very advanced use of its type system to check many properties of a program at compile time. This allows to drastically reduce the development time of complex apps, and makes it easier to refactor the code to follow evolutions of its features. As an example, the conformance of generated HTML is checked at compile time, which makes it almost impossible to generate invalid pages.
- *Multi-tier programming*: client and server sides of the application are written using the same language, and as a *single code*. Annotations in the code are used indicate on which side the code is to be run. The client side parts are automatically extracted and compiled into JavaScript to be executed in the browser. This gives a lot of flexibility to the programmer, allowing for example to generate some parts of pages either on client or server code according to your needs. It also makes communication between server and client straightforward, as you can use server side variables in client code, or call a server side OCaml functions from client code.
- *Web and mobile multi-platform apps*: Android and iOS apps are generated from the exact same code as the Web app, and run in a webview.
To see some examples of mobile or Web apps written with Ocsigen, have a look at the [Be Sport social network](https://www.besport.com/news) (available in [Google Play Store](https://play.google.com/store/apps/details?id=com.besport.www.mobile) and [Apple app store](https://apps.apple.com/fr/app/be-sport/id1104216922)), or [Ocsigen Start's demo app](http://ocsigen-1.inria.fr/ocsigen-start/demo/) (available on [Google Play store](https://play.google.com/store/apps/details?id=com.osdemo.mobile)).

Ocsigen consists of several quite independent projects, all released as open source software on [Github](https://github.com/ocsigen). The main projects are:

- `Lwt`, a general purpose concurrent programming library for OCaml,
- `TyXML` for generating typed XML,
- the `Js_of_ocaml` compiler (from Ocaml bytecode to JavaScript),
- `Eliom`, the multi-tier framework for client-server Web and mobile apps,
- `Ocsigen Server`, a full-featured Web server,
- `Ocsigen Toolkit`, a client-server widget library written for Eliom and Js\_of\_ocaml,
- `Ocsigen Start`, an application template with many code examples, to be used as a basis for your apps, or to learn.
The [installation is described here](https://ocsigen.org/install).

Ocsigen originates from a research project by the CNRS, Université de Paris and Inria. It innovates in many aspects, and you will have to learn several new programming techniques to become autonomous. Depending on your level and goals, we suggest to continue by reading some of the following chapters:

- Chapter [Client-server application programming guide](./basics.md) can be used as your training plan. It provides a wide overview of each main concept, with links to more detailed documentation.
- If you want to start with a server-side only Web site, read [Server-side website programming guide](./basics-server.md) instead.
- Then, a good starting point is this [Ocsigen Start tutorial](./start.md), if you plan to build a client-server Web (and/or mobile) app. It will help you to build your first app very quickly, with many code samples to study.
- If you are fluent in OCaml and want a quick introduction to client-server Web programming with Eliom, read tutorial [Eliom apps basics: writing client server widgets](./tutowidgets.md). It illusrates the client-server syntax with an example, and is a good starting point for understanding Eliom's client-server features.
- If you want a full step-by-step tutorial on how to write a client-server Web application, read tutorial [Client-server application](./application.md). It describes step by step how to write a client/server [collaborative drawing application](https://ocsigen.org/graffiti/). You will learn, from the very beginning, how to:
- Create new *services*
- Output *valid HTML*
- Send *OCaml code* to be executed *on the client*
- Call *JavaScript methods* from OCaml
- Catch *mouse events*
- *Communicate* with the server, in both directions
- Create services with *non-HTML output*
- If you want to build mobile applications, read tutorial [Mobile applications with Ocsigen](./mobile.md). It describes how to build a mobile app (e.g., for Android) with the same codebase as for your Web application.
- If you want to write a more traditional Web site, with pages, forms, and sessions, read tutorial [Service based Web programming](./interaction.md). It is devoted to server side programming. It shows how to create a new Web site with several pages and user connections. You will learn how to:
- Create a *link* towards another service
- Create *forms*
- Register *session data* or *session services*
- Create services performing *actions* (with no output)
- Dynamically register new services (*continuation based* Web programming)
- If you want to learn more details about Ocsigen read tutorial [Miscellaneous features](./misc.md). It will mix the client-server drawing application with the session mechanism and user management to produce a multi-user collaborative drawing application. In this chapter, you will learn how to:
- Integrate a typical Web interaction (links, forms,~ …) with a client side program.
- Add *sounds or videos* to your application
- Change pages *without stopping the client side program*
- Connect with external accounts (*openID*)
- Add an Atom feed
- If you want to have a full application with user management (registration, activation emails, authentication), have a look at `Ocsigen-start`. Ocsigen-start is a library and a template for Eliom distillery that contains a working Eliom application with user and right management.
- For a more comprehensive understanding refer to the manual of each project, and/or the API documentation.
- You will also find more tutorials in the menu on the left.
We recommend to ask your questions on [discuss.ocaml.org](https://discuss.ocaml.org) with tag `ocsigen`. You can also come and chat with us on IRC in channel `#ocsigen` on `freenode.net` (e.g. by using their [webchat](http://webchat.freenode.net/?channels=ocsigen))\!

Now, we recommend to read, chapter [All Ocsigen in one page](./basics.md) for a wide and complete overview.
