
# How to stop default behaviour of events?

Example:

```ocaml

(** Disable Js event with stopping propagation during capture phase **)
let disable_event event html_elt =
  Lwt.async (fun () ->
   Lwt_js_events.seq_loop
     (Lwt_js_events.make_event event) ~use_capture:true html_elt
     (fun ev _ -> Dom.preventDefault ev; Lwt.return ())))


disable_event Dom_html.Event.dragstart Dom_html.document
```
- event is a Dom\_html.Event<br/>
- html\_elt is the target
More details in documentation: `Js_of_ocaml.Dom.preventDefault`
