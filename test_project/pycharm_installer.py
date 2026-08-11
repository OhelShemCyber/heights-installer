import os
import subprocess
import tempfile
import urllib.request
import urllib.error
import json
import winreg
import re
import sys
import time

# --- Force Miniconda paths ---
miniconda_base = r"C:\Heights\Miniconda"
miniconda_paths = [
    miniconda_base,
    os.path.join(miniconda_base, "Scripts"),
    os.path.join(miniconda_base, "Library", "bin"),
    os.path.join(miniconda_base, "Library", "usr", "bin"),
    os.path.join(miniconda_base, "Library", "mingw-w64", "bin"),
]
os.environ["PATH"] = ";".join(miniconda_paths) + ";" + os.environ["PATH"]

# --- Fix SSL errors ---
try:
    import certifi
    os.environ["SSL_CERT_FILE"] = certifi.where()
except ImportError:
    print("[WARN] 'certifi' is not installed, SSL may fail. Run: pip install certifi")

INSTALL_FLAGS = ["/S", "/CONFIG=install_config.cfg"]

def log(msg):
    print(f"[LOG] {msg}")

def get_installed_versions():
    editions = {}
    reg_paths = [
        r"SOFTWARE\JetBrains",
        r"SOFTWARE\WOW6432Node\JetBrains",
        r"SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        r"SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    ]
    for root in (winreg.HKEY_LOCAL_MACHINE, winreg.HKEY_CURRENT_USER):
        for path in reg_paths:
            try:
                with winreg.OpenKey(root, path) as key:
                    for i in range(winreg.QueryInfoKey(key)[0]):
                        sub = winreg.EnumKey(key, i)
                        with winreg.OpenKey(key, sub) as sk:
                            try:
                                name, _ = winreg.QueryValueEx(sk, "DisplayName")
                                ver, _ = winreg.QueryValueEx(sk, "DisplayVersion")
                                editions[name] = ver
                            except FileNotFoundError:
                                continue
            except FileNotFoundError:
                continue
    return editions

def get_latest_community_info():
    url = "https://data.services.jetbrains.com/products/releases?code=PCP&latest=true&type=release"
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
            latest = data["PCP"][0]
            marketing_version = latest["version"]
            build_number = latest["build"]
            download_url = f"https://download-cdn.jetbrains.com/python/pycharm-community-{marketing_version}.exe"
            log(f"Latest Community version: {marketing_version} (Build {build_number})")
            log(f"Download URL: {download_url}")
            return marketing_version, build_number, download_url
    except Exception as e:
        raise Exception(f"Failed to fetch version info: {e}")


def download_installer(url):
    log("Downloading PyCharm installer...")
    fd, path = tempfile.mkstemp(suffix=".exe")
    try:
        with urllib.request.urlopen(url) as response, os.fdopen(fd, "wb") as f:
            while True:
                chunk = response.read(8192)
                if not chunk:
                    break
                f.write(chunk)
        log(f"Installer downloaded to: {path}")
        return path
    except urllib.error.URLError as e:
        raise Exception(f"Failed to download installer: {e}")

def write_config():
    config = """[Install]
mode=user
launcher64=1
updateContextMenu=1
updatePATH=1
"""
    with open("install_config.cfg", "w") as f:
        f.write(config)
    log("Wrote install_config.cfg for Windows integration.")

def version_newer(v1, v2):
    parse = lambda v: [int(x) for x in re.findall(r"\d+", v)]
    return parse(v1) > parse(v2)

def main():
    log("Checking installed PyCharm editions...")
    installed = get_installed_versions()
    for name, ver in installed.items():
        if "pycharm" in name.lower():
            log(f"Detected: {name} v{ver}")

    if any("Professional" in name for name in installed):
        log("PyCharm Professional is installed. Skipping install.")
        return

    # Grab installed community build number if exists
    community_ver = None
    for name, ver in installed.items():
        if "Community" in name:
            community_ver = ver  # This is already a build number like 251.26094.141
            log(f"PyCharm Community installed: v{community_ver}")
            break

    marketing_ver, latest_build, download_url = get_latest_community_info()

    if community_ver == latest_build:
        log("Installed Community version is up to date. No action needed.")
        return

    action = "Updating" if community_ver else "Installing"
    log(f"{action} PyCharm Community to build {latest_build}...")

    installer_path = download_installer(download_url)
    write_config()

    log("Launching installer...")
    subprocess.run([installer_path] + INSTALL_FLAGS, check=True)
    log("✅ PyCharm Community installation complete.")

    
    


if __name__ == "__main__":
    main()
