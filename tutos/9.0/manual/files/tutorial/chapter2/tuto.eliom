(* Final code of the tutorial "Service based Web programming", for Eliom 13.
   Put it in app/tuto.eliom of a project created with
   eliom-distillery -name tuto -template app *)

open Lwt.Syntax

(* Services *)
let main_service = Eliom.Service.create
  ~path:(Eliom.Service.Path [""])
  ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
  ()

let user_service  = Eliom.Service.create
  ~path:(Eliom.Service.Path ["users"])
  ~meth:(Eliom.Service.Get Eliom.Parameter.(suffix (string "name")))
  ()

let connection_service = Eliom.Service.create
  ~path:(Eliom.Service.No_path)
  ~meth:(Eliom.Service.Post (
    Eliom.Parameter.unit,
    Eliom.Parameter.(string "name" ** string "password")))
  ()

let disconnection_service = Eliom.Service.create
  ~path:(Eliom.Service.No_path)
  ~meth:(Eliom.Service.Post (Eliom.Parameter.unit, Eliom.Parameter.unit))
  ()

let new_user_form_service = Eliom.Service.create
  ~path:(Eliom.Service.Path ["registration"])
  ~meth:(Eliom.Service.Get Eliom.Parameter.unit)
  ()

let account_confirmation_service =
  Eliom.Service.create_attached_post
    ~fallback:new_user_form_service
    ~post_params:(Eliom.Parameter.(string "name" **  string "password"))
    ()

(* User names and passwords: *)
let users = ref [("Calvin", "123"); ("Hobbes", "456")]

let user_links = Eliom.Content.Html.D.(
  let link_of_user = fun (name, _) ->
    li [a ~service:user_service [txt name] name]
  in
  fun () -> ul (List.map link_of_user !users)
)

let check_pwd name pwd =
  try List.assoc name !users = pwd with Not_found -> false

let username =
  Eliom.Reference.eref ~scope:Eliom.Common.default_session_scope None

let wrong_pwd =
  Eliom.Reference.eref ~scope:Eliom.Common.request_scope false

let disconnect_box () = Eliom.Content.Html.D.(
  Form.post_form ~service:disconnection_service
    (fun _ ->
      [fieldset [Form.input ~input_type:`Submit ~value:"Log out" Form.string]]
    )
    ()
)

let account_form () = Eliom.Content.Html.D.(
  Form.post_form ~service:account_confirmation_service
    (fun (name1, name2) ->
      [fieldset
         [label [txt "login: "];
          Form.input ~input_type:`Text ~name:name1 Form.string;
          br ();
          label [txt "password: "];
          Form.input ~input_type:`Password ~name:name2 Form.string;
          br ();
          Form.input ~input_type:`Submit ~value:"Connect" Form.string
         ]]) ()
)

let connection_box () = Eliom.Content.Html.D.(
  let* u = Eliom.Reference.get username in
  let* wp = Eliom.Reference.get wrong_pwd in
  Lwt.return
    (match u with
      | Some s -> div [p [txt "You are connected as "; txt s; ];
                       disconnect_box () ]
      | None ->
        let l =
          [Form.post_form ~service:connection_service
            (fun (name1, name2) ->
              [fieldset
                 [label [txt "login: "];
                  Form.input ~input_type:`Text ~name:name1 Form.string;
                  br ();
                  label [txt "password: "];
                  Form.input ~input_type:`Password ~name:name2 Form.string;
                  br ();
                  Form.input ~input_type:`Submit ~value:"Connect" Form.string
                 ]]) ();
             p [a ~service:new_user_form_service
                  [txt "Create an account"] ()]]
        in
        if wp
        then div ((p [em [txt "Wrong user or password"]])::l)
        else div l
    )
)

(* Services Registration *)
let () = Eliom.Content.Html.D.(

  Eliom.Registration.Html.register
    ~service:main_service
    (fun () () ->
      let* cf = connection_box () in
      Lwt.return
        (html (head (title (txt "")) [])
              (body [h1 [txt "Hello"];
                     cf;
                     user_links ()])));

  Eliom.Registration.Html.register
    ~service:user_service
    (fun name () ->
      if List.mem_assoc name !users then begin
        let* cf = connection_box () in
        Lwt.return
          (html (head (title (txt name)) [])
             (body [h1 [txt name];
                    cf;
                    p [a ~service:main_service [txt "Home"] ()]]))
      end
      else begin
        Eliom.Registration.set_status `Not_found;
        Lwt.return
          (html (head (title (txt "404")) [])
             (body [h1 [txt "404"];
                    p [txt "That page does not exist"]]))
      end);

  Eliom.Registration.Action.register
    ~service:connection_service
    (fun () (name, password) ->
      if check_pwd name password
      then Eliom.Reference.set username (Some name)
      else Eliom.Reference.set wrong_pwd true);

  Eliom.Registration.Action.register
    ~service:disconnection_service
    (fun () () -> Eliom.State.discard ~scope:Eliom.Common.default_session_scope ());

  Eliom.Registration.Html.register
    ~service:new_user_form_service
    (fun () () ->
      Lwt.return
        (html (head (title (txt "")) [])
              (body [h1 [txt "Create an account"];
                     account_form ();
                    ])));

  Eliom.Registration.Html.register
    ~service:account_confirmation_service
    (fun () (name, pwd) ->
      let create_account_service =
        Eliom.Service.create_attached_get
          ~fallback:main_service
          ~get_params:Eliom.Parameter.unit
          ~timeout:60.
          ~max_use:1
          ()
      in
      let _ = Eliom.Registration.Action.register
        ~service:create_account_service
        (fun () () ->
          users := (name, pwd)::!users;
          Lwt.return ())
      in
      Lwt.return
        (html
           (head (title (txt "")) [])
           (body
              [h1 [txt "Confirm account creation for "; txt name];
               p [a ~service:create_account_service [txt "Yes"] ();
                  txt " ";
                  a ~service:main_service [txt "No"] ()]
              ])))
)
