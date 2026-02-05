{config, ...}: {
  my.aspects.shell = {
    description = "Basic shell environment configuration and QoL tools.";
    dependsOn = with config.my.aspects; [
      base
    ];
  };
}
