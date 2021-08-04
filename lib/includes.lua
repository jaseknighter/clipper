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
sample_recorder = include "clipper/lib/sample_recorder"
instructions = include "clipper/lib/instructions"
include "clipper/lib/Cutter"
controller = include("clipper/lib/controller")
cut_detector = include("clipper/lib/cut_detector")
