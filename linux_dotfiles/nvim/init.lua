vim.pack.add {
    "https://github.com/catppuccin/nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/williamboman/mason.nvim",
    "https://github.com/williamboman/mason-lspconfig.nvim",
    "https://github.com/zapling/mason-conform.nvim",
    "https://github.com/rshkarin/mason-nvim-lint",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/mfussenegger/nvim-lint",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/hrsh7th/nvim-cmp",
    "https://github.com/hrsh7th/cmp-nvim-lsp",
    "https://github.com/hrsh7th/cmp-buffer",
    "https://github.com/numToStr/Comment.nvim",
    "https://github.com/HiPhish/rainbow-delimiters.nvim",
    "https://github.com/rktjmp/lush.nvim",
    "https://github.com/vermdeep/darcula_dark.nvim",
    "https://github.com/windwp/nvim-ts-autotag",
    "https://github.com/stevearc/conform.nvim",
}

require("nvim-autopairs").setup()
require('nvim-ts-autotag').setup()

vim.cmd.colorscheme("catppuccin")


-- keybindings
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>v', ':vsp<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>h', '<C-w>h', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>j', '<C-w>j', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>k', '<C-w>k', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>l', '<C-w>l', { noremap = true, silent = true })


-- vim settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes:1"
vim.o.confirm = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.scrolloff = 8
vim.opt.swapfile = false


-- MASON & LSP SETUP
require("mason").setup()

-- Automatically manage and install LSP servers
require("mason-lspconfig").setup({
    ensure_installed = {
        "pyright",
        "lua_ls",
        "clangd",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "eslint",
    },
})

require('mason-conform').setup({
    automatic_installation = true,
    ensure_installed = {
        "stylua",
        "ruff", -- Contains ruff_format
        "black",
        "clang-format",
        "prettier",
    },
})

-- Diagnostic display settings
vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { source = true },
})

vim.o.autocomplete = true

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(ev)
        local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})
        end
    end
})

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'buffer' },
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
        ['<Tab>'] = cmp.mapping.select_next_item(),
        ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    }),
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
})

vim.opt.complete:append('o')
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.pumheight = 5

-- Comment.nvim setup
require('Comment').setup()

-- Oil (file explorer)
require('oil').setup({
    view_options = { show_hidden = true }
}) 
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

-- fzf-lua
local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>ff', function() fzf.files({ cwd = vim.fn.getcwd() }) end, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', function() fzf.live_grep({ cwd = vim.fn.getcwd() }) end, { desc = 'Live grep' })
vim.keymap.set('n', '<leader>fb', function() fzf.buffers({ cwd = vim.fn.getcwd() }) end, { desc = 'Find buffers' })

-- treesitter
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/core/opt/nvim-treesitter')
require('nvim-treesitter').setup({
    ensure_installed = { "python", "lua", "c", "java", "javascript", "typescript", "tsx", "html", "css", "json" },
    highlight = { enable = true },
})

require('rainbow-delimiters.setup').setup({
    strategy = {
        [''] = require('rainbow-delimiters').strategy['global'],
        vim = require('rainbow-delimiters').strategy['local'],
        c =  require('rainbow-delimiters').strategy['local'],
    },
    query = {
        [''] = 'rainbow-delimiters',
        lua = 'rainbow-delimiters',
        c = 'rainbow-delimiters',
    },
    highlight = {
        'RainbowDelimiterRed',
        'RainbowDelimiterYellow',
        'RainbowDelimiterBlue',
        'RainbowDelimiterOrange',
        'RainbowDelimiterGreen',
        'RainbowDelimiterViolet',
        'RainbowDelimiterCyan',
    },
})

-- ==========================================
-- LINTING (Mason Integrated)
-- ==========================================
local lint = require('lint')

lint.linters_by_ft = {
    python     = { 'pylint' },
    javascript = { 'eslint_d' },
    typescript = { 'eslint_d' },
    lua        = { 'luacheck' },
    c          = { 'cpplint' },
}

-- Bridge mason and nvim-lint to handle installations automatically
require('mason-nvim-lint').setup({
    automatic_installation = true,
})

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost' }, {
    callback = function()
        lint.try_lint()
    end,
})

-- ==========================================
-- FORMATTING (Conform)
-- ==========================================
require('conform').setup({
    formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black" }, -- Uses ruff if available, otherwise black
        c = { "clang-format" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
    }
})

vim.keymap.set('n', '<leader>f', function() require('conform').format() end, { desc = 'Format buffer' })
