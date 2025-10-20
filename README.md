# DevContainerTool

A modular development container system for building, testing, and deploying C++ and Python projects under **Ubuntu 22.04 (Jammy)** and **Ubuntu 20.04 (Dunfell)** environments.  
It automates image creation, container execution, dependency management, testing, coverage analysis, and deployment—supporting both **AMD64** and **ARMv8** workflows.

---

## 🔧 Overview

DevContainerTool standardizes your build workflow through Dockerized environments that include:

- Preinstalled **C++/Python toolchains**, `cmake`, `conan`, `gtest`, `gcov/llvm-cov`, and editors (`vim`, `nvim`).
- Host integration: `~/.ssh` and `~/.gitconfig` automatically mapped for private repo access.
- Seamless build and coverage pipelines—results viewable from your host browser.
- Configurable build targets (AMD64, ARMv8 with Yocto SDK).
- Conan-powered dependency management.
- Support for **cross-compiling and remote testing** on physical ARM boards.
- Optional integration with **[cpp-dev.vim](https://github.com/bedebruyn/cpp-dev.vim)** for fully automated build/test/deploy loops.

---

## 🚀 Quick Start

```bash
# 1. Install host-side symlinks (adds all tools to /usr/local/bin)
install-dev-tools.sh

# 2. Build the x86_64 image (Ubuntu 22.04)
build-jammy-x86_64-img.sh

# 3. Or build the ArmV8 Dunfell image (Ubuntu 20.04 + Yocto SDK)
build-armv8-dunfell-img.sh

# 4. Start a dev container for your project
run-img -f <name>.yaml
```

You’ll enter an interactive shell in `/repo` (mounted from your host).  
Build, test, and generate coverage as usual—outputs remain in your host workspace.

---

## 📦 Installation

Running `install-dev-tools.sh`:

1. Executes `uninstall.sh` to remove any stale symlinks in `/usr/local/bin`.
2. Runs `install.sh` to link all utility scripts (`run-img`, `build-*`, etc.) from the repo into `/usr/local/bin`.

No binaries are installed system-wide—just symbolic links for convenience.  
Docker must already be installed on the host.

---

## 🧰 Usage

### Run a Dev Container

```bash
run-img -f <name>.yaml
```

What happens:

- Creates a container (if missing) from the specified image.
- Mounts the **current working directory** into `/repo`.
- Maps host SSH/Git config for private repo access.
- Passes environment variables (`BRANCH_DEV`, `BRANCH_INT`, `CONAN_PROFILE`).
- Enables host networking and privileged access for development.

Re-running `run-img` launches additional terminals into the same container.

### View Coverage Results

All `gcov`/`llvm-cov` HTML files generated inside the container appear in your mounted project directory.  
You can open `coverage/index.html` directly in your host browser—no GUI needed inside the container.

### Conan + CMake Workflow

Conan manages dependencies and compiler configurations:

```bash
conan install . --build=missing -pr <profile>
cmake -B build -S .
cmake --build build -j
ctest --test-dir build
```

Helper `.cmake` functions simplify adding source and header files to static/dynamic targets.

### gtest Harness

Included test runners allow execution of:

- A single fixture,
- All fixtures in one file,
- Or all compiled tests.

Coverage tools (gcov/llvm-cov) integrate seamlessly with these workflows.

---

## 🧩 ARMv8 / Yocto Dunfell Workflow

The **ARMV8** variant uses **Ubuntu 20.04 (Dunfell)** and leverages the **NXP Yocto SDK** installed under `/opt`.

### Build the Image

```bash
build-armv8-dunfell-img.sh
```

- Uses the same `RunConfig.sh` framework as Jammy.
- Mounts the Yocto SDK into `/opt` within the container (generic setup, external SDK required).
- Configures the Conan profile to use Yocto’s cross-compilers (`aarch64-linux-gnu-*`).
- Ensures identical workflow across architectures.

### Cross-Compile & Remote Testing

When connected to an ARM target via Ethernet:

1. The container uses an **environment variable** (set by the user) containing the board’s IP.
2. A helper script (integrated through the [cpp-dev.vim](https://github.com/bedebruyn/cpp-dev.vim) plugin) automates:
   - Copying the compiled binaries to the target.
   - Executing them remotely via SSH.
   - Capturing test logs and coverage results.
   - Copying results (including **coverage HTML**) back to the host-mounted project directory.

You can open these coverage reports on the host browser, just as you do for x86 builds.

---

## ⚙️ Configuration (YAML)

### Example (`<name>.yaml`)

```yaml
integration: main
branch:      MyFeatureBranch
root:        AppRepoName
container:   MyFeatureBranch
profile:     install-gcov.sh
image:       jammy-x86_64
```

Each field’s role:

| Field | Description |
|-------|-------------|
| `integration` | Integration branch where feature merges back |
| `branch` | Active development branch |
| `root` | Top-level directory of the GitHub repo |
| `container` | Container name for this session |
| `profile` | Conan configuration or setup script |
| `image` | Docker image tag to use |

Invoke with:

```bash
run-img -f <name>.yaml
```

---

## 🧱 File Reference

| File | Role |
|------|------|
| **install-dev-tools.sh** | Host installer: removes and reinstalls tool symlinks in `/usr/local/bin` |
| **install.sh** | Creates symlinks from repo tools to `/usr/local/bin` |
| **uninstall.sh** | Removes existing DevContainerTool symlinks |
| **build-jammy-x86_64-img.sh** | Builds Ubuntu 22.04 x86_64 image from Dockerfile |
| **build-armv8-dunfell-img.sh** | Builds Ubuntu 20.04 (Yocto Dunfell) image for ARMV8 toolchain |
| **RunConfig.sh** | Common driver: parses YAML, symlinks correct Dockerfile, runs `docker build` with args |
| **run-img** | Core runtime script: reads YAML, creates/starts container, mounts volumes, passes SSH & Git configs |
| **Dockerfile** | Defines Jammy developer environment: compilers, cmake, vim/nvim, conan, gtest, gcov |
| **<name>.yaml** | Example YAML defining branches, container/image names, and conan profile |

---

## 🌐 Integration with cpp-dev.vim

**cpp-dev.vim** (Vim/Neovim plugin) automates DevContainerTool workflows directly from your editor:  

- Cross-compiles C++ targets inside the container.  
- Transfers binaries to a remote ARM target via SSH.  
- Executes unit tests and retrieves results automatically.  
- Copies **coverage HTML output** back to the host-mounted workspace for viewing.  

This integration provides a seamless “build → deploy → test → coverage” loop from within Vim/Neovim.

---

## 🧩 Under the Hood

DevContainerTool uses modular Bash scripts that cooperate through YAML-driven orchestration:

1. `install-dev-tools.sh` calls `uninstall.sh` → `install.sh`.
2. `build-jammy-x86_64-img.sh` and `build-armv8-dunfell-img.sh` both call `RunConfig.sh`.
3. `RunConfig.sh` reads YAML, selects Dockerfile, and builds image with UID/GID mapping.
4. `run-img` creates containers, mounts host workspace, injects SSH/Git credentials, and launches an interactive shell.
5. Coverage and test results remain on the host due to the volume mount model.

---

## 📋 Prerequisites

- Docker installed and configured for non-root execution.  
- Host has `~/.gitconfig` and `~/.ssh/id_rsa` (for private repo access).  
- Basic familiarity with `docker`, `conan`, and `cmake` is assumed.  

---

## 🧪 Example Workflow Summary

| Step | Command | Description |
|------|----------|-------------|
| 1 | `install-dev-tools.sh` | Install symlinks |
| 2 | `build-jammy-x86_64-img.sh` | Build image for host architecture |
| 3 | `run-img -f <name>.yaml` | Start container for project |
| 4 | `conan install` + `cmake` | Configure & build |
| 5 | `ctest` | Run tests |
| 6 | `gcovr --html-details` | Generate coverage |
| 7 | `open coverage/index.html` | View coverage in host browser |

---

## 🧑‍💻 Contributing

Pull requests are welcome. Keep scripts POSIX-compliant where practical and maintain consistency across x86 and ARM workflows.  

---

## 🪪 License

MIT License (or organization-specific equivalent).
