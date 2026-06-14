[%%shared
    open Eliom_content
    open Html5

    type action = Play | Pause | Seek of float
]

let%client media_s, set_media_s = React.S.create Pause

let%client progress_s, set_progress_s = React.S.create (0., 0.)

let%client unblock_s, set_unblock_s = React.S.create true

let progress_bar () =
  let progress_value =
    [%client
      (let f (time, duration) =
         if duration = 0. then 0. else time /. duration *. 100.
       in
       React.S.map f progress_s
       : float React.signal)
    ] in
  let attrs = D.([
      a_input_min 0.;
      a_input_max 100.;
      a_onmousedown [%client fun _ -> set_unblock_s false];
      a_onmouseup [%client fun _ -> set_unblock_s true];
      C.attr [%client
        R.a_value
          (React.S.map (Printf.sprintf "%0.f")
             (React.S.on unblock_s 0. ~%progress_value))]
    ])
  in
  let d_input =
    D.Form.input ~input_type:`Range ~value:0. ~a:attrs
      D.Form.float
  in
  let _ = [%client
    (Lwt.async (fun () ->
         let d_input = To_dom.of_input ~%d_input in
         Lwt_js_events.inputs d_input (fun _ _ ->
             set_media_s (Seek (Js.parseFloat d_input##.value)) ;
             Lwt.return ()
           ))
     : unit)
  ] in
  d_input

let media_uri =
  Html5.D.make_uri
    ~service:(Eliom_service.static_dir ())
    ["hb.mp3"]

let media_tag () =
  let media = D.(audio ~src:media_uri [pcdata "alt"]) in
  let _ = [%client
    (Lwt.async (fun () ->
         let media = To_dom.of_audio ~%media in
         let media_map = function
           | Play ->
             media##play
           | Pause ->
             media##pause
           | Seek f ->
             media##.currentTime := (f /. 100. *. media##.duration)
         in Lwt_react.S.keep (React.S.map media_map media_s) ;
         Lwt_js_events.timeupdates media (fun _ _ ->
             set_progress_s (media##.currentTime, media##.duration) ;
             Lwt.return ()
           ))
     : unit)
  ] in
  media

let pause_button () =
  D.(Form.button_no_value
       ~button_type:`Button
       ~a:[a_onclick  [%client  fun _ -> set_media_s Pause ]]
       [pcdata "Pause"])

let play_button () =
  D.(Form.button_no_value
       ~button_type:`Button
       ~a:[a_onclick  [%client  fun _ -> set_media_s Play ]]
       [pcdata "Play"])

module React_Player_app =
  Eliom_registration.App
    (struct
      let application_name = "react_player"
    end)

let media_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () =
  React_Player_app.register
    ~service:media_service
    (fun name () ->
       let body =
         D.(body [
             h2 [pcdata "Media"];
             media_tag ();
             div [play_button (); pause_button (); progress_bar ()]
           ])
       in
       Lwt.return (Eliom_tools.D.html ~title:"Media" ~css:[] body))
