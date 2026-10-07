#!/usr/bin/env bash
# Kura Storage-Native Decoupled Inference Engine Bootstrap Installer
#
# Supported Usage:
#   curl -fsSL https://raw.githubusercontent.com/fraol163/kura-benchmarks/main/install.sh | bash
#   ./install.sh [--dir PATH] [--kura-home PATH] [--stage NAME] [--manifest] [--json] [--non-interactive] [--verbose]
#
# Stage Protocol:
#   --manifest            Print the stage list as JSON
#   --stage NAME [--json] Run one stage
#   --non-interactive     Skip interactive prompts
#   --verbose             Stream child command output directly
set -u

REPO_URL="${KURA_REPO_URL:-https://github.com/fraol163/kura-benchmarks.git}"
BRANCH="main"
KURA_HOME="${KURA_HOME:-$HOME/.kura}"
STAGE=""
WANT_MANIFEST=false
JSON=false
NON_INTERACTIVE=false
VERBOSE=false

while [ $# -gt 0 ]; do
    case "$1" in
        --dir|--kura-home|-KuraHome|--stage|-Stage)
            option="$1"
            if [ $# -lt 2 ] || [ -z "$2" ] || [[ "$2" == -* ]]; then
                printf '%s needs a value\n' "$option" >&2
                exit 2
            fi
            case "$option" in
                --dir|--kura-home|-KuraHome) KURA_HOME="$2" ;;
                --stage|-Stage) STAGE="$2" ;;
            esac
            shift 2 ;;
        --manifest|-Manifest) WANT_MANIFEST=true; shift ;;
        --json|-Json) JSON=true; shift ;;
        --non-interactive|-NonInteractive) NON_INTERACTIVE=true; shift ;;
        --verbose|-Verbose) VERBOSE=true; shift ;;
        -h|--help)
            echo "Usage: install.sh [--kura-home PATH]"
            echo "                  [--manifest] [--stage NAME] [--json]"
            echo "                  [--non-interactive] [--verbose]"
            echo
            echo "Kura storage-native engine automated bootstrap installer."
            exit 0 ;;
        *) echo "unknown option: $1" >&2; exit 1 ;;
    esac
done

export KURA_HOME
BIN_DIR="$KURA_HOME/bin"
LOG_DIR="$KURA_HOME/logs"
MODELS_DIR="$KURA_HOME/models"
INSTALL_LOG="$LOG_DIR/install.log"

# Color styling for terminals
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
    C_RED=$'\033[0;31m'
    C_GREEN=$'\033[0;32m'
    C_YELLOW=$'\033[0;33m'
    C_CYAN=$'\033[0;36m'
    C_BLUE=$'\033[38;5;75m'
    C_BOLD=$'\033[1m'
    C_DIM=$'\033[2m'
    C_NC=$'\033[0m'
else
    C_RED="" C_GREEN="" C_YELLOW="" C_CYAN="" C_BLUE="" C_BOLD="" C_DIM="" C_NC=""
fi

log() { printf '%s▸%s %s\n' "$C_BLUE" "$C_NC" "$1"; }
log_success() { printf '%s■%s %s\n' "$C_GREEN" "$C_NC" "$1"; }
log_warn() { printf '%s▫%s %s\n' "$C_YELLOW" "$C_NC" "$1"; }
log_error() { printf '%s✗%s %s\n' "$C_RED" "$C_NC" "$1" >&2; }
fail() { STAGE_REASON="$1"; log_error "$1"; exit 1; }

