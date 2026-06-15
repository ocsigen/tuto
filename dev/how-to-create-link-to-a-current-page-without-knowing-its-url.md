
# How to create a link to the current page (without knowing its URL)?

Void coservices are here for that:

```ocaml
a ~service:Eliom.Service.reload_action
  [txt "Click to reload"] ();
```
More information in [Eliom's manual](https://ocsigen.org/eliom/latest/server-services.html#void), and API documentation of `Eliom.Service.reload_action`.
