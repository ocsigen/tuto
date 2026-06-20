
# How to add a CSS stylesheet?

*Warning: css\_link and make\_uri come from Eliom\_content.Html.D module. This module is opened for each piece of code*

CSS stylesheet are included in the header using the **css\_link** function.

```ocaml
css_link
     ~uri:(make_uri (Eliom_service.static_dir ())
              ["css";"style.css"])
     ()
```
This function has 2 parameters: the file path and unit.

The file path is generated using the **make\_uri** function. This function creates the relative URL string using the static directory configured in the configuration file and the given list.


### Where?

Insert this piece of code on the list given in parameter to the **head** function:

```ocaml
  (html
     (head (title (txt "Page Title"))
        [css_link ~uri:(make_uri (Eliom_service.static_dir ())
	        	  ["css";"style.css"]) ()])
     (body [p [txt "Hello World!"]]))))
```
Or you can use: `Eliom_tools.F.head`


### Download full code

*Warning: This third party code may be outdated. Please notify the author is something is broken, or do a pull request on github.*

- [Read the full code](https://github.com/db0company/Ocsigen-Quick-Howto/blob/master/css/example.eliom)
- [Download and try this example](https://github.com/db0company/Ocsigen-Quick-Howto)

### Links

- `About images, css and javascript`
- `Eliom_content.Html.D.make_uri`
- `Configuring Ocsigen Server for serving static files`