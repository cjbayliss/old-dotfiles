-- general config
vim.o.cursorline = true
vim.o.guicursor = 'a:hor20,i:ver20,a:blinkwait300-blinkon200-blinkoff150'
vim.o.hidden = true
vim.o.number = true
vim.g.mapleader = ' '
vim.o.signcolumn = 'yes'
vim.o.shell = '/usr/bin/env fish'

-- spaces please
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

-- 256 compatible colour scheme inspired by Xcode and Modus Vivendi
vim.cmd.colorscheme('lunaperche')

vim.cmd.highlight('StatusLine cterm=NONE ctermbg=233')
vim.cmd.highlight('StatusLineNc cterm=NONE ctermbg=0')
vim.cmd.highlight('VertSplit ctermbg=NONE')

vim.cmd.highlight('Normal ctermfg=white cterm=italic')
vim.cmd.highlight('Comment ctermfg=115 cterm=italic')
vim.cmd.highlight('Constant ctermfg=153 cterm=bold')
vim.cmd.highlight('Conditional ctermfg=209')
vim.cmd.highlight('PreProc ctermfg=209')
vim.cmd.highlight('Repeat ctermfg=209')
vim.cmd.highlight('Function ctermfg=183')
vim.cmd.highlight('Special ctermfg=183')
vim.cmd.highlight('Delimiter ctermfg=250')
vim.cmd.highlight('String ctermfg=111')
vim.cmd.highlight('Float ctermfg=153')
vim.cmd.highlight('Number ctermfg=153')
vim.cmd.highlight('Boolean ctermfg=183 cterm=italic')
vim.cmd.highlight('Type ctermfg=153')
vim.cmd.highlight('Keyword ctermfg=122 cterm=italic')
vim.cmd.highlight('Statement ctermfg=209')
vim.cmd.highlight('Todo ctermfg=216 cterm=italic,bold')
vim.cmd.highlight('MatchParen ctermfg=222 cterm=reverse')

vim.cmd.highlight('MoreMsg ctermfg=115')
vim.cmd.highlight('ModeMsg ctermfg=white cterm=bold')
vim.cmd.highlight('Directory ctermfg=153')
vim.cmd.highlight('PmenuSel ctermbg=24')
vim.cmd.highlight('FloatBorder ctermbg=234 ctermfg=238')

vim.cmd.highlight('CursorLine ctermbg=233')
vim.cmd.highlight('CursorLineNr ctermbg=233 ctermfg=white cterm=bold')
vim.cmd.highlight('LineNr ctermfg=248')
vim.cmd.highlight('EndOfBuffer ctermfg=248')

vim.cmd.highlight('PackerWorking ctermfg=248')
vim.cmd.highlight('clear PackerSuccess')
vim.cmd.highlight('link PackerSuccess DiffAdd')

vim.cmd.highlight('DiagnosticError ctermfg=203')
vim.cmd.highlight('DiagnosticHint ctermfg=115')
vim.cmd.highlight('DiagnosticInfo ctermfg=153')
vim.cmd.highlight('DiagnosticWarn ctermfg=222')
vim.cmd.highlight('ErrorMsg ctermbg=NONE ctermfg=203 cterm=NONE')
vim.cmd.highlight('WarningMsg ctermfg=222 cterm=NONE')
vim.cmd.highlight('Error ctermbg=NONE ctermfg=203 cterm=bold')

vim.cmd.highlight('Search ctermbg=24 ctermfg=231')
vim.cmd.highlight('IncSearch ctermbg=55 ctermfg=231')
vim.cmd.highlight('CurSearch ctermbg=55 ctermfg=231')

vim.cmd.highlight('DiffAdd ctermbg=NONE ctermfg=115')
vim.cmd.highlight('DiffChange ctermbg=NONE ctermfg=216')
vim.cmd.highlight('DiffDelete ctermbg=NONE ctermfg=203')
vim.cmd.highlight('diffLine ctermfg=white cterm=bold')
vim.cmd.highlight('diffSubname ctermfg=250 cterm=bold')

vim.cmd.highlight('clear diffAdded')
vim.cmd.highlight('clear diffChanged')
vim.cmd.highlight('clear diffFile')
vim.cmd.highlight('clear diffIndexLine')
vim.cmd.highlight('clear diffRemoved')

vim.cmd.highlight('link diffAdded DiffAdd')
vim.cmd.highlight('link diffChanged DiffChange')
vim.cmd.highlight('link diffFile Constant')
vim.cmd.highlight('link diffIndexLine Constant')
vim.cmd.highlight('link diffRemoved DiffDelete')

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
    vim.cmd.packadd('packer.nvim')
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
                preview_config = {
                    border = {
                        { '🭽', 'FloatBorder' },
                        { '▔', 'FloatBorder' },
                        { '🭾', 'FloatBorder' },
                        { '▕', 'FloatBorder' },
                        { '🭿', 'FloatBorder' },
                        { '▁', 'FloatBorder' },
                        { '🭼', 'FloatBorder' },
                        { '▏', 'FloatBorder' },
                    },
                    row = 1,
                    col = 0,
                },
                on_attach = function()
                    vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', { link = 'Comment' })
                    vim.api.nvim_set_hl(0, 'GitSignsAdd', { link = 'DiffAdd' })
                    vim.api.nvim_set_hl(0, 'GitSignsChange', { link = 'DiffChange' })
                    vim.api.nvim_set_hl(0, 'GitSignsDelete', { link = 'DiffDelete' })
                end,
            })
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
        'nvim-telescope/telescope.nvim',
        tag = '0.1.0',
        requires = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<Leader>ff', builtin.find_files, { desc = 'Find files in current directory tree' })
            vim.keymap.set('n', '<Leader>fg', builtin.live_grep, { desc = 'Grep files in current directory tree' })
            vim.keymap.set('n', '<Leader>fb', builtin.buffers, { desc = 'Swap buffer' })
            vim.keymap.set('n', '<Leader>fh', builtin.help_tags, { desc = 'Search Neovim help' })
            vim.keymap.set('n', '<Leader>fo', builtin.oldfiles, { desc = 'List and open previously opened files' })
            vim.keymap.set('n', '<Leader>fr', builtin.lsp_references, { desc = 'Find references for object at point' })
            vim.keymap.set('n', '<Leader>fs', builtin.lsp_document_symbols, { desc = 'List and select symbols' })
            vim.keymap.set('n', '<Leader>g', builtin.diagnostics, { desc = 'Open diagnostics list' })
        end,
    })

    use({
        'neovim/nvim-lspconfig',
        config = function()
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

            local on_attach = function(_, bufnr)
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

            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- rust
            require('lspconfig').rust_analyzer.setup({
                on_attach = on_attach,
                capabilities = capabilities,
                settings = {
                    ['rust-analyzer'] = {
                        checkOnSave = {
                            command = 'clippy',
                        },
                    },
                },
            })

            -- lua
            require('lspconfig').sumneko_lua.setup({
                on_attach = on_attach,
                capabilities = capabilities,
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

            -- only show when on line
            vim.diagnostic.config({
                virtual_lines = { only_current_line = true },
            })
        end,
    })

    use({
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
        },
        config = function()
            local cmp = require('cmp')

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
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
                    { name = 'luasnip' }, -- For luasnip users.
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

    if firstRun then
        packer.sync()
    end
end)
