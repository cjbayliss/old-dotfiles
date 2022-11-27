-- general config
vim.o.cursorline = true
vim.o.guicursor = 'n-v-c:hor20,i-ci:ver20,a:blinkwait300-blinkon200-blinkoff150'
vim.o.hidden = true
vim.o.number = true
vim.o.termguicolors = true
vim.g.mapleader = ' '

-- spaces please
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- undo these format options
vim.api.nvim_create_autocmd({ 'FileType' }, {
    command = 'setlocal formatoptions-=o',
})

-- unset arrow keys
for _, key in ipairs({ '<up>', '<down>', '<left>', '<right>' }) do
    for _, mode in ipairs({ '', 'i' }) do
        vim.api.nvim_set_keymap(mode, key, '', { noremap = true })
    end
end

-- general keybindings
vim.api.nvim_set_keymap('', '<Leader>[', '<cmd>bprevious<CR>', { noremap = true, desc = 'Go to previous buffer' })
vim.api.nvim_set_keymap('', '<Leader>]', '<cmd>bnext<CR>', { noremap = true, desc = 'Go to next buffer' })

-- manage packages with packer, the use-package of neovim
local firstRun = false
local status, packer = pcall(require, 'packer')
while not status do
    vim.fn.system({
        'git',
        'clone',
        'https://github.com/wbthomason/packer.nvim',
        vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim',
    })
    vim.api.nvim_command('packadd packer.nvim')
    firstRun = true
    status, packer = pcall(require, 'packer')
end

packer.startup(function()
    use({
        'lewis6991/impatient.nvim',
        config = function()
            require('impatient')
        end,
    })

    use({
        'wbthomason/packer.nvim',
    })

    use({
        'kvrohit/rasmus.nvim',
        config = function()
            vim.g.rasmus_italic_keywords = true
            vim.api.nvim_exec('colorscheme rasmus', false)
            -- FIXME: figure out how to use vim.api.nvim_set_hl to do this
            vim.api.nvim_exec('highlight Keyword guifg=#de9bc8', false)
            vim.api.nvim_exec('highlight String guifg=#61957f', false)
            vim.api.nvim_exec('highlight Conditional guifg=#ffc591', false)
            vim.api.nvim_exec('highlight Repeat guifg=#ffc591', false)
            vim.api.nvim_exec('highlight DiffAdd gui=NONE', false)
            vim.api.nvim_exec('highlight DiffDelete gui=NONE', false)
        end,
    })

    use({
        'ethanholz/nvim-lastplace',
        config = function()
            require('nvim-lastplace').setup()
        end,
    })

    -- remove trailing whitespace automatically
    use({
        'lewis6991/spaceless.nvim',
        config = function()
            require('spaceless').setup()
        end,
    })

    use({
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup()
        end,
    })

    use({
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup({
                current_line_blame = true,
                current_line_blame_opts = {
                    delay = 100,
                },
                current_line_blame_formatter = '<abbrev_sha>, <author>, <author_time:%Y-%m-%d>',
                on_attach = function()
                    vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', { link = 'Comment' })
                end,
            })
        end,
    })

    use({
        'TimUntersberger/neogit',
        requires = 'nvim-lua/plenary.nvim',
        config = function()
            require('neogit').setup()
        end,
    })

    use({
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end,
    })

    use({
        'folke/which-key.nvim',
        config = function()
            require('which-key').setup()
            require('which-key').register({
                ['gd'] = { 'Go to definition' },
                ['grr'] = { 'Rename symbol' },
            })
        end,
    })

    use({
        'neovim/nvim-lspconfig',
        config = function()
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

            local on_attach = function(_, bufnr)
                vim.o.signcolumn = 'number'
                vim.keymap.set('n', '<Leader>k', vim.lsp.buf.hover, { noremap = true, silent = true, buffer = bufnr, desc = 'Show documentation for item at cursor' })
                vim.keymap.set('n', '<Leader>r', vim.lsp.buf.rename, { noremap = true, silent = true, buffer = bufnr, desc = 'Rename symbol' })
                vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, { noremap = true, silent = true, buffer = bufnr, desc = 'Add workspace folder' })
                vim.keymap.set('n', '<Leader>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, { noremap = true, silent = true, buffer = bufnr, desc = 'List workspace folders' })
                vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, { noremap = true, silent = true, buffer = bufnr, desc = 'Remove workspace folder' })
                vim.keymap.set('n', 'grf', function()
                    vim.lsp.buf.format({ async = true })
                end, { noremap = true, silent = true, buffer = bufnr, desc = 'Reformat buffer' })
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { noremap = true, silent = true, buffer = bufnr, desc = 'Go to declaration' })
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { noremap = true, silent = true, buffer = bufnr, desc = 'Go to implementation' })
                vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, { noremap = true, silent = true, buffer = bufnr, desc = 'Go to type definition' })
            end

            -- python
            require('lspconfig').pyright.setup({ on_attach = on_attach })

            -- php
            require('lspconfig').phpactor.setup({ on_attach = on_attach })

            -- lua
            require('lspconfig').sumneko_lua.setup({
                on_attach = on_attach,
                settings = {
                    Lua = {
                        runtime = { version = 'LuaJIT' },
                        diagnostics = { globals = { 'vim', 'use' } },
                        workspace = {
                            library = vim.api.nvim_get_runtime_file('', true),
                            checkThirdParty = false,
                        },
                        telemetry = { enable = false },
                    },
                },
            })

            -- nice icons
            for _, type in ipairs({ 'Error', 'Warn', 'Hint', 'Info' }) do
                local hl = 'DiagnosticSign' .. type
                vim.fn.sign_define(hl, { text = '●', texthl = hl, numhl = hl })
            end

            -- don't print diagnostic text in buffer
            vim.diagnostic.config({
                virtual_text = false,
                virtual_lines = { only_current_line = true },
            })
        end,
    })

    use({
        'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
        config = function()
            require('lsp_lines').setup()
        end,
    })

    use({
        'folke/trouble.nvim',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function()
            require('trouble').setup({
                icons = false,
                fold_closed = '▶',
                fold_open = '▼',
                indent_lines = false,
                use_diagnostic_signs = true,
            })

            vim.keymap.set('n', '<Leader>g', '<cmd>TroubleToggle<cr>', { silent = true, noremap = true, desc = 'Toggle diagnostics list' })
        end,
    })

    use({
        'hrsh7th/nvim-cmp',
        requires = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-buffer' },
        config = function()
            local cmp = require('cmp')

            cmp.setup({
                window = {
                    documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                }, {
                    { name = 'buffer' },
                }),
            })
        end,
    })

    -- the whole reason to use neovim
    use({
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    })

    use({
        'nvim-treesitter/nvim-treesitter-refactor',
        after = 'nvim-treesitter',
        config = function()
            vim.o.updatetime = 50
            require('nvim-treesitter.configs').setup({
                ensure_installed = 'all',
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                refactor = {
                    highlight_definitions = { enable = true },
                    smart_rename = { enable = true },
                    navigation = {
                        enable = true,
                        keymaps = {
                            -- unbind these
                            goto_definition = '<Nop>',
                            goto_next_usage = '<Nop>',
                            goto_previous_usage = '<Nop>',
                            list_definitions = '<Nop>',
                            list_definitions_toc = '<Nop>',
                            -- fallback to lsp
                            goto_definition_lsp_fallback = 'gd',
                        },
                    },
                },
            })
        end,
    })

    use('fladson/vim-kitty')

    if firstRun then
        packer.sync()
    end
end)
