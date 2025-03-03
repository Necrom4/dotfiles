return {
  'glts/vim-radical',
  dependencies = {
    {
      'glts/vim-magnum',
    }
  },
  keys = {
    { 'gA', desc = 'shows the four representations of the number under the cursor' },
    { 'crd', desc = 'convert the number under the cursor to decimal' },
    { 'crx', desc = 'convert the number under the cursor to hex' },
    { 'cro', desc = 'convert the number under the cursor to octal' },
    { 'crb', desc = 'convert the number under the cursor to binary' },
  }
}
