
# How to add a JavaScript script?

If you have client-side programs on your website, you can use Eliom's client-server features, that will compile client-side parts to JS using **Ocsigen Js\_of\_ocaml**, and automatically include the script in the page. But in some cases you may also want to include external JS scripts yourself.


### Include the script in the HTML header

Javascript scripts are included in the header using the **js\_script** function (defined in `Eliom.Content.Html.D`).

```ocaml
open Eliom.Content.Html.D (* for make_uri an js_script *)

js_script
     ~uri:(make_uri (Eliom.Service.static_dir ())
              ["hello.js"])
     ()
```
This function has 2 parameters: the file path and unit.

The file path is generated using the **make\_uri** function (from `Eliom.Content.Html.D` module). This function creates the relative URL string using the static directory (which is a service) configured in the configuration file and the given list.

Insert this piece of code on the list given in parameter to the **head** function.

Or you can use: `Eliom.Tools.F.head`


### Call an external function

Have a look at [this page of Js\_of\_ocaml's manual](https://ocsigen.org/js_of_ocaml/latest/js_of_ocaml/bindings.html) to understand how to call JS function from your OCaml program.
