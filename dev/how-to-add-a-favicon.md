
# How to add a Favicon?

A favicon is a file of type "ico" which contain a picture of size 16x16px. It is the picture that you can ususally see next to the title of the page on a browser.

<!--wodoc:img src="http://public.db0.fr/dev/ocsigen/favicon.png" alt="favicon for Ocsigen.org"-->
By default, all browsers look for a file `favicon.ico` at the root of the website:

```ocaml
 http://website.com/favicon.ico
```
Just put the file at the root of the static directory set in the configuration file.


### Links

- [Configuring Ocsigen Server for serving static files](https://ocsigen.org/ocsigenserver/latest/staticmod.html)
- [An example of a favicon generator](http://www.favicon.cc/)