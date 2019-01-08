open Eliom_pervasives
open HTML5.M
open Common
open Lwt

module My_appl =
  Eliom_output.Eliom_appl (struct
    let application_name = "graffiti"
  end)

let rgb_from_string color = (* color is in format "#rrggbb" *)
  let get_color i =
    (float_of_string ("0x"^(String.sub color (1+2*i) 2))) /. 255.
  in
  try get_color 0, get_color 1, get_color 2 with | _ -> 0.,0.,0.

let launch_server_canvas () =
  let bus = Eliom_bus.create Json.t<messages> in

  let draw_server, image_string =
    let surface = Cairo.image_surface_create
      Cairo.FORMAT_ARGB32 ~width ~height in
    let ctx = Cairo.create surface in
    ((fun ((color : string), size, (x1, y1), (x2, y2)) ->

      (* Set thickness of brush *)
      Cairo.set_line_width ctx (float size) ;
      Cairo.set_line_join ctx Cairo.LINE_JOIN_ROUND ;
      Cairo.set_line_cap ctx Cairo.LINE_CAP_ROUND ;
      let red, green, blue =  rgb_from_string color in
      Cairo.set_source_rgb ctx ~red ~green ~blue ;

      Cairo.move_to ctx (float x1) (float y1) ;
      Cairo.line_to ctx (float x2) (float y2) ;
      Cairo.close_path ctx ;

      (* Apply the ink *)
      Cairo.stroke ctx ;
     ),
     (fun () ->
       let b = Buffer.create 10000 in
       (* Output a PNG in a string *)
       Cairo_png.surface_write_to_stream surface (Buffer.add_string b);
       Buffer.contents b
     ))
  in
  let _ = Lwt_stream.iter draw_server (Eliom_bus.stream bus) in
  bus,image_string

let graffiti_info = Hashtbl.create 0

let imageservice =
  Eliom_output.Text.register_service
    ~path:["image"]
    ~headers:Http_headers.dyn_headers
    ~get_params:(let open Eliom_parameters in string "name" ** int "q")
    (* we add another parameter for the browser not to cache: at least
       for chrome, there is no way to force the browser to reload the
       image without leaving the application *)
    (fun (name,_) () ->
      try_lwt
        let _ ,image_string = Hashtbl.find graffiti_info name in
	Lwt.return (image_string (), "image/png")
      with
	| Not_found -> raise_lwt Eliom_common.Eliom_404)

let get_bus (name:string) =
  (* create a new bus and image_string function only if it did not exists *)
  try
    fst (Hashtbl.find graffiti_info name)
  with
    | Not_found ->
      let bus,image_string = launch_server_canvas () in
      Hashtbl.add graffiti_info name (bus,image_string);
      bus

let main_service = Eliom_services.service ~path:[""]
  ~get_params:(Eliom_parameters.unit) ()
let multigraffiti_service = Eliom_services.service ~path:[""]
  ~get_params:(Eliom_parameters.suffix (Eliom_parameters.string "name")) ()

let choose_drawing_form () =
  Eliom_output.Html5.get_form ~service:multigraffiti_service
    (fun (name) ->
      [fieldset
	  [label ~a:[Eliom_output.Html5.a_for name] [pcdata "drawing name: "];
           Eliom_output.Html5.string_input ~input_type:`Text ~name ();
           br ();
           Eliom_output.Html5.string_input ~input_type:`Submit ~value:"Go" ()
          ]])

let connection_service =
  Eliom_services.post_coservice'
    ~post_params:(let open Eliom_parameters in (string "name" ** string "password"))
    ()
let disconnection_service = Eliom_services.post_coservice' ~post_params:Eliom_parameters.unit ()
let create_account_service =
  Eliom_services.post_coservice ~fallback:main_service ~post_params:(let open Eliom_parameters in (string "name" ** string "password")) ()

let username = Eliom_references.eref ~scope:Eliom_common.session None

let user_table = Ocsipersist.open_table "user_table"
let check_pwd name pwd =
  try_lwt
    lwt saved_password = Ocsipersist.find user_table name in
    Lwt.return ( pwd = saved_password )
  with
    Not_found -> Lwt.return false

let () = Eliom_output.Action.register
  ~service:create_account_service
  (fun () (name, pwd) -> Ocsipersist.add user_table name pwd)

let () = Eliom_output.Action.register
  ~service:connection_service
  (fun () (name, password) ->
    match_lwt check_pwd name password with
      | true -> Eliom_references.set username (Some name)
      | false -> Lwt.return ())

let () =
  Eliom_output.Action.register
    ~service:disconnection_service
    (fun () () -> Eliom_state.discard ~scope:Eliom_common.session ())

let disconnect_box () =
  Eliom_output.Html5.post_form disconnection_service
    (fun _ -> [fieldset
		  [Eliom_output.Html5.string_input
                      ~input_type:`Submit ~value:"Log out" ()]]) ()

let login_name_form service button_text =
  Eliom_output.Html5.post_form ~service
    (fun (name1, name2) ->
      [fieldset
	  [label ~a:[Eliom_output.Html5.a_for name1] [pcdata "login: "];
           Eliom_output.Html5.string_input ~input_type:`Text ~name:name1 ();
           br ();
           label ~a:[Eliom_output.Html5.a_for name2] [pcdata "password: "];
           Eliom_output.Html5.string_input ~input_type:`Password ~name:name2 ();
           br ();
           Eliom_output.Html5.string_input ~input_type:`Submit ~value:button_text ()
          ]]) ()

let oclosure_script =
    HTML5.M.unique
      (Eliom_output.Html5_forms.js_script
         ~uri:(HTML5.M.uri_of_string "./graffiti_oclosure.js") ())

let make_page body =
  Lwt.return
    (HTML5.M.html
       (HTML5.M.head
	  (HTML5.M.title (HTML5.M.pcdata "Graffiti"))
 	  [
	    Eliom_output.Html5_forms.css_link
	      ~uri:(HTML5.M.uri_of_string"./css/closure/common.css") ();
	    Eliom_output.Html5_forms.css_link
	      ~uri:(HTML5.M.uri_of_string"./css/closure/hsvpalette.css") ();
	    Eliom_output.Html5_forms.css_link
	      ~uri:(HTML5.M.uri_of_string"./css/slider.css") ();
            oclosure_script;
	    Eliom_output.Html5_forms.css_link
	      ~uri:(HTML5.M.uri_of_string"./css/graffiti.css") ();
          ])
       (HTML5.M.body body))


let default_content () =
  make_page
    [h1 [pcdata "Welcome to Multigraffiti"];
     h2 [pcdata "log in"];
     login_name_form connection_service "Connect";
     h2 [pcdata "create account"];
     login_name_form create_account_service "Create account";]

module Connected_translate =
struct
  type page = string -> My_appl.page Lwt.t
  let translate page =
    Eliom_references.get username >>=
      function
	| None -> default_content ()
	| Some username -> page username
end

module Connected =
  Eliom_output.Customize ( My_appl ) ( My_appl ) ( Connected_translate )

let ( !% ) f = fun a b -> return (fun c -> f a b c)

let () = Connected.register ~service:main_service
  !% (fun () () username ->
    make_page
      [h1 [pcdata ("Welcome to Multigraffiti " ^ username)];
       choose_drawing_form ()])

