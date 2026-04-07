return {
  { "vim-airline/vim-airline" },
  {
    "vim-airline/vim-airline-themes",
    init = function()
      vim.g.airline_powerline_fonts = 1
    end
  },
}