detect_latest_tag() {
    if [ -n "${KURA_VERSION:-}" ]; then
        local user_tag="$KURA_VERSION"
        [[ "$user_tag" == v* ]] || user_tag="v$user_tag"
        echo "$user_tag"
        return 0
    fi

    local tag=""
    # 1. Query GitHub releases/latest API endpoint
    tag="$(curl -fsSL -H "User-Agent: Kura-Installer" "https://api.github.com/repos/fraol163/kura-benchmarks/releases/latest" 2>/dev/null | grep -m1 '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' || true)"

    # 2. Fallback to GitHub releases API list
    if [ -z "$tag" ]; then
        tag="$(curl -fsSL -H "User-Agent: Kura-Installer" "https://api.github.com/repos/fraol163/kura-benchmarks/releases" 2>/dev/null | grep -m1 '"tag_name":' | sed -E 's/.*"tag_name": *"([^"]+)".*/\1/' || true)"
    fi

    # 3. Fallback to git remote tags
    if [ -z "$tag" ] && command -v git >/dev/null 2>&1; then
        tag="$(git -c 'versionsort.suffix=-' ls-remote --tags --sort='v:refname' https://github.com/fraol163/kura-benchmarks.git 2>/dev/null | grep -o 'refs/tags/v[0-9].*' | sed 's|refs/tags/||' | tail -n1 || true)"
    fi

    # 4. Safe baseline fallback
    if [ -z "$tag" ]; then
        tag="v1.0.0"
    fi
    echo "$tag"
}

print_banner() {
    local tag
    tag="$(detect_latest_tag)"
    printf '\n%s%s' "$C_CYAN" "$C_BOLD"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢺⣇⠀⠀⠀⠀⠀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣹⡇⠀⠀⠀⠀⠀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⠷⢶⣤⣄⣀⠀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣴⣤⡤⠀⠀⠀⠀⠀⢠⣤⣤⣦⣤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⠃⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢭⣿⣿⣿⡗⠀⠀⠀⣠⣾⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⢀⣾⣿⠇⠀⠀⠀⠀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡲⣿⣿⣿⡗⠀⣠⣾⣿⣿⡿⠋⠁⢸⣿⣿⠀⠀⠀⢘⣿⣿⠽⣿⣿⣰⣿⣿⣯⠀⠀⠀⣼⣿⣿⣶⣄⠀⠀⠀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣭⣿⣿⣿⣿⣾⣿⣿⣿⠋⠀⠀⠀⢸⣿⣿⠀⠀⠀⢘⡾⣕⢹⣪⢯⠋⠁⠀⠀⠀⠀⣼⣿⡿⠙⣿⣿⡆⠀⠀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠲⣿⣿⣿⣏⠙⢿⣿⣿⣷⣆⡀⠀⢸⣿⣿⣦⣄⣤⡾⣯⢗⢱⢽⣽⠀⠀⠀⠀⠀⣰⣿⣿⠁⠀⠸⣿⣿⡄⠀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣝⣿⣿⣿⣇⠀⠀⠙⢿⣿⣿⣷⣤⠀⠙⠻⠟⠟⠋⠘⠚⠛⠙⠛⠛⠀⠀⠀⠀⣰⣿⣿⣿⣾⣷⣷⣿⣿⣿⡀⠀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠶⣿⣿⣿⣇⠀⠀⠀⠀⠙⢿⣿⣿⣷⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⠏⠉⠁⠉⠉⠉⢻⣿⣿⡀"
    printf '%s\n' "  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠉⠉⠉⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠉⠉⠀⠀⠀⠀⠀⠀⠈⠉⠉⠁"
    printf '%s\n' "=================================================================================="
    printf '%s\n' "                   STORAGE-NATIVE DECOUPLED INFERENCE ENGINE"
    printf '%s\n' "               Production Release ${tag} : Zero-Telemetry Verified"
    printf '%s\n' "=================================================================================="
    printf '%s\n' "$C_NC"
}

quiet_output() {
    [ "$VERBOSE" = true ] && return 1
    if [ -n "${CI:-}" ] || [ -n "${GITHUB_ACTIONS:-}" ]; then
        return 1
    fi
    [ -t 1 ]
}

status_line() {
    local text="  $1" width=$(( $2 - 1 ))
    [ "${#text}" -le "$width" ] || text="${text:0:width}"
    printf '\r\033[K%s%s%s' "$C_DIM" "$text" "$C_NC"
}

