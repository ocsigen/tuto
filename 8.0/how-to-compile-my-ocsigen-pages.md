
# How to compile my Ocsigen pages?


### Eliom distillery

Eliom-distillery will help you to build your client-server application using Eliom. It comes with several templates ("client-server.basic", "os.pgocaml", and more to come ...).

```
$ eliom-distillery -name <name> -template client-server.basic [-target-directory <dir>]
```
Eliom distillery will also create a default configuration file for Ocsigen Server.

More information on Eliom distillery in [Eliom's manual](https://ocsigen.org/eliom/latest/workflow-distillery.html).

More information on how client-server Eliom project are compiled on [this page](https://ocsigen.org/eliom/latest/workflow-configuration.html).

If you don't need client-server features, the compilation process is very simple and without surprise. Compile with `ocamlc` or `ocamlopt` using `ocamlfind`, with package `eliom.server`. You will have to create your configuration file manually. But you can still use Eliom distillery, which will make easier the inclusion of client side features, later.


### Compilation details

- **eliomdep** helps you handle dependencies of eliom files
- **eliomc** compile server-side eliom files (and ml files too)
- **js\_of\_eliom** compile client-side eliom files
Read manuals for mor information about these compilers.


### Links

- [Full documentation about Ocsigen compilation](https://ocsigen.org/eliom/latest/workflow-configuration.html)