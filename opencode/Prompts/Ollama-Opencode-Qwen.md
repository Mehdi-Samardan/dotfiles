# Prompt: Set up local LLM (Qwen3-Coder) with Opencode via Ollama
Set up my local machine to run opencode with a locally-hosted Qwen3-Coder model via Ollama.
## Steps
1. **Start Ollama service** — Create a user-level systemd service at `~/.config/systemd/user/ollama.service` with `ExecStart=/usr/bin/ollama serve`, then enable and start it with `systemctl --user daemon-reload && systemctl --user enable --now ollama`. Enable lingering with `loginctl enable-linger mehdi`.
2. **Pull the model** — Run `ollama pull qwen3-coder`.
3. **Configure opencode** — Edit `~/.config/opencode/opencode.json` to add Ollama as a provider with qwen3-coder as the default model:
   ```json
   {
     "$schema": "https://opencode.ai/config.json",
     "autoupdate": false,
     "model": "ollama/qwen3-coder",
     "provider": {
       "ollama": {
         "npm": "@ai-sdk/openai-compatible",
         "name": "Ollama (local)",
         "options": {
           "baseURL": "http://localhost:11434/v1"
         },
         "models": {
           "qwen3-coder": {
             "name": "Qwen3-Coder (local)"
           }
         }
       }
     }
   }
4. Verify — Test the API with curl -s http://localhost:11434/v1/chat/completions -d '{"model":"qwen3-coder","messages":[{"role":"user","content":"1+1="}],"max_tokens":10}'. The model should respond correctly.