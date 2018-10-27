job "sockshop" {
  datacenters = ["dc1"]

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

# - carts - #
group "carts" {
  count = 1

  restart {
    attempts = 10
    interval = "5m"
    delay = "25s"
    mode = "delay"
  }

  # - app - #
  task "cart" {
    driver = "docker"

    env {
        db = "127.0.0.1"
        db_port = "${NOMAD_PORT_cartproxy_tcp}"
    }

    config {
      image = "weaveworksdemos/carts:0.4.8"
      hostname = "carts.service.consul"
      port_map = {
        http = 80
      }
    }

    service {
      name = "carts"
      tags = ["app", "carts"]
      port = "http"
    }

    resources {
      cpu = 100 # 100 Mhz
      memory = 1024 # 1024MB
      network {
        mbits = 10
        port "http" {}
      }
    }
  } # - end app - #

  # - cart connect upstream proxy - #
  task "cartproxy" {
    driver = "raw_exec"

    config {
      command = "/usr/local/bin/consul"
      args    = [
        "connect", "proxy",
        #"-http-addr", "${NOMAD_IP_tcp}:8500",
        "-log-level", "trace",
        "-service", "carts",
        "-upstream", "carts-db:${NOMAD_PORT_tcp}",
      ]
    }

    resources {
      network {
        port "tcp" {}
      }
    }
  } # - end carts upstream proxy - #

  # - db - #
  task "cartdb" {
    driver = "docker"

    config {
      image = "mongo:3.4.3"
      hostname = "carts-db.service.consul"
      port_map = {
        http = 27017
      }
    }

    service {
      name = "carts-db"
      tags = ["db", "carts", "carts-db"]
      port = "http"
    }

    resources {
      cpu = 100 # 100 Mhz
      memory = 128 # 128MB
      network {
        mbits = 10
              port "http" {}
      }
    }
  } # - end db - #

  # - cartdb proxy - #
  task "cartdbproxy" {
    driver = "raw_exec"

    config {
      command = "/usr/local/bin/consul"
      args    = [
        "connect", "proxy",
        #"-http-addr", "${NOMAD_IP_tcp}:8500",
        "-log-level", "trace",
        "-service", "carts-db",
        "-service-addr", "${NOMAD_ADDR_cartdb_http}",
        "-listen", ":${NOMAD_PORT_tcp}",
        "-register",
      ]
    }

    resources {
      network {
        port "tcp" {}
      }
    }
  } # - end cartdbproxy - #
} # - end carts - #

}
