import sys
import os
import winreg

def check_pycharm():
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
                        try:
                            sub = winreg.EnumKey(key, i)
                            with winreg.OpenKey(key, sub) as sk:
                                name, _ = winreg.QueryValueEx(sk, "DisplayName")
                                if "PyCharm" in name:
                                    version, _ = winreg.QueryValueEx(sk, "DisplayVersion")
                                    editions[name] = version
                        except (FileNotFoundError, OSError):
                            continue
            except FileNotFoundError:
                continue

    return editions


if __name__ == "__main__":
    print("✅ Python is working! Welcome to Heights Programming.")
    print(f"🐍 Python version: {sys.version.split()[0]}")

    pycharms = check_pycharm()
    if pycharms:
        print("🧠 PyCharm installations detected:")
        for name, version in pycharms.items():
            print(f"   - {name}: {version}")
    else:
        print("⚠️  No PyCharm installation found.")
