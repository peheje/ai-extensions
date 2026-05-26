# AI Extensions

Personal collection of pi coding agent extensions.

## Install

```bash
pi install git:github.com/peheje/ai-extensions
```

Update an existing install:

```bash
pi update git:github.com/peheje/ai-extensions
```

## Extensions

### openrouter-session

Sets `body.session_id` on OpenRouter requests to enable chat history in OpenRouter's UI.

- New sessions → new OpenRouter chats
- Resumed sessions → continue existing OpenRouter chats

### openrouter-floor

Appends `:floor` to `body.model` on OpenRouter requests so OpenRouter routes to the cheapest provider for the selected model.

- Ignores non-OpenRouter providers
- Leaves models that already end in `:floor` unchanged

Place in `~/.pi/agent/extensions/` or reference via pi packages.

## Scripts

### setup-codex-openrouter.sh

Sets up an optional Codex CLI OpenRouter profile without changing the normal ChatGPT subscription config.

```bash
./scripts/setup-codex-openrouter.sh
source ~/.bashrc

codex              # normal Codex
codex-openrouter   # Codex through OpenRouter
```
