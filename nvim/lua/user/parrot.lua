local function setup()
  local providers = {
    -- Local Ollama (no API key). Run: ollama serve && ollama pull <model>
    ollama = {
      name = "ollama",
      endpoint = "http://localhost:11434/api/chat",
      api_key = "",
      params = {
        chat = { temperature = 1.5, top_p = 1, num_ctx = 8192, min_p = 0.05 },
        command = { temperature = 1.5, top_p = 1, num_ctx = 8192, min_p = 0.05 },
      },
      topic = {
        model = "llama3.2",
        params = { max_tokens = 32 },
      },
      models = { "codestral", "llama3.2", "gemma2", "qwen2.5-coder" },
      process_stdout = function(response)
        if response:match("message") and response:match("content") then
          local ok, data = pcall(vim.json.decode, response)
          if ok and data.message and data.message.content then
            return data.message.content
          end
        end
      end,
    },
  }

  -- OpenAI if API key is set (e.g. export OPENAI_API_KEY=...)
  if os.getenv("OPENAI_API_KEY") then
    providers.openai = {
      name = "openai",
      api_key = os.getenv("OPENAI_API_KEY"),
      endpoint = "https://api.openai.com/v1/chat/completions",
      params = {
        chat = { temperature = 1.1, top_p = 1 },
        command = { temperature = 1.1, top_p = 1 },
      },
      topic = {
        model = "gpt-4.1-nano",
        params = { max_completion_tokens = 64 },
      },
      models = { "gpt-4o", "gpt-4o-mini", "o4-mini", "gpt-4.1-nano" },
    }
  end

  require("parrot").setup({
    providers = providers,
    toggle_target = "vsplit",
    chat_user_prefix = "🗨:",
    llm_prefix = "🦜:",
  })

  -- Keep <space>c for "close buffer" (which-key). Parrot defaults to <space>c for new chat;
  -- remove that so which-key's <leader>c wins. New chat is <space>pc (see whichkey.lua).
  for _, mode in ipairs({ "n", "v", "x" }) do
    pcall(vim.keymap.del, mode, "<space>c")
  end
end

return { setup = setup }
