# 1. NEW TRIGGER: Focus on the "Game Over" message
# We ignore the noisy resets and wait for the definitive "device wedged"
PATTERN="xe .*device wedged"

LOG_DIR="/var/log/gpu-crashes"
mkdir -p "$LOG_DIR"

echo "Starting GPU Crash Monitor..."

journalctl -k -f -n 0 | while read line; do
  if [[ "$line" =~ $PATTERN ]]; then
    TIMESTAMP=$(date +%Y%m%d-%H%M%S)
    echo "CRITICAL: GPU Device Wedged at $TIMESTAMP"
    
    # --- 1. CAPTURE JOURNAL ---
    LOG_FILENAME="journal-wedged-$TIMESTAMP.zst"
    LOG_FILEPATH="$LOG_DIR/$LOG_FILENAME"
    
    # Context for Email Body (Last 100 lines, Newest First)
    CONTEXT=$(journalctl -k -n 100 -r --no-pager)
    # Full Boot Log (Attachment 1)
    journalctl -k -b 0 --no-pager | zstd --ultra -19 -c > "$LOG_FILEPATH"
    echo "Journal saved."

    # --- 2. CAPTURE GPU DEVICE COREDUMP ---
    # The log says checking /sys/class/drm/card0/device/devcoredump/data
    # We look for ANY card that might have a dump available.
    
    DUMP_ATTACH_OPT=""
    DUMP_MSG="No GPU device dump found in /sys/class/drm/*/device/devcoredump/data"
    
    # Find the devcoredump file. 
    # It usually lives at .../cardX/device/devcoredump/data
    # We use `find` to handle card0, card1, etc.
    DEV_DUMP_PATH=$(find /sys/class/drm/ -path "*/device/devcoredump/data" -print -quit)

    if [ -n "$DEV_DUMP_PATH" ] && [ -f "$DEV_DUMP_PATH" ]; then
        echo "Found GPU Device Dump at: $DEV_DUMP_PATH"
        
        RAW_DUMP="$LOG_DIR/gpu-dump-$TIMESTAMP.bin"
        ZST_DUMP="$LOG_DIR/gpu-dump-$TIMESTAMP.bin.zst"
        
        # Read the sysfs file to disk (This captures the binary state)
        cat "$DEV_DUMP_PATH" > "$RAW_DUMP"
        
        # Compress it
        zstd --ultra -19 "$RAW_DUMP" -o "$ZST_DUMP"
        rm "$RAW_DUMP"
        
        SIZE=$(stat -c%s "$ZST_DUMP")
        echo "compressed dump down to $((SIZE/1024)) KB"
        
        # 5MB Limit Check
        if [ $SIZE -le 5242880 ]; then
          DUMP_ATTACH_OPT="-A $ZST_DUMP"
          DUMP_MSG="Attached GPU Device Core Dump (Size: $((SIZE/1024)) KB)"
        else
          DUMP_MSG="GPU Dump too large ($((SIZE/1024/1024)) MB). Saved to $ZST_DUMP but not attached."
        fi
        
        # Optional: Clear the dump from memory so the driver can create a new one next time
        # echo 1 > "$DEV_DUMP_PATH"/../failing_device
        # (Actually, writing to the 'data' file usually clears it, or the driver handles it)
    fi

    # --- 3. SEND EMAIL ---
    echo -e "The Intel B580 GPU driver has declared the device WEDGED.
    Reboot is likely required to recover functionality.
    
    Event Trigger:
    $line

    GPU Dump Status:
    ($DEV_DUMP_PATH)
    $DUMP_MSG

    ---------------------------------------------------------------
    LAST 200 LINES (Newest First)
    ---------------------------------------------------------------
    $CONTEXT
    " | \
    mail -s "Dynas GPU driver crash detected at [$TIMESTAMP]" \
          -A "$LOG_FILEPATH" \
          $DUMP_ATTACH_OPT \
          simon.jeanteur@gmail.com

    echo "user notified"

    # --- 4. DEBOUNCE ---
    # If the device is wedged, it won't un-wedge itself quickly.
    # Long sleep is appropriate.
    sleep 1200
  fi
done