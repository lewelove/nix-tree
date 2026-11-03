#!/usr/bin/env fish

set WIDTH 320.0

jq ".panelLayout.docking.layout.root.Split.first.Dock.columns[0].width = $WIDTH" preferences.json | sponge preferences.json

jq ".panelLayout.docking.layout.root.Split.second.Split.second.Dock.columns[0].width = $WIDTH" preferences.json | sponge preferences.json
