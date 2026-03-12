#!/usr/bin/env bash
set -euo pipefail

# Resolve this script's absolute path (symlink-safe, CWD-independent)
SELF="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SELF")"

# Auto-discover sibling *.sh files, excluding self, sorted alphabetically
mapfile -t SCRIPTS < <(
  for f in "$SCRIPT_DIR"/*.sh; do
    [[ "$(readlink -f "$f")" == "$SELF" ]] && continue
    [[ -f "$f" ]] && printf '%s\n' "$f"
  done | sort
)

if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  echo "ERROR: No workflow scripts found in $SCRIPT_DIR" >&2
  exit 1
fi

# Resolve ComfyUI directory: CLI arg > env var > interactive prompt
if [[ -n "${1:-}" ]]; then
  COMFY_DIR="$1"
elif [[ -n "${COMFY_DIR:-}" ]]; then
  echo "Using COMFY_DIR from environment: $COMFY_DIR"
else
  printf 'ComfyUI directory [/workspace/ComfyUI]: '
  read -r COMFY_DIR || true
  COMFY_DIR="${COMFY_DIR:-/workspace/ComfyUI}"
fi

if [[ ! -d "$COMFY_DIR" ]]; then
  echo "ERROR: ComfyUI directory does not exist: $COMFY_DIR" >&2
  exit 1
fi

# Main interaction loop
while true; do
  echo ""
  echo "=== ComfyUI Workflow Installer ==="
  echo "ComfyUI dir: $COMFY_DIR"
  echo ""

  for i in "${!SCRIPTS[@]}"; do
    name="$(basename "${SCRIPTS[$i]}" .sh)"
    printf '  %d) %s\n' "$((i + 1))" "$name"
  done

  echo ""
  printf 'Select workflows (e.g. 1,3,5 or 1-%d) or q to quit: ' "${#SCRIPTS[@]}"
  read -r choice || true

  # Quit on q, Q, or empty input
  case "${choice:-}" in
    q|Q|'')
      break
      ;;
  esac

  # Expand selection into an array of numbers (supports commas and ranges)
  selected=()
  IFS=',' read -ra parts <<< "$choice"
  valid=true
  for part in "${parts[@]}"; do
    part="${part// /}"  # strip spaces
    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      lo="${BASH_REMATCH[1]}"
      hi="${BASH_REMATCH[2]}"
      if (( lo < 1 || hi > ${#SCRIPTS[@]} || lo > hi )); then
        echo "Invalid range: $part"
        valid=false; break
      fi
      for (( n=lo; n<=hi; n++ )); do selected+=("$n"); done
    elif [[ "$part" =~ ^[0-9]+$ ]]; then
      if (( part < 1 || part > ${#SCRIPTS[@]} )); then
        echo "Out of range: $part"
        valid=false; break
      fi
      selected+=("$part")
    else
      echo "Invalid input: $part"
      valid=false; break
    fi
  done
  $valid || continue

  for num in "${selected[@]}"; do
    TARGET="${SCRIPTS[$((num - 1))]}"
    echo ""
    echo "Running: $(basename "$TARGET") ..."
    echo ""

    chmod +x "$TARGET"
    "$TARGET" "$COMFY_DIR" || {
      echo ""
      echo "WARNING: Script exited with a non-zero status. Check output above."
    }
  done

  # Copy JSON workflow files once after all installs
  WORKFLOW_DIR="$COMFY_DIR/user/default/workflows"
  mkdir -p "$WORKFLOW_DIR"
  if ls "$SCRIPT_DIR"/*.json &>/dev/null; then
    cp "$SCRIPT_DIR"/*.json "$WORKFLOW_DIR/"
    echo ""
    echo "Copied workflow JSONs to $WORKFLOW_DIR"
  fi

  echo ""
  printf 'Run another workflow? [y/N]: '
  read -r again || true
  case "${again:-}" in
    y|Y) continue ;;
    *)   break ;;
  esac
done

echo ""
echo "Done. Remember to restart ComfyUI to load any new custom nodes."
