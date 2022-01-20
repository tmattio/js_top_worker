(* Simplest example *)
open Js_of_ocaml
open Js_top_worker_rpc
module W = Js_top_worker_client.W

let log s = Firebug.console##log (Js.string s)

let initialise s callback =
  let ( let* ) = Lwt_result.bind in
  let rpc = Js_top_worker_client.start s 100000 callback in
  let* () = W.init rpc Toplevel_api_gen.{ cmas = []; cmi_urls = [] } in
  Lwt.return (Ok rpc)

let log_output (o : Toplevel_api_gen.exec_result) =
  Option.iter (fun s -> log ("stdout: " ^ s)) o.stdout;
  Option.iter (fun s -> log ("stderr: " ^ s)) o.stderr;
  Option.iter (fun s -> log ("sharp_ppf: " ^ s)) o.sharp_ppf;
  Option.iter (fun s -> log ("caml_ppf: " ^ s)) o.caml_ppf

let start rpc =
  let ( let* ) = Lwt_result.bind in
  let* o = W.setup rpc () in
  log_output o;
  Lwt.return (Ok o)

let exec rpc txt =
  let ( let* ) = Lwt_result.bind in
  let* o = W.exec rpc txt in
  log_output o;
  Lwt.return (Ok o)

let _ =
  let ( let* ) = Lwt_result.bind in
  let* rpc = initialise "worker.js" (fun _ -> log "Timeout") in
  let* _ = start rpc in
  let* _ = exec rpc "2*2;;" in
  Lwt.return (Ok ())
