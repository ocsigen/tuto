{shared{
  open Eliom_content.Html5.D
  open Common
}}
{client{
  open Client
}}
open Server

let start_drawing name image canvas =
  let bus = get_bus name in
  Eliom_service.onload
    {{
      let canceller = launch_client_canvas %bus %image %canvas in
      Eliom_client.on_unload (fun () -> stop_drawing canceller)
    }}

let counter = ref 0

let player =
  Eliom_content.Html5.Id.create_global_elt
    (audio
       ~srcs:(make_uri (Eliom_service.static_dir ())
                  ["music.ogg"],[])
       ~a:[a_autoplay (`Autoplay);a_controls (`Controls)]
       [pcdata "Your browser does not support audio element" ])
    
let () = Connected.register ~service:multigraffiti_service
  !% ( fun name () username ->
    (* Some browsers won't reload the image, so we force
       them by changing the url each time. *)
    incr counter;
    let image = img ~alt:name ~src:(make_uri
					      ~service:imageservice (name,!counter)) () in
    let canvas = canvas ~a:[ a_width width; a_height height ]
			   [pcdata "your browser doesn't support canvas"; br (); image] in
    start_drawing name image canvas;
    make_page
      [h1 [pcdata name];
       disconnect_box ();
       choose_drawing_form ();
       canvas;
       player])

