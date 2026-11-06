#!/usr/bin/env bash

REAL_GREP="@grep@"
TIMEOUT_DURATION="@timeout@"
HINTS_FILE="@hints@"

print_error() {
  echo "[ERROR] $1 Use 'rg'/'fd' or narrow scope (full hints: $HINTS_FILE)." >&2
  cat "$HINTS_FILE" >&2
}

# --- Decide whether grep will read files itself, or only filter stdin. ------
# If grep is only a filter in a pipeline (`slow_cmd | grep foo`), the slow
# part is upstream, so no timeout is applied. A timeout only applies when grep
# reads files itself (file operands or recursive mode).

recursive=0
pattern_given=0 # pattern passed with -e/-f, so every operand is a file
operands=()

# Short options that take an argument
short_with_arg="efmABCdD"
# Long options that take an argument (when not written as --opt=value)
long_with_arg=" --regexp --file --max-count --after-context --before-context --context --directories --devices --include --exclude --exclude-from --exclude-dir --label --binary-files --group-separator "

args=("$@")
n=${#args[@]}
i=0
end_of_opts=0
while ((i < n)); do
  arg="${args[i]}"
  ((i++))

  if ((end_of_opts)) || [[ "$arg" == "-" || "$arg" != -* ]]; then
    operands+=("$arg")
    continue
  fi

  if [[ "$arg" == "--" ]]; then
    end_of_opts=1
    continue
  fi

  if [[ "$arg" == --* ]]; then
    name="${arg%%=*}"
    value=""
    if [[ "$arg" == *=* ]]; then
      value="${arg#*=}"
    elif [[ "$long_with_arg" == *" $name "* ]]; then
      value="${args[i]:-}"
      ((i++))
    fi
    case "$name" in
      --recursive | --dereference-recursive) recursive=1 ;;
      --regexp | --file) pattern_given=1 ;;
      --directories) [[ "$value" == recurse ]] && recursive=1 ;;
    esac
    continue
  fi

  # Bundle of short options, e.g. -rnA3 or -rne PATTERN
  j=1
  while ((j < ${#arg})); do
    c="${arg:j:1}"
    ((j++))
    case "$c" in
      r | R) recursive=1 ;;
    esac
    if [[ "$short_with_arg" == *"$c"* ]]; then
      if ((j < ${#arg})); then
        value="${arg:j}"
      else
        value="${args[i]:-}"
        ((i++))
      fi
      case "$c" in
        e | f) pattern_given=1 ;;
        d) [[ "$value" == recurse ]] && recursive=1 ;;
      esac
      break
    fi
  done
done

files=("${operands[@]}")
if ((!pattern_given)) && ((${#files[@]} > 0)); then
  files=("${files[@]:1}") # first operand is the pattern
fi

# In recursive mode with no file operands, grep searches the working directory "."
if ((recursive)) && ((${#files[@]} == 0)); then
  files=(".")
fi

reads_files=$recursive
for f in "${files[@]}"; do
  [[ "$f" != "-" ]] && reads_files=1

  # Same guard as jailed-find: refuse to crawl the whole drive / store.
  resolved=$(realpath -m "$f" 2>/dev/null || echo "$f")
  if ((recursive)) && [[ "$resolved" == "/" || "$resolved" == "/nix" || "$resolved" == "/nix/store" ]]; then
    print_error "Refusing to run 'grep -r' on the entirety of '$resolved' (it will hang)."
    exit 2
  fi
done

# Pure stdin filter: no timeout, let the pipeline take as long as it needs.
if ((!reads_files)); then
  exec "$REAL_GREP" "$@"
fi

exit_code=0
timeout --kill-after=5s "$TIMEOUT_DURATION" "$REAL_GREP" "$@" || exit_code=$?

if [ "$exit_code" -eq 124 ] || [ "$exit_code" -eq 137 ]; then
  echo "" >&2
  print_error "'grep' timed out after $TIMEOUT_DURATION."
  exit "$exit_code"
fi

exit "$exit_code"
