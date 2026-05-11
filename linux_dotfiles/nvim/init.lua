-- initial setup for packages
vim.pack.add {
	"https://github.com/catppuccin/nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/windwp/nvim-autopairs",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }
}

require("nvim-autopairs").setup()

vim.cmd.colorscheme("catppuccin")


-- keybindings
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)


-- vim settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes:1"
vim.o.confirm = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true


-- autocomplete
vim.lsp.enable({ 
    "pyright",
    "lua-lsp",
    "clangd"
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

vim.opt.complete:append('o')
vim.opt.completeopt = { 'menuone', 'noselect' }
vim.opt.pumheight = 5

vim.keymap.set('i', '<Tab>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-n>'
    end
    return '<Tab>'
end, { expr = true })

vim.keymap.set('i', '<S-Tab>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-p>'
    end
    return '<S-Tab>'
end, { expr = true })
vim.keymap.set('i', '<CR>', function()
    if vim.fn.pumvisible() == 1 then
        return '<C-y>'
    end
    return '<CR>'
end, { expr = true })

-- Oil (file explorer)
require('oil').setup()
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

-- fzf-lua
local fzf = require('fzf-lua')
vim.keymap.set('n', '<leader>ff', function()
    fzf.files({ cwd = vim.fn.getcwd() })
end, { desc = 'Find files' })

vim.keymap.set('n', '<leader>fg', function()
    fzf.live_grep({ cwd = vim.fn.getcwd() })
end, { desc = 'Live grep' })

vim.keymap.set('n', '<leader>fb', function()
    fzf.buffers({ cwd = vim.fn.getcwd() })
end, { desc = 'Find buffers' })

-- treesitter
vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/site/pack/core/opt/nvim-treesitter')
require('nvim-treesitter').setup({
    ensure_installed = { "Python", "lua", "C", "Java", "javascript" },
    highlight = { enable = true },
})
