# Prompt: Set up a local LLM with Opencode via Ollama
Set up my local machine to run opencode with a locally-hosted LLM via Ollama.
## Interactive step — Check my hardware first
Run these commands to inspect my system, then recommend the best model(s) for me in a table:
```bash
echo "=== CPU ===" && lscpu | grep -E 'Model name|CPU\(s\)|Thread|Core'
echo "=== RAM ===" && free -h
echo "=== GPU ===" && lspci | grep -iE 'vga|3d|nvidia|amd'
echo "=== VRAM ===" && nvidia-smi --query-gpu=memory.total --format=csv,noheader 2>/dev/null || echo "No NVIDIA GPU"
echo "=== Disk ===" && df -h / | tail -1
echo "=== Installed Ollama Models ===" && ollama list 2>/dev/null || echo "Ollama not installed"
Based on the output, present a table of recommended models ranked by suitability for my hardware (consider VRAM, RAM, and disk space). Include model name, size, VRAM fit, speed, and code quality rating.
Steps
1. Start Ollama service — Create a user-level systemd service at ~/.config/systemd/user/ollama.service with ExecStart=/usr/bin/ollama serve, then enable and start it with systemctl --user daemon-reload && systemctl --user enable --now ollama. Enable lingering with loginctl enable-linger mehdi.
2. Pull the model — Run ollama pull <recommended-model>.
3. Configure opencode — Edit ~/.config/opencode/opencode.json to add Ollama as a provider with the model as default. Use this structure:
{
  "$schema": "https://opencode.ai/config.json",
  "autoupdate": false,
  "model": "ollama/<model-name>",
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "<model-name>": {
          "name": "<Display Name> (local)"
        }
      }
    }
  }
}
If I want multiple models, add them under "models".
4. Verify — Test the API with:
curl -s http://localhost:11434/v1/chat/completions \
  -d '{"model":"<model-name>","messages":[{"role":"user","content":"1+1="}],"max_tokens":10}'
Notes
- Opencode supports switching models at runtime via /models.
- Models stay cached in Ollama; only the active one consumes VRAM.
- If I change my mind, remove a model with ollama rm <model-name>.