run_logged() {
    local may_fail=false
    if [ "$1" = --may-fail ]; then may_fail=true; shift; fi
    local label="$1"; shift
    if ! quiet_output || ! { mkdir -p "${INSTALL_LOG%/*}" && : >> "$INSTALL_LOG"; } 2>/dev/null; then
        log "$label"
        "$@"
        return
    fi
    local start cols rc line shown
    start=$(( $(wc -l < "$INSTALL_LOG") + 1 ))
    cols="$(tput cols 2>/dev/null)" || cols=80
    [ "${cols:-0}" -gt 20 ] 2>/dev/null || cols=80
    printf '==> %s (%s)\n' "$label" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$INSTALL_LOG"
    status_line "$label" "$cols"
    "$@" </dev/null 2>&1 | {
        while IFS= read -r line || [ -n "$line" ]; do
            line="${line%$'\r'}"
            printf '%s\n' "$line" >&3
            shown="${line##*$'\r'}"
            [ -z "$shown" ] || status_line "$label: $shown" "$cols"
        done
    } 3>>"$INSTALL_LOG"
    rc=${PIPESTATUS[0]}
    printf '\r\033[K'
    if [ "$rc" -ne 0 ] && [ "$may_fail" = false ]; then
        log_error "$label failed (exit $rc). Last output:"
        tail -n +"$(( start + 1 ))" "$INSTALL_LOG" | tail -n 20 | sed 's/^/    /' >&2
        printf '    full log: %s\n' "$INSTALL_LOG" >&2
    fi
    return "$rc"
}

kura_bootstrap_target() {
    local _arch
    case "$(uname -m)" in
        arm64|aarch64) _arch="arm64" ;;
        x86_64|amd64)  _arch="x86_64" ;;
        *) return 1 ;;
    esac
    case "$(uname -s)" in
        Linux*)
            if [ "$_arch" = "arm64" ]; then
                echo "linux-aarch64"
            else
                echo "linux-x86_64"
            fi
            ;;
        Darwin*)
            echo "darwin-$_arch"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            echo "windows-x86_64"
            ;;
        *) return 1 ;;
    esac
}

kura_binary_url() {
    local target="$1"
    local tag="$2"
    case "$target" in
        linux-x86_64) echo "https://github.com/fraol163/kura-benchmarks/releases/download/${tag}/kura-linux-x86_64.tar.gz" ;;
        linux-aarch64|linux-arm64) echo "https://github.com/fraol163/kura-benchmarks/releases/download/${tag}/kura-linux-aarch64.tar.gz" ;;
        darwin-x86_64) echo "https://github.com/fraol163/kura-benchmarks/releases/download/${tag}/kura-darwin-x86_64.tar.gz" ;;
        darwin-arm64)  echo "https://github.com/fraol163/kura-benchmarks/releases/download/${tag}/kura-darwin-arm64.tar.gz" ;;
        windows-x86_64) echo "https://github.com/fraol163/kura-benchmarks/releases/download/${tag}/kura-windows-x86_64.zip" ;;
        *) return 1 ;;
    esac
}

check_platform() {
    case "$(uname -s 2>/dev/null)" in
        Linux*|Darwin*|CYGWIN*|MINGW*|MSYS*) : ;;
        *) fail "unsupported platform: $(uname -s). Kura supports Linux, macOS, and Windows." ;;
    esac
}

json_string() {
    local value="$1" code char escaped
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    for ((code = 1; code < 32; code++)); do
        printf -v char '\\%03o' "$code"
        printf -v char '%b' "$char"
        printf -v escaped '\\u%04x' "$code"
        value="${value//"$char"/$escaped}"
    done
    printf '"%s"' "$value"
}

json_frame() {
    if [ -n "${4:-}" ]; then
        printf '{"ok":%s,"stage":%s,"skipped":%s,"reason":%s}\n' "$1" "$(json_string "$2")" "$3" "$(json_string "$4")"
    else
        printf '{"ok":%s,"stage":%s,"skipped":%s}\n' "$1" "$(json_string "$2")" "$3"
    fi
}

stage_result() {
    local code="$1" ok=false reason="${STAGE_REASON:-}"
    if [ "$code" -eq 0 ]; then
        ok=true
    else
        reason="${reason:-stage failed (exit $code)}"
    fi
    if [ "$JSON" = true ]; then
        json_frame "$ok" "$STAGE" "${STAGE_SKIPPED:-false}" "$reason"
    fi
}

stage_names() {
    printf '%s\n' prerequisites probe binary config shell tui complete
}

