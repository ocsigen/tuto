# How the Ocsigen tutorial is generated

The tutorial is published in two places, from the same `.mld` sources:

- on <https://ocsigen.org/tuto/>, built with **odoc** and themed with the
  Ocsigen site chrome by [**wodoc**](https://github.com/ocsigen/wodoc), for all
  the versions;
- on ocaml.org, as the documentation of the opam package **`ocsigen`**, built by
  ocaml.org with odoc_driver, for the latest version only.

## Sources

| What | Where | Format |
|---|---|---|
| Tutorial pages | `tutos/<version>/manual/*.mld` | odoc pages |
| Images and files the pages show | `tutos/<version>/manual/files/` | |
| Landing page, page order on ocaml.org (9.0 and later) | `tutos/<version>/manual/index.mld` (`@children_order`) | odoc page |
| Page order on ocsigen.org | `tutos/<version>/manual/nav` | wodoc nav file |
| Site configuration | [`doc/wodoc`](wodoc) | wodoc config (S-expression) |
| opam package | [`dune-project`](../dune-project), `tutos/<latest>/manual/dune`, `tutos/<latest>/manual/odoc-config.sexp` | dune, odoc config |

The published versions, **`9.0`**, **`8.0`** and **`dev`**, are **distinct
manuals** kept side by side in `master` under `tutos/<version>/manual/` (the
tutorials for the stable releases and the one describing upcoming features).

`nav` and `index.mld` list the same pages in the same sections: change both.

## Writing pages

- Cross-references to other packages use odoc paths, such as
  `{!/eliom/server/services/page-types}` or `{!Eliom.Service.create}`. ocaml.org
  resolves them with the packages and libraries listed in `odoc-config.sexp`;
  wodoc turns them into links to the docs of these projects on ocsigen.org.
- odoc does not reach the values of a client library whose root module has the
  same name as the server one, such as `{!Eliom.Client.onload}`
  ([ocaml/odoc#1450](https://github.com/ocaml/odoc/issues/1450)). These
  references are shown as code, without a link.
- Show an image with `{{image!files/screenshots/start1.png}Ocsigen Start}`. The
  file goes under `files/`, and must be installed by the `install` stanza of
  `tutos/<latest>/manual/dune` to appear on ocaml.org. Link to a file of `files/`
  with `{{:files/...}text}`, and install it too.
- `{%wodoc:...%}` blocks (asides, code block sides, galleries) only style the
  pages on ocsigen.org; odoc ignores them on ocaml.org.

## Build for ocsigen.org

Unlike the API projects, the tutorial has no library or `.mli` to document.
wodoc therefore drives odoc **directly on the `.mld` pages** (its *direct-mld*
mode), from the sources rather than from the installed package:

```
opam pin add -n wodoc https://github.com/ocsigen/wodoc.git
opam install wodoc odoc
for v in 9.0 8.0 dev; do
  wodoc build --config doc/wodoc --label "$v" --out _doc-site/$v \
    --mld-dir "tutos/$v/manual" --nav "tutos/$v/manual/nav" \
    --menu https://ocsigen.org/doc/menu.html
done
```

Add `--local` to fetch the shared `/css//img/` assets and preview offline. A
local build skips the link requalification that the CI runs (see below).

## Build like ocaml.org

Install the package, then run odoc_driver, the engine of ocaml.org's docs:

```
# until ocsigen-start 9.0.0 is on opam, as package.yml does:
opam pin add ocsigen-start https://github.com/ocsigen/ocsigen-start.git#9.0.0 --no-action

opam pin add ocsigen . --no-action
opam install ocsigen odoc-driver
odoc_driver ocsigen --remap
```

The pages are in `_html/ocsigen/`. The links to the other packages point to
ocaml.org.

## CI

[`.github/workflows/package.yml`](../.github/workflows/package.yml) runs this
build on every pull request and push to `master`. It lists the odoc warnings of
the pages in the job summary, and keeps the HTML as an artifact
(`ocaml-org-preview`), to see how a change will look on ocaml.org.

[`.github/workflows/doc.yml`](../.github/workflows/doc.yml) builds **all
the versions** for ocsigen.org and publishes the whole site to the project's
**`gh-pages`** branch (served at `ocsigen.org/tuto/`), on every push to
`master`:

- builds `9.0/`, `8.0/` and `dev/`, each with a `index.html` redirect to its
  first page (it replaces the page built from `index.mld`, which is the landing
  page on ocaml.org only);
- builds `9.0/` with `--latest`, so that wodoc symlinks `latest` → `9.0` and
  writes the project-root files: the `index.html` redirect to `latest`, the
  `404.html` that sends a missing page to the index of its version, and
  `versions.json` for the in-page version selector (the `dev` build refreshes it);
- writes `.nojekyll`;
- runs `wodoc requalify-xrefs`, so that a link written with the flat module name
  of an older release (`Eliom_registration`) reaches the page the project now
  deploys under its wrapper (`Eliom/Registration`). It checks each rewrite
  against the file lists of the other projects' `gh-pages`.

The deploy uses `clean: true`, so each run **replaces the entire `gh-pages`
tree**: the published site is exactly what the latest `master` builds.

## Releasing a new version of the tutorial

For a new Ocsigen Start version `X`:

1. Copy `tutos/dev` to `tutos/X.0`.
2. Move the `dune` and `odoc-config.sexp` files of the previous latest version
   to `tutos/X.0/manual/`, and name the new version in `tutos/dune`.
3. In `dune-project`, set the version to `X.0.0` and update the version
   constraints of the dependencies; `dune build` regenerates `ocsigen.opam`.
4. In `doc.yml`, add the version to the `for v in …` list, and give it
   `--latest` (the `if [ "$v" = … ]` test).
5. Update the version numbers that the files name: `grep` for the previous
   version in `README.md`, `doc/README.md`, `dune-project`, `doc/wodoc` and
   `doc.yml`. Check the `libraries` of `odoc-config.sexp` against the new APIs.
6. Tag `X.0.0`, and submit the package to opam-repository (for instance with
   `opam publish`). ocaml.org then builds its documentation.

To retire a version from ocsigen.org, remove its `tutos/<v>/manual/` directory
and its entry in `doc.yml`.
