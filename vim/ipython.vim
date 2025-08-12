vim9script

g:interactive_bufnr = -1
g:interactive_cell_marker = "^##%%"
g:interactive_program = 'ipython'


def SendText(text: string)
    if g:interactive_bufnr == -1
        return
    endif
    term_sendkeys(g:interactive_bufnr, text)
enddef

def g:InteractiveBegin(program: string)
    var lines = execute(':ls')->split('\n')

    g:interactive_bufnr = -1
    for line in lines
        var tokens = line->split('\W\+')
        var bufnr  = str2nr(tokens[0])
        var bufname = tokens[2]

        if bufname =~ '^InteractiveConsole.*'
            g:interactive_bufnr = bufnr
        endif
    endfor

    if g:interactive_bufnr == -1
        g:interactive_bufnr = term_start(program, {
            'term_name': 'InteractiveConsole',
            'vertical': true
        })
        
        if program =~ 'ipython'
            SendText("%autoindent\<Cr>")
        endif
    endif
enddef

def g:InteractiveSendLine()
    var line = getline('.')
    SendText(line .. "\<Cr>")
enddef

def g:InteractiveSendCell()

    var cur_row = line('.')
    var cur_col = col('.')
    var cur_lastcol = col('$')

    var cur_line = getline(cur_row)

    var cell_begin = 0
    var cell_end   = 0

    if cur_line =~ g:interactive_cell_marker
        cell_begin = cur_row + 1
    else
        cell_begin = search(g:interactive_cell_marker, 'bW') + 1
    endif

    cursor(cell_begin, 1)

    cell_end = search(g:interactive_cell_marker, 'W')
    if cell_end == 0
        cell_end = line('$')
    else
        cell_end = cell_end - 1
    endif

    var lines = getline(cell_begin, cell_end)

    cursor(cur_row, cur_lastcol)

    var first_line = true
    for line in lines
        if len(line) > 0
            if first_line
                SendText(line .. "\<C-O>\<Cr>")
            else
                SendText(line .. "\<Cr>")
            endif
            first_line = false
        endif
    endfor
    SendText("\<Cr>")

    cursor(cur_row, cur_col)
enddef

command! -nargs=1 InteractiveBegin call g:InteractiveBegin(<f-args>)
command! -nargs=0 InteractiveSendLine call g:InteractiveSendLine()
command! -nargs=0 InteractiveSendCell call g:InteractiveSendCell()

nmap <leader>isl :InteractiveSendLine<Cr>
nmap <leader>isc :InteractiveSendCell<Cr>

##%%

# print('Block3')

##%%

# print('Hello world')
# print('My interactive shell')

##%%

# print('Hello world')
# print('Block 2 here')


