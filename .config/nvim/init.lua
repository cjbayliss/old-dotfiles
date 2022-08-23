-- general config
vim.o.cursorline = true
vim.o.guicursor = ''
vim.o.hidden = true
vim.o.number = true

-- 16 colourscheme
vim.cmd([[
hi Comment ctermfg=gray
hi Todo ctermbg=NONE ctermfg=yellow cterm=bold

hi CursorLine ctermbg=235 cterm=NONE
hi CursorLineNr ctermbg=235 ctermfg=darkyellow cterm=NONE
hi LineNr ctermfg=darkgray
hi StatusLine ctermbg=235 ctermfg=white cterm=NONE
hi MatchParen ctermbg=NONE ctermfg=red cterm=bold

hi Constant ctermfg=NONE
hi String ctermfg=darkgreen
hi Number ctermfg=darkred
hi Boolean ctermfg=darkred
hi Float ctermfg=darkred
hi Label ctermfg=darkred
hi Tag ctermfg=darkred
hi StorageClass ctermfg=darkred

hi Identifier ctermfg=darkmagenta cterm=NONE
hi Function ctermfg=darkyellow cterm=NONE
hi Statement ctermfg=blue
hi Operator ctermfg=darkyellow
hi Delimiter ctermfg=darkblue
hi Special ctermfg=cyan cterm=bold
]])

-- spaces please
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.softtabstop = 4

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
        'ethanholz/nvim-lastplace',
        config = function()
            require('nvim-lastplace').setup()
        end,
    })

    use({
        'f-person/git-blame.nvim',
        config = function()
            vim.g.gitblame_message_template = '<sha>, <date>, <author>'
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
        'lewis6991/gitsigns.nvim',
        config = function()
            require('gitsigns').setup()
        end,
    })

    use({
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end,
    })

    -- fennel
    use({ 'Olical/conjure', ft = 'fennel' })
    use({
        'Olical/aniseed',
        requires = { 'Olical/conjure' },
        config = function()
            vim.api.nvim_command('packadd packer.nvim')
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

    if firstRun then
        packer.sync()
    end
end)
