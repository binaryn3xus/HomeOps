import re
import sys
from pathlib import Path
import requests
from bs4 import BeautifulSoup

CONFIGMAP_PATH = Path("kubernetes/apps/games/minecraft-bedrock/app/configmap.yaml")
WIKI_URL = "https://minecraft.wiki/w/Bedrock_Edition_version_history"

def get_latest_bedrock_version():
    resp = requests.get(WIKI_URL)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, 'html.parser')
    # Find all 'Latest: x.x.xxx' in the text
    text = soup.get_text()
    latest_versions = re.findall(r'Latest: (1\.\d{2,3}\.\d{1,3})', text)
    if latest_versions:
        # Pick the highest version
        latest_versions_sorted = sorted(latest_versions, key=lambda v: tuple(map(int, v.split('.'))), reverse=True)
        return latest_versions_sorted[0]
    # Fallback: Find all 1.xx.xxx and pick the highest
    versions = re.findall(r'1\.\d{2,3}\.\d{1,3}', text)
    if not versions:
        print("Could not find any Bedrock versions on wiki", file=sys.stderr)
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
    latest = get_latest_bedrock_version()
    changed = update_configmap(latest)
    sys.exit(0 if changed else 2)
