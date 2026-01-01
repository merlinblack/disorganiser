package.path = './scripts/?.lua;' .. package.path

require 'packatlas'

MakeAtlas(256, 128, 'media/lemmings', 'media/lemmings')
