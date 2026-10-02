#!/usr/bin/env bash
# Checks the translation schema of _posts (CI friendly, exit 1 on errors).
#   scripts/check-translations.sh            # source checks
#   scripts/check-translations.sh _site      # additionally: built pages link each other / lists have no duplicates
set -euo pipefail
cd "$(dirname "$0")/.."
exec python3 - "${1:-}" <<'PY'
import glob, os, re, sys

site = sys.argv[1]
LANGS = {"en", "de"}
errors, warnings = [], []
posts = []

for f in sorted(glob.glob("_posts/**/*.md", recursive=True)):
    txt = open(f, encoding="utf-8").read()
    m = re.match(r"---\n(.*?)\n---\n(.*)", txt, re.S)
    if not m:
        errors.append(f"{f}: front matter missing"); continue
    fm, body = m.groups()
    def get(k):
        mm = re.search(rf"^{k}:\s*[\"']?(.*?)[\"']?\s*$", fm, re.M)
        return mm.group(1) if mm else None
    base = os.path.basename(f)[:-3]
    mm = re.match(r"(\d{4})-(\d{2})-(\d{2})-(.*)", base)
    if not mm:
        errors.append(f"{f}: filename must be YYYY-MM-DD-<slug>.md"); continue
    y, mo, d, slug = mm.groups()
    cats = re.search(r"^categories:\s*\n((?:\s+- .*\n?)+)", fm, re.M)
    posts.append(dict(file=f, lang=get("lang") or "en", ref=get("ref"), slug=slug,
                      date=f"{y}-{mo}-{d}", url=f"/blog/{y}/{mo}/{d}/{slug}/",
                      cats=cats.group(1).split() if cats else [], body=body))

for p in posts:
    if p["lang"] not in LANGS:
        errors.append(f"{p['file']}: lang must be en|de, is '{p['lang']}'")
    if p["slug"].endswith("-de") and p["lang"] != "de":
        errors.append(f"{p['file']}: '-de' file must have lang: de")
    if p["lang"] == "de" and not p["ref"]:
        errors.append(f"{p['file']}: lang: de needs a ref (translation group)")
    if re.search(r"^\*\[(Deutsche Version|English version)\]", p["body"], re.M):
        errors.append(f"{p['file']}: manual language link in body - layout does that via ref")

groups = {}
for p in posts:
    if p["ref"]:
        groups.setdefault(p["ref"], []).append(p)
for ref, ps in groups.items():
    seen = {}
    for p in ps:
        if p["lang"] in seen:
            errors.append(f"ref '{ref}': more than one {p['lang']} file ({seen[p['lang']]['file']}, {p['file']})")
        seen[p["lang"]] = p
    if len(ps) < 2:
        errors.append(f"ref '{ref}': only {ps[0]['file']} - a ref needs both languages (or drop ref)")
        continue
    en = seen.get("en")
    if en and en["slug"] != ref:
        errors.append(f"ref '{ref}': should equal the slug of the English file ('{en['slug']}')")
    if len({p["date"] for p in ps}) > 1:
        errors.append(f"ref '{ref}': translations must have the same date")
    if len({tuple(p["cats"]) for p in ps}) > 1:
        warnings.append(f"ref '{ref}': categories differ between translations")

if site:
    for ref, ps in groups.items():
        for p in ps:
            page = os.path.join(site, p["url"].strip("/"), "index.html")
            if not os.path.exists(page):
                errors.append(f"{page}: not built"); continue
            html = open(page, encoding="utf-8").read()
            for q in ps:
                if q is not p and f'href="{q["url"]}" hreflang="{q["lang"]}" lang="{q["lang"]}" data-setlang' not in html:
                    errors.append(f"{page}: no link to translation {q['url']}")
    for feed in ("feed.xml", "de/feed.xml"):
        fp = os.path.join(site, feed)
        if os.path.exists(fp):
            ids = re.findall(r"<entry[^>]*>.*?<id>(.*?)</id>", open(fp, encoding="utf-8").read(), re.S)
            if len(ids) != len(set(ids)):
                errors.append(f"{fp}: duplicate entries")
            for ref, ps in groups.items():
                hits = [p for p in ps if any(i.endswith(p["url"]) for i in ids)]
                if len(hits) > 1:
                    errors.append(f"{fp}: ref '{ref}' appears more than once")

for w in warnings: print("WARN ", w)
for e in errors: print("ERROR", e)
print(f"{len(posts)} posts, {len(groups)} translation group(s), {len(errors)} error(s), {len(warnings)} warning(s)")
sys.exit(1 if errors else 0)
PY
