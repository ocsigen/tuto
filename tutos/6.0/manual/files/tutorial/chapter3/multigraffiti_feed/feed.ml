open Eliom_content
open Html5.D
open Server
open Eliom_lib
open Eliom_lib.Lwt_ops

let static_dir =
  match Eliom_config.get_config () with
    | [Simplexmlparser.Element ("staticdir", [], [Simplexmlparser.PCData dir])] ->
        dir
    | [] ->
      raise (Ocsigen_extensions.Error_in_config_file
               ("staticdir must be configured"))
    | _ ->
      raise (Ocsigen_extensions.Error_in_config_file
               ("Unexpected content inside graffiti config"))

let image_dir name =
  let dir = static_dir ^ "/graffiti_saved/" ^ (Eliom_lib.Url.encode name) in
  (try_lwt Lwt_unix.mkdir dir 0o777 with
    | _ -> debug "could not create the directory %s" dir; Lwt.return ()) >|=
  (fun () -> dir)

let make_filename name number =
  image_dir name >|= ( fun dir -> (dir ^ "/" ^ (string_of_int number) ^ ".png") )

let save image name number =
  lwt file_name = make_filename name number in
  lwt out_chan = Lwt_io.open_file ~mode:Lwt_io.output file_name in
  Lwt_io.write out_chan image

let image_info_table = Ocsipersist.open_table "image_info_table"

let save_image username =
  let now = CalendarLib.Calendar.now () in
  lwt number,_,list =
    try_lwt Ocsipersist.find image_info_table username with
      | Not_found -> Lwt.return (0,now,[])
      | e -> Lwt.fail e
  in
  lwt () = Ocsipersist.add image_info_table
    username (number+1,now,(number,now)::list) in
  let (_,image_string) = Hashtbl.find graffiti_info username in
  save (image_string ()) username number

let save_image_box name =
  let save_image_service =
    Eliom_registration.Action.register_post_coservice'
      ~post_params:Eliom_parameter.unit
      (fun () () -> save_image name)
  in
  post_form save_image_service
    (fun _ ->
      [p [string_input
             ~input_type:`Submit ~value:"save" ()]]) ()

let feed_service = Eliom_service.Http.service ~path:["feed"]
  ~get_params:(Eliom_parameter.string "name") ()

let local_filename name number =
  ["graffiti_saved"; Url.encode name ; (string_of_int number) ^ ".png"]

let rec entries name list = function
  | 0 -> []
  | len ->
    match list with
      | [] -> []
      | (n,saved)::q ->
	let title = Atom_feed.plain ("graffiti " ^ name ^ " " ^ (string_of_int n)) in
	let uri =
	  Xhtml.M.uri_of_string
            (Eliom_uri.make_string_uri
               ~service:(Eliom_service.static_dir ())
               (local_filename name n))
	in
	let entry =
	  Atom_feed.entry ~title ~id:uri ~updated:saved
            [Atom_feed.xhtmlC [ Xhtml.M.img ~src:uri ~alt:"image" ()]] in
	entry::(entries name q (len - 1))

let feed name () =
  let id = Xhtml.M.uri_of_string
              (Eliom_uri.make_string_uri
                 ~service:feed_service name) in
  let title = Atom_feed.plain ("nice drawings of " ^ name) in
  try_lwt
    Ocsipersist.find image_info_table name >|=
      (fun (number,updated,list) -> Atom_feed.feed ~id ~updated ~title (entries name list 10))
  with
    | Not_found ->
      let now = CalendarLib.Calendar.now () in
      Lwt.return (Atom_feed.feed ~id ~updated:now ~title [])
    | e -> Lwt.fail e

let feed name () =
  let id = Xhtml.M.uri_of_string
              (Eliom_uri.make_string_uri ~service:feed_service name) in
  let title = Atom_feed.plain ("nice drawings of " ^ name) in
  Lwt.catch
    (fun () -> Ocsipersist.find image_info_table name >|=
	(fun (number,updated,list) -> Atom_feed.feed ~id ~updated ~title (entries name list 10)))
    ( function Not_found ->
      let now = CalendarLib.Calendar.now () in
      Lwt.return (Atom_feed.feed ~id ~updated:now ~title [])
      | e -> Lwt.fail e )

let () = Eliom_atom.Reg.register
  ~service:feed_service feed
