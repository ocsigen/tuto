{shared{
  open Eliom_content.Html5.D
  open Common
}}
{client{
  open Client
}}
open Server
open Feed

let start_drawing name image canvas =
  let bus = get_bus name in
  Eliom_service.onload
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
    let image =
      img ~alt:name
        ~src:(make_uri
		~service:imageservice (name,!counter)) () in
    let canvas =
      canvas ~a:[ a_width width; a_height height ]
        [pcdata "your browser doesn't support canvas"; br (); image] in
    start_drawing name image canvas;
    make_page
      [h1 [pcdata name];
       disconnect_box ();
       choose_drawing_form ();
       a feed_service [pcdata "atom feed"] name;
       div ( if name = username
	 then [save_image_box name]
	 else [pcdata "no saving"] );
       canvas;])

