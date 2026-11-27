; Per-package odoc configuration, read by odoc_driver on ocaml.org.
; [libraries]: unqualified module references ({!Eliom.Service}) resolve in
; these libraries. When a server and a client library define the same root
; module (Eliom), they resolve in the server one. A library path reaches a
; client module ({!/eliom.client/Eliom.Client}), but with odoc 3.2 not the
; values inside it.
; [packages]: pages and modules of these packages are reachable with the
; {!/package/...} path syntax.
(libraries
 eliom.server
 eliom.client
 ocsigen-start.server
 ocsigen-start.client
 ocsigen-toolkit.server
 ocsigen-toolkit.client
 ocsigenserver
 ocsipersist
 js_of_ocaml
 js_of_ocaml-lwt
 lwt
 lwt.unix
 tyxml)
(packages eliom ocsigen-start ocsigen-toolkit ocsigenserver lwt tyxml js_of_ocaml)
