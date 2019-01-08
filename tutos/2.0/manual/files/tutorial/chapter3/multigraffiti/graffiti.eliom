{shared{
  open Eliom_pervasives
  open HTML5.M
  open Common
}}
{client{
  open Client
}}
open Server
open Feed

let start_drawing name image canvas =
  let bus = get_bus name in
  Eliom_services.onload
    {{
      let canceller = launch_client_canvas %bus %image %canvas in
      Eliom_client.on_unload (fun () -> stop_drawing canceller)
    }}

let counter = ref 0

let () = Connected.register ~service:multigraffiti_service
  !% ( fun name () username ->
    (* Some browsers won't reload the image, so we force
       them by changing the url each time. *)
    incr counter;
    let image = unique (img ~alt:name ~src:(Eliom_output.Html5.make_string_uri
					      ~service:imageservice (name,!counter)) ()) in
    let canvas = unique (canvas ~a:[ a_width width; a_height height ]
			   [pcdata "your browser doesn't support canvas"; br (); image]) in
    start_drawing name image canvas;
    make_page
      [h1 [pcdata name];
       disconnect_box ();
       choose_drawing_form ();
       Eliom_output.Html5.a feed_service [pcdata "atom feed"] name;
       div ( if name = username
	 then [save_image_box name]
	 else [pcdata "no saving"] );
       canvas;])

