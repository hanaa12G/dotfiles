vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

vim.opt.smarttab = true
vim.opt.expandtab = true

vim.opt.signcolumn ="yes:1"

vim.opt.wrap = false

vim.opt.scrolloff=5
vim.opt.sidescrolloff=10

vim.opt.textwidth = 80
vim.opt.linebreak = true
vim.opt.list = true
vim.opt.listchars = { eol = '$'}

vim.cmd [[
  colorscheme retrobox
]]


vim.g.mapleader = '<Space>'

-- Switch between number mode -- 
g_opt_number_mode = 2
vim.keymap.set('n', '<leader>n', 
function () 
  g_opt_number_mode = g_opt_number_mode + 1
  if g_opt_number_mode > 2 then
    g_opt_number_mode = 0
  end
  if g_opt_number_mode == 0 then
    vim.opt.number = true
    vim.opt.relativenumber = true
  elseif g_opt_number_mode == 1 then
    vim.opt.relativenumber = false
    vim.opt.number = true
  else
    vim.opt.number = false
  end
end
)


-- Indent guide highlighting, copy idea from [this repo] (https://github.com/preservim/vim-indent-guides)
-- and reduce it to smallest form
function hlindent_create_pattern(startcol, endcol)
    return string.format('^ *\\%%%dv\\zs *\\%%%dv\\ze', startcol, endcol)
end
 
function hlindent_init_patterns()
    local hlindent_start_level = 1
    local hlindent_end_level   = 10
    local hlindent_width = vim.opt.softtabstop:get()
    for level=hlindent_start_level,hlindent_end_level do
        local start_col = (level - 1) * hlindent_width + 1
        local end_col   = start_col + 1
        local pattern   = hlindent_create_pattern(start_col, end_col)
        vim.fn.matchadd('IndentGuide', pattern)
    end
end
 
function hlindent_disable()
    vim.api.nvim_set_hl(0, 'IndentGuide', {})
end
 
function hlindent_enable()
    vim.api.nvim_set_hl(0, 'IndentGuide', { link="StatusLine"})
end
 
vim.api.nvim_create_autocmd(
    {'BufRead', 'BufNewFile'},
    {
        callback = function ()
            hlindent_init_patterns()
            hlindent_enable()
        end
    }
)


function scratch_new(opts)
    filetype = nil
    if opts.fargs[1] then
        filetype = opts.fargs[1]
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    local width = vim.opt.columns:get()
    local height = vim.opt.lines:get()
    local padding_y = 3
    local padding_x = 10

    local floating_width = (width - padding_x * 2)
    local floating_height = (height - padding_y * 2)

    local start_x = padding_x
    local start_y = padding_y

    local winnr = vim.api.nvim_open_win(bufnr, true, {
        relative='editor',
        row=start_y, col=start_x,
        width=floating_width, height=floating_height,
        border='double'
    })

    vim.api.nvim_set_option_value('bufhidden', 'wipe', {
        buf=bufnr
    })
    if filetype then
        vim.api.nvim_set_option_value('filetype', filetype, {
            buf=bufnr
        })
    end
end

vim.api.nvim_create_user_command("Scratch", scratch_new, {nargs = '*'})
