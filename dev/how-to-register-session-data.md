
# How to register session data?

It is very easy to register session data using *Eliom references*. Just create an Eliom reference of *scope* session and its value will be different for each session (one session \= one browser process).

But most of the time, what we want is to store data for one user, not for one browser instance. To do that, we group all the sessions for one user together, by creating a group of sessions. The name of the group may be for example the user id.

To create a session group, open the session by doing something like:

```ocaml
let open_session login password =
  let%lwt b = check_password login password in
  if b
  then Eliom.State.set_volatile_data_session_group
      ~scope:Eliom.Common.default_session_scope
      (Int64.to_string (get_userid login))
  else ...

```
If you want to store user data, just create a global Eliom reference of scope group:

```ocaml

let myref =
  Eliom.Reference.Volatile.eref
    ~scope:Eliom.Common.default_group_scope
    None

```
And during a request, set this reference:

```ocaml

  ...
  Eliom.Reference.Volatile.set myref (Some "user data")

```
The value of this reference is different for each user:

```ocaml

  Eliom.Reference.Volatile.get myref

```
It is possible to create *persistent* Eliom references (see module `Eliom.Reference`).


## Other scopes

If you want to store server side data for one browser (one session), use scope `Eliom.Common.default_session_scope`.

If you want to store server side data for one tab of your browser (one client process), use scope `Eliom.Common.default_process_scope` (available only if you have a client-server Eliom application).

If you want to store server side data during one request, use scope `Eliom.Common.request_scope`.


## Persistent references

Module `Eliom.Reference` also defines an interface for persistent references, that will survive if you restart the server.


## Links

- [More information on session data](https://ocsigen.org/eliom/latest/server-state.html)
- module `Eliom.Reference`