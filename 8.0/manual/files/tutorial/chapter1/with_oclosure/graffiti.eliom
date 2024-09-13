{shared{
  open Eliom_content
  open Eliom_content.Html5.D
  open Eliom_lib.Lwt_ops
  let width = 700
  let height = 400
}}

module My_appl =
  Eliom_registration.App (
    struct
      let application_name = "graffiti"
    end)

{client{
  let draw ctx (color, size, (x1, y1), (x2, y2)) =
    ctx##strokeStyle <- (Js.string color);
    ctx##lineWidth <- float size;
    ctx##beginPath();
    ctx##moveTo(float x1, float y1);
    ctx##lineTo(float x2, float y2);
    ctx##stroke()
}}

{shared{
  type messages = (string * int * (int * int) * (int * int)) deriving (Json)
}}

let bus = Eliom_bus.create ~name:"graff" Json.t<messages>

let rgb_from_string color = (* color is in format "#rrggbb" *)
  let get_color i = (float_of_string ("0x"^(String.sub color (1+2*i) 2))) /. 255. in
  try get_color 0, get_color 1, get_color 2 with | _ -> 0.,0.,0.

let draw_server, image_string =
  let surface = Cairo.image_surface_create Cairo.FORMAT_ARGB32 ~width ~height in
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

let _ = Lwt_stream.iter draw_server (Eliom_bus.stream bus)

let imageservice =
  Eliom_registration.String.register_service
    ~path:["image"]
    ~get_params:Eliom_parameter.unit
    (fun () () -> Lwt.return (image_string (), "image/png"))

let canvas_elt =
  canvas ~a:[a_width width; a_height height]
    [pcdata "your browser doesn't support canvas"]

let page =
  html
    (head
       (title (pcdata "Graffiti"))
       [ css_link
           ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"common.css"]) ();
         css_link
           ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"hsvpalette.css"]) ();
         css_link
           ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"slider.css"]) ();
         css_link
           ~uri:(make_uri (Eliom_service.static_dir ())
                  ["css";"graffiti.css"]) ();
         js_script
           ~uri:(make_uri  (Eliom_service.static_dir ())
                  ["graffiti_oclosure.js"]) ();
       ])
    (body [h1 [pcdata "Graffiti"]; canvas_elt])

let init_client () = ignore {unit{

  (* Initialize the canvas *)
  let canvas = Html5.To_dom.of_canvas %canvas_elt in
  let ctx = canvas##getContext (Dom_html._2d_) in
  ctx##lineCap <- Js.string "round";

  (* The initial image: *)
  let img =
    Html5.To_dom.of_img
      (img ~alt:"canvas"
         ~src:(make_uri ~service:%imageservice ())
         ())
  in
  img##onload <- Dom_html.handler
    (fun _ -> ctx##drawImage(img, 0., 0.); Js._false);

  (* Size of the brush *)
  let slider = jsnew Goog.Ui.slider(Js.null) in
  slider##setOrientation(Goog.Ui.SliderBase.Orientation._VERTICAL);
  slider##setMinimum(1.);
  slider##setMaximum(80.);
  slider##setValue(10.);
  slider##setMoveToPointEnabled(Js._true);
  slider##render(Js.some Dom_html.document##body);

  (* The color palette: *)
  let pSmall =
    jsnew Goog.Ui.hsvPalette(Js.null, Js.null,
                             Js.some (Js.string "goog-hsv-palette-sm"))
  in
  pSmall##render(Js.some Dom_html.document##body);

  let x = ref 0 and y = ref 0 in

  let set_coord ev =
    let x0, y0 = Dom_html.elementClientPosition canvas in
    x := ev##clientX - x0; y := ev##clientY - y0 in

  let compute_line ev =
    let oldx = !x and oldy = !y in
    set_coord ev;
    let color = Js.to_string (pSmall##getColor()) in
    let size = int_of_float (Js.to_float (slider##getValue())) in
    (color, size, (oldx, oldy), (!x, !y))
  in

  let line ev =
    let v = compute_line ev in
    let _ = Eliom_bus.write %bus v in
    draw ctx v;
    Lwt.return ()
  in

  let _ = Lwt_stream.iter (draw ctx) (Eliom_bus.stream %bus) in

  let open Lwt_js_events in
  ignore (mousedowns canvas
            (fun ev _ -> set_coord ev; line ev >>= fun () ->
              Lwt.pick [mousemoves Dom_html.document (fun x _ -> line x);
		        mouseup Dom_html.document >>= line]));
}}

let main_service =
  My_appl.register_service ~path:[""] ~get_params:Eliom_parameter.unit
    (fun () () ->
      init_client ();
      Lwt.return page)

