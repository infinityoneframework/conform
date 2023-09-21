import Config

config :logger, :backends, [
  :console,
  {ExSyslog, :exsyslog_error},
  {ExSyslog, :exsyslog_debug}
]
