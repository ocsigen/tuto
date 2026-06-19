
# How to add a select (or other form element)?


### In forms towards Eliom services:

```ocaml
open Eliom_content

Html.D.Form.select ~name:select_name
  Html.D.Form.string (* type of the parameter *)
  (Html.D.Form.Option
    ([] (* attributes *),
     "Bob" (* value *),
     None (* Content, if different from value *),
     false (* not selected *))) (* first line *)
    [Html.D.Form.Option ([], "Marc", None, false);
     (Html.D.Form.Optgroup
        ([],
         "Girls",
         ([], "Karin", None, false),
         [([a_disabled `Disabled], "Juliette", None, false);
          ([], "Alice", None, true);
          ([], "Germaine", Some (txt "Bob's mother"), false)]))]
```

### Basic HTML5 elements without Eliom services

For example if you want to use them with client side event handler.

```ocaml
open Eliom_content.Html.D

Raw.select [option (txt "hello");
            option ~a:[a_value "a"; a_selected `Selected] (txt "cool")]
```

### Links

- *How to write forms*
- [Eliom forms and links](https://ocsigen.org/eliom/latest/server-links.html)
- API `Eliom_content.Html.D.Form`
- signature `Html_sigs.T` (Element attributes)