# jknexus-basejka

Hardened Jedi Academy Linux Dedicated Server (`linuxjampded`) with security patches applied to the 1.0.1.0 source code.

This repository contains the full source code for **Jedi Academy Multiplayer (codemp)** with **16 critical security vulnerabilities patched**, plus automated GitHub Actions builds that compile a 32-bit `linuxjampded` binary and `jampgamei386.so` game library.

---

## Security Fixes Applied

The following vulnerabilities have been identified and patched in the source code:

### Critical — Remote Exploits

| # | Vulnerability | File(s) | Fix |
|---|--------------|---------|-----|
| 1 | **Vote newline/command injection** | `game/g_cmds.c` | Block `\n`, `\r` in addition to `;` in `callvote` and `callteamvote` arguments |
| 2 | **RCON amplification/reflection (DDoS)** | `server/sv_main.cpp` | Drop invalid RCON packets without sending any response |
| 3 | **RCON global rate-limit DoS** | `server/sv_main.cpp` | Replaced global 500ms limit with per-IP rate limiter (16 slots) |
| 4 | **RCON stack buffer overflow** | `server/sv_main.cpp` | Replaced unbounded `strcat` with `Q_strcat` in `remaining[1024]` |
| 5 | **Client name command injection** | `server/sv_client.cpp`, `game/g_client.c` | Sanitize quotes `"`, semicolons `;`, newlines `\n`, `\r`, backslashes `\` from player names |
| 6 | **Server console say overflow** | `server/sv_ccmds.cpp` | Replaced `strcpy`/`strcat` with `Q_strncpyz`/`Q_strcat` |
| 7 | **Authorize response stack overflow** | `server/sv_client.cpp` | Replaced `sprintf` with `Com_sprintf` with bounds checking |
| 8 | **Info string off-by-one overflow** | `game/q_shared.c` | Fixed `>` vs `>=` comparison for `MAX_INFO_STRING`/`BIG_INFO_STRING` bounds |

### High — Buffer Overflows / Corruption

| # | Vulnerability | File(s) | Fix |
|---|--------------|---------|-----|
| 9 | **SVC_Status stack overflow** | `server/sv_main.cpp` | Fixed bounds check and replaced `strcpy` with `memcpy` |
| 10 | **SV_SendServerCommand overflow** | `server/sv_main.cpp` | Replaced `vsprintf` with `Q_vsnprintf` |
| 11 | **Cmd_Args / Cmd_ArgsFrom overflow** | `qcommon/cmd_common.cpp` | Replaced `strcat` with `Q_strcat` with bounds |
| 12 | **Info_RemoveKey overlapping copy** | `game/q_shared.c` | Replaced `strcpy` with `memmove` (both `Info_RemoveKey` and `Info_RemoveKey_Big`) |
| 13 | **BotImport_Print overflow** | `server/sv_bot.cpp` | Replaced `vsprintf` with `Q_vsnprintf` |

### Medium — Logic / Format String Bugs

| # | Vulnerability | File(s) | Fix |
|---|--------------|---------|-----|
| 14 | **Format string via localized assets** | `server/sv_client.cpp` | Wrapped `Com_Printf(SE_GetString(...), ...)` with `Com_Printf("%s", va(...))` |
| 15 | **Hostname unsafe copy** | `server/sv_main.cpp` | Replaced `strcpy` with `Q_strncpyz` |
| 16 | **Master server strstr bug** | `server/sv_main.cpp` | Fixed reversed arguments: `strstr(":", addr)` → `strstr(addr, ":")` |

---

## Building Locally

### Requirements

- Linux (x86 or x86_64 with multilib)
- `gcc` / `g++`
- `gcc-multilib` and `g++-multilib` (for 32-bit builds on 64-bit systems)
- `nasm`
- `make`

### Build Steps

```bash
# Install dependencies (Debian/Ubuntu)
sudo apt-get update
sudo apt-get install -y build-essential gcc-multilib g++-multilib libc6-dev-i386 nasm

# Clone repository
git clone https://github.com/akiondev/jknexus-basejka.git
cd jknexus-basejka

# The original Makefile uses Intel compiler flags that are not available
# with modern GCC. A patched version is used automatically in CI.
# For local builds, patch the Makefile:
cd jediacademy-master/codemp
sed -i 's/-Kc++//g; s/-use_msasm//g; s/-unroll//g; s|-I/opt/intel/compiler50/ia32/include||g' unix/makefile

# Build release binaries (32-bit)
make -f unix/makefile release CC="gcc -m32" CXX="g++ -m32" ARCH=i386

# Output files:
#   run/releasei386/linuxjampded
#   run/releasei386/baseq3/jampgamei386.so
```

---

## Running the Server

```bash
cd jediacademy-master/run/releasei386

# Basic startup
./linuxjampded +set fs_game base +set net_port 29070 +exec server.cfg

# With specific map
./linuxjampded +set fs_game base +set net_port 29070 +map mp/ffa1

# Make sure jampgamei386.so is in the same directory or in base/
```

---

## GitHub Actions Automated Builds

This repository includes a GitHub Actions workflow (`.github/workflows/build-linuxjampded.yml`) that:

1. Installs all required build dependencies on `ubuntu-latest`
2. Patches the Makefile to work with modern GCC
3. Compiles both `linuxjampded` and `jampgamei386.so` as 32-bit binaries
4. Uploads build artifacts
5. **Creates a GitHub Release** automatically when a tag is pushed (e.g. `v1.0.1`)

### Trigger a Release

```bash
# Tag and push to create a release
git tag v1.0.1
git push origin v1.0.1
```

The workflow will compile the binaries and attach them to a new GitHub Release.

---

## Project Structure

```
jknexus-basejka/
├── jediacademy-master/         # Full Jedi Academy MP source code
│   ├── codemp/
│   │   ├── game/              # Game DLL source (g_cmds.c, g_client.c, q_shared.c, etc.)
│   │   ├── server/            # Dedicated server source (sv_main.cpp, sv_client.cpp, etc.)
│   │   ├── qcommon/           # Common code (cmd_common.cpp, etc.)
│   │   └── unix/              # Linux build files (makefile, nasm files)
│   └── ...
├── docker/                     # Docker image files
├── egg/                        # Pterodactyl egg configuration
└── .github/workflows/          # GitHub Actions CI/CD
```

---

## License

This source code is released under the terms of the original Jedi Academy SDK license by Raven Software / Activision. See `jediacademy-master/LICENSE.txt` for full details.

The security patches in this repository are provided as-is for the community to build safer dedicated servers.
