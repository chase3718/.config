vim.g.mapleader = " "

-- TEMP SOURCE CMD FOR EDITING CONFIG
vim.keymap.set("n", "<leader>o", ":update<CR>:source<CR>")

-- Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.showtabline = 2
vim.o.signcolumn = "yes"
vim.o.wrap = false
vim.o.cursorcolumn = false
vim.o.ignorecase = true
vim.o.smartindent = true
vim.o.termguicolors = true
vim.o.undofile = true
vim.o.winborder = "rounded"
vim.o.clipboard = "unnamedplus"

-- Keymaps
vim.keymap.set("i", "jj", "<Esc>", {
	desc = "Exit insert mode",
})

vim.keymap.set("n", "<leader>e", ":Explore<CR>", {
	desc = "Open File Explorer",
})

vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", {
	desc = "Move line down",
})

vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", {
	desc = "Move line up",
})

vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv", {
	desc = "Move selection down",
})

vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv", {
	desc = "Move selection up",
})

vim.keymap.set({ "n", "x", "i", "v" }, "<C-s>", "<Esc>:write<CR>", { desc = "Save buffer" })

vim.keymap.set("n", "<leader>qq", ":qall<CR>", { desc = "Quit all" })

-- Plugins
vim.pack.add({
	{
		src = "https://github.com/neovim/nvim-lspconfig",
	},
	{
		src = "https://github.com/windwp/nvim-autopairs",
	},
	{
		src = "https://github.com/nvim-tree/nvim-web-devicons",
	},
	{
		src = "https://github.com/folke/which-key.nvim",
	},
	{
		src = "https://github.com/Saghen/blink.cmp",
	},
	{
		src = "https://github.com/rafamadriz/friendly-snippets",
	},
	{
		src = "https://github.com/morhetz/gruvbox",
	},
	{
		src = "https://github.com/kdheepak/lazygit.nvim",
	}
})

-- Autopairs
require("nvim-autopairs").setup()

-- Blink completion
require("blink.cmp").setup({
	keymap = {
		preset = "default",

		-- Manually open completion
		["<C-Space>"] = {
			"show",
			"show_documentation",
			"hide_documentation",
		},

		-- Accept completion
		["<CR>"] = {
			"accept",
			"fallback",
		},

		-- Snippet / completion navigation
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

	-- Don't automatically show completion
	completion = {
		menu = {
			auto_show = true,
		},

		documentation = {
			auto_show = false,
		},
	},

	-- Use Blink's built-in snippet support
	snippets = {
		preset = "default",
	},

	-- Completion sources
	sources = {
		default = {
			"lsp",
			"path",
			"snippets",
			"buffer",
		},
	},
})

-- LSP
local capabilities = require("blink.cmp").get_lsp_capabilities()

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

vim.lsp.config("ts_ls", {
	capabilities = capabilities,
})

vim.lsp.config("svelte", {
	capabilities = capabilities,
})

vim.lsp.enable({
	"lua_ls",
	"ts_ls",
	"svelte",
})

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {
		clear = true,
	}),

	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufnr = args.buf

		-- Format on save
		if client and client:supports_method("textDocument/formatting") then
			vim.api.nvim_create_autocmd("BufWritePre", {
				buffer = bufnr,

				callback = function()
					vim.lsp.buf.format({
						async = false,
						id = client.id,
					})
				end,
			})
		end

		-- LSP keymaps
		local opts = {
			buffer = bufnr,
			silent = true,
		}

		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)

		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)

		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
	end,
})

-- Manual formatting
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format, {
	desc = "Format current file",
})

-- Which Key
local wk = require("which-key")

wk.add({
	{
		"<leader>l",
		group = "language",
	},
})

-- lazygit

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })

-- THEME --
vim.cmd("colorscheme gruvbox")
