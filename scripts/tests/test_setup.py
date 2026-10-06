"""Offline setup tests: package managers and remote installers are mocked."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO = Path(__file__).resolve().parents[2]
SCRIPT = REPO / "scripts/setup.sh"
LIBRARY = SCRIPT.read_text().rsplit('\nparse_args "$@"', 1)[0]


class SetupTests(unittest.TestCase):
    def setUp(self):
        temporary_root = "/tmp/opencode" if Path("/tmp/opencode").is_dir() else None
        self.temp = tempfile.TemporaryDirectory(prefix="setup-test-", dir=temporary_root)
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.home = self.root / "home with spaces"
        self.home.mkdir()
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.log = self.root / "calls"
        self.log.write_text("")
        self.env = {
            "HOME": str(self.home),
            "PATH": str(self.bin),
            "SHELL": "/bin/bash",
            "TEST_LOG": str(self.log),
            "TMPDIR": str(self.root),
        }
        # Only expose basic utilities, never real package managers/downloaders.
        for command in ("dirname", "mkdir", "rm", "mktemp", "ln", "readlink", "mv", "cp", "cat", "tar", "gzip", "sh", "bash"):
            executable = shutil.which(command)
            if executable:
                (self.bin / command).symlink_to(executable)
        self.mock("uname", 'if [ "$1" = "-m" ]; then echo x86_64; else echo Linux; fi')
        self.mock("sudo", 'exec "$@"')

    def mock(self, name, body='exit 0'):
        path = self.bin / name
        if path.is_symlink():
            path.unlink()
        path.write_text('#!/bin/bash\n' + body + '\n')
        path.chmod(0o755)

    def run_functions(self, body, expected=0):
        result = subprocess.run(
            ["/bin/bash"], input=LIBRARY + "\n" + body,
            env=self.env, cwd=self.root, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return result

    def installed_tools(self):
        for tool in ("git", "stow", "curl", "unzip", "zsh", "tmux", "vim", "ssh", "rg", "fd", "cc", "make", "python3", "rustc", "cargo", "fzf", "fnm", "node", "zoxide"):
            self.mock(tool)
        self.mock("nvim", 'echo "NVIM v0.11.0"')
        zinit = self.home / ".local/share/zinit/zinit.git"
        zinit.mkdir(parents=True)
        (zinit / "zinit.zsh").write_text("")

    def test_ubuntu_debian_packages(self):
        self.mock("apt-get", 'printf "apt-get %s\\n" "$*" >> "$TEST_LOG"')
        self.run_functions("install_system_dependencies")
        calls = self.log.read_text().splitlines()
        self.assertEqual(calls[0], "apt-get update")
        self.assertTrue(calls[1].startswith("apt-get install -y "))
        self.assertIn("fd-find", calls[1])
        self.assertEqual(calls[1].split().count("build-essential"), 1)
        self.assertNotIn("rustc", calls[1])
        self.assertNotIn("cargo", calls[1])

    def test_arch_packages_do_not_upgrade_or_refresh_database(self):
        self.mock("pacman", 'printf "pacman %s\\n" "$*" >> "$TEST_LOG"')
        self.run_functions("install_system_dependencies")
        calls = self.log.read_text().splitlines()
        self.assertEqual(len(calls), 1)
        self.assertTrue(calls[0].startswith("pacman -S --needed --noconfirm "))
        self.assertIn("fd", calls[0].split())
        self.assertEqual(calls[0].split().count("base-devel"), 1)

    def test_fedora_and_homebrew_package_names(self):
        self.mock("dnf", 'printf "dnf %s\\n" "$*" >> "$TEST_LOG"')
        self.run_functions("install_system_dependencies")
        self.assertIn("vim-enhanced", self.log.read_text())
        self.mock("brew", 'printf "brew %s\\n" "$*" >> "$TEST_LOG"')
        (self.bin / "tar").unlink()
        self.run_functions('OS=Darwin; install_system_dependencies')
        self.assertIn("brew install", self.log.read_text())
        self.assertIn("gnu-tar", self.log.read_text())

    def test_existing_tools_skip_package_and_user_installers(self):
        self.installed_tools()
        self.mock("apt-get", 'echo unexpected >> "$TEST_LOG"; exit 99')
        self.mock("curl", 'echo unexpected >> "$TEST_LOG"; exit 99')
        self.run_functions("install_system_dependencies; install_user_dependencies")
        self.assertEqual(self.log.read_text(), "")

    def test_rust_uses_official_curl_installer(self):
        self.installed_tools()
        (self.bin / "rustc").unlink()
        (self.bin / "cargo").unlink()
        self.mock("curl", '''
printf 'curl %s\\n' "$*" >> "$TEST_LOG"
while [ "$#" -gt 0 ]; do
  if [ "$1" = "-o" ]; then
    printf '#!/bin/sh\\nprintf "rustup %%s\\\\n" "$*" >> "$TEST_LOG"\\n' > "$2"
    exit 0
  fi
  shift
done
exit 99''')
        self.run_functions("install_user_dependencies")
        calls = self.log.read_text()
        self.assertIn("https://sh.rustup.rs", calls)
        self.assertIn("--proto =https --tlsv1.2", calls)
        self.assertIn("rustup -y --profile minimal --default-toolchain stable --no-modify-path", calls)
        self.assertEqual(list(self.root.glob("dotfiles-setup.*")), [])

    def test_download_failure_does_not_execute_installer(self):
        self.mock("curl", 'exit 22')
        self.run_functions("run_installer https://sh.rustup.rs sh -y", expected=22)
        self.assertEqual(list(self.root.glob("dotfiles-setup.*")), [])

    def test_fnm_and_node_installation(self):
        self.installed_tools()
        (self.bin / "fnm").unlink()
        (self.bin / "node").unlink()
        fnm = self.root / "mock-fnm"
        fnm.write_text('#!/bin/bash\nif [ "$1" = exec ]; then exit 1; fi\nprintf "fnm %s\\n" "$*" >> "$TEST_LOG"\n')
        fnm.chmod(0o755)
        self.env["TEST_FNM"] = str(fnm)
        self.run_functions('''
export PATH="$BIN_DIR:$FNM_DIR:$PATH"
run_installer() {
  printf 'installer %s\\n' "$*" >> "$TEST_LOG"
  mkdir -p "$FNM_DIR"
  cp "$TEST_FNM" "$FNM_DIR/fnm"
}
install_user_dependencies''')
        calls = self.log.read_text()
        self.assertIn("https://fnm.vercel.app/install bash --install-dir", calls)
        self.assertIn("--skip-shell --force-no-brew", calls)
        self.assertIn("fnm install --lts", calls)
        self.assertIn("fnm default lts-latest", calls)

    def test_fnm_managed_node_prevents_reinstall(self):
        self.installed_tools()
        (self.bin / "node").unlink()
        self.mock("fnm", 'if [ "$1" = exec ]; then exit 0; fi; echo unexpected >> "$TEST_LOG"; exit 99')
        self.run_functions("install_user_dependencies")
        self.assertEqual(self.log.read_text(), "")

    def test_neovim_version_requirement(self):
        for version, expected in (("0.10.4", 1), ("0.11.0", 0), ("0.12.1", 0), ("1.0.0", 0)):
            with self.subTest(version=version):
                self.mock("nvim", f'echo "NVIM v{version}"')
                self.run_functions("has_modern_nvim", expected=expected)

    def test_neovim_stable_archive_and_repeat_install(self):
        archive_root = self.root / "nvim-linux-x86_64"
        (archive_root / "bin").mkdir(parents=True)
        executable = archive_root / "bin/nvim"
        executable.write_text('#!/bin/bash\necho "NVIM v0.11.0"\n')
        executable.chmod(0o755)
        archive = self.root / "nvim.tar.gz"
        subprocess.run([shutil.which("tar"), "-czf", str(archive), "-C", str(self.root), archive_root.name], check=True)
        self.env["TEST_ARCHIVE"] = str(archive)
        self.mock("curl", '''
printf 'curl %s\\n' "$*" >> "$TEST_LOG"
while [ "$1" != "-o" ]; do shift; done
cp "$TEST_ARCHIVE" "$2"''')
        self.run_functions('export PATH="$BIN_DIR:$PATH"; install_neovim; install_neovim')
        self.assertTrue((self.home / ".local/bin/nvim").is_symlink())
        calls = self.log.read_text().splitlines()
        self.assertEqual(len(calls), 1)
        self.assertIn("/releases/download/stable/nvim-linux-x86_64.tar.gz", calls[0])

    def test_fzf_installer_does_not_modify_shell_files(self):
        self.installed_tools()
        self.mock("fzf", "exit 1")  # Simulate an old distro version.
        self.mock("git", '''
printf 'git %s\\n' "$*" >> "$TEST_LOG"
for destination; do :; done
mkdir -p "$destination/.git"
cp "$TEST_INSTALLER" "$destination/install"''')
        installer = self.root / "fzf-installer"
        installer.write_text('''#!/bin/bash
printf 'fzf-installer %s\\n' "$*" >> "$TEST_LOG"
mkdir -p "$(dirname "$0")/bin"
cp "$TEST_FZF" "$(dirname "$0")/bin/fzf"
''')
        fzf = self.root / "mock-fzf"
        fzf.write_text('#!/bin/bash\nexit 0\n')
        fzf.chmod(0o755)
        self.env.update(TEST_INSTALLER=str(installer), TEST_FZF=str(fzf))
        self.run_functions('export PATH="$BIN_DIR:$PATH"; install_user_dependencies; install_user_dependencies')
        self.assertTrue((self.home / ".local/bin/fzf").is_symlink())
        self.assertIn("fzf-installer --bin", self.log.read_text())
        self.assertEqual(self.log.read_text().count("fzf-installer"), 1)
        self.assertFalse((self.home / ".zshrc").exists())
        self.assertFalse((self.home / ".bashrc").exists())

    def test_fdfind_alias_and_no_binary_overwrites(self):
        self.installed_tools()
        (self.bin / "fd").unlink()
        self.mock("fdfind")
        self.run_functions("install_user_dependencies")
        fd = self.home / ".local/bin/fd"
        self.assertTrue(fd.is_symlink())
        self.assertEqual(fd.resolve(), self.bin / "fdfind")
        self.run_functions("install_user_dependencies")
        fd.unlink()
        fd.write_text("existing fd\n")
        self.run_functions('link_binary /another/fd fd', expected=1)
        self.assertEqual(fd.read_text(), "existing fd\n")

    def test_full_dry_run_changes_nothing(self):
        self.mock("apt-get", 'echo unexpected >> "$TEST_LOG"; exit 99')
        self.mock("curl", 'echo unexpected >> "$TEST_LOG"; exit 99')
        result = subprocess.run(["/bin/bash", str(SCRIPT), "--dry-run"],
                                env=self.env, cwd=self.root, text=True, capture_output=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("Would install system packages with apt-get", result.stdout)
        self.assertIn("Would install Rust", result.stdout)
        self.assertIn("Would install fzf", result.stdout)
        self.assertIn("Would install fnm", result.stdout)
        self.assertIn("Would install current stable Neovim", result.stdout)
        self.assertEqual(self.log.read_text(), "")
        self.assertEqual(list(self.home.iterdir()), [])

    def test_help_and_missing_directory_value(self):
        for args, expected in ((["--help"], 0), (["--install-dir"], 1), (["--unknown"], 1)):
            result = subprocess.run(["/bin/bash", str(SCRIPT), *args],
                                    env=self.env, cwd=self.root, text=True, capture_output=True)
            self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_skip_dependencies_and_stow_conflicts(self):
        stow = shutil.which("stow")
        if not stow:
            self.skipTest("GNU Stow is needed for the symlink integration test")
        (self.bin / "stow").symlink_to(stow)
        self.mock("git", 'echo unexpected >> "$TEST_LOG"; exit 99')
        self.mock("curl", 'echo unexpected >> "$TEST_LOG"; exit 99')
        checkout = self.root / "checkout with spaces"
        (checkout / "scripts").mkdir(parents=True)
        (checkout / ".config/test-app").mkdir(parents=True)
        (checkout / ".git").mkdir()
        shutil.copy2(SCRIPT, checkout / "scripts/setup.sh")
        (checkout / ".bashrc").write_text("repo configuration\n")
        (checkout / ".config/test-app/settings").write_text("settings\n")
        (checkout / "README.md").write_text("metadata\n")
        (checkout / "LICENSE.md").write_text("metadata\n")
        target = self.home / ".bashrc"
        target.write_text("existing configuration\n")
        command = ["/bin/bash", str(checkout / "scripts/setup.sh"), "--skip-dependencies", "--skip-shell"]
        result = subprocess.run(command, env=self.env, cwd=self.root, text=True, capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(target.read_text(), "existing configuration\n")
        self.assertEqual(list(self.home.iterdir()), [target])
        self.assertEqual((checkout / ".bashrc").read_text(), "repo configuration\n")
        target.rename(self.home / ".bashrc.backup")
        for _ in range(2):
            result = subprocess.run(command, env=self.env, cwd=self.root, text=True, capture_output=True)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(target.resolve(), checkout / ".bashrc")
        for name in ("scripts", "README.md", "LICENSE.md", ".git"):
            self.assertFalse((self.home / name).exists())
        self.assertEqual(self.log.read_text(), "")

    def test_zsh_startup_without_optional_tools(self):
        zsh = shutil.which("zsh")
        if not zsh:
            self.skipTest("Zsh is needed for the shell startup test")
        # Prevent plugin downloads and completion-cache writes in this test.
        zinit = self.home / ".local/share/zinit/zinit.git"
        zinit.mkdir(parents=True)
        (zinit / "zinit.zsh").write_text("function zinit() { :; }\n")
        self.env["TEST_ZSHRC"] = str(REPO / ".zshrc")
        result = subprocess.run(
            [zsh, "-f", "-c", 'function autoload() { :; }; function compinit() { :; }; source "$TEST_ZSHRC"'],
            env=self.env, cwd=self.root, text=True, capture_output=True,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, "")


if __name__ == "__main__":
    unittest.main()
