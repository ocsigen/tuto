
(* =============================Eliom references============================= *)

let username =
  Eliom_reference.eref ~scope:Eliom_common.default_session_scope None

let wrong_pwd =
  Eliom_reference.eref ~scope:Eliom_common.request_scope false


(* =================================Services================================= *)

let main_service = Eliom_service.create
  ~path:(Eliom_service.Path [""])
  ~meth:(Eliom_service.Get Eliom_parameter.unit)
  ()

let user_service  = Eliom_service.create
  ~path:(Eliom_service.Path ["users"])
  ~meth:(Eliom_service.Get Eliom_parameter.(suffix (string "name")))
  ()

let redir_service = Eliom_service.create
    ~path:(Eliom_service.Path ["redir"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let connection_service = Eliom_service.create
  ~path:(Eliom_service.No_path)
  ~meth:(Eliom_service.Post (
    Eliom_parameter.unit,
    Eliom_parameter.(string "name" ** string "password")))
  ()

let disconnection_service =
  Eliom_service.attach_post
    ~fallback:redir_service
    ~post_params:Eliom_parameter.unit
    ()

let new_user_form_service = Eliom_service.create
  ~path:(Eliom_service.Path ["registration"])
  ~meth:(Eliom_service.Get Eliom_parameter.unit)
  ()

let account_confirmation_service =
  Eliom_service.attach_post
    ~fallback:new_user_form_service
    ~post_params:Eliom_parameter.(string "name" **  string "password")
    ()

(* ===========================Usernames/Passwords============================ *)

let users = ref [("Calvin", "123"); ("Hobbes", "456")]

let user_links = Eliom_content.Html.D.(
  let link_of_user = fun (name, _) ->
    li [a ~service:user_service [pcdata name] name]
  in
  fun () -> ul (List.map link_of_user !users)
)

let check_pwd name pwd =
  try List.assoc name !users = pwd with Not_found -> false


(* =================================Widgets================================== *)

let account_form = Eliom_content.Html.D.(
  Form.post_form ~service:account_confirmation_service
    (fun (name1, name2) ->
      [fieldset
         [label [pcdata "login: "];
          Form.input ~input_type:`Text ~name:name1 Form.string;
          br ();
          label [pcdata "password: "];
          Form.input ~input_type:`Password ~name:name2 Form.string;
          br ();
          Form.input ~input_type:`Submit ~value:"Create Account" Form.string
         ]]) ()
)

let disconnect_box () = Eliom_content.Html.D.(
  Form.post_form disconnection_service
    (fun _ ->
      [fieldset [Form.input ~input_type:`Submit ~value:"Log out" Form.string]]
    )
    ()
  |> Lwt.return
)

(* =========================Authentification Handler========================= *)

let authenticated_handler g f = Eliom_content.Html.D.(
  let handle_anonymous _get _post =
    let%lwt wp = Eliom_reference.get wrong_pwd in
    let connection_box =
      let l = [
	Form.post_form ~service:connection_service
          (fun (name1, name2) ->
	    [fieldset
		[label [pcdata "login: "];
		 Form.input ~input_type:`Text ~name:name1 Form.string;
		 br ();
		 label [pcdata "password: "];
		 Form.input ~input_type:`Password ~name:name2 Form.string;
		 br ();
		 Form.input ~input_type:`Submit ~value:"Connect" Form.string
		]]) ();
        p [a new_user_form_service
              [pcdata "Create an account"] ()]]
      in
      div (if wp then p [pcdata "Wrong login or password"]::l else l)
    in
    g
      (html
        (head (title (pcdata "")) [])
        (body [h1 [pcdata "Please connect"];
	       connection_box;]))
    in
    Eliom_tools.wrap_handler
      (fun () -> Eliom_reference.get username)
      handle_anonymous (* Called when [username] is [None]     *)
      f                (* Called [username] contains something *)
)
(* ===========================Services Registration========================== *)

let () = Eliom_content.Html.D.(

  Eliom_registration.Html.register
    ~service:main_service
    (authenticated_handler Lwt.return (fun name () () ->
      let%lwt cf = disconnect_box () in
      Lwt.return
        (html (head (title (pcdata "")) [])
              (body [h1 [pcdata ("Hello " ^ name)];
                     cf;
                     user_links ()]))));

  Eliom_registration.Any.register
    ~service:user_service
    (authenticated_handler Eliom_registration.Html.send (fun _ name () ->
      if List.mem_assoc name !users then
	begin
	  let%lwt cf = disconnect_box () in
	  Eliom_registration.Html.send
            (html (head (title (pcdata name)) [])
               (body [h1 [pcdata name];
                      cf;
                      p [a ~service:main_service [pcdata "Home"] ()]]))
	end
      else
	Eliom_registration.Html.send
          ~code:404
          (html (head (title (pcdata "404")) [])
             (body [h1 [pcdata "404"];
                    p [pcdata "That page does not exist"]]))
    ));

  Eliom_registration.Action.register
    ~service:connection_service
    (fun () (name, password) ->
      if check_pwd name password
      then Eliom_reference.set username (Some name)
      else Eliom_reference.set wrong_pwd true);

  Eliom_registration.Redirection.register
    ~service:redir_service
    (fun () () -> Lwt.return (Eliom_registration.Redirection main_service));

  Eliom_registration.Action.register
    ~service:disconnection_service
    (fun () () -> Eliom_state.discard ~scope:Eliom_common.default_session_scope ());

  Eliom_registration.Html.register
    ~service:new_user_form_service
    (fun () () ->
      Lwt.return
        (html (head (title (pcdata "")) [])
              (body [h1 [pcdata "Create an account"];
                     account_form;
                    ])));

  Eliom_registration.Html.register
    ~service:account_confirmation_service
    (fun () (name, pwd) ->
      let create_account_service =
	Eliom_service.attach_get
          ~fallback:main_service
          ~get_params:Eliom_parameter.unit
          ~timeout:60.
	  ~max_use:1
	  ()
      in
      let _ = Eliom_registration.Action.register
	~service:create_account_service
        (fun () () ->
          users := (name, pwd)::!users;
          Lwt.return ())
      in
      Lwt.return
	(html
           (head (title (pcdata "")) [])
           (body
              [h1 [pcdata "Confirm account creation for "; pcdata name];
               p [a ~service:create_account_service [pcdata "Yes"] ();
                  pcdata " ";
                  a ~service:main_service [pcdata "No"] ()]
              ])));
)
