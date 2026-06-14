# How the Ocsigen tutorial is generated

The Ocsigen tutorial published at <https://ocsigen.org/tuto/> is built with
**odoc** and themed with the Ocsigen site chrome by
[**wodoc**](https://github.com/ocsigen/wodoc) (an odoc driver).

Unlike the API projects, the tutorial is **manual-only** — there is no library or
`.mli` to document. wodoc therefore drives odoc **directly on the `.mld` pages**
(its *direct-mld* mode): no `dune build @doc`, no installed package.

## Sources

| What | Where | Format |
|---|---|---|
| Tutorial pages | `tutos/<version>/manual/*.mld` | odoc pages |
| Page order (nav) | `tutos/<version>/manual/nav` | wodoc nav file |
| Site configuration | [`doc/wodoc`](wodoc) | wodoc config (S-expression) |

The two published versions — **`8.0`** and **`dev`** — are **distinct manuals**
kept side by side in `master` under `tutos/8.0/manual/` and `tutos/dev/manual/`
(the tutorial for the stable release and the one describing upcoming features).
The CI builds **both**, so there is no "freeze dev" release step.

Cross-references to other Ocsigen projects are written as **full
`https://ocsigen.org/<project>/…` URLs** (not site-absolute `/<project>/…`), so
they also resolve when these `.mld` are rendered on ocaml.org.

## Build

```
opam pin add -n wodoc https://github.com/ocsigen/wodoc.git
opam install wodoc odoc
for v in 8.0 dev; do
  wodoc build --config doc/wodoc --label "$v" --out _doc-site/$v \
    --mld-dir "tutos/$v/manual" --nav "tutos/$v/manual/nav" \
    --menu https://ocsigen.org/doc/menu.html
done
```

Add `--local` to fetch the shared `/css//img/` assets and preview offline.

## Deployment (CI)

[`.github/workflows/doc.yml`](../.github/workflows/doc.yml) builds **both
versions** and publishes the whole site to the project's **`gh-pages`** branch
(served at `ocsigen.org/tuto/`), triggered on every push to `master`:

- builds `8.0/` and `dev/`, each with a `index.html` redirect to its first page;
- symlinks `latest` → `8.0` and writes the root `index.html` redirect to `latest`;
- writes `versions.json` (`{"latest":"8.0","list":["dev","8.0"]}`) for the in-page
  version selector, and `.nojekyll`.

The deploy uses `clean: true`, so each run **replaces the entire `gh-pages`
tree** — the published site is exactly what the latest `master` builds. To add or
retire a tutorial version, add/remove its `tutos/<v>/manual/` directory and update
the `for v in …` list (and `versions.json`) in the workflow.
