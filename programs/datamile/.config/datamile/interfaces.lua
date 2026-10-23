local interface_dir = d.fs.normalize("~/dev/datamile/interfaces/web-app")

datamile.interface("default", {
  label = "Web App (Production)",
  description = "Run web application preview server",
  run = function(ctx)
    d.system({ "bun", "run", "preview" }, {
      cwd = interface_dir,
      env = {
        DATAMILE_SERVER_URL = ctx.server.url,
        DATAMILE_WS_URL = ctx.server.ws_url,
      },
      stdio = "inherit",
    })
  end,
})

datamile.interface("dev", {
  label = "Web App (Development)",
  description = "Run Vite development server with hot module replacement",
  run = function(ctx)
    d.system({ "bun", "run", "dev" }, {
      cwd = interface_dir,
      env = {
        DATAMILE_SERVER_URL = ctx.server.url,
        DATAMILE_WS_URL = ctx.server.ws_url,
      },
      stdio = "inherit",
    })
  end,
})
