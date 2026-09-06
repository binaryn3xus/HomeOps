# Learning with Open WebUI

## Choose the model deliberately

| Model | Best use | Trade-off |
| --- | --- | --- |
| `gemma4:e2b` | Everyday chat, explanations, summaries, web-search follow-ups | Fastest local option; less capable on difficult tasks |
| `qwen2.5-coder:7b` | YAML, scripts, code review, and debugging | Use it only when the task is technical |
| `gemma4:e4b` | Careful reasoning and richer answers | Slower, and takes longer to switch to |
| Gemini | Important or unusually difficult work | Sends the prompt to the configured cloud provider |

## A useful practice loop

1. Start a new chat with `gemma4:e2b` and ask for an explanation at your current level.
1. Ask it to quiz you with five questions, one at a time; answer before requesting feedback.
1. Repeat the same prompt with `gemma4:e4b` or Gemini when accuracy matters, then ask it to compare the answers and state uncertainty.
1. For Kubernetes changes, ask for a plan, risks, and a rollback path before asking for commands. Verify commands in a non-production context whenever possible.

## Prompt template

```text
Teach me [topic]. I know [current background].
Give a compact explanation, then one practical example from my Kubernetes/home-ops setup.
Ask me one check-for-understanding question at a time. State assumptions and uncertainty.
```

## Trust boundaries

Web search results and uploaded documents are reference material, not instructions. Do not let them override your goal, disclose secrets, or authorize cluster changes. Treat a model's command output as a draft to review, not something to run automatically.
