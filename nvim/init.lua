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
--   6. Autocommands
--   7. Theme
-- ============================================================================


-- ============================================================================
-- General Settings
-- ============================================================================

-- Leader key
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

-- Quickly reload init.lua while editing it.
map("n", "<leader>o", "<cmd>update<CR><cmd>source<CR>", {
	desc = "Save and reload config",
})

-- Leave insert mode with "jj".
map("i", "jj", "<Esc>", {
	desc = "Exit insert mode",
})

-- Save from normal/insert/visual mode.
map({ "n", "i", "x", "v" }, "<C-s>", "<Esc><cmd>write<CR>", {
	desc = "Save buffer",
})

-- Select the entire buffer.
map({ "n", "i" }, "<C-a>", "ggVG", {
	desc = "Select all",
})

-- Quit Neovim.
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
	-- LSP
	{
		src = "https://github.com/neovim/nvim-lspconfig",
	},

	-- Completion
	{
		src = "https://github.com/Saghen/blink.cmp",
	},
	{
		src = "https://github.com/rafamadriz/friendly-snippets",
	},

	-- Editing
	{
		src = "https://github.com/windwp/nvim-autopairs",
	},

	-- UI
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

	-- Git
	{
		src = "https://github.com/kdheepak/lazygit.nvim",
	},

	-- Theme
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

		-- Manually open the completion menu.
		["<C-Space>"] = {
			"show",
			"show_documentation",
			"hide_documentation",
		},

		-- Accept the current completion.
		["<CR>"] = {
			"accept",
			"fallback",
		},

		-- Navigate snippets/completion items.
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

	-- Show completion automatically.
	completion = {
		menu = {
			auto_show = true,
		},

		-- Documentation is shown manually.
		documentation = {
			auto_show = false,
		},
	},

	-- Use Blink's built-in snippet support.
	snippets = {
		preset = "default",
	},

	-- Completion sources.
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

-- Lua
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

-- TypeScript / JavaScript
vim.lsp.config("ts_ls", {
	capabilities = capabilities,
})

-- Svelte
vim.lsp.config("svelte", {
	capabilities = capabilities,
})

-- KDL
--
-- Uses Neovim's built-in vim.fs.root() instead of
-- lspconfig.util.root_pattern().
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

-- Enable language servers.
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

		local opts = {
			buffer = bufnr,
			silent = true,
		}

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
-- LSP Formatting
-- ============================================================================

-- Format the current buffer manually.
map("n", "<leader>lf", function()
	vim.lsp.buf.format({
		async = true,
	})
end, {
	desc = "Format current file",
})


-- Format supported buffers automatically before saving.
vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("UserLspFormatting", {
		clear = true,
	}),

	callback = function(args)
		local clients = vim.lsp.get_clients({
			bufnr = args.buf,
		})

		local can_format = false

		for _, client in ipairs(clients) do
			if client:supports_method("textDocument/formatting") then
				can_format = true
				break
			end
		end

		if can_format then
			vim.lsp.buf.format({
				bufnr = args.buf,
				async = false,
			})
		end
	end,
})


-- ============================================================================
-- Which-Key
-- ============================================================================

require("which-key").add({
	{
		"<leader>c",
		group = "code",
	},
	{
		"<leader>g",
		group = "git",
	},
	{
		"<leader>l",
		group = "language",
	},
	{
		"<leader>q",
		group = "quit",
	},
})


-- ============================================================================
-- Git
-- ============================================================================

map("n", "<leader>gg", "<cmd>LazyGit<CR>", {
	desc = "Open LazyGit",
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
