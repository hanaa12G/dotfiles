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

vim.api.nvim_create_autocmd(
    {'VimEnter'},
    {
        callback = function ()
            if vim.fn.has('win32') and vim.fn.environ()['MSYSTEM'] then
                vim.opt.shellcmdflag = '-s -c'
            end
        end
    }
)

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

function create_floating_window()
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


    return bufnr, winnr

end

function string_nil_or_empty(s)
    return s == nil or s == ""
end

function determine_project_dir()
    local dir = nil
    if not string_nil_or_empty(vim.fn.expand('%')) then
        dir = vim.fn.expand('%:h')
    else
        dir = vim.fn.getcwd(0)
    end
    -- Search upward for git
    local found = vim.fn.finddir('.git', ';' )  

    if not string_nil_or_empty(found) then
        found = vim.fs.dirname(found)
    else
        found = dir
    end

    return found
end

function scratch_new(opts)
    local bufnr, winnr = create_floating_window()
    if opts.fargs[1] then
        vim.api.nvim_set_option_value('filetype', opts.fargs[1], {
            buf=bufnr
        })
    end
end

function term_new(opts)
    local bufnr, winnr = create_floating_window()
    local cwd = determine_project_dir()

    vim.api.nvim_set_option_value('bufhidden', 'wipe', {
        buf=bufnr
    })

    vim.fn.termopen('fzf', {
        cwd=cwd,
        on_exit = function (a, b, c)

            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            local return_line

            for k, v in ipairs(lines) do
                if v and value ~= "" then
                    return_line = v
                    break
                end
            end

            vim.defer_fn(function()
                if return_line and return_line ~= "" then
                    if vim.api.nvim_win_is_valid(winnr) then
                        vim.api.nvim_win_close(winnr, true)
                    end
                    if return_line then
                        vim.cmd(":edit " .. vim.fs.joinpath(cwd, return_line))
                    end
                end
            end, 0)
        end,
    })

    vim.api.nvim_set_current_win(winnr);
    vim.cmd([[:startinsert]])

end

vim.api.nvim_create_user_command("Scratch", scratch_new, {nargs = '*'})
vim.api.nvim_create_user_command("BrowseFile", term_new, {nargs = '*'})

