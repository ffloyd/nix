# Objective: Provide a flake output that pretty-prints hosts, their aspects, features, and adjustments
{
  lib,
  config,
  ...
}: let
  # ANSI formatting
  #
  # Useful resources:
  # - https://ansi.tools/
  # - https://www.tutorialpedia.org/blog/list-of-ansi-color-escape-sequences/#816-color-mode-basic--bright-colors
  ansi = rec {
    # It's known problem:
    # https://discourse.nixos.org/t/how-can-i-put-an-nonprintable-character-in-a-nix-expression/47750/6
    esc = builtins.fromJSON ''"\u001b"'';

    reset = esc + "[0m";

    bold = esc + "[1m";
    dim = esc + "[2m";
    italic = esc + "[3m";

    black = esc + "[30m";
    red = esc + "[31m";
    green = esc + "[32m";
    yellow = esc + "[33m";
    blue = esc + "[34m";
    magenta = esc + "[35m";
    cyan = esc + "[36m";
    white = esc + "[37m";

    brightGreen = esc + "[92m";
    brightWhite = esc + "[97m";
  };

  fmtSeparator = str: with ansi; dim + white + str + reset;
  fmtSecondary = str: with ansi; dim + white + italic + str + reset;
  fmtHostkey = str: with ansi; bold + brightGreen + str + reset;
  fmtSectionTitle = str: with ansi; bold + str + reset;
  fmtAspectName = str: with ansi; bold + cyan + str + reset;
  fmtAspectDesc = str: with ansi; italic + str + reset;
  fmtFeaturePrefix = str: with ansi; italic + dim + blue + str + reset;

  printList = strList: ident: let
    inherit (builtins) concatStringsSep;
    inherit (lib.strings) replicate;
    listEntries =
      map
      (str: (replicate ident " ") + (fmtSeparator "• ") + str)
      strList;
  in
    concatStringsSep "\n" listEntries;

  # features stored as [scope description] pairs.
  # it's convenient for writing, but it makes code that works with them less expressive
  # so we transorm them to simple attrsets to improve readablity of the code here
  normalizeFeatures = features: let
    inherit (builtins) elemAt;
  in
    map
    (feature: {
      scope = elemAt feature 0;
      desc = elemAt feature 1;
    })
    features;

  featuresList = features: let
    inherit (builtins) length;
    prefixFor = feature:
      if feature.scope == "common"
      then ""
      else fmtFeaturePrefix "[${feature.scope} only] ";
    featureDescsWithPrefix =
      map
      (feature: prefixFor feature + feature.desc)
      features;
  in
    if length features == 0
    then fmtSecondary "    (no features for the host's system)"
    else printList featureDescsWithPrefix 4;

  aspectReport = aspectName: system: let
    inherit (builtins) filter;
    aspect = config.my.aspects.${aspectName};
    features = normalizeFeatures aspect.features;
    hostSystemScope =
      {
        x86_64-linux = "nixos";
        aarch64-darwin = "macos";
      }.${
        system
      }
      or (throw "overview: unknown system '${system}' — add a mapping for it.");
    systemSpecificFeatures =
      filter
      (feat: feat.scope == hostSystemScope)
      features;
    commonFeatures =
      filter
      (feat: feat.scope == "common")
      features;
    relevantFeatures = systemSpecificFeatures ++ commonFeatures;
  in ''
      ${fmtAspectName aspectName} - ${fmtAspectDesc aspect.description}

    ${featuresList relevantFeatures}
  '';

  hostReport = hostkey: let
    inherit (builtins) concatStringsSep;
    hostConfig = config.my.hosts.${hostkey};
    aspectReports =
      map
      (aspectName: aspectReport aspectName hostConfig.system)
      hostConfig.aspects;
  in ''
    ${fmtSectionTitle "=> config.my.hosts."}${fmtHostkey hostkey}
      ${fmtSecondary "hostname:"} ${hostConfig.hostname}
      ${fmtSecondary "username:"} ${hostConfig.username}
      ${fmtSecondary "system:  "} ${hostConfig.system}

    ${fmtSectionTitle "Host-specific adjustments:"}

    ${
      if hostConfig.adjustments == []
      then fmtSecondary "  (no adjustments defined)"
      else printList hostConfig.adjustments 2
    }

    ${fmtSectionTitle "Aspects:"}

    ${
      if hostConfig.aspects == []
      then fmtSecondary "  (no aspects enabled)"
      else concatStringsSep "\n" aspectReports
    }
  '';

  overviewText = let
    inherit (builtins) attrNames concatStringsSep;
    inherit (lib) trim;
    hostReports = map hostReport (attrNames config.my.hosts);
    untrimmed = concatStringsSep "\n" hostReports;
  in
    trim untrimmed;
in {
  perSystem = {pkgs, ...}: {
    packages.overview = pkgs.writeShellScriptBin "overview" ''
      cat <<ENDOUTPUT
      ${overviewText}
      ENDOUTPUT
    '';
  };
}
