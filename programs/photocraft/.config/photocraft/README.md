# Semantic `preferences.json` Config

Setting width of the leftmost column

```bash
jq '.panelLayout.docking.layout.root.Split.first.Dock.columns[0].width = 350.0' preferences.json | sponge preferences.json
```

And of the rightmost column

```bash
jq '.panelLayout.docking.layout.root.Split.second.Split.second.Dock.columns[0].width = 350.0' preferences.json | sponge preferences.json
```
