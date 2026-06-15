
# How to add an image?

1. Internal image
```ocaml
  img ~alt:("Ocsigen Logo")
      ~src:(make_uri
              ~service:(Eliom.Service.static_dir ())
              ["ocsigen_logo.png"])
    ()

```
1. External image
```ocaml
  img ~alt:("Ocsigen Logo")
      ~src:(Xml.uri_of_string ("http://website.com/image.png"))
    ()
```
The function **img** has 3 parameters:

- **alt**: A description of the image
- **src**: the URL of the image
- unit
For an internal image, the file path is generated using the **make\_uri** function. This function creates the relative URL string using the static directory configured in the configuration file and the given list.

For an external image, you must convert the string url into uri using the **uri\_of\_string** function. You can also create an [external service](https://ocsigen.org/eliom/latest/server-services.html#unregistrable_services).


### Download full code

*Warning: This third party code may be outdated. Please notify the author is something is broken, or do a pull request on github.*

- [Read the full code](https://github.com/db0company/Ocsigen-Quick-Howto/blob/master/elements/example.eliom)
- [Download and try this example](https://github.com/db0company/Ocsigen-Quick-Howto)

### Links

- Modules `Eliom.Content.Html.D` and `Eliom.Content.Html.F` (HTML5 Elements)
- The `Html_sigs.T.img` element
- [Alt attribute](http://en.wikipedia.org/wiki/Alt_attribute)
- signature `Html_sigs.T` (Element attributes)