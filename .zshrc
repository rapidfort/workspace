export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH"

# ----- History -----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=20000
SAVEHIST=20000
setopt hist_ignore_dups hist_reduce_blanks inc_append_history share_history

# ----- Completion -----
autoload -Uz compinit && compinit

# --- Git branch in prompt (green) ---
# --- Fancy Git prompt (macOS zsh) ---

# 1) Enable substitutions in PROMPT and load helpers
setopt prompt_subst
autoload -Uz vcs_info add-zsh-hook

# 2) Configure vcs_info for Git
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true          # detect dirty state
zstyle ':vcs_info:git:*' stagedstr ' +'                  # staged changes marker
zstyle ':vcs_info:git:*' unstagedstr ' %'                # unstaged changes marker
zstyle ':vcs_info:git:*' formats '%F{yellow}(%b%c%u)%f'  # (branch + staged/unstaged)
zstyle ':vcs_info:git:*' actionformats '%F{yellow}(%b%c%u|%a)%f'  # rebase/merge actions

# 3) Refresh vcs_info before each prompt
vcs_precmd() { vcs_info }
add-zsh-hook precmd vcs_precmd

# 5) Prompt: [platform][IP] user@host (branch + dirty) : cwd  with root/# or user/% ending
#    Example: [platform][100.92.16.57] rajeevt@jmac (main %) : ~/workspace %
PROMPT='%F{green}%n@%m%f ${vcs_info_msg_0_} %F{blue}%~%f %(#.#.%%) '

# Optional right prompt: show last exit code when non-zero + time
RPROMPT='%(?..%F{red}↩ %?%f) %F{240}%*%f'

# ----- Don’t clobber builtins on macOS -----
export TERM=xterm-256color

# ----- Load your aliases/functions -----
[ -f "$HOME/.my_aliases" ] && source "$HOME/.my_aliases"

# Optional per-tool extras (if you keep them)
for f in "$HOME/.kubectl_aliases" "$HOME/.docker_aliases" "$HOME/.git_aliases"; do
  [ -f "$f" ] && source "$f"
done
