open Eliom_content
open Common
open Eliom_lib.Lwt_ops

let draw ctx (color, size, (x1, y1), (x2, y2)) =
  ctx##strokeStyle <- (Js.string color);
  ctx##lineWidth <- float size;
  ctx##beginPath();
  ctx##moveTo(float x1, float y1);
  ctx##lineTo(float x2, float y2);
  ctx##stroke()

(* type containing all informations we need to stop interaction
   inside the page *)
type drawing_canceller =
    { drawing_thread : unit Lwt.t;
      (* the thread reading messages from the bus *)
      drawing_event_thread : unit Lwt.t;
      (* the thread handling mouse events *)
    }

let stop_drawing { drawing_thread; drawing_event_thread } =
  Lwt.cancel drawing_thread;
  (* cancelling this thread also closes the bus *)
  Lwt.cancel drawing_event_thread

let launch_client_canvas bus image_elt canvas_elt =
  let canvas = Html5.To_dom.of_canvas canvas_elt in
  let ctx = canvas##getContext (Dom_html._2d_) in
  ctx##lineCap <- Js.string "round";

  let img = Html5.To_dom.of_img image_elt in
  let copy_image () = ctx##drawImage(img, 0., 0.) in
  if Js.to_bool (img##complete)
  then copy_image ()
  else img##onload <- Dom_html.handler
    (fun ev -> copy_image (); Js._false);

  (* Size of the brush *)
  let slider = jsnew Goog.Ui.slider(Js.null) in
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
    let _ = Eliom_bus.write bus v in
    draw ctx v;
    Lwt.return ()
  in
  let t = Lwt_stream.iter (draw ctx) (Eliom_bus.stream bus) in
  let drawing_event_thread =
    let open Lwt_js_events in
    mousedowns canvas
      (fun ev _ -> set_coord ev; line ev >>= fun () ->
        Lwt.pick [mousemoves Dom_html.document (fun x _ -> line x);
		  mouseup Dom_html.document >>= line])
  in
  { drawing_thread = t;
    drawing_event_thread = drawing_event_thread }
