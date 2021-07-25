-- required and included files

-- required for multiple files
-- MusicUtil = require "musicutil"
-- tabutil = require "tabutil"

UI = require "ui"
fileselect = require 'fileselect'
textentry= require 'textentry'
-- cs = require 'controlspec'


vector = include("clipper/lib/vector")
globals = include "clipper/lib/globals"


encoders_and_keys = include "clipper/lib/encoders_and_keys"
sample_player = include "clipper/lib/sample_player"
instructions = include "clipper/lib/instructions"
include "clipper/lib/Cutter"
-- cutup_pages = include("clipper/lib/cutup_pages")
controller = include("clipper/lib/controller")