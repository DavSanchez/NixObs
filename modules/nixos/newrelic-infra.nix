{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.services.newrelic-infra;
in {
  options.services.newrelic-infra = {
    enable = lib.mkEnableOption "newrelic-infra service";
    config = lib.mkOption {
      type = lib.types.path;
      example = "./newrelic-infra.yml";
      description = "Infrastructure Agent configuration. Will be placed in `/etc/newrelic-infra.yml`. Refer to <https://docs.newrelic.com/docs/infrastructure/install-infrastructure-agent/configuration/infrastructure-agent-configuration-settings> for details on supported values.";
    };
    # TODO: withIntegrations = [ drv drv ... ];
  };

  config = lib.mkIf cfg.enable {
    systemd.services.newrelic-infra = {
      description = "New Relic Infrastructure Agent";

      after = [
        "dbus.service"
        "syslog.target"
        "network.target"
      ];

      serviceConfig = {
        RuntimeDirectory = "newrelic-infra";
        Type = "simple";
        ExecStart = "${pkgs.infrastructure-agent}/bin/newrelic-infra-service";
        MemoryMax = "1G";
        Restart = "always";
        RestartSec = 20;
        PIDFile = "/run/newrelic-infra/newrelic-infra.pid";
      };

      unitConfig = {
        StartLimitInterval = 0;
        StartLimitBurst = 5;
      };

      wantedBy = ["multi-user.target"];
    };

    environment.etc."newrelic-infra.yml".source = cfg.config;
  };
}
