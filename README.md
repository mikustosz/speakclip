# 🎙️ SpeakClip


Quick voice transcription and integrating GPTs with your clipboard through keyboard shortcuts for Linux.


## ✨ Features

- 🎤 Voice-to-text transcription with clipboard integration
- 🧠 Voice commands with clipboard context for GPT responses  
- 🐧 Native Wayland support (Ubuntu & other Linux distros)


## 📦 Installation
**Requirements**:
- 🐧 Ubuntu/Linux with Wayland
- 🔑 OpenAI API key

### Quick setup

#### 1. Install dependencies, clone & configure
```bash
sudo apt update && sudo apt install curl jq wl-clipboard pulseaudio-utils ffmpeg

git clone https://github.com/mikustosz/SpeakClip.git
cd SpeakClip
chmod +x scripts/voice_to_text.sh scripts/voice_to_gpt.sh
cp .speakclip_config ~/.speakclip_config
nano ~/.speakclip_config  # Add your OpenAI API key here
```
#### 2. Set up keyboard shortcuts

**Ubuntu (GNOME)**:
1. Settings → Keyboard → Shortcuts → Custom Shortcuts → "+"
2. Add:
   - 📝 **SpeakClip Transcribe**: `Ctrl+Space` → `/path/to/scripts/voice_to_text.sh`
   - 🤖 **SpeakClip GPT**: `Ctrl+Shift+Space` → `/path/to/scripts/voice_to_gpt.sh`

**KDE Plasma**:
System Settings → Shortcuts → Custom Shortcuts → New → Global Shortcut → Command/URL

## 🚀 Usage

### 📝 Voice-to-Text
1. Press `Ctrl+Space` → Start recording
2. Speak
3. Press `Ctrl+Space` again → Get text in clipboard
4. Paste anywhere!

### 🧠 Voice-to-GPT
1. Copy context to clipboard
2. Press `Ctrl+Shift+Space` → Start recording
3. Give command (e.g., "Summarize this," "Reply to this email")
4. Press `Ctrl+Shift+Space` again → Get AI response in clipboard
5. Paste anywhere!

## 💡 Use Cases

- ✍️ Draft emails and messages by voice
- 📊 Analyze text and data
- 🔄 Rewrite and improve content
- 💻 Get code suggestions
- 🌐 Translate languages
- 📋 Organize notes and ideas

## 📄 License

[MIT License](LICENSE)