stage_record() {
    case "$1" in
        prerequisites) echo "Check prerequisites|runtime|false" ;;
        probe)         echo "Probe hardware vector SIMD and storage|runtime|false" ;;
        binary)        echo "Acquire Kura engine binary|runtime|false" ;;
        config)        echo "Prepare runtime paths and models store|configuration|false" ;;
        shell)         echo "Configure user PATH environment|configuration|false" ;;
        tui)           echo "Launch interactive terminal user interface|interface|true" ;;
        complete)      echo "Finalize installation|runtime|false" ;;
    esac
}

emit_manifest() {
    printf '%s' '{"protocol_version":1,"stages":['
    local _sep=""
    for _s in $(stage_names); do
        IFS='|' read -r _title _category _needs <<< "$(stage_record "$_s")"
        printf '%s{"name":"%s","title":"%s","category":"%s","needs_user_input":%s}' \
            "$_sep" "$_s" "$_title" "$_category" "$_needs"
        _sep=","
    done
    printf '%s\n' ']}'
}

stage_prerequisites() {
    command -v curl >/dev/null 2>&1 || fail "curl is required to download binaries and dependencies."
    command -v tar >/dev/null 2>&1 || fail "tar is required to unpack release archives."
    log_success "Prerequisites validated (curl, tar)"
}

stage_probe() {
    log "Probing host vector execution features and storage substrate"
    local isa="Standard x86-64"
    if [ "$(uname -s)" = "Linux" ]; then
        if grep -q "avx512f" /proc/cpuinfo 2>/dev/null; then
            isa="AVX-512 FMA (High Throughput Vector SIMD)"
        elif grep -q "avx2" /proc/cpuinfo 2>/dev/null; then
            isa="AVX2 256-bit SIMD"
        fi
    elif [ "$(uname -s)" = "Darwin" ]; then
        if [ "$(uname -m)" = "arm64" ]; then
            isa="ARM NEON 128-bit (Apple Silicon Unified)"
        fi
    fi
    log_success "Vector SIMD Architecture: $isa"

    local storage="Block Storage"
    if [ "$(uname -s)" = "Linux" ]; then
        if lsblk -d -o NAME 2>/dev/null | grep -q "nvme"; then
            storage="Direct NVMe PCIe SSD"
        fi
    elif [ "$(uname -s)" = "Darwin" ]; then
        storage="APFS Internal High-Speed SSD"
    fi
    log_success "Storage Substrate: $storage"
}

stage_binary() {
    local target
    if ! target="$(kura_bootstrap_target)"; then
        fail "unsupported platform architecture: $(uname -s) $(uname -m)"
    fi

    local tag
    tag="$(detect_latest_tag)"
    log "Resolved target platform: $target | Detected latest release tag: $tag"

    mkdir -p "$BIN_DIR"
    local bin_dest="$BIN_DIR/kura"

    # Check if installed binary already matches target version
    if [ -x "$bin_dest" ]; then
        local installed_ver
        installed_ver="$("$bin_dest" --version 2>/dev/null | awk '{print $2}')"
        local target_clean_ver="${tag#v}"
        if [ -n "$installed_ver" ] && [ "$installed_ver" = "$target_clean_ver" ]; then
            log_success "Kura native binary already up to date ($bin_dest, version $installed_ver)"
            return 0
        fi
    fi

    # Download prebuilt release binary from GitHub Releases
    local url
    url="$(kura_binary_url "$target" "$tag")" || fail "no release binary URL mapped for $target"
    log "Downloading precompiled Kura binary for $target ($tag) from GitHub Releases"

    local tmp_dir
    tmp_dir="$(mktemp -d 2>/dev/null || echo "/tmp/kura-install.$$")"
    mkdir -p "$tmp_dir"

    local archive_name="kura.tar.gz"
    if [[ "$url" == *.zip ]]; then
        archive_name="kura.zip"
    fi

    if run_logged "Fetching $url" curl -LsSf "$url" -o "$tmp_dir/$archive_name"; then
        # Check integrity if SHA256SUMS.txt is available in the release
        local sha_url="https://github.com/fraol163/kura-benchmarks/releases/download/${tag}/SHA256SUMS.txt"
        if curl -fsSL -s "$sha_url" -o "$tmp_dir/SHA256SUMS.txt" 2>/dev/null; then
            local expected_hash
            local target_asset_name="${url##*/}"
            expected_hash="$(grep "$target_asset_name" "$tmp_dir/SHA256SUMS.txt" 2>/dev/null | awk '{print $1}')"
            if [ -n "$expected_hash" ]; then
                local computed_hash=""
                if command -v sha256sum >/dev/null 2>&1; then
                    computed_hash="$(sha256sum "$tmp_dir/$archive_name" | awk '{print $1}')"
                elif command -v shasum >/dev/null 2>&1; then
                    computed_hash="$(shasum -a 256 "$tmp_dir/$archive_name" | awk '{print $1}')"
                fi
                if [ -n "$computed_hash" ] && [ "$computed_hash" != "$expected_hash" ]; then
                    rm -rf "$tmp_dir"
                    fail "SHA-256 checksum mismatch for $target_asset_name (expected $expected_hash, got $computed_hash)"
                fi
                log_success "SHA-256 integrity verified ($computed_hash)"
            fi
        fi

        if [ "$archive_name" = "kura.zip" ]; then
            if command -v unzip >/dev/null 2>&1; then
                unzip -q -o "$tmp_dir/kura.zip" -d "$tmp_dir" || fail "failed to unpack kura archive"
            else
                tar -xf "$tmp_dir/kura.zip" -C "$tmp_dir" || fail "failed to unpack kura archive"
            fi
        else
            tar -xzf "$tmp_dir/$archive_name" -C "$tmp_dir" || fail "failed to unpack kura archive"
        fi
        local extracted
        extracted="$(find "$tmp_dir" -type f \( -name "kura" -o -name "kura.exe" -o -name "kura-*" \) ! -name "*.tar.gz" ! -name "*.zip" | head -n1)"
        if [ -n "$extracted" ]; then
            mv "$extracted" "$bin_dest"
            chmod 755 "$bin_dest"
            rm -rf "$tmp_dir"
            log_success "Kura native binary installed ($bin_dest)"
            return 0
        fi
    fi
    rm -rf "$tmp_dir"

    # Fallback: Check if cargo is present to compile on-host
    if command -v cargo >/dev/null 2>&1; then
        log_warn "Release asset not reachable; falling back to local compilation via cargo"
        cargo install --git "$REPO_URL" --bin kura --root "$KURA_HOME" || fail "cargo build failed"
        log_success "Kura compiled and installed via cargo ($bin_dest)"
        return 0
    fi

    fail "Could not acquire prebuilt binary and cargo is not available. Please install rustup or verify internet connectivity."
}

stage_config() {
    mkdir -p "$KURA_HOME" "$BIN_DIR" "$LOG_DIR" "$MODELS_DIR" "$KURA_HOME/cache"
    log_success "Kura directories prepared in $KURA_HOME"
}

append_shell_path() {
    local rc="$1" line="$2" pattern="$3"
    if [ -f "$rc" ] && grep -E "$pattern" "$rc" >/dev/null 2>&1; then
        return 0
    fi
    mkdir -p "$(dirname "$rc")"
    printf '\n# Kura Storage-Native Decoupled Engine\n%s\n' "$line" >> "$rc" || fail "cannot update PATH in $rc"
    log_success "Added $BIN_DIR and ~/.local/bin to PATH in $rc"
}

