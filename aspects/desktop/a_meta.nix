{config, ...}: {
  my.aspects.desktop = {
    description = "Desktop environment tailored to my workflows";
    dependsOn = [config.my.aspects.base];
  };
}
