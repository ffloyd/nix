let
  # Use `ssh-keyscan localhost` to identify local keys
  # or look in ~/.ssh/id_ed25519.pub
  #
  # Use host keys from my.hosts.[key] for naming.
  framework-13-amd-ai-300 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPKUVUw3eHWnygfbaKQ1P4bEoO8tDdd0CSeykNNpBhP0";
in {
  "test.age".publicKeys = [ framework-13-amd-ai-300 ];
  "Caddyfile.work".publicKeys = [ framework-13-amd-ai-300 ];
}
