#!/usr/bin/env python3
"""
Convert the Squarespace WordPress export into Astro markdown posts.

Run from the root of the website repo:
    python3 convert-newsletter.py

Reads   archive/*.xml
Writes  src/content/news/<slug>.md
Copies  archive/images-web/* (or archive/images/*) -> public/news/
Rewrites every <img> to a local /news/<file> path.
"""

import html
import os
import re
import shutil
import sys
import urllib.parse
import xml.etree.ElementTree as ET
from pathlib import Path

NS = {
    "wp": "http://wordpress.org/export/1.2/",
    "content": "http://purl.org/rss/1.0/modules/content/",
}

ROOT = Path.cwd()
OUT = ROOT / "src" / "content" / "news"
PUB = ROOT / "public" / "news"


def harvest_name(url: str) -> str:
    """Reproduce the filename fetch-images.sh gave this URL, post-.webp-rename."""
    url = url.split("?")[0]
    fname = url.rsplit("/", 1)[-1]
    uuid = url.rsplit("/", 2)[-2]
    decoded = urllib.parse.unquote(fname)          # %XX -> char, '+' left alone
    safe = decoded.replace(" ", "_").replace("/", "_")
    stem = safe.rsplit(".", 1)[0] if "." in safe else safe
    return f"{uuid[:8]}-{stem}.webp"


def to_markdown(body: str, used: set) -> str:
    s = body

    # images first, so their attributes aren't mangled by later passes
    def img(m):
        tag = m.group(0)
        src = re.search(r'src="([^"]+)"', tag)
        alt = re.search(r'alt="([^"]*)"', tag)
        if not src:
            return ""
        local = harvest_name(src.group(1))
        used.add(local)
        return f'\n\n![{html.unescape(alt.group(1)) if alt else ""}](/news/{local})\n\n'

    s = re.sub(r"<img[^>]*>", img, s)

    # block level
    s = re.sub(r"<h1[^>]*>(.*?)</h1>", r"\n\n## \1\n\n", s, flags=re.S)
    s = re.sub(r"<h2[^>]*>(.*?)</h2>", r"\n\n## \1\n\n", s, flags=re.S)
    s = re.sub(r"<h3[^>]*>(.*?)</h3>", r"\n\n### \1\n\n", s, flags=re.S)
    s = re.sub(r"<br\s*/?>", "\n", s)
    s = re.sub(r"</p\s*>", "\n\n", s)
    s = re.sub(r"<p[^>]*>", "", s)

    # inline
    s = re.sub(r"<a[^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>", r"[\2](\1)", s, flags=re.S)
    s = re.sub(r"<(strong|b)[^>]*>(.*?)</\1>", r"**\2**", s, flags=re.S)
    s = re.sub(r"<(em|i)[^>]*>(.*?)</\1>", r"*\2*", s, flags=re.S)

    # anything left
    s = re.sub(r"<[^>]+>", "", s)
    s = html.unescape(s)

    # tidy whitespace
    s = re.sub(r"[ \t]+\n", "\n", s)
    s = re.sub(r"\n{3,}", "\n\n", s)
    return s.strip()


def yaml_quote(v: str) -> str:
    return '"' + v.replace("\\", "\\\\").replace('"', '\\"') + '"'


def main():
    xmls = sorted((ROOT / "archive").glob("*.xml"))
    if not xmls:
        sys.exit("No XML found in archive/ — run this from the repo root.")
    root = ET.parse(xmls[0]).getroot()

    posts = [
        i for i in root.findall("./channel/item")
        if (i.find("wp:post_type", NS) is not None
            and i.find("wp:post_type", NS).text == "post"
            and i.find("wp:status", NS).text == "publish")
    ]

    OUT.mkdir(parents=True, exist_ok=True)
    PUB.mkdir(parents=True, exist_ok=True)
    used: set = set()
    written = 0

    for p in posts:
        title = (p.find("title").text or "Untitled").strip()
        slug = (p.find("wp:post_name", NS).text or "").strip()
        date = (p.find("wp:post_date", NS).text or "").split(" ")[0]
        body = p.find("content:encoded", NS).text or ""
        if not slug:
            continue

        md = to_markdown(body, used)

        # first image doubles as the card thumbnail
        hero = re.search(r"!\[[^\]]*\]\((/news/[^)]+)\)", md)

        fm = [
            "---",
            f"title: {yaml_quote(title)}",
            f"date: {date}",
        ]
        if hero:
            fm.append(f"cover: {yaml_quote(hero.group(1))}")
        fm += ["archived: true", "---", ""]

        (OUT / f"{slug}.md").write_text("\n".join(fm) + md + "\n", encoding="utf-8")
        written += 1

    # copy the images those posts actually reference
    src_dir = ROOT / "archive" / "images-web"
    if not src_dir.exists():
        src_dir = ROOT / "archive" / "images"
    copied, missing = 0, []
    for name in sorted(used):
        src = src_dir / name
        if src.exists():
            shutil.copy2(src, PUB / name)
            copied += 1
        else:
            missing.append(name)

    print(f"posts written : {written}  -> src/content/news/")
    print(f"images copied : {copied} of {len(used)}  -> public/news/")
    if missing:
        print(f"\nMissing {len(missing)} image(s) — first few:")
        for m in missing[:10]:
            print("  ", m)
        print("\nCheck archive/images-web exists, or rerun after the .webp rename.")


if __name__ == "__main__":
    main()
