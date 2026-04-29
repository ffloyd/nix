# Objective: Provide a flake output that pretty-prints hosts, their aspects, features, and adjustments
# ⚠ Vibecoded — do not use this file as a reference for generating other code in this project
{
  lib,
  config,
  ...
}: let
  inherit (lib) concatMapStringsSep concatStringsSep sort attrNames hasSuffix optionalString;
  inherit (builtins) lessThan filter stringLength genList;

  # ============================================================================
  # ANSI formatting
  # ============================================================================

  esc = builtins.fromJSON ''"\u001b"'';

  rst = esc + "[0m";
  bld = esc + "[1m";
  dim = esc + "[2m";
  cyn = esc + "[96m";
  ylw = esc + "[33m";
  grn = esc + "[32m";
  blu = esc + "[34m";

  fmtCyn = s: "${bld}${cyn}${s}${rst}";
  fmtDim = s: "${dim}${s}${rst}";
  fmtYlw = s: "${bld}${ylw}${s}${rst}";
  fmtGrn = s: "${bld}${grn}${s}${rst}";
  fmtBlu = s: "${bld}${blu}${s}${rst}";

  # ============================================================================
  # Helpers
  # ============================================================================

  hostScopeFor = system:
    if hasSuffix "linux" system
    then "nixos"
    else "macos";

  normFeature = pair: {
    scope = builtins.elemAt pair 0;
    feature = builtins.elemAt pair 1;
  };

  isFeatureRelevant = hostScope: {scope, ...}:
    scope == "common" || scope == hostScope;

  compareFeatures = a: b:
    a.feature < b.feature;

  repeatStr = s: n:
    concatStringsSep "" (genList (_: s) n);

  # ============================================================================
  # Formatters
  # ============================================================================

  formatFeatureBody = hostScope: features: let
    fs = map normFeature features;
    relevant = filter (isFeatureRelevant hostScope) fs;
    relevantSorted = sort compareFeatures relevant;
    hostFeatures = filter (f: f.scope == hostScope) relevantSorted;
    commonFeatures = filter (f: f.scope == "common") relevantSorted;

    hostScopeLabel =
      {
        nixos = "NixOS-specific features";
        macos = "macOS-specific features";
      }.${
        hostScope
      };

    commonPart =
      if commonFeatures == []
      then ""
      else concatMapStringsSep "\n" (f: "    ${fmtDim "•"} ${f.feature}") commonFeatures;

    hostPart =
      if hostFeatures == []
      then ""
      else
        "${fmtBlu "    ${hostScopeLabel}:"}\n"
        + concatMapStringsSep "\n" (f: "      ${fmtDim "•"} ${f.feature}") hostFeatures;

    parts = filter (p: p != "") [commonPart hostPart];
  in
    if relevant == []
    then fmtDim "    (no features listed for this host)"
    else concatStringsSep "\n\n" parts;

  formatAspect = hostScope: aspectName: let
    aspectCfg = config.my.aspects.${aspectName} or {};
    desc =
      optionalString (aspectCfg.description or "" != "")
      "${fmtDim " — ${aspectCfg.description}"}";
    featuresBody = formatFeatureBody hostScope (aspectCfg.features or []);
  in "${fmtGrn aspectName}${desc}\n${featuresBody}";

  formatAspects = hostScope: aspectNames:
    concatMapStringsSep "\n\n"
    (formatAspect hostScope)
    (sort lessThan aspectNames);

  formatAdjustments = adjustments:
    if adjustments == []
    then fmtDim "  (none)"
    else concatMapStringsSep "\n" (a: "  ${fmtDim "•"} ${a}") adjustments;

  formatHost = hostName: hostCfg: let
    hostScope = hostScopeFor hostCfg.system;

    SEP = 64;

    headerPrefix = "━ ${fmtCyn hostCfg.hostname} ";
    headerSuffix = repeatStr "━" (SEP - stringLength hostCfg.hostname - 3);
  in ''
    ${fmtDim "${headerPrefix}${headerSuffix}"}
      ${fmtDim "System :"} ${hostCfg.system}
      ${fmtDim "User   :"} ${hostCfg.username}

    ${fmtYlw "Host-specific adjustments:"}
    ${formatAdjustments hostCfg.adjustments}

    ${fmtYlw "Aspects:"}

    ${formatAspects hostScope hostCfg.aspects}
  '';

  hostsSorted = sort lessThan (attrNames config.my.hosts);

  overviewText =
    concatMapStringsSep "\n"
    (hostName: formatHost hostName config.my.hosts.${hostName})
    hostsSorted;
in {
  perSystem = {pkgs, ...}: {
    packages.overview = pkgs.writeShellScriptBin "overview" ''
            cat <<'ENDOUTPUT'
      ${overviewText}
      ENDOUTPUT
    '';
  };
}
