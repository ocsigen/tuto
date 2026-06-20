
# How to add lists in a page?


#### Simple list and ordered list


##### Simple list

```ocaml
  ul
    [li [txt "first item"];
     li [txt "second item"];
     li [txt "third item"];
     li [txt "fourth item"]]
```

##### Ordered list

```ocaml
  ol
    [li [txt "first item"];
     li [txt "second item"]]
```
**Required parameter**: list containing **li** elements ([Details of li content](https://ocsigen.org/tyxml/latest/tyxml/Html_types/index.html#type-li_attrib)).

**Optional parameter** for attributes "a" (`How to set and id, classes or other attributes to HTML elements?`).


#### Definition list

```ocaml
  dl
    [((dt [txt "Banana"], []),
      (dd [txt "An elongated curved fruit"], []));
     ((dt [txt "Orange"], []),
      (dd [txt "A globose, reddish-yellow, edible fruit"],
       [dd [txt "A color between yellow and red"]]));
     ((dt [txt "Kiwi"], []),
      (dd [txt "Egg-sized green fruit from China"], []))]
```
This kind of list contains definitions.

**Required parameter**: A list of pair of:

- A pair containing:
- The first element of type dt
- A list of elements of type dt
- Another pair containing:
- The first element of type dd
- A list of elements of type dd
Details:

- [dd content](https://ocsigen.org/tyxml/latest/tyxml/Html_types/index.html#type-phrasing)
- [dt content](https://ocsigen.org/tyxml/latest/tyxml/Html_types/index.html#type-flow5)
**Optional parameter** for attributes "a" (`How to set and id, classes or other attributes to HTML elements?`).


### Download full code

*Warning: This third party code may be outdated. Please notify the author is something is broken, or do a pull request on github.*

- [Read the full code](https://github.com/db0company/Ocsigen-Quick-Howto/blob/master/elements/example.eliom)
- [Download and try this example](https://github.com/db0company/Ocsigen-Quick-Howto)

### Links

- Modules `Eliom_content.Html.D` and `Eliom_content.Html.F` (HTML5 Elements)
- signature `Html_sigs.T` (Element attributes)