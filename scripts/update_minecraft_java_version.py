import re
import sys
from pathlib import Path
import requests
from bs4 import BeautifulSoup

CONFIGMAP_PATH = Path("kubernetes/apps/games/minecraft-java/app/configmap.yaml")
WIKI_URL = "https://minecraft.wiki/w/Java_Edition_version_history"

def get_latest_java_version():
    resp = requests.get(WIKI_URL)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, 'html.parser')
    text = soup.get_text()
    # Only use the first 'Latest: x.x.xx' occurrence (official release)
    m = re.search(r'Latest: (1\.\d{1,2}\.\d{1,2})', text)
    if m:
        return m.group(1)
    # Fallback: Find all 1.x.xx and pick the highest
    versions = re.findall(r'1\.\d{1,2}\.\d{1,2}', text)
    if not versions:
        print("Could not find any Java versions on wiki", file=sys.stderr)
        sys.exit(1)
    versions_sorted = sorted(versions, key=lambda v: tuple(map(int, v.split('.'))), reverse=True)
    return versions_sorted[0]

def update_configmap(version):
    text = CONFIGMAP_PATH.read_text()
    new_text = re.sub(r'(VERSION:\s*)[0-9.]+', r'\g<1>' + version, text)
    if text != new_text:
        CONFIGMAP_PATH.write_text(new_text)
        print(f"Updated VERSION to {version}")
        return True
    print("VERSION already up to date")
    return False

if __name__ == "__main__":
    latest = get_latest_java_version()
    changed = update_configmap(latest)
    sys.exit(0 if changed else 2)
