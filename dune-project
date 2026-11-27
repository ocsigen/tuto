(lang dune 3.18)

(name ocsigen)
(version 9.0.0)
(maintainers dev@ocsigen.org)
(authors dev@ocsigen.org)
(license MIT)
(homepage https://ocsigen.org/)
(documentation https://ocsigen.org/tuto/latest/)
(source (github ocsigen/tuto))

(generate_opam_files true)

(package
 (name ocsigen)
 (synopsis "Ocsigen tutorial, and the Ocsigen stack it uses")
 (description "Ocsigen is a framework for client/server Web and mobile applications in OCaml.
This package carries the Ocsigen tutorial as its documentation, and installs the main libraries the tutorial uses: Eliom, Ocsigen Server, Ocsigen Start, Ocsigen Toolkit, and Ocsipersist with its SQLite backend.
Ocsigen Start needs PostgreSQL.
")
 (maintenance_intent "(latest)")
 ; The tutorial version follows Ocsigen Start: tutorial 9.0 is for Ocsigen
 ; Start 9 and Eliom 13.
 (depends
  (eliom (and (>= 13.0.0) (< 14.0)))
  (ocsigenserver (and (>= 8.0.0) (< 9.0)))
  (ocsigen-start (and (>= 9.0.0) (< 10.0)))
  (ocsigen-toolkit (and (>= 5.0.0) (< 6.0)))
  (ocsipersist-sqlite-config (and (>= 3.1) (< 4.0)))))
