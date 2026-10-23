local interface_dir = d.fs.normalize("~/dev/dale/interfaces/web-app")

dale.interface("default", {
  label = "Web App (Production)",
  description = "Run web application preview server",
  run = function(ctx)
    d.system({ "bun", "run", "preview" }, {
      cwd = interface_dir,
      env = {
        DALE_SERVER_URL = ctx.server.url,
        DALE_WS_URL = ctx.server.ws_url,
      },
      stdio = "inherit",
    })
  end,
})

dale.interface("dev", {
  label = "Web App (Development)",
  description = "Run Vite development server with hot module replacement",
  run = function(ctx)
    d.system({ "bun", "run", "dev" }, {
      cwd = interface_dir,
      env = {
        DALE_SERVER_URL = ctx.server.url,
        DALE_WS_URL = ctx.server.ws_url,
      },
      stdio = "inherit",
    })
  end,
})
