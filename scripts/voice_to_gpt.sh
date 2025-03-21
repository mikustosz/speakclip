#!/bin/bash
# Source the configuration file
source "$HOME/.speakclip_config"

# Configuration
RECORDING_INFO_FILE="/tmp/audio_recording.info"

# Functions for clipboard operations (supports both Wayland and X11)
copy_to_clipboard() { [ "$XDG_SESSION_TYPE" = "wayland" ] && echo -n "$1" | wl-copy || echo -n "$1" | xclip -selection clipboard; }
paste_from_clipboard() { [ "$XDG_SESSION_TYPE" = "wayland" ] && wl-paste || xclip -selection clipboard -o; }

if [ -f "$RECORDING_INFO_FILE" ]; then
    # Stop an ongoing recording
    IFS=':' read -r RECORDING_PID RECORDING_FILE < "$RECORDING_INFO_FILE"

    if kill -0 "$RECORDING_PID" 2>/dev/null; then
        kill "$RECORDING_PID"
        wait "$RECORDING_PID" 2>/dev/null
        rm "$RECORDING_INFO_FILE"
        
        # Convert the WAV file to an MP3 file
        MP3_RECORDING_FILE="/tmp/recording_$(date +%Y%m%d_%H%M%S).mp3"
        ffmpeg -y -i "$RECORDING_FILE" -codec:a libmp3lame "$MP3_RECORDING_FILE"
        
        # Retrieve clipboard text
        CLIPBOARD_TEXT=$(paste_from_clipboard)
        
        # Create the user prompt with the clipboard content
        USER_PROMPT="TEXT CONTEXT:\n\n${CLIPBOARD_TEXT}"
        
        # Base64 encode the MP3 file
        BASE64_AUDIO=$(base64 "$MP3_RECORDING_FILE")
        
        # Prepare the JSON payload using jq in the specified format
        JSON_PAYLOAD=$(jq -n \
          --arg model "$GPT_MODEL" \
          --arg system_prompt "$GPT_SYSTEM_PROMPT" \
          --arg user_prompt "$USER_PROMPT" \
          --arg audio "$BASE64_AUDIO" \
          '{
            model: $model,
            modalities: ["text"],
            messages: [
              {
                role: "system",
                content: $system_prompt
              },
              {
                role: "user",
                content: [
                  { type: "text", text: $user_prompt },
                  {
                    type: "input_audio",
                    input_audio: {
                      data: $audio,
                      format: "mp3"
                    }
                  }
                ]
              }
            ]
          }')
        
        # Call the OpenAI API with the constructed JSON payload
        RESPONSE=$(curl --silent --show-error --request POST \
          --url https://api.openai.com/v1/chat/completions \
          --header "Content-Type: application/json" \
          --header "Authorization: Bearer $OPENAI_API_KEY" \
          --data "$JSON_PAYLOAD" 2>&1)
        
        # Extract only the assistant's message text from the API response
        MESSAGE=$(echo "$RESPONSE" | jq -r '.choices[0].message.content')
        
        # Copy the extracted message to the clipboard
        copy_to_clipboard "$MESSAGE"
        
        # Calculate volume (convert 0-1 scale to 0-65536)
        VOLUME=$(awk "BEGIN {print int($NOTIFICATION_VOLUME * 65536)}")
        
        # Play a notification sound
        paplay --volume=$VOLUME "$NOTIFICATION_SOUND" 2>/dev/null
        
        # Clean up temporary audio files
        rm "$RECORDING_FILE" "$MP3_RECORDING_FILE" &
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
