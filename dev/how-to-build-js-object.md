
# How to build js object?

Use syntax `new%js`:

Example:

```ocaml
let get_timestamp () =
  let date = new%js Js.date_now in
  int_of_float (Js.to_float (date##getTime))
```
More details in documentation: `Js object constructor`
