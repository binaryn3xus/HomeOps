#!/usr/bin/env bash
# preview-all-kokoro-voices.sh - Generate samples for all Kokoro voices

VOICES=(
  # American Female
  af_alloy af_aoede af_bella af_heart af_jadzia af_jessica af_kore af_nicole
  af_nova af_river af_sarah af_sky af_v0 af_v0bella af_v0irulan af_v0nicole
  af_v0sarah af_v0sky
  # American Male
  am_adam am_echo am_eric am_fenrir am_liam am_michael am_onyx am_puck
  am_santa am_v0adam am_v0gurney am_v0michael
  # British Female
  bf_alice bf_emma bf_lily bf_v0emma bf_v0isabella
  # British Male
  bm_daniel bm_fable bm_george bm_lewis bm_v0george bm_v0lewis
  # Other Languages
  ef_dora em_alex em_santa ff_siwis hf_alpha hf_beta hm_omega hm_psi
  if_sara im_nicola jf_alpha jf_gongitsune jf_nezumi jf_tebukuro jm_kumo
  pf_dora pm_alex
)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Generating samples for ${#VOICES[@]} voices..."
echo "This will take a few minutes..."
echo ""

for voice in "${VOICES[@]}"; do
  echo "[$voice] Generating..."
  "$SCRIPT_DIR/preview-kokoro-voice.sh" "$voice" | grep -v "tar:"
done

echo ""
echo "✓ Complete! Generated ${#VOICES[@]} voice samples"
echo "Files: kokoro-preview-*.wav"
