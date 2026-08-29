#!/usr/bin/env python3
"""Generate Flutter AppLocalizations Dart files from ARB JSON files."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
L10N_DIR = ROOT / "lib" / "l10n"


def camel_case(key: str) -> str:
    parts = re.split(r"[_-]", key)
    return parts[0] + "".join(p[:1].upper() + p[1:] for p in parts[1:])


def parse_arb(path: Path) -> tuple[str, dict[str, str], dict[str, dict]]:
    data = json.loads(path.read_text(encoding="utf-8-sig"))
    locale = data.get("@@locale", path.stem.replace("app_", ""))
    messages: dict[str, str] = {}
    metadata: dict[str, dict] = {}
    for key, value in data.items():
        if key.startswith("@"):
            if key != "@@locale":
                metadata[key[1:]] = value
            continue
        if key == "@@locale":
            continue
        messages[key] = value
    return locale, messages, metadata


def method_signature(key: str, meta: dict | None) -> tuple[str, str, list[str]]:
    name = camel_case(key)
    placeholders = []
    if meta and "placeholders" in meta:
        for pname, pinfo in meta["placeholders"].items():
            ptype = pinfo.get("type", "String")
            dart_type = "int" if ptype == "int" else "String"
            placeholders.append((pname, dart_type))
    if placeholders:
        params = ", ".join(f"{ptype} {pname}" for pname, ptype in placeholders)
        sig = f"String {name}({params})"
        args = ", ".join(f"{{{pname}}}" for pname, _ in placeholders)
        body = f"return '{messages_ref(key)}'.replace(...)"  # placeholder
        return sig, name, [p[0] for p in placeholders]
    return f"String get {name}", name, []


messages_ref = lambda k: k  # noqa: E731


def render_impl(key: str, template: str, meta: dict | None) -> str:
    name = camel_case(key)
    if meta and "placeholders" in meta:
        param_types = [
            (pname, "int" if info.get("type") == "int" else "String")
            for pname, info in meta["placeholders"].items()
        ]
        params = ", ".join(f"{ptype} {pname}" for pname, ptype in param_types)
        dart_template = template
        for pname, _ in param_types:
            dart_template = dart_template.replace("{" + pname + "}", "${" + pname + "}")
        escaped = dart_template.replace("\\", "\\\\").replace("'", "\\'").replace("\n", "\\n")
        return f"  @override\n  String {name}({params}) => '{escaped}';"
    escaped = template.replace("'", "\\'").replace("\n", "\\n")
    return f"  @override\n  String get {name} => '{escaped}';"


def generate():
    arb_files = sorted(L10N_DIR.glob("app_*.arb"))
    if not arb_files:
        raise SystemExit("No ARB files found")

    locales_data: list[tuple[str, dict, dict]] = []
    for arb in arb_files:
        locales_data.append(parse_arb(arb))

    # Use English as canonical key list
    en = next((item for item in locales_data if item[0] == "en"), locales_data[0])
    _, en_messages, en_meta = en
    keys = list(en_messages.keys())

    abstract_methods = []
    for key in keys:
        meta = en_meta.get(key)
        name = camel_case(key)
        if meta and "placeholders" in meta:
            params = ", ".join(
                f"{'int' if info.get('type') == 'int' else 'String'} {pname}"
                for pname, info in meta["placeholders"].items()
            )
            abstract_methods.append(f"  String {name}({params});")
        else:
            abstract_methods.append(f"  String get {name};")

    locales = [loc for loc, _, _ in locales_data]

    delegate_body = "\n".join(
        f"    Locale('{loc}')," for loc in locales
    )

    lookup_cases = "\n".join(
        f"      case '{loc}': return AppLocalizations{loc.title() if loc != 'en' else 'En'}();"
        if loc == "en"
        else f"      case '{loc}': return AppLocalizations{loc[0].upper() + loc[1:]}();"
        for loc in locales
    )

    # Fix lookup class names
    def class_name(loc: str) -> str:
        if loc == "en":
            return "AppLocalizationsEn"
        return "AppLocalizations" + loc[0].upper() + loc[1:]

    lookup_cases = "\n".join(
        f"      case '{loc}': return {class_name(loc)}();" for loc in locales
    )

    imports = "\n".join(
        f"import 'app_localizations_{loc}.dart';" for loc in locales if loc != "en"
    )

    main_dart = f"""// GENERATED CODE - do not edit by hand.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
{imports}

abstract class AppLocalizations {{
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {{
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }}

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
{delegate_body}
  ];

{chr(10).join(abstract_methods)}
}}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {{
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {{
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }}

  @override
  bool isSupported(Locale locale) => AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}}

AppLocalizations lookupAppLocalizations(Locale locale) {{
  switch (locale.languageCode) {{
{lookup_cases}
  }}
  return AppLocalizationsEn();
}}
"""

    (L10N_DIR / "app_localizations.dart").write_text(main_dart, encoding="utf-8")

    for loc, messages, meta in locales_data:
        impls = []
        for key in keys:
            template = messages.get(key, en_messages[key])
            impls.append(render_impl(key, template, meta.get(key) or en_meta.get(key)))

        class_nm = class_name(loc)
        impl_dart = f"""// GENERATED CODE - do not edit by hand.
import 'app_localizations.dart';

class {class_nm} extends AppLocalizations {{
  {class_nm}() : super('{loc}');

{chr(10).join(impls)}
}}
"""
        out_name = f"app_localizations_{loc}.dart"
        (L10N_DIR / out_name).write_text(impl_dart, encoding="utf-8")
        print(f"Wrote {out_name}")


if __name__ == "__main__":
    generate()
