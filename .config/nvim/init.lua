-- general config
vim.o.cursorline = true
vim.o.guicursor = 'n-v-c:hor20,i-ci:ver20,a:blinkwait300-blinkon200-blinkoff150'
vim.o.hidden = true
vim.o.number = true
vim.o.termguicolors = true

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

-- manage packages with packer, the use-package of neovim
::PackerConfig::
local status, packer = pcall(require, 'packer')
if not status then
    vim.fn.system({
        'git',
        'clone',
        'https://github.com/wbthomason/packer.nvim',
        vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim',
    })
    vim.api.nvim_command('packadd packer.nvim')
    firstRun = true
    goto PackerConfig
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
        config = function()
            vim.api.nvim_exec(
                [[
              augroup Packer
                autocmd!
                autocmd BufWritePost init.lua PackerCompile
              augroup end]],
                false
            )
        end,
    })

    use({
        'kvrohit/rasmus.nvim',
        config = function()
            vim.api.nvim_exec('colorscheme rasmus', false)
            -- FIXME: figure out how to use vim.api.nvim_set_hl to do this
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
        end,
    })

    use({
        'neovim/nvim-lspconfig',
        config = function()
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            -- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

            local on_attach = function(client, bufnr)
                local bufopts = { noremap = true, silent = true, buffer = bufnr }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, bufopts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
                vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                vim.keymap.set('n', '<space>f', function()
                    vim.lsp.buf.format({ async = true })
                end, bufopts)
            end

            -- python
            require('lspconfig').pyright.setup({})

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
            local signs = { Error = '✖', Warn = '‼', Hint = '●', Info = '○' }
            for type, icon in pairs(signs) do
                local hl = 'DiagnosticSign' .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
            end

            -- don't print diagnostic text in buffer
            vim.diagnostic.config({
                virtual_text = false,
                -- virtual_text = { prefix = '●' },
            })

            -- display the diagnostic on hover
            vim.api.nvim_create_autocmd('CursorHold', {
                callback = function()
                    local opts = {
                        focusable = false,
                        close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
                        border = 'rounded',
                        source = 'always',
                        prefix = ' ',
                        scope = 'cursor',
                    }
                    vim.diagnostic.open_float(nil, opts)
                end,
            })
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

            vim.keymap.set('n', '<space>q', '<cmd>TroubleToggle<cr>', { silent = true, noremap = true })
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
        requires = { 'nvim-treesitter/nvim-treesitter-refactor' },
        run = ':TSUpdate',
        config = function()
            vim.o.updatetime = 50
            require('nvim-treesitter.configs').setup({
                ensure_installed = 'all',
                highlight = { enable = true, additional_vim_regex_highlighting = false },
                refactor = {
                    highlight_definitions = { enable = true },
                    smart_rename = { enable = true },
                    navigation = { enable = true },
                },
            })

            function jump_to_def()
                local ts_utils = require('nvim-treesitter.ts_utils')
                local locals = require('nvim-treesitter.locals')
                local buf = vim.api.nvim_get_current_buf()
                local point = ts_utils.get_node_at_cursor()

                if not point then
                    return
                end

                local _, _, kind = locals.find_definition(point, buf)
                local def = locals.find_definition(point, buf)

                if tostring(kind) == 'nil' then
                    local name = ts_utils.get_node_text(point, nil)[1]
                    vim.cmd(string.format('tag %s', name))
                else
                    ts_utils.goto_node(def)
                end
            end

            vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua jump_to_def()<CR>', { noremap = true })
        end,
    })

    use('fladson/vim-kitty')

    if firstRun then
        packer.sync()
    end
end)
