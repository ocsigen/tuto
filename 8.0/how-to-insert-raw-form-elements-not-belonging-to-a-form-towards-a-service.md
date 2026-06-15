
# How to insert "raw" form elements (not belonging to a form towards a service)?

Eliom redefines most forms elements (inputs, textareas, checkboxes, etc.) to make possible to check the type of the form w.r.t. the type of the service.

If you don't want that (for example if you want to use it only from a client side program), you can use "raw form elements" (that is, basic tyxml elements), using module [`Eliom_content.Html.D.Raw`](https://ocsigen.org/eliom/latest/eliom.server/Eliom/Content/Html/D/Raw/index.html) (or [`Eliom_content.Html.F.Raw`](https://ocsigen.org/eliom/latest/eliom.server/Eliom/Content/Html/F/Raw/index.html)).

Example:

```ocaml
{{{
open Eliom_content.Html.D

Raw.textarea (txt "blah")

}}}
```