#!/usr/bin/env bash
# Interactive Chrome profile setup for ~/.profile
#
# Detects the Chrome profiles that actually exist on this machine and, for each
# of CHROME_PROFILE_WORK / CHROME_PROFILE_PERSONAL / CHROME_PROFILE_DEFAULT that
# is not already defined, prompts which profile to map to it. Choices are
# appended to ~/.profile. Already-set values and a non-interactive stdin are
# both respected (the latter falls back to warnings, never blocks).

set -u

PROFILE_FILE="$HOME/.profile"

# --- Locate the Chrome user-data directory across OSes ----------------------
if [ -d "$HOME/Library/Application Support/Google/Chrome" ]; then
    CHROME_DIR="$HOME/Library/Application Support/Google/Chrome"
elif [ -d "$HOME/.config/google-chrome" ]; then
    CHROME_DIR="$HOME/.config/google-chrome"
elif [ -n "${LOCALAPPDATA:-}" ] && [ -d "$LOCALAPPDATA/Google/Chrome/User Data" ]; then
    CHROME_DIR="$LOCALAPPDATA/Google/Chrome/User Data"
else
    CHROME_DIR=""
fi

echo "Checking Chrome profile environment variables..."

# --- Ensure ~/.profile exists so we have somewhere to write -----------------
if [ ! -f "$PROFILE_FILE" ]; then
    echo "Creating $PROFILE_FILE for machine-specific settings..."
    {
        echo "# Machine-specific settings - not managed by git"
        echo "# Add your machine-specific environment variables and settings here"
        echo ""
    } > "$PROFILE_FILE"
fi

# Load any values already defined in ~/.profile so we don't re-prompt for them.
# shellcheck disable=SC1090
. "$PROFILE_FILE" 2>/dev/null || true

if [ -z "$CHROME_DIR" ]; then
    echo "No Chrome profiles found in standard locations. Skipping interactive setup."
    exit 0
fi

# --- Collect available profile directories (Default, Profile 1, ...) --------
profiles=()
while IFS= read -r p; do
    [ -n "$p" ] && profiles+=("$p")
done < <(ls -1 "$CHROME_DIR" 2>/dev/null | grep -E '^(Default|Profile [0-9]+)$' | sort)

if [ ${#profiles[@]} -eq 0 ]; then
    echo "No Chrome profiles found in $CHROME_DIR. Skipping interactive setup."
    exit 0
fi

# Resolve a human-friendly label (the name shown in Chrome) for a profile dir.
friendly_name() {
    local prefs="$CHROME_DIR/$1/Preferences"
    [ -f "$prefs" ] || return 0
    command -v python3 >/dev/null 2>&1 || return 0
    python3 - "$prefs" <<'PY' 2>/dev/null
import json, sys
try:
    with open(sys.argv[1]) as f:
        print(json.load(f).get("profile", {}).get("name", ""))
except Exception:
    pass
PY
}

# Build display labels once: "Profile 3  (Work)" when a friendly name exists.
labels=()
for p in "${profiles[@]}"; do
    fn="$(friendly_name "$p")"
    if [ -n "$fn" ]; then
        labels+=("$p  ($fn)")
    else
        labels+=("$p")
    fi
done

# True if $1 is one of the profiles that actually exist on this machine.
profile_in_list() {
    local needle="$1" p
    for p in "${profiles[@]}"; do
        [ "$p" = "$needle" ] && return 0
    done
    return 1
}

# Replace (or add) the assignment for CHROME_PROFILE_<type> in ~/.profile.
# Writes through the symlink (truncate-in-place) so the link itself survives,
# and drops any prior export/plain assignment to avoid duplicates.
write_profile_var() {
    local type="$1" value="$2" tmp
    tmp="$(mktemp)"
    grep -vE "^[[:space:]]*(export[[:space:]]+)?CHROME_PROFILE_$type=" "$PROFILE_FILE" > "$tmp"
    echo "export CHROME_PROFILE_$type=\"$value\"" >> "$tmp"
    cat "$tmp" > "$PROFILE_FILE"
    rm -f "$tmp"
}

# --- Prompt for a single profile type if it isn't already set / valid -------
prompt_for_type() {
    local type="$1"
    local var="CHROME_PROFILE_$type"
    local current="${!var:-}"
    local reason

    if [ -n "$current" ]; then
        if profile_in_list "$current"; then
            echo "CHROME_PROFILE_$type is already set to: $current  (leaving as-is)"
            return
        fi
        reason="set to \"$current\", which is not a Chrome profile on this machine"
    else
        reason="not set"
    fi

    if [ ! -t 0 ]; then
        echo "WARNING: CHROME_PROFILE_$type is $reason; skipping (stdin not interactive)."
        echo "  Set it later with: make set-chrome-profile PROFILE_TYPE=$type PROFILE_NAME=<name>"
        return
    fi

    echo ""
    echo "CHROME_PROFILE_$type is $reason. Which Chrome profile should map to $type?"
    local i
    for i in "${!labels[@]}"; do
        printf "  %d) %s\n" "$((i + 1))" "${labels[$i]}"
    done
    echo "  0) Skip (leave unchanged)"

    local choice
    while true; do
        printf "Select a profile for %s [0-%d]: " "$type" "${#profiles[@]}"
        read -r choice || { echo; choice=0; }
        [ -z "$choice" ] && choice=0
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 0 ] && [ "$choice" -le "${#profiles[@]}" ]; then
            break
        fi
        echo "Invalid selection: '$choice'"
    done

    if [ "$choice" -eq 0 ]; then
        echo "Skipped $type (left unchanged)."
        return
    fi

    local selected="${profiles[$((choice - 1))]}"
    write_profile_var "$type" "$selected"
    printf -v "$var" '%s' "$selected"   # reflect in this process too
    echo "Set CHROME_PROFILE_$type=\"$selected\" in $PROFILE_FILE"
}

for type in WORK PERSONAL DEFAULT; do
    prompt_for_type "$type"
done

echo ""
echo "Done. Restart your terminal or run 'source ~/.profile' for changes to take effect."
echo "Note: make sure your ~/.zshrc sources ~/.profile."
