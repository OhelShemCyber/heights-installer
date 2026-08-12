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

LOG_PATH = r"C:\Heights\install_log.txt"

def log(msg):
    # Print live to the console AND append to the log, so the window shows
    # progress while it runs and there is still a record afterwards.
    line = f"[LOG] {msg}"
    print(line, flush=True)
    try:
        with open(LOG_PATH, "a", encoding="utf-8") as f:
            f.write(line + "\n")
    except OSError:
        pass

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
    url = "https://data.services.jetbrains.com/products/releases?code=PCC&latest=true&type=release"
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode())
            latest = data["PCC"][0]
            marketing_version = latest["version"]
            build_number = latest["build"]
            # Take the link JetBrains reports rather than rebuilding the filename.
            # The old "pycharm-community-<ver>.exe" pattern is retired and 404s.
            download_url = latest["downloads"]["windows"]["link"]
            log(f"Latest Community version: {marketing_version} (Build {build_number})")
            log(f"Download URL: {download_url}")
            return marketing_version, build_number, download_url
    except Exception as e:
        raise Exception(f"Failed to fetch version info: {e}")


def download_installer(url):
    log("Downloading PyCharm installer (this is a large file, please wait)...")
    fd, path = tempfile.mkstemp(suffix=".exe")
    try:
        with urllib.request.urlopen(url) as response, os.fdopen(fd, "wb") as f:
            total = int(response.headers.get("Content-Length") or 0)
            if total:
                log(f"Total size: {total // (1024 * 1024)} MB")
            done = 0
            next_pct = 0
            next_mb = 0
            while True:
                chunk = response.read(65536)
                if not chunk:
                    break
                f.write(chunk)
                done += len(chunk)
                # Report every 5%, or every 25 MB when the server sends no size.
                if total:
                    pct = done * 100 // total
                    if pct >= next_pct:
                        log(f"   {pct:3d}%  -  {done // (1024 * 1024)} / {total // (1024 * 1024)} MB")
                        next_pct = pct + 5
                elif done >= next_mb:
                    log(f"   {done // (1024 * 1024)} MB downloaded")
                    next_mb = done + 25 * 1024 * 1024
        log(f"Download complete: {path}")
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

    # get_installed_versions() returns EVERY installed program, so these checks
    # must require "PyCharm" too. A bare "Professional" match also hits things
    # like "Microsoft Office Professional Plus", which silently skipped install.
    if any("PyCharm" in name and "Professional" in name for name in installed):
        log("PyCharm Professional is installed. Skipping install.")
        return

    # Grab the installed build number if present. Do NOT match on "Community":
    # JetBrains now registers the free edition as plain "PyCharm 2025.3", so
    # that substring never matches and every run would reinstall from scratch.
    # Anything reaching here is not Professional - that returned above.
    community_ver = None
    for name, ver in installed.items():
        if "PyCharm" in name:
            community_ver = ver  # DisplayVersion is a build number, e.g. 253.28294.336
            log(f"PyCharm already installed: {name} (build {community_ver})")
            break

    marketing_ver, latest_build, download_url = get_latest_community_info()

    if community_ver == latest_build:
        log("Installed Community version is up to date. No action needed.")
        return

    action = "Updating" if community_ver else "Installing"
    log(f"{action} PyCharm Community to build {latest_build}...")

    installer_path = download_installer(download_url)
    write_config()

    log("Running the PyCharm installer silently - this takes a few minutes...")
    subprocess.run([installer_path] + INSTALL_FLAGS, check=True)
    log("PyCharm Community installation complete.")

    try:
        os.remove(installer_path)
        log("Removed the downloaded installer.")
    except OSError:
        pass

    
    


if __name__ == "__main__":
    try:
        main()
    except Exception:
        import traceback
        log("PyCharm setup FAILED:")
        for line in traceback.format_exc().rstrip().splitlines():
            log("  " + line)
        sys.exit(1)
