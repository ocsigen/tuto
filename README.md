# Ocsigen tutorial

[Ocsigen](https://ocsigen.org/) is a framework for client/server Web and mobile
applications in OCaml. This repository holds its tutorial, from a first
application to advanced features.

Read it on [ocsigen.org](https://ocsigen.org/tuto/latest/), or on
[ocaml.org](https://ocaml.org/p/ocsigen/latest/doc/index.html), where it is the
documentation of the opam package `ocsigen`.

## The opam package `ocsigen`

```
opam install ocsigen
```

This command installs the main libraries the tutorial uses: Eliom, Ocsigen
Server, Ocsigen Start, Ocsigen Toolkit, and Ocsipersist with its SQLite backend.
Ocsigen Start needs PostgreSQL. See the
[installation instructions](https://ocsigen.org/install) for details.

The package carries the latest version of the tutorial. Its version follows
Ocsigen Start: tutorial 9.0 is for Ocsigen Start 9 and Eliom 13.

## Contents

- `tutos/<version>/manual/`: the pages of each version of the tutorial
  (odoc `.mld` files), with the images and the code of the tutorial
  applications in `files/`.
- `doc/`: how the tutorial is built and published, see
  [doc/README.md](https://github.com/ocsigen/tuto/blob/master/doc/README.md).

## Contributing

Corrections and new pages are welcome. Please open an issue or a pull request on
[GitHub](https://github.com/ocsigen/tuto). Change the pages of `tutos/dev` and,
for a fix that also applies to the latest release, of that version too.

## License

MIT, see [LICENSE](https://github.com/ocsigen/tuto/blob/master/LICENSE).
