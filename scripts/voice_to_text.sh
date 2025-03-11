#!/bin/bash
# Source the configuration file
source "$HOME/.speakclip_config"

# Configuration
RECORDING_INFO_FILE="/tmp/audio_recording.info"

if [ -f "$RECORDING_INFO_FILE" ]; then
    # Stop an ongoing recording
    IFS=':' read -r RECORDING_PID RECORDING_FILE < "$RECORDING_INFO_FILE"

    if kill -0 "$RECORDING_PID" 2>/dev/null; then
        kill "$RECORDING_PID"
        wait "$RECORDING_PID" 2>/dev/null
        rm "$RECORDING_INFO_FILE"
        
        # Send the WAV file to the OpenAI API for transcription
        RESPONSE=$(curl --silent --show-error --request POST \
          --url https://api.openai.com/v1/audio/transcriptions \
          --header "Authorization: Bearer $OPENAI_API_KEY" \
          --header 'Content-Type: multipart/form-data' \
          --form "file=@$RECORDING_FILE" \
          --form model=$TRANSCRIPTION_MODEL \
          --form response_format=text \
          --form prompt="$TRANSCRIPTION_PROMPT" 2>&1)

        # Copy the transcription to clipboard
        echo -n "$RESPONSE" | wl-copy
        
        # Calculate volume (convert 0-1 scale to 0-65536)
        VOLUME=$(awk "BEGIN {print int($NOTIFICATION_VOLUME * 65536)}")
        
        # Play notification sound
        paplay --volume=$VOLUME "$NOTIFICATION_SOUND" 2>/dev/null

        # Clean up the temporary WAV file
        rm "$RECORDING_FILE" &
    else
        rm "$RECORDING_INFO_FILE"
    fi
else
    # Start a new recording
    RECORDING_FILE="/tmp/recording_$(date +%Y%m%d_%H%M%S).wav"
    parecord --channels=1 --format=s16le --rate=16000 "$RECORDING_FILE" &
    RECORDING_PID=$!
    echo "${RECORDING_PID}:${RECORDING_FILE}" > "$RECORDING_INFO_FILE"
fi

