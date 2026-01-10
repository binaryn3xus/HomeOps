#!/usr/bin/env bash
# preview-kokoro-voice.sh - Preview Kokoro TTS voices

# How to use:
#   ./scripts/preview-kokoro-voice.sh [voice_name]
# Example:
#   ./scripts/preview-kokoro-voice.sh af_sarah  # Afrikaans - Sarah
#   ./scripts/preview-kokoro-voice.sh en_matthew  # English - Matthew


VOICE="${1:-af_sarah}"
POD=$(kubectl get pods -n ai -l app.kubernetes.io/name=kokoro-fastapi-gpu -o name | head -1 | cut -d/ -f2)
OUTPUT="$HOME/.private/kokoro-preview/kokoro-preview-${VOICE}.wav"

TEXT="Good morning! Welcome to the voice preview system. This sample demonstrates the natural speech capabilities of text-to-speech synthesis. Notice how the voice handles different sentence structures, punctuation, and emotional tones. Can you hear the clarity in complex words like 'sophisticated' and 'revolutionary'? The quick brown fox jumps over the lazy dog - a classic pangram. Numbers like one, two, three, four, five are pronounced smoothly. Thank you for listening to this demonstration."

echo "Generating preview for voice: $VOICE"
echo "Pod: $POD"

kubectl exec -n ai "$POD" -- \
  curl -s -X POST http://localhost:8880/v1/audio/speech \
    -H "Content-Type: application/json" \
    -o /tmp/preview.wav \
    -d "{\"model\":\"kokoro\",\"input\":\"$TEXT\",\"voice\":\"$VOICE\"}"

kubectl cp -n ai "$POD":/tmp/preview.wav "$OUTPUT" 2>/dev/null

if [ -f "$OUTPUT" ]; then
  echo "✓ Audio saved to: $OUTPUT"
  echo "Play with: vlc $OUTPUT"
else
  echo "✗ Failed to generate audio"
fi
