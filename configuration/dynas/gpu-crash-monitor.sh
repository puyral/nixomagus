# 1. Define the trigger pattern (Regex)
# Matches: "trying reset", "*ERROR* GT0", "Run out of VRAM", etc.
PATTERN="xe .*trying reset|xe .*ERROR.*GT|xe .*Force wake domain"

# 2. Define storage for fallback logs
LOG_DIR="/var/log/gpu-crashes"
mkdir -p "$LOG_DIR"

echo "Starting GPU Crash Monitor..."

# 3. Start watching the kernel journal in real-time
# -k : kernel messages only
# -f : follow (live)
# -n 0 : don't read old logs, only new ones
journalctl -k -f -n 0 | while read line; do
  if [[ "$line" =~ $PATTERN ]]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    FILENAME="dmesg-crash-$TIMESTAMP.ztsd"
    FILEPATH="$LOG_DIR/$FILENAME"

    echo "Crash detected at $TIMESTAMP! Processing..."

    # --- STEP A: LOCAL FALLBACK (Always works) ---
    # Dump the full dmesg ring buffer and compress it
    touch "$FILEPATH"
    dmesg | zstd --ultra -19 -o "$FILEPATH"
    echo "Log saved locally to $FILEPATH"

    # --- STEP B: EMAIL NOTIFICATION ---
    # Try to send email. If network is down (e.g. NIC crash), this fails,
    # but we already have the local file.
    echo "The Intel B580 GPU driver has crashed and attempts a reset.
    
    Attached is the full kernel log.
    
    Event Trigger:
    $line" | \
    mail -s "⚠️ NAS GPU CRASH DETECTED" \
          -A "$FILEPATH" \
          simon.jeanteur@gmail.com

    # --- STEP C: DEBOUNCE ---
    # Sleep for 20 minutes to avoid spamming 500 emails 
    # if the kernel loops errors.
    sleep 1200
  fi
  sleep 1
done