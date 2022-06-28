local M = {}

local function line_to_entry(line)
    local splits = vim.split(line, "|")
    return {
        filename = splits[1],
        lnum = splits[2],
        col = splits[3],
        text = splits[4],
    }
end

function M.pylint_to_qf(file_path, mode)
    if mode == nil then
        mode = "r"
    end

    local use_file_path = file_path
    if use_file_path == nil then
        local buffer = vim.api.nvim_get_current_buf()
        use_file_path = vim.api.nvim_buf_get_name(buffer)

        local buffer_filetype = vim.api.nvim_buf_get_option(buffer, "filetype")
        if buffer_filetype ~= "python" then
            print("This function can only work with python-files!")
            return
        end
    else
        print("Scanning '" .. file_path .. "'")
        print("This can take a while...")
    end

    local pylint_report = io.popen(
        "pylint "
            .. "--msg-template='{path}|{line}|{column}|[{msg_id}: {symbol}] {msg}' "
            .. "--reports=n "
            .. "--score=n "
            .. use_file_path
    )

    if pylint_report == nil then
        return
    end

    local line = pylint_report:read()
    local entries = {}
    local got_results = false
    while line ~= nil do
        -- ignore module separator
        if string.find(line, "%*%*%*%*%*%*%*%*") == nil then
            got_results = true
            table.insert(entries, line_to_entry(line))
        end

        line = pylint_report:read()
    end

    local relative_file_name = vim.fn.expand("%:t")
    local qf_title = string.format("pylint: %s", relative_file_name)
    local qf_argument = { title = qf_title, items = entries }
    vim.fn.setqflist({}, mode, qf_argument)

    vim.cmd(":copen")
    if got_results then
        if mode == "r" then
            vim.cmd(":cfirst")
        end
    else
        print("No errors found!")
    end
end

return M
