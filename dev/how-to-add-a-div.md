
# How to add a div?

```ocaml
div ~a:[a_class ["firstclass"; "secondclass"]] [txt "Hello!"]
```
**Required parameter**: list containing other elements (Details of available elements in type `Html_types.flow5`).

**Optional parameter** for attributes "a" ([How to set and id, classes or other attributes to HTML elements?](./how-to-set-and-id-classes-or-other-attributes-to-html-elements.md)).


### Download full code

*Warning: This third party code may be outdated. Please notify the author is something is broken, or do a pull request on github.*

- [Read the full code](https://github.com/db0company/Ocsigen-Quick-Howto/blob/master/elements/example.eliom)
- [Download and try this example](https://github.com/db0company/Ocsigen-Quick-Howto)

### Links

- Modules `Eliom.Content.Html.D` and `Eliom.Content.Html.F` (HTML5 Elements)
- signature `Html_sigs.T` (Element attributes)