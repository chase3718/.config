-- ============================================================================
-- Neovim Configuration
-- ============================================================================
-- Requires: Neovim 0.11+
--
-- Structure:
--   1. General settings
--   2. Keymaps
--   3. Plugins
--   4. Plugin configuration
--   5. LSP
--   6. Formatting
--   7. Autocommands
--   8. Theme
-- ============================================================================


-- ============================================================================
-- General Settings
-- ============================================================================

vim.g.mapleader = " "

-- Disable netrw because we use nvim-tree instead.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- UI
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.showtabline = 2
vim.o.termguicolors = true
vim.o.winborder = "rounded"

-- Editing
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.smartindent = true
vim.o.wrap = false

-- Search
vim.o.ignorecase = true

-- Persistence
vim.o.undofile = true

-- Clipboard
vim.o.clipboard = "unnamedplus"


-- ============================================================================
-- Keymaps
-- ============================================================================

local map = vim.keymap.set


-- --------------------------------------------------------------------------
-- General
-- --------------------------------------------------------------------------

map("n", "<leader>o", "<cmd>update<CR><cmd>source<CR>", {
	desc = "Save and reload config",
})

map("i", "jj", "<Esc>", {
	desc = "Exit insert mode",
})

map({ "n", "i", "x", "v" }, "<C-s>", "<Esc><cmd>write<CR>", {
	desc = "Save buffer",
})

map({ "n", "i" }, "<C-a>", "ggVG", {
	desc = "Select all",
})

map("n", "<leader>qq", "<cmd>qall<CR>", {
	desc = "Quit all",
})


-- --------------------------------------------------------------------------
-- Line Movement
-- --------------------------------------------------------------------------

map("n", "<A-j>", "<cmd>m .+1<CR>==", {
	desc = "Move line down",
})

map("n", "<A-k>", "<cmd>m .-2<CR>==", {
	desc = "Move line up",
})

map("v", "<A-j>", "<cmd>m '>+1<CR>gv=gv", {
	desc = "Move selection down",
})

map("v", "<A-k>", "<cmd>m '<-2<CR>gv=gv", {
	desc = "Move selection up",
})


-- ============================================================================
-- Plugins
-- ============================================================================

vim.pack.add({
	-- ------------------------------------------------------------------------
	-- LSP / Formatting
	-- ------------------------------------------------------------------------

	{
		src = "https://github.com/neovim/nvim-lspconfig",
	},

	{
		src = "https://github.com/stevearc/conform.nvim",
	},

	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
	},


	-- ------------------------------------------------------------------------
	-- Util
	-- ------------------------------------------------------------------------

	{
		src = "https://github.com/ibhagwan/fzf-lua",
	},


	-- ------------------------------------------------------------------------
	-- Completion
	-- ------------------------------------------------------------------------

	{
		src = "https://github.com/Saghen/blink.cmp",
	},

	{
		src = "https://github.com/rafamadriz/friendly-snippets",
	},


	-- ------------------------------------------------------------------------
	-- Editing
	-- ------------------------------------------------------------------------

	{
		src = "https://github.com/windwp/nvim-autopairs",
	},


	-- ------------------------------------------------------------------------
	-- UI
	-- ------------------------------------------------------------------------

	{
		src = "https://github.com/nvim-tree/nvim-web-devicons",
	},

	{
		src = "https://github.com/nvim-tree/nvim-tree.lua",
	},

	{
		src = "https://github.com/folke/which-key.nvim",
	},

	{
		src = "https://github.com/brenoprata10/nvim-highlight-colors",
	},

	{
		src = "https://github.com/nvim-lualine/lualine.nvim",
	},

	{
		src = "https://github.com/akinsho/bufferline.nvim",
	},


	-- ------------------------------------------------------------------------
	-- Git
	-- ------------------------------------------------------------------------

	{
		src = "https://github.com/kdheepak/lazygit.nvim",
	},

	{
		src = "https://github.com/lewis6991/gitsigns.nvim",
	},


	-- ------------------------------------------------------------------------
	-- Theme
	-- ------------------------------------------------------------------------

	{
		src = "https://github.com/morhetz/gruvbox",
	},
})


-- ============================================================================
-- Autopairs
-- ============================================================================

require("nvim-autopairs").setup()


-- ============================================================================
-- Blink Completion
-- ============================================================================

local blink = require("blink.cmp")

blink.setup({
	keymap = {
		preset = "default",

		["<C-Space>"] = {
			"show",
			"show_documentation",
			"hide_documentation",
		},

		["<CR>"] = {
			"accept",
			"fallback",
		},

		["<Tab>"] = {
			"snippet_forward",
			"select_next",
			"fallback",
		},

		["<S-Tab>"] = {
			"snippet_backward",
			"select_prev",
			"fallback",
		},
	},

	completion = {
		menu = {
			auto_show = true,
		},

		documentation = {
			auto_show = false,
		},
	},

	snippets = {
		preset = "default",
	},

	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
		},
	},
})


-- ============================================================================
-- LSP
-- ============================================================================

local capabilities = blink.get_lsp_capabilities()


-- --------------------------------------------------------------------------
-- Lua
-- --------------------------------------------------------------------------

vim.lsp.config("lua_ls", {
	capabilities = capabilities,

	settings = {
		Lua = {
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})


-- --------------------------------------------------------------------------
-- TypeScript / JavaScript
-- --------------------------------------------------------------------------

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
})


-- --------------------------------------------------------------------------
-- Svelte
-- --------------------------------------------------------------------------

vim.lsp.config("svelte", {
	capabilities = capabilities,
})


-- --------------------------------------------------------------------------
-- KDL
-- --------------------------------------------------------------------------

vim.lsp.config("kdl_ls", {
	cmd = {
		"kdl-ls",
		"--stdio",
	},

	filetypes = {
		"kdl",
	},

	root_dir = function(bufnr, on_dir)
		local root = vim.fs.root(bufnr, {
			".git",
			"config.kdl",
		})

		if root then
			on_dir(root)
		end
	end,

	capabilities = capabilities,
})


-- --------------------------------------------------------------------------
-- Enable Language Servers
-- --------------------------------------------------------------------------

vim.lsp.enable({
	"lua_ls",
	"ts_ls",
	"svelte",
	"jsonls",
	"kdl_ls",
})


-- ============================================================================
-- LSP Keymaps
-- ============================================================================

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {
		clear = true,
	}),

	callback = function(args)
		local bufnr = args.buf

		-- Navigation
		map("n", "K", vim.lsp.buf.hover, {
			buffer = bufnr,
			desc = "LSP hover",
		})

		map("n", "gd", vim.lsp.buf.definition, {
			buffer = bufnr,
			desc = "Go to definition",
		})

		map("n", "gr", vim.lsp.buf.references, {
			buffer = bufnr,
			desc = "Find references",
		})

		-- Refactoring
		map("n", "<leader>ca", vim.lsp.buf.code_action, {
			buffer = bufnr,
			desc = "Code action",
		})

		map("n", "<leader>rn", vim.lsp.buf.rename, {
			buffer = bufnr,
			desc = "Rename symbol",
		})
	end,
})


-- ============================================================================
-- Conform Formatting
-- ============================================================================

local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		-- ----------------------------------------------------------------------
		-- Lua
		-- ----------------------------------------------------------------------

		lua = {
			"stylua",
		},


		-- ----------------------------------------------------------------------
		-- JavaScript / TypeScript
		-- ----------------------------------------------------------------------

		javascript = {
			"prettier",
		},

		typescript = {
			"prettier",
		},

		javascriptreact = {
			"prettier",
		},

		typescriptreact = {
			"prettier",
		},


		-- ----------------------------------------------------------------------
		-- Svelte
		-- ----------------------------------------------------------------------

		svelte = {
			"prettier",
		},


		-- ----------------------------------------------------------------------
		-- Web
		-- ----------------------------------------------------------------------

		html = {
			"prettier",
		},

		css = {
			"prettier",
		},

		scss = {
			"prettier",
		},


		-- ----------------------------------------------------------------------
		-- JSON
		-- ----------------------------------------------------------------------

		json = {
			"prettier",
		},

		jsonc = {
			"prettier",
		},


		-- ----------------------------------------------------------------------
		-- YAML
		-- ----------------------------------------------------------------------

		yaml = {
			"prettier",
		},


		-- ----------------------------------------------------------------------
		-- Markdown
		-- ----------------------------------------------------------------------

		markdown = {
			"prettier",
		},


		-- ----------------------------------------------------------------------
		-- KDL
		-- ----------------------------------------------------------------------

		-- KDL doesn't have an external formatter configured here.
		-- Fall back to the LSP if it supports formatting.
		kdl = {
			lsp_format = "fallback",
		},


		-- ----------------------------------------------------------------------
		-- Shell
		-- ----------------------------------------------------------------------

		sh = {
			"shfmt",
		},

		bash = {
			"shfmt",
		},


		-- ----------------------------------------------------------------------
		-- TOML
		-- ----------------------------------------------------------------------

		toml = {
			"taplo",
		},
	},


	-- --------------------------------------------------------------------------
	-- Format on Save
	-- --------------------------------------------------------------------------

	format_on_save = {
		timeout_ms = 500,

		-- Use Conform's formatter first.
		-- If no formatter is available, use the LSP.
		lsp_format = "fallback",
	},

	notify_on_error = true,
})


-- --------------------------------------------------------------------------
-- Manual Formatting
-- --------------------------------------------------------------------------

map("n", "<leader>lf", function()
	conform.format({
		async = true,
		lsp_format = "fallback",
	})
end, {
	desc = "Format current file",
})


-- ============================================================================
-- Treesitter
-- ============================================================================

require("nvim-treesitter").install({
	"lua",
	"vim",
	"vimdoc",
	"javascript",
	"typescript",
	"tsx",
	"svelte",
	"json",
	"jsonc",
	"html",
	"css",
	"scss",
	"bash",
	"markdown",
	"markdown_inline",
	"yaml",
	"toml",
	"kdl",
	"gitignore",
	"gitcommit",
	"diff",
})


vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserTreesitter", {
		clear = true,
	}),

	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})


-- ============================================================================
-- Fuzzy Find (fzf-lua)
-- ============================================================================

local fzf = require("fzf-lua")

fzf.setup({
	fzf_colors = true,

	winopts = {
		height = 0.85,
		width = 0.90,

		preview = {
			layout = "vertical",
			vertical = "down:45%",
		},
	},

	files = {
		fzf_opts = {
			["--history"] = vim.fn.stdpath("data") .. "/fzf-lua-history",
		},

		-- Don't show hidden files or .git by default.
		fd_opts = [[
			--color=never
			--type f
			--hidden
			--exclude .git
		]],
	},

	grep = {
		rg_opts = [[
			--column
			--line-number
			--no-heading
			--color=never
			--smart-case
			--hidden
			--glob=!**/.git/**
		]],
	},

	buffers = {
		sort_lastused = true,
	},

	git = {
		files = {
			cmd = "git ls-files --cached --others --exclude-standard",
		},
	},
})


-- ============================================================================
-- FzfLua Keymaps
-- ============================================================================


-- --------------------------------------------------------------------------
-- Files
-- --------------------------------------------------------------------------

map("n", "<leader>ff", fzf.files, {
	desc = "Find files",
})

map("n", "<leader>fF", function()
	fzf.files({
		fd_opts = [[
			--color=never
			--type f
			--hidden
			--no-ignore
			--exclude .git
		]],
	})
end, {
	desc = "Find all files",
})


-- --------------------------------------------------------------------------
-- Search
-- --------------------------------------------------------------------------

map("n", "<leader>fg", fzf.live_grep, {
	desc = "Live grep",
})

map("n", "<leader>fG", function()
	fzf.live_grep({
		rg_opts = [[
			--column
			--line-number
			--no-heading
			--color=never
			--smart-case
			--hidden
			--no-ignore
			--glob=!**/.git/**
		]],
	})
end, {
	desc = "Live grep all files",
})


-- --------------------------------------------------------------------------
-- Buffers
-- --------------------------------------------------------------------------

map("n", "<leader>fb", fzf.buffers, {
	desc = "Find buffers",
})


-- --------------------------------------------------------------------------
-- Recent Files
-- --------------------------------------------------------------------------

map("n", "<leader>fr", fzf.oldfiles, {
	desc = "Recent files",
})


-- --------------------------------------------------------------------------
-- Git
-- --------------------------------------------------------------------------

map("n", "<leader>gf", fzf.git_files, {
	desc = "Git files",
})


-- --------------------------------------------------------------------------
-- LSP
-- --------------------------------------------------------------------------

map("n", "<leader>fs", fzf.lsp_document_symbols, {
	desc = "Document symbols",
})

map("n", "<leader>fS", fzf.lsp_workspace_symbols, {
	desc = "Workspace symbols",
})

map("n", "<leader>fd", fzf.lsp_definitions, {
	desc = "Definitions",
})

map("n", "<leader>fR", fzf.lsp_references, {
	desc = "References",
})


-- --------------------------------------------------------------------------
-- Neovim
-- --------------------------------------------------------------------------

map("n", "<leader>fh", fzf.help_tags, {
	desc = "Help tags",
})

map("n", "<leader>fk", fzf.keymaps, {
	desc = "Keymaps",
})

map("n", "<leader>fc", fzf.commands, {
	desc = "Commands",
})

map("n", "<leader>fm", fzf.marks, {
	desc = "Marks",
})


-- --------------------------------------------------------------------------
-- Resume
-- --------------------------------------------------------------------------

map("n", "<leader>fp", fzf.resume, {
	desc = "Resume picker",
})


-- ============================================================================
-- Which-Key
-- ============================================================================

require("which-key").add({
	-- --------------------------------------------------------------------------
	-- Buffers
	-- --------------------------------------------------------------------------

	{
		"<leader>b",
		group = "buffers",
	},

	-- Keep numbered buffer shortcuts functional without displaying
	-- all nine entries in Which-Key.
	{
		"<leader>1",
		hidden = true,
	},

	{
		"<leader>2",
		hidden = true,
	},

	{
		"<leader>3",
		hidden = true,
	},

	{
		"<leader>4",
		hidden = true,
	},

	{
		"<leader>5",
		hidden = true,
	},

	{
		"<leader>6",
		hidden = true,
	},

	{
		"<leader>7",
		hidden = true,
	},

	{
		"<leader>8",
		hidden = true,
	},

	{
		"<leader>9",
		hidden = true,
	},


	-- --------------------------------------------------------------------------
	-- Code
	-- --------------------------------------------------------------------------

	{
		"<leader>c",
		group = "code",
	},


	-- --------------------------------------------------------------------------
	-- Git
	-- --------------------------------------------------------------------------

	{
		"<leader>g",
		group = "git",
	},

	{
		"<leader>h",
		group = "hunks",
	},


	-- --------------------------------------------------------------------------
	-- Language
	-- --------------------------------------------------------------------------

	{
		"<leader>l",
		group = "language",
	},


	-- --------------------------------------------------------------------------
	-- Quit
	-- --------------------------------------------------------------------------

	{
		"<leader>q",
		group = "quit",
	},


	-- --------------------------------------------------------------------------
	-- Config
	-- --------------------------------------------------------------------------

	{
		"<leader>o",
		desc = "Save and reload config",
	},


	-- --------------------------------------------------------------------------
	-- File Explorer
	-- --------------------------------------------------------------------------

	{
		"<leader>e",
		desc = "Toggle file explorer",
	},

	{
		"<leader>E",
		desc = "Reveal current file",
	},
})


-- ============================================================================
-- Git
-- ============================================================================

map("n", "<leader>gg", "<cmd>LazyGit<CR>", {
	desc = "Open LazyGit",
})


-- ============================================================================
-- Git Signs
-- ============================================================================

require("gitsigns").setup({
	-- --------------------------------------------------------------------------
	-- Signs
	-- --------------------------------------------------------------------------

	signs = {
		add = {
			text = "+",
		},

		change = {
			text = "~",
		},

		delete = {
			text = "_",
		},

		topdelete = {
			text = "‾",
		},

		changedelete = {
			text = "~",
		},
	},

	signcolumn = true,


	-- --------------------------------------------------------------------------
	-- Line Blame
	-- --------------------------------------------------------------------------

	current_line_blame = false,

	current_line_blame_opts = {
		virt_text = true,
		virt_text_pos = "eol",
		delay = 500,
		ignore_whitespace = false,
	},

	current_line_blame_formatter =
	"<author>, <author_time:%R> - <summary>",


	-- --------------------------------------------------------------------------
	-- Preview
	-- --------------------------------------------------------------------------

	preview_config = {
		border = "rounded",
		style = "minimal",
		relative = "cursor",
		row = 0,
		col = 1,
	},


	-- --------------------------------------------------------------------------
	-- Watch for changes
	-- --------------------------------------------------------------------------

	watch_gitdir = {
		follow_files = true,
	},


	-- --------------------------------------------------------------------------
	-- Performance
	-- --------------------------------------------------------------------------

	update_debounce = 100,


	-- --------------------------------------------------------------------------
	-- Navigation
	-- --------------------------------------------------------------------------

	on_attach = function(bufnr)
		local gs = package.loaded.gitsigns

		local function map_gitsigns(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, {
				buffer = bufnr,
				desc = desc,
			})
		end


		-- ----------------------------------------------------------------------
		-- Hunk Navigation
		-- ----------------------------------------------------------------------

		map_gitsigns("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]h", bang = true })
			else
				gs.next_hunk()
			end
		end, "Next git hunk")


		map_gitsigns("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[h", bang = true })
			else
				gs.prev_hunk()
			end
		end, "Previous git hunk")


		-- ----------------------------------------------------------------------
		-- Hunk Actions
		-- ----------------------------------------------------------------------

		map_gitsigns(
			"n",
			"<leader>hs",
			gs.stage_hunk,
			"Stage hunk"
		)

		map_gitsigns(
			"n",
			"<leader>hr",
			gs.reset_hunk,
			"Reset hunk"
		)


		map_gitsigns("v", "<leader>hs", function()
			gs.stage_hunk({
				vim.fn.line("."),
				vim.fn.line("v"),
			})
		end, "Stage selected hunk")


		map_gitsigns("v", "<leader>hr", function()
			gs.reset_hunk({
				vim.fn.line("."),
				vim.fn.line("v"),
			})
		end, "Reset selected hunk")


		map_gitsigns(
			"n",
			"<leader>hS",
			gs.stage_buffer,
			"Stage buffer"
		)

		map_gitsigns(
			"n",
			"<leader>hR",
			gs.reset_buffer,
			"Reset buffer"
		)


		-- ----------------------------------------------------------------------
		-- Hunk Information
		-- ----------------------------------------------------------------------

		map_gitsigns(
			"n",
			"<leader>hp",
			gs.preview_hunk,
			"Preview hunk"
		)


		map_gitsigns("n", "<leader>hb", function()
			gs.blame_line({
				full = true,
			})
		end, "Blame line")


		map_gitsigns(
			"n",
			"<leader>hd",
			gs.diffthis,
			"Diff buffer"
		)


		map_gitsigns("n", "<leader>hD", function()
			gs.diffthis("~")
		end, "Diff against HEAD")


		-- ----------------------------------------------------------------------
		-- Toggle
		-- ----------------------------------------------------------------------

		map_gitsigns(
			"n",
			"<leader>ht",
			gs.toggle_current_line_blame,
			"Toggle line blame"
		)

		map_gitsigns(
			"n",
			"<leader>hT",
			gs.toggle_deleted,
			"Toggle deleted lines"
		)
	end,
})


-- ============================================================================
-- Nvim Highlight Colors
-- ============================================================================

require("nvim-highlight-colors").setup()


-- ============================================================================
-- LuaLine
-- ============================================================================

require("lualine").setup()


-- ============================================================================
-- Buffer Line
-- ============================================================================

require("bufferline").setup({
	options = {
		mode = "buffers",

		always_show_bufferline = true,

		-- Icons
		show_buffer_icons = true,
		show_buffer_close_icons = true,
		show_close_icon = true,

		-- Tab indicators
		show_tab_indicators = true,

		-- Buffer name sizing
		max_name_length = 18,
		max_prefix_length = 15,
		tab_size = 18,

		-- Buffer separators
		separator_style = "slant",

		-- LSP diagnostics
		diagnostics = "nvim_lsp",

		-- Integrate with NvimTree
		offsets = {
			{
				filetype = "NvimTree",
				text = "File Explorer",
				text_align = "left",
				separator = true,
			},
		},

		-- Don't display these buffers in BufferLine
		custom_filter = function(buf_number)
			local filetype = vim.bo[buf_number].filetype

			local excluded = {
				"alpha",
				"NvimTree",
				"help",
				"qf",
				"fugitive",
			}

			for _, ft in ipairs(excluded) do
				if filetype == ft then
					return false
				end
			end

			return true
		end,
	},
})


-- --------------------------------------------------------------------------
-- Buffer Navigation
-- --------------------------------------------------------------------------

map("n", "<C-h>", "<cmd>BufferLineCyclePrev<CR>", {
	desc = "Previous buffer",
})

map("n", "<C-l>", "<cmd>BufferLineCycleNext<CR>", {
	desc = "Next buffer",
})

map("n", "<C-Left>", "<cmd>BufferLineCyclePrev<CR>", {
	desc = "Previous buffer",
})

map("n", "<C-Right>", "<cmd>BufferLineCycleNext<CR>", {
	desc = "Next buffer",
})


-- --------------------------------------------------------------------------
-- Buffer Selection
-- --------------------------------------------------------------------------

map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", {
	desc = "Pick buffer",
})

for i = 1, 9 do
	map(
		"n",
		"<leader>" .. i,
		"<cmd>BufferLineGoToBuffer " .. i .. "<CR>",
		{
			desc = "Go to buffer " .. i,
		}
	)
end

map("n", "<leader>$", "<cmd>BufferLineGoToBuffer -1<CR>", {
	desc = "Go to last buffer",
})


-- --------------------------------------------------------------------------
-- Buffer Closing
-- --------------------------------------------------------------------------

map("n", "<leader>bd", "<cmd>bdelete<CR>", {
	desc = "Delete buffer",
})

map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", {
	desc = "Close other buffers",
})

map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", {
	desc = "Close buffers to left",
})

map("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>", {
	desc = "Close buffers to right",
})

map("n", "<leader>ba", "<cmd>bufdo bdelete<CR>", {
	desc = "Close all buffers",
})


-- ============================================================================
-- Nvim Tree
-- ============================================================================

require("nvim-tree").setup()

map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", {
	desc = "Toggle file explorer",
})

map("n", "<leader>E", "<cmd>NvimTreeFindFile<CR>", {
	desc = "Reveal current file",
})


-- ============================================================================
-- Theme
-- ============================================================================

vim.cmd.colorscheme("gruvbox")