stage_shell() {
    # Symlink to ~/.local/bin if writable
    mkdir -p "$HOME/.local/bin"
    if [ -f "$BIN_DIR/kura" ]; then
        ln -sf "$BIN_DIR/kura" "$HOME/.local/bin/kura" 2>/dev/null || true
    fi

    local login_shell="${SHELL:-/bin/bash}"
    case "${login_shell##*/}" in
        zsh)
            append_shell_path "$HOME/.zshrc" "export PATH=\"$BIN_DIR:\$HOME/.local/bin:\$PATH\"" 'PATH=.*\.kura/bin'
            append_shell_path "$HOME/.zprofile" "export PATH=\"$BIN_DIR:\$HOME/.local/bin:\$PATH\"" 'PATH=.*\.kura/bin'
            ;;
        fish)
            append_shell_path "$HOME/.config/fish/config.fish" "fish_add_path \"$BIN_DIR\" \"$HOME/.local/bin\"" 'fish_add_path.*\.kura/bin'
            ;;
        *)
            append_shell_path "$HOME/.bashrc" "export PATH=\"$BIN_DIR:\$HOME/.local/bin:\$PATH\"" 'PATH=.*\.kura/bin'
            append_shell_path "$HOME/.profile" "export PATH=\"$BIN_DIR:\$HOME/.local/bin:\$PATH\"" 'PATH=.*\.kura/bin'
            if [ -f "$HOME/.bash_profile" ]; then
                append_shell_path "$HOME/.bash_profile" "export PATH=\"$BIN_DIR:\$HOME/.local/bin:\$PATH\"" 'PATH=.*\.kura/bin'
            fi
            ;;
    esac
}

has_terminal() { (: </dev/tty) 2>/dev/null; }

stage_tui() {
    if [ "$NON_INTERACTIVE" = true ]; then
        log "Interactive TUI launch skipped (--non-interactive)"
        return 0
    fi

    if ! has_terminal; then
        log "Interactive TUI launch skipped (no terminal attached)"
        return 0
    fi

    printf '\n%s  ▸ Press [Enter] to launch the Kura TUI now (or Ctrl+C to exit): %s' "$C_CYAN" "$C_NC"
    read -r _dummy </dev/tty || true
    "$BIN_DIR/kura" tui </dev/tty || true
}

stage_complete() {
    log_success "Kura Engine bootstrap completed successfully."
    printf '\n%s' "$C_BOLD"
    echo "Quick Commands:"
    echo "  kura tui                        Launch interactive terminal UI"
    echo "  kura run <model.gguf>           Execute text generation"
    echo "  kura serve --port 8080          Start OpenAI-compatible HTTP server"
    echo "  kura update check               Query genuine update availability"
    echo "  kura profile                    Inspect CPU SIMD and NVMe storage bandwidth"
    echo "  kura plan --model <model.gguf>  Compile LOOM physical execution plan"
    printf '%s\n' "$C_NC"
}

print_path_reload_hint() {
    case ":$PATH:" in *":$BIN_DIR:"*|*":$HOME/.local/bin:"*) return 0 ;; esac
    local rc
    local login_shell="${SHELL:-}"
    case "${login_shell##*/}" in
        zsh) rc="source ~/.zshrc" ;;
        fish) rc="source ~/.config/fish/config.fish" ;;
        bash|"") rc="source ~/.bashrc" ;;
        *) rc=". ~/.profile" ;;
    esac
    log "Reload your shell to run 'kura' directly: open a new terminal, or run: $rc"
}

run_stage() (
    set -e
    STAGE="$1"
    STAGE_REASON=""
    STAGE_SKIPPED=false
    trap 'stage_result "$?"' EXIT
    if [ "$NON_INTERACTIVE" = true ] && [ "$STAGE" = tui ]; then
        STAGE_SKIPPED=true
        STAGE_REASON="needs user input"
        exit 0
    fi
    case "$1" in
        prerequisites) stage_prerequisites ;;
        probe)         stage_probe ;;
        binary)        stage_binary ;;
        config)        stage_config ;;
        shell)         stage_shell ;;
        tui)           stage_tui ;;
        complete)      stage_complete ;;
        *) STAGE_REASON="unknown stage: $1"; printf '%s\n' "$STAGE_REASON" >&2; exit 2 ;;
    esac
)

if [ "${BASH_SOURCE[0]:-$0}" = "$0" ]; then
    if [ "$WANT_MANIFEST" = true ]; then
        emit_manifest
        exit 0
    fi

    if [ -n "$STAGE" ] && [ "$JSON" = true ]; then
        trap 'stage_result "$?"' EXIT
    fi
    check_platform
    trap - EXIT

    if [ -n "$STAGE" ]; then
        run_stage "$STAGE"
        exit "$?"
    fi

    print_banner
    for s in $(stage_names); do
        run_stage "$s"
        rc=$?
        [ "$rc" -eq 0 ] || exit "$rc"
    done
    print_path_reload_hint
fi
