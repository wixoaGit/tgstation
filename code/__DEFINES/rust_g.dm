//#define rustg_log_write(fname, text) call(RUST_G, "log_write")(fname, text)
#define rustg_log_write(fname, text) if (fname != null) file(fname) << text//not_actual