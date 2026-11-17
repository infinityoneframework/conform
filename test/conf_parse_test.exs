defmodule ConfParseTest do
  use ExUnit.Case, async: true

  test "can parse a valid conf file" do
    path = Path.join(["test", "confs", "test.conf"]) |> Path.expand()
    conf = path |> Conform.Parse.file!()

    assert [
             {[~c"log", ~c"error", ~c"file"], [~c"/var/log/error.log"]},
             {[~c"log", ~c"console", ~c"file"], [~c"/var/log/console.log"]},
             {[~c"log", ~c"syslog"], [~c"on"]},
             {[~c"sasl", ~c"errlog_type"], [~c"error"]},
             {[~c"myapp", ~c"some_val"], [~c"foo"]},
             {[~c"some", ~c"string value"], [~c"stringkeys"]},
             {[~c"starting string", ~c"key"], [~c"stringkeys"]},
             {[~c"myapp", ~c"Custom", ~c"Enum"], [~c"prod"]}
           ] == conf
  end

  test "can parse string values containing newlines" do
    path = Path.join(["test", "confs", "strings.conf"]) |> Path.expand()
    conf = path |> Conform.Parse.file!()

    assert [
             {[~c"logger", ~c"format"], [~c"$time $metadata[$level] $levelpad$message\\n"]},
             {[~c"logger", ~c"values"], [~c"error", ~c"random_-\\\\alkjda;k__23232"]}
           ] == conf
  end

  test "can parse nested lists" do
    conf = "app.nested_lists = [opt1 = val1, opt2 = \"val two\"]"
    result = Conform.Parse.parse!(conf)

    assert [{[~c"app", ~c"nested_lists"], [[{~c"opt1", ~c"val1"}, {~c"opt2", ~c"val two"}]]}] ==
             result

    conf = "app.nested_lists = [opt1 = val1, opt2 = \"val two\"], [opt1 = val3, opt2 = \"val4\"]"
    result = Conform.Parse.parse!(conf)

    assert [
             {[~c"app", ~c"nested_lists"],
              [
                [{~c"opt1", ~c"val1"}, {~c"opt2", ~c"val two"}],
                [{~c"opt1", ~c"val3"}, {~c"opt2", ~c"val4"}]
              ]}
           ] == result
  end

  test "can parse nested lists which are not key/value pairs" do
    result = Conform.Parse.file!(Path.join([__DIR__, "confs", "evl_daemon.conf"]))

    assert [
             {[~c"evl_daemon", ~c"mailer_api_key"], [~c"SECRET API KEY"]},
             {[~c"evl_daemon", ~c"host"], [~c"127.0.0.1"]},
             {[~c"evl_daemon", ~c"port"], [~c"4025"]},
             {[~c"evl_daemon", ~c"password"], [~c"EVL portal password"]},
             {[~c"evl_daemon", ~c"auto_connect"], [~c"true"]},
             {[~c"evl_daemon", ~c"event_notifiers"],
              [
                [{~c"type", ~c"console"}],
                [
                  {~c"type", ~c"email"},
                  {~c"recipient", ~c"user@example.com"},
                  {~c"sender", ~c"noreply@example.com"}
                ],
                [
                  {~c"type", ~c"sms"},
                  {~c"from", ~c"+12345678"},
                  {~c"to", ~c"+19876543"},
                  {~c"sid", ~c"SID"},
                  {~c"auth_token", ~c"Twilio AUTH TOKEN"}
                ]
              ]},
             {[~c"evl_daemon", ~c"storage_engines"],
              [[{~c"type", ~c"memory"}, {~c"maximum_events", ~c"100"}], [{~c"type", ~c"dummy"}]]},
             {[~c"evl_daemon", ~c"zones"],
              [
                [~c"1", ~c"Front door"],
                [~c"2", ~c"Garage door"],
                [~c"3", ~c"Basement door"],
                [~c"4", ~c"Kitchen door"],
                [~c"5", ~c"Office motion sensor"],
                [~c"6", ~c"Family room motion sensor"],
                [~c"7", ~c"Basement glass break sensor"],
                [~c"8", ~c"Basement motion sensor"]
              ]},
             {[~c"evl_daemon", ~c"partitions"], [[~c"1", ~c"Main"]]},
             {[~c"evl_daemon", ~c"system_emails_sender"], [~c"noreply@example.com"]},
             {[~c"evl_daemon", ~c"system_emails_recipient"], [~c"user@example.com"]},
             {[~c"evl_daemon", ~c"log_level"], [~c"info"]},
             {[~c"evl_daemon", ~c"auth_token"], [~c"SECRET"]}
           ] == result
  end

  test "parsing utf8 should succeed" do
    conf = Conform.Parse.parse!("setting = thingŒ\n")
    assert [{[~c"setting"], [_]}] = conf
  end
end
