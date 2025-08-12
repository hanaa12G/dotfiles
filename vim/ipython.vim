vim9script

g:interactive_bufnr = -1
g:interactive_cell_marker = "^##%%"

def g:InteractiveBegin()
    var lines = execute(':ls')->split('\n')

    for line in lines
        var tokens = line->split('\W\+')
        var bufnr  = str2nr(tokens[0])
        var bufname = tokens[2]

        if bufname =~ '^InteractiveConsole.*'
            g:interactive_bufnr = bufnr
        endif
    endfor

    if g:interactive_bufnr == -1
        g:interactive_bufnr = term_start('ipython', {
            'term_name': 'InteractiveConsole',
            'vertical': true
        })
    endif
enddef

def g:InteractiveSendLine()
    if g:interactive_bufnr == -1
        return
    endif
    var line = getline('.')
    term_sendkeys(g:interactive_bufnr, line .. "\<Cr>")
enddef

def g:InteractiveSendCell()
    if g:interactive_bufnr == -1
        return
    endif

    var cell_begin: number  = 1
    var cell_end: number = line('$')

    var cur_row = line('.')
    var cur_lastcol = col('$')

    cursor(cur_row, cur_lastcol)

    ## TODO: Restore cursor position

    var res = search(g:interactive_cell_marker, 'bW')
    if res != 0 
        cell_begin = res + 1
    endif

    cursor(cell_begin, 0)

    res = search(g:interactive_cell_marker, 'W')
    if res != 0 
        cell_end = res - 1
    endif

    var lines = getline(cell_begin, cell_end)
    echo lines

    cursor(cur_row, cur_lastcol)

    for line in lines
        if len(line) > 0
            term_sendkeys(g:interactive_bufnr, line .. "\<C-O>\<Down>")
        endif
    endfor
    term_sendkeys(g:interactive_bufnr, "\<Cr>")

enddef

command! -nargs=0 InteractiveBegin call g:InteractiveBegin()
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


