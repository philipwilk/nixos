{
  config,
  ...
}:
{
  services.alloy.enable = true;

  environtment.etc."alloy/config.alloy".text = ''
    logging {
      format = "logfmt"
      level = "debug"
      write_to = [loki.relabel.alloy_logs_receiver]
    }
  '';
}
