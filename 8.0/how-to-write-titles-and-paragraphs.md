
# How to write titles and paragrahs?

1. Titles
```ocaml
h3 [txt "Hello world"]
```
There are 6 types of titles: h1, h2, h3, h4, h5 and h6. h1 is the largest and h6 is the smallest.

1. Pagragraph
```ocaml
p [txt "Some text, blah blah blah"]
```
**Required parameter**: list containing other elements (content: `Html_types.flow5` elements).

**Optional parameter** for attributes "a" ([How to set and id, classes or other attributes to HTML elements?](how-to-set-and-id-classes-or-other-attributes-to-html-elements.html)).


### Download full code

*Warning: This third party code may be outdated. Please notify the author is something is broken, or do a pull request on github.*

- [Read the full code](https://github.com/db0company/Ocsigen-Quick-Howto/blob/master/elements/example.eliom)
- [Download and try this example](https://github.com/db0company/Ocsigen-Quick-Howto)

### Links

- Modules `Eliom_content.Html.D` and `Eliom_content.Html.F` (HTML5 Elements)
- The `Html_sigs.T.h1` element
- signature `Html_sigs.T` (Element attributes